{SysList} = require "../sys/SysList"

#用户列表
PrnClzz = SysList
exports.UsrList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Usr"
    headArr: ["code","lbl","role_id","prn_id","email","mph","wechat","lgn_tm","ip","create_time","lgn_num","rem"]
    headObj:
      "code":"用户名"
      "lbl":"姓名"
      "role_id":"角色"
      "prn_id":"父用户"
      "email":"邮箱"
      "mph":"手机"
      "wechat":"微信"
      "lgn_tm":"登录时间"
      "ip":"IP地址"
      "create_time":"注册时间"
      "lgn_num":"密码错误"
      "rem":"备注"
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  initOptDel: (optTd)->
    t = this
    o = t.options
    dt_tr = optTd.getParent ".dt_tr"
    eny = dt_tr.retrieve "eny"
    return if eny.code is 'admin'
    return if o.usr.code isnt "admin"
    PrnClzz.prototype.initOptDel.apply t,arguments
  initTd: (tr,key)->
    td = new Element "td"
    td.inject tr
    eny = tr.retrieve "eny"
    val = eny[key]
    td.set "text",val
    td.addClass "initTd_"+key
    td
