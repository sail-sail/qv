{MainFrame} = require "MainFrame"
{Srv} = require "Srv"

PrnClzz = MainFrame
exports.MainApp = new Class
  Extends: PrnClzz
  options:
    thisSrv: undefined
    usr: {}
    I18NEny:
      "logo_title":"系统"
      "session_timeout_msg":"登录超时,请重新登录!"
      "edit_password":"修改密码"
      "logout":"退出登录"
      "confirm":"确定"
      "cancel":"取消"
    bodySize: {}
    prnMenuEny: undefined
  I18NEnyAfter: (key,val)->
    if key is "logo_title"
      document.title = val
    return
  initThisSrv: ->
    t = this
    o = t.options
    elt = o.ele
    o.thisSrv = new Srv {clz:"sys.MainFrameSrv"}
    o.thisSrv.options.ele = elt
    return
  onDraw: ->
    t = this
    o = t.options
    window.plus = window.plus or undefined
    t.initBack()
    o.bodySize = document.body.getSize()
    t.initAvalon()
    t.initThisSrv()
    await t.initLogin()
    return
  initBack: ->
    t = this
    o = t.options
    elt = o.ele
    back_but = elt.getE "[h:but=back_but]"
    back_but.addEvent "tap",(e)->
      e.preventDefault()
      await t.back_butClk this
      return
    mui.back = ->
      await t.back_butClk()
      return
    return
  back_butClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    ofwMp = mui("#offCanvasWrapper").offCanvas()
    if ofwMp.isShown()
      ofwMp.close()
      return
    ofccEl = $ "offCanvasContentScroll"
    win = ofccEl.getE "[h:pg]"
    winWg = win and win.wg()
    if !winWg or !winWg.back
      if plus and !mui.os.ios
        plus.runtime.quit()
      else
        window.location.reload()
      return
    await winWg.back but
    return
  setAppTitle: (title)->
    t = this
    o = t.options
    elt = o.ele
    titleEl = elt.getE ".main_app_title"
    titleEl.set "text",title if titleEl
    return
  initLogin: ->
    t = this
    o = t.options
    elt = o.ele
    contentEl = $ "offCanvasContentScroll"
    loginWin = await Srv.createWindow "/usr/LoginApp.html"
    loginWin = loginWin[0]
    loginWin.inject contentEl
    await loginWin.onDrawAsync()
    loginWinWg = loginWin.wg()
    loginWinWg.lgnSucc = ->
      await t.initFrm()
      return
    return
  initFrm: ->
    t = this
    o = t.options
    elt = o.ele
    await t.chgPg "/sys/FlowMenuApp.html"
    return
  chgPg: (url,bftOnDraw)->
    t = this
    o = t.options
    elt = o.ele
    contentEl = $ "offCanvasContentScroll"
    newWin = await Srv.createWindow url
    newWin = newWin[0]
    return if !newWin
    win = contentEl.getE "[h:pg]"
    if win
      winWg = win.wg()
      await winWg.closePage() if winWg
      win.destroy()
    newWin.hide()
    newWin.inject contentEl
    try
      bftOnDraw newWin if bftOnDraw
      await newWin.onDrawAsync() if newWin.onDrawAsync
    catch err
      throw err
    finally
      newWin.show()
    newWin