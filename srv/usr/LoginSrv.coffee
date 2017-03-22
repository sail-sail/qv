url = require "url"
{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.LoginSrv = new Class
  Extends: PrnClzz
  onDraw: ->
    t = this
    await SysSrv.prototype.onDraw.apply t,arguments
  "@listLang":{notSid:true}
  listLang: (reqOpt)->
    t = this
    sql = "select * from lang"
    rltSet = await t.callArr reqOpt,sql
    rltSet
  "@login":{isTran:true,notSid:true}
  login: (reqOpt,code,password,lang,ixbupwjj)->
    t = this
    sql = "select id,lgn_num from usr where code=@code"
    eny = await t.callOne reqOpt,sql,{code:code}
    if eny
      if eny.lgn_num >= 5
        t.session.usr = undefined
        return {suc:false,errMsg:"用户 #{code} 已被锁定!"}
    lang = lang or t.getLanguage reqOpt
    sql = "select * from usr where code=@code and password=@password"
    rltSet = await t.callArr reqOpt,sql,{code:code,password:password}
    suc = rltSet.length isnt 0
    errMsg = null
    if suc is false
      await t.callOne reqOpt,"update usr set lgn_num=lgn_num+1 where code=@code",{code:code}
      password_incorrect = await t.getMsg reqOpt,"password_incorrect",undefined,lang
      errMsg = password_incorrect
      t.session.usr = undefined
    else
      t.session.usr = rltSet[0]
      
      #更新IP地址,登录时间
      if ixbupwjj isnt ""
        t.session.usr.lang = lang
        ip = t.getClientIp reqOpt
        t.session.usr.ip = ip
        t.session.usr.lgn_num = 0
        sql = "update usr set ip=@ip,lgn_tm=now(),lgn_num=0 where id=@id"
        await t.callSql reqOpt,sql,t.session.usr
      
      sql = "select r.* from role r left join usr u on u.role_id=r.id where u.id=@id limit 1"
      _role = await t.callOne reqOpt,sql,t.session.usr
      _role = {} if !_role
      t.session.usr._role = _role
    rvObj = {suc:suc,errMsg:errMsg}
    if suc
      usr = t.session.usr
      rvObj.usr = {id:usr.id,lbl:usr.lbl,code:usr.code,lang:lang,_role:usr._role}
    rvObj
