require "./Login.css"
{SysWin} = require "../sys/SysWin"
{Srv} = require "Srv"

#登录
exports.Login = new Class
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
      "logo_title":"销售管理系统"
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
    #await t.initLang_input()
    elt.show()
    t.initButEvt ["commit"]
    
    codeEl = elt.getE "[h:iez='code']"
    passwordEl = elt.getE "[h:iez='password']"
    commit = elt.getE "[h:but='commit']"
    codeEl.focus()
    codeEl.addEvent "keydown",(e)->
      if e.code is 13
        passwordEl.focus()
      return
    passwordEl.addEvent "keydown",(e)->
      if e.code is 13
        commit.fireEvent "click"
      return
    return
  I18NEnyAfter: (key,val)->
    if key is "logo_title"
      document.title = val
    return
  afterDraw: ->
    t = this
    o = t.options
    elt = o.ele
    codeEl = elt.getE "[h:iez='code']"
    passwordEl = elt.getE "[h:iez='password']"
    eny = localStorage.getItem "Login.rembPhoneVal.1"
    try eny = JSON.decode eny if eny catch err
    if eny
      codeEl.set "value",eny.code
      passwordEl.set "value",eny.password
      commit = elt.getE "[h:but='commit']"
      await t.commitClk commit
    return
  initLang_input: ->
    t = this
    o = t.options
    elt = o.ele
    lang_input = elt.getE ".lang_input"
    langEnyArr = await o.thisSrv.ajax "listLang"
    for langEny in langEnyArr
      option = new Element "option"
      option.set "value",langEny.code
      option.set "text",langEny.lbl
      option.inject lang_input
      option.selected = true if langEny.code is navigator.language
    lang = localStorage.getItem "navigator_language"
    if lang
      lang_input.set "value",lang
    lang = lang_input.get "value"
    await t.initI18N lang
    lang_input.addEvent "change",->
      lang2 = lang_input.get "value"
      localStorage.setItem "navigator_language",lang2
      t.initI18N lang2
      return
    return
  commitClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    eny = await t.getPgVal()
    if String.isEmpty eny.code
      window.ncWg.addNotice "error","用户名不能为空!",2
      codeEl = elt.getE "[h:iez=code]"
      codeEl.focus()
      codeEl.selectRange()
      return
    if !eny.password
      window.ncWg.addNotice "error","密码不能为空!",2
      passwordEl = elt.getE "[h:iez=password]"
      passwordEl.focus()
      passwordEl.selectRange()
      return
    but.set "disabled",true if but
    await o.thisSrv.ajax "_sessionId"
    rss = await o.thisSrv.ajax "login",[eny.code,eny.password,eny.lang,window.ixbupwjj]
    but.set "disabled",false if but
    errMsg = rss.errMsg
    if errMsg
      window.ncWg.addNotice "error",errMsg,4
    if rss.suc is true
      usr = rss.usr
      window._usr = usr
      rembPhoneEl = elt.getE ".rembPhone"
      rembPhoneVal = 0
      rembPhoneVal = 1 if rembPhoneEl.hasClass "mui-active"
      if rembPhoneVal
        localStorage.setItem "Login.rembPhoneVal.1",JSON.encode eny
      await t.lgnSucc()
    return
