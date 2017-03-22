require "./SysWinApp.css"
{SysList} = require "./SysList"
{Srv} = require "Srv"

PrnClzz = SysList
exports.SysListApp = new Class
  Extends: PrnClzz
  options:
    pl_type: "app"
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    body = document.body
    bodyWg = body.wg()
    menuEny = elt.retrieve "menuEny"
    if menuEny
      bodyWg.setAppTitle menuEny.lbl if bodyWg.setAppTitle
    await PrnClzz.prototype.onDraw.apply t,arguments
  initGrid: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.initGrid.apply t,arguments
    #表格下拉刷新功能
    ###
    grid_tbl = elt.getE ".grid_tbl"
    gr_drag_rfh = elt.getE ".gr_drag_rfh"
    grid_tbl.addEventListener "dragstart",(e)->
      this.style.transition = undefined
      this.setStyles {"margin-top":0}
      return
    grid_tbl.addEventListener "drag",(e)->
      deltaY = e.detail.deltaY
      gr_drag_rfh.show() if deltaY > 30
      deltaY = 60 if deltaY > 60
      this.setStyle "margin-top",deltaY
      return
    grid_tbl.addEventListener "dragend",(e)->
      this.style.transition = "margin-top .4s ease-out"
      this.setStyles {"margin-top":0}
      gr_drag_rfh.hide()
      return
    ###
    grid_tbl = elt.getE ".grid_tbl"
    grid_tbl.addEventListener "swiperight",(e)->
      t.showOptTd this
      return
    grid_tbl.addEventListener "swipeleft",(e)->
      t.hideOptTd this
      return
    t.initButEvt ["swipeleft","swiperight"]
    rvObj
  #点击向左滑动按钮
  swipeleftClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    t.hideOptTd grid_tbl
    return
  swiperightClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    t.showOptTd grid_tbl
    return
  #显示操作列
  showOptTd: (grid_tbl)->
    t = this
    o = t.options
    elt = o.ele
    optTdArr = grid_tbl.getEs ".optTd"
    optTdArr.show()
    optLblArr = grid_tbl.getEs ".optLbl"
    optLblArr.show()
    return
  hideOptTd: (grid_tbl)->
    t = this
    o = t.options
    elt = o.ele
    optTdArr = grid_tbl.getEs ".optTd"
    optTdArr.hide()
    optLblArr = grid_tbl.getEs ".optLbl"
    optLblArr.hide()
    return
  #操作
  initOptTd: (tr)->
    t = this
    o = t.options
    optTd = PrnClzz.prototype.initOptTd.apply t,arguments
    optTd.hide()
    optTd
  back: (but)->
    t = this
    o = t.options
    elt = o.ele
    body = document.body
    bodyWg = body.wg()
    bftOnDraw = (win)->
      win.store "not_initMenu",true
      return
    win = await bodyWg.chgPg "/sys/FlowMenuApp.html",bftOnDraw
    winWg = win.wg()
    await winWg.initMenu bodyWg.options.prnMenuEny
    return