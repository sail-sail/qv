{Component} = require "Component"

PrnClzz = Component
exports.ComboTree = new Class(
  Extends: PrnClzz
  options:
    winClk: undefined
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    await Component.prototype.onDraw.apply t,arguments
    t.initButEvt()
    return
  initButEvt: ->
    t = this
    o = t.options
    elt = o.ele
    input = elt.getE ".combotree_input"
    addon = elt.getE ".combotree_addon"
    tree = elt.getE ".combotree_tree"
    inputWg = input.wg()
    addErrBox = inputWg.addErrBox
    inputWg.addErrBox = (str,time,injIez)-> addErrBox.apply this,[str,time,elt]
    tree.addEvent "click",(e)-> e.stop()
    o.winClk = ->
      t.hideTree()
      return
    treeWg = tree.wg()
    getChildren = treeWg.getChildren
    treeWg.getChildren = (tree_li,hLvl)->
      liElArr = await getChildren.apply this,arguments
      if hLvl is 0
        liEl = new Element "div"
        liEl.addClass "tree_empty_li"
        liElArr.unshift liEl
      liElArr
    selectLi = treeWg.selectLi
    treeWg.selectLi = (liEl)->
      lbl = treeWg.getLbl liEl
      input.set "value",lbl
      t.hideTree()
      await selectLi.apply this,arguments
    treeWg.liAddEvt = (liEl)->
      tree_div = liEl.getFirst ".tree_div"
      tree_div.addEvent "click",->
        await treeWg.selectLi liEl
        return
      return
    addon.addEvent "click",(e)->
      e.stop()
      await t.treeAddonClk this
      return
    addon.addEvent "mousedown",(e)->
      e.stop()
      addon.addClass "combotree_addon_kd"
      return
    addon.addEvent "mouseup",(e)->
      e.stop()
      addon.removeClass "combotree_addon_kd"
      return
    addon.addEvent "mouseenter",(e)->
      e.stop()
      addon.addClass "combotree_addon_hv"
      return
    addon.addEvent "mouseleave",(e)->
      e.stop()
      addon.removeClass "combotree_addon_hv"
      return
    return
  showTree: ->
    t = this
    o = t.options
    elt = o.ele
    tree = elt.getE ".combotree_tree"
    size = elt.getSize()
    tree.setStyle "width",size.x-2
    tree.position {relativeTo:elt,position:"bottomLeft"}
    window.addEvent "click",o.winClk if o.winClk
    tree.show()
    return
  hideTree: ->
    t = this
    o = t.options
    elt = o.ele
    tree = elt.getE ".combotree_tree"
    window.removeEvent "click",o.winClk if o.winClk
    tree.hide()
    return
  #点击向下的箭头展开树
  treeAddonClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    input = elt.getE ".combotree_input"
    tree = elt.getE ".combotree_tree"
    if tree.isDisplayed()
     t.hideTree()
    else
      t.showTree()
    return
  getOldVal: ->
    t = this
    o = t.options
    elt = o.ele
    cb_tree = elt.getE ".combotree_tree"
    cb_treeWg = cb_tree.wg()
    cb_treeWg.getOldVal()
  #设置默认值
  setOldVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    cb_tree = elt.getE ".combotree_tree"
    cb_treeWg = cb_tree.wg()
    cb_treeWg.setOldVal val
  getVal: (opt)->
    t = this
    o = t.options
    elt = o.ele
    cb_tree = elt.getE ".combotree_tree"
    cb_treeWg = cb_tree.wg()
    cb_treeWg.getVal.apply cb_treeWg,arguments
  setVal: (eny)->
    t = this
    o = t.options
    elt = o.ele
    cb_tree = elt.getE ".combotree_tree"
    cb_treeWg = cb_tree.wg()
    await cb_treeWg.setVal eny
)