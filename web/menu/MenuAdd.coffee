{SysAdd} = require "/sys/SysAdd"
{Srv} = require "Srv"
{SysTree} = require "/sys/SysTree"

PrnClzz = SysAdd
#菜单增加
exports.MenuAdd = new Class
  Extends: PrnClzz
  Implements: [SysTree]
  options:
    enyStr: "Menu"
    headArr: ["prn_id","lbl","page_id","open_op","is_root","is_leaf","enable","sort_num"]
    headObj:
      "prn_id":"父菜单"
      "lbl":"标签"
      "page_id":"页面"
      "open_op":"打开方式"
      "is_root":"根节点"
      "is_leaf":"叶子"
      "enable":"生效"
      "sort_num":"排序"
    $vdts: ["lbl","prn_id","page_id"]
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    await t.initPrn_id()
    return
  lblVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
  prn_idVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
  page_idVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
  ###
  initPage_id: ->
    t = this
    o = t.options
    elt = o.ele
    page_id = elt.getE "[h:iez=page_id]"
    cb_input = elt.getE ".combotree_input"
    cb_tree = page_id.getE ".combotree_tree"
    cb_treeWg = cb_tree.wg()
    setVal = cb_treeWg.setVal
    cb_treeWg.setVal = (id)->
      menuEny = await o.thisSrv.ajax "findMenuByPageId",[id]
      await setVal.apply this,[menuEny]
    getVal = cb_treeWg.getVal
    cb_treeWg.getVal = ->
      eny = await getVal.apply this,arguments
      return 0 if eny is null
      if eny
        oldVal = this.getOldVal()
        return if oldVal is eny.page_id
        return eny.page_id
      return
    selectLi = cb_treeWg.selectLi
    cb_treeWg.selectLi = (tree_li)->
      isLeaf = await this.isLeaf tree_li
      return if !isLeaf
      await selectLi.apply this,arguments
    cb_treeWg.liAddEvt = -> Tree.prototype.liAddEvt.apply this,arguments
    cb_treeWg.treAllPrnId = (eny)->
      return [] if !eny
      rltSet = await o.thisSrv.ajax "treAllPrnId",[eny.id]
      rltSet
    cb_treeWg.getLbl = (tree_li)->
      eny = tree_li.retrieve "eny"
      lbl = eny and eny.lbl or ""
      lbl
    cb_treeWg.isLeaf = (tree_li)->
      eny = tree_li.retrieve "eny"
      return eny.is_leaf if eny
      true
    getChildren = cb_treeWg.getChildren
    cb_treeWg.getChildren = (tree_li,hLvl)->
      liElArr = await getChildren.apply this,arguments
      rltSet = []
      if hLvl is 0
        rltSet = await o.thisSrv.ajax "pageRoot"
      else
        eny = tree_li.retrieve "eny"
        rltSet = await o.thisSrv.ajax "pageCld",[eny.id] if eny
      for eny in rltSet
        li = new Element "div"
        li.store "eny",eny
        liElArr.push li
      liElArr
    await cb_treeWg.dataTree()
    return
  ###
