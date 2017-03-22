{SysSrv} = require "./SysSrv"
uuid = require "uuid"
fsAsync = require "fsAsync"
fs = require "fs"
{Dao} = require "../../dao/Dao"
weixin_payAsync = require 'node-weixin-payAsync'

wechatSrv = undefined

PrnClzz = SysSrv
exports.WechatSrv = new Class
  Extends: PrnClzz
  initialize: (options) ->
    t = this
    return wechatSrv if wechatSrv
    PrnClzz.prototype.setOptions.apply [options]
    o = t.options
    o.dao = Dao.getInstance()
    wechatSrv = t
    t
  getConfigCnf: (reqOpt,isCtfp)->
    t = this
    api_key = undefined
    appid = undefined
    app_secret = undefined
    mch_id = undefined
    app_token = undefined
    certificate_pfx = undefined
    sql = """
    select code,lbl from "option" where code in(
      'wechat_api_key','wechat_appid','wechat_app_secret','wechat_mch_id','wechat_app_token','wechat_certificate_pfx'
    )
    """
    optEnyArr = await t.callArr reqOpt,sql
    for optEny in optEnyArr
      if optEny.code is "wechat_api_key"
        api_key = optEny.lbl
      else if optEny.code is "wechat_appid"
        appid = optEny.lbl
      else if optEny.code is "wechat_app_secret"
        app_secret = optEny.lbl
      else if optEny.code is "wechat_mch_id"
        mch_id = optEny.lbl
      else if optEny.code is "wechat_app_token"
        app_token = optEny.lbl
      else if optEny.code is "wechat_certificate_pfx" and isCtfp
        certificate_pfx = optEny.lbl
    if isCtfp
      certificate_pfx = await t.bufByOid reqOpt,certificate_pfx
      if !certificate_pfx
        throw "option.certificate_pfx can be empty!"
    merchantCnf = {
      id: mch_id
      key: api_key
    }
    appCnf = {
      id: appid
      secret: app_secret
      token: app_token
    }
    configCnf = {
      app: appCnf
      merchant: merchantCnf
      certificate: undefined
    }
    #证书
    if isCtfp
      configCnf.certificate = {
        pfx: certificate_pfx
        pfxKey: mch_id
      }
    configCnf
  unified: (reqOpt,total_fee2)->
    t = this
    usr = t.session.usr
    if String.isEmpty total_fee2
      throw "Please enter the amount you need to recharge!"
    total_fee2 = Number total_fee2
    if isNaN(total_fee2) or total_fee2 <= 0
      throw "Recharge amount must be greater than 0 of the value!"
    
    host = undefined
    dev_wechat = undefined
    api_key = undefined
    appid = undefined
    app_secret = undefined
    mch_id = undefined
    app_token = undefined
    spbill_create_ip = undefined
    certificate_pfx = undefined
    sql = """
    select code,lbl from "option" where code in(
      'host','ip','dev_wechat','wechat_api_key','wechat_appid','wechat_app_secret','wechat_mch_id','wechat_app_token','wechat_certificate_pfx'
    )
    """
    optEnyArr = await t.callArr reqOpt,sql
    for optEny in optEnyArr
      if optEny.code is "host"
        host = optEny.lbl
      else if optEny.code is "ip"
        spbill_create_ip = optEny.lbl
      else if optEny.code is "dev_wechat"
        dev_wechat = optEny.lbl
      else if optEny.code is "wechat_api_key"
        api_key = optEny.lbl
      else if optEny.code is "wechat_appid"
        appid = optEny.lbl
      else if optEny.code is "wechat_app_secret"
        app_secret = optEny.lbl
      else if optEny.code is "wechat_mch_id"
        mch_id = optEny.lbl
      else if optEny.code is "wechat_app_token"
        app_token = optEny.lbl
      else if optEny.code is "wechat_certificate_pfx"
        certificate_pfx = optEny.lbl
    certificate_pfx = await t.bufByOid reqOpt,certificate_pfx
    if !certificate_pfx
      throw "option.certificate_pfx can be empty!"
    merchantCnf = {
      id: mch_id
      key: api_key
    }
    appCnf = {
      id: appid
      secret: app_secret
      token: app_token
    }
    #证书
    certificateCnf = {
      pfx: certificate_pfx
      pfxKey: mch_id
    }
    configCnf = {
      app: appCnf
      merchant: merchantCnf
      certificate: certificateCnf
    }
    
    total_fee = (total_fee2.round(2)*100).round 0
    date = new Date()
    dateStr = date.Format "yyyyMMddhhmmssS"
    dateStr = dateStr.pad 17,"r"
    if dateStr.length > 17
      dateStr = dateStr.substring dateStr.length-17
    out_trade_no = "usr#{dateStr}#{usr.id}"
    nonce_str = uuid.v4().replace /-/g,""
    unified_body = await t.getMsg reqOpt,"WeChat_unified_body"
    params = {
      spbill_create_ip: spbill_create_ip
      notify_url: "#{host}/sys.WechatSrv/wcPayCb"
      body: unified_body
      out_trade_no: out_trade_no
      total_fee: total_fee
      trade_type: "NATIVE"
      appid: appid
      mch_id: mch_id
      nonce_str: nonce_str
    }
    data = await weixin_payAsync.unifiedAsync configCnf, params
    gen_success_qrcode = await t.getMsg reqOpt,"gen_success_qrcode",{total_fee:total_fee2}
    {msg:gen_success_qrcode,code_url:data.code_url}
  "@wcPayCb":{notSid:true,isTran:true}
  wcPayCb: (reqOpt,buffer)->
    t = this
    o = t.options
    req = reqOpt.req
    res = reqOpt.res
    req.body = buffer.toString()
    reqOpt.res_auto_end = false
    configCnf = await t.getConfigCnf reqOpt,false
    data = await weixin_payAsync.notifyAsync configCnf.app,configCnf.merchant,req,res
    if data.out_trade_no.indexOf("usr") is 0
      sql = "select id from rg_jr where transaction_id=$1"
      rg_jrEny = await t.callOne reqOpt,sql,[data.transaction_id]
      if !rg_jrEny
        usrId = Number data.out_trade_no.substring "usr".length+17
        usrId = 0 if isNaN usrId
        total_fee = (Number(data.total_fee)/100).round 2
        time_end = data.time_end
        time_end = time_end.substring(0,time_end.length-10)+"-"+time_end.substring(time_end.length-10,time_end.length-8)+"-"+time_end.substring(time_end.length-8,time_end.length-6)+" "+time_end.substring(time_end.length-6,time_end.length-4)+":"+time_end.substring(time_end.length-4,time_end.length-2)+":"+time_end.substring(time_end.length-2)
        sql = "insert into rg_jr(usr_id,openid,is_subscribe,bank_type,total_fee,transaction_id,time_end) values($1,$2,$3,$4,$5,$6,$7)"
        await t.callSql reqOpt,sql,[usrId,data.openid,data.is_subscribe,data.bank_type,total_fee,data.transaction_id,time_end]
        sql = "update usr set amt=amt+$1 where id=$2"
        await t.callSql reqOpt,sql,[total_fee,usrId]
    return
  