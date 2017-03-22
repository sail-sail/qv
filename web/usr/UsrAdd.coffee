{SysAdd} = require "../sys/SysAdd"
{SysTree} = require "/sys/SysTree"

#用户增加
PrnClzz = SysAdd
exports.UsrAdd = new Class
  Extends: PrnClzz
  Implements: [SysTree]
  options:
    enyStr: "Usr"
    headArr: ["code","password","lbl","email","role_id","prn_id","mph","wechat","tph","lgn_num","img","rem"]
    headObj:
      "code":"用户名"
      "password":"密码"
      "lbl":"姓名"
      "email":"邮箱"
      "role_id":"角色"
      "prn_id":"父用户"
      "mph":"手机"
      "wechat":"微信"
      "tph":"固定电话"
      "lgn_num":"密码错误"
      "img":"头像"
      "rem":"备注"
    $vdts: ["code","password","role_id","prn_id"]
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    await t.initPrn_id()
    await PrnClzz.prototype.initPg.apply t,arguments
  #编码code验证方法,执行runAllVdts时会调用此方法
  codeVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
  passwordVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
  role_idVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
  prn_idVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
