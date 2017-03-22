require "./Login.css"
{SysWin} = require "../sys/SysWin"
{Srv} = require "Srv"

#手机端登录
exports.LoginApp = new Class
  Extends: SysWin
  options:
    enyStr: "Usr"
    thisSrv: undefined
    butObj: {}
    headArr: ["code","password"]
    headObj:
      "code":"用户名"
      "password":"密码"
    I18NEny:
      "logo_title":"系统"
      "login":"登录"
  initThisSrv: ->
    t = this
    o = t.options
    elt = o.ele
    o.thisSrv = new Srv {clz:"usr.LoginSrv"}
    o.thisSrv.options.ele = elt
    return
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    t.initAvalon()
    await t.initThisSrv()
    mui(".mui-switch").switch()
    document.body.wg().setAppTitle o.I18NEny["login"]
    elt.show()
    t.initButEvt ["commit"]
    
    codeEl = elt.getE "[h:iez='code']"
    passwordEl = elt.getE "[h:iez='password']"
    commit = elt.getE "[h:but='commit']"
    codeEl.addEvent "keydown",(e)->
      if e.code is 13
        passwordEl.focus()
      return
    passwordEl.addEvent "keydown",(e)->
      if e.code is 13
        commit.fireEvent "click"
      return
    ###debug await t.setPgVal {code:"admin",password:"admin123"}
    commit = $(t).getE "[h:but=commit]"
    commit.click() ###
    return
  commitClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    eny = await t.getPgVal()
    if String.isEmpty eny.code
      window.ncWg.addNotice "error","用户名不能为空!",2
      return
    if !eny.password
      window.ncWg.addNotice "error","密码不能为空!",2
      return
    but.set "disabled",true if but
    await o.thisSrv.ajax "_sessionId"
    rltSet = await o.thisSrv.ajax "login",[eny.code,eny.password,eny.lang]
    but.set "disabled",false if but
    errMsg = rltSet.errMsg
    if errMsg
      window.ncWg.addNotice "error",errMsg,4
    if rltSet.suc is true
      usr = rltSet.usr
      window._usr = usr
      await t.lgnSucc()
    return
  