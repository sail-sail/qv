{SysAdd} = require "../sys/SysAdd"
{Srv} = require "Srv"
{UsrAdd} = require "./UsrAdd"

SupperClzz = SysAdd
#修改密码
exports.Et_psw = new Class
  Extends: SupperClzz
  options:
    enyStr: "Usr"
    headArr: ["old_psw","password"]
    headObj:
      "old_psw":"原密码"
      "password":"新密码"
    $vdts: ["password"]
    I18NEny:
      "confirm":"确定"
      "cancel":"取消"
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    await SupperClzz.prototype.initPg.apply t,arguments
    return
  initThisSrv: ->
    t = this
    o = t.options
    elt = o.ele
    o.thisSrv = new Srv clz:"usr.Et_pswSrv"
    o.thisSrv.options.ele = elt
    return
  passwordVdt: (key,val,id)-> await UsrAdd.prototype.passwordVdt.apply this,arguments
  confirmButClk: (but,e,headArr)->
    t = this
    o = t.options
    elt = o.ele
    but.set "disabled",true if but
    isPass = await t.runAllVdts()
    if !isPass
      but.set "disabled",false if but
      return
    eny = {}
    await t.getPgVal eny,{cmpOldVal:false}
    rltSet = await o.thisSrv.ajax "et_psw",[eny.old_psw,eny.password]
    but.set "disabled",false if but
    if rltSet is true
      window.ncWg.addNotice "info","密码修改成功!",2
      cancelBut = elt.getE ".cancelBut"
      await t.cancelButClk cancelBut,undefined,false
    else
       window.ncWg.addNotice "error",rltSet.err,2
    return
  