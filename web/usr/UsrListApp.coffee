{SysListApp} = require "../sys/SysListApp"

#用户列表
PrnClzz = SysListApp
exports.UsrListApp = new Class
  Extends: PrnClzz
  options:
    enyStr: "Usr"
    headArr: ["code","name"]
    headObj:
      "code":"用户名"
      "name":"姓名"
      "email":"邮箱"
      "mph":"手机"
      "wechat":"微信"
      "tph":"固定电话"
      "fax":"传真"
      "img":"头像"
      "create_time":"注册时间"
      "rem":"备注"
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    return
  initOptDel: (optTd)->
    t = this
    o = t.options
    dt_tr = optTd.getParent ".dt_tr"
    eny = dt_tr.retrieve "eny"
    if eny.code is 'admin' or o.usr.code isnt "admin"
      optTd.setStyle "text-align","right"
      return
    PrnClzz.prototype.initOptDel.apply t,arguments
  