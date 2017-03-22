{SysWin} = require "../sys/SysWin"
{Srv} = require "Srv"

#菜单
PrnClzz = SysWin
exports.FlowMenuApp = new Class
  Extends: PrnClzz
  options:
    enyStr: "Menu"
    prnMenuEny: undefined
  I18NEny:
    "menu":"菜单"
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    await PrnClzz.prototype.initPg.apply t,arguments
    body = document.body
    bodyWg = body.wg()
    bodyWg.setAppTitle o.I18NEny["menu"]
    await t.initMenu() if !elt.retrieve "not_initMenu"
    return
  initThisSrv: ->
    t = this
    o = t.options
    elt = o.ele
    o.thisSrv = new Srv {clz:"sys.FlowMenuAppSrv"}
    o.thisSrv.options.ele = elt
    return
  initMenu: (prnMenuEny)->
    t = this
    o = t.options
    elt = o.ele
    body = document.body
    bodyWg = body.wg()
    if prnMenuEny and prnMenuEny.is_leaf
      page_id = prnMenuEny.page_id
      return if !page_id
      pageEny = await o.thisSrv.ajax "findPageById",[page_id]
      return if String.isEmpty pageEny.url
      bftOnDraw = (win)->
        win.store "menuEny",prnMenuEny
        win.store "pageEny",pageEny
        return
      win = await bodyWg.chgPg pageEny.url,bftOnDraw
      return win
    rltSet = []
    bodyWg.options.prnMenuEny = prnMenuEny
    if !prnMenuEny or !prnMenuEny.id
      rltSet = await o.thisSrv.ajax "menuRoot"
    else
      rltSet = await o.thisSrv.ajax "menuCld",[prnMenuEny.id]
    return if !rltSet
    menu_table_view = elt.getE ".menu_table_view"
    menu_table_view.destroyChd()
    for eny in rltSet
      menu_table_cell = new Element "li.menu_table_cell.mui-table-view-cell"
      menu_table_cell.store "eny",eny
      menu_table_cell.set "text",eny.lbl
      menu_table_cell.addEvent "click",->
        await t.menuClk this
        return
      menu_table_cell.inject menu_table_view
    return
  menuClk: (menu_table_cell)->
    t = this
    o = t.options
    elt = o.ele
    eny = menu_table_cell.retrieve "eny"
    return if !eny
    await t.initMenu eny
    return
  back: ->
    t = this
    o = t.options
    prnMenuEny = document.body.wg().options.prnMenuEny
    if !prnMenuEny
      return if !window.confirm "确定退出系统?"
      await o.thisSrv.ajax "_clearSession"
      if plus and !mui.os.ios
        plus.runtime.quit()
      else
        window.location.reload()
      return
    eny = await o.thisSrv.ajax "menuPrn",[prnMenuEny.prn_id]
    await t.initMenu eny
    return