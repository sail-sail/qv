
exports.SysTree = new Class
  initPrn_id: ->
    t = this
    o = t.options
    elt = o.ele
    prn_id = elt.getE "[h:iez='prn_id']"
    lbl_fld = prn_id.get "h:lbl_fld"
    lbl_fld = lbl_fld or "lbl"
    combotree = prn_id.getParent ".combotree"
    cb_tree = combotree.getE ".combotree_tree"
    cb_treeWg = cb_tree.wg()
    cb_treeWg.treAllPrnId = (eny)->
      return [] if !eny
      rltSet = await o.thisSrv.ajax "treAllPrnId",[eny.id]
      rltSet
    cb_treeWg.getLbl = (tree_li)->
      eny = tree_li.retrieve "eny"
      lbl = eny and eny[lbl_fld] or ""
      lbl
    cb_treeWg.isLeaf = (tree_li)->
      eny = tree_li.retrieve "eny"
      if eny
        is_leaf = eny.is_leaf
        is_leaf = true if is_leaf is undefined
        return is_leaf
      true
    getChildren = cb_treeWg.getChildren
    cb_treeWg.getChildren = (tree_li,hLvl)->
      liElArr = await getChildren.apply this,arguments
      rltSet = undefined
      if hLvl is 0
        rltSet = await o.thisSrv.ajax "treeRoot"
      else
        eny = tree_li.retrieve "eny"
        rltSet = await o.thisSrv.ajax "treeCld",[eny.id]
      return liElArr if !rltSet
      for eny in rltSet
        li = new Element "div"
        li.store "eny",eny
        liElArr.push li
      liElArr
    await cb_treeWg.dataTree()
    return