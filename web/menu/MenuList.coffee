require "/menu/MenuList.css"
{SysList} = require "/sys/SysList"

#菜单列表
exports.MenuList = new Class
  Extends: SysList
  options:
    enyStr: "Menu"
    headArr: ["lbl","prn_id","page_id","open_op","is_root","is_leaf","enable","sort_num"]
    headObj:
      "lbl":"标签"
      "prn_id":"父菜单"
      "page_id":"页面"
      "open_op":"打开方式"
      "is_root":"根节点"
      "is_leaf":"叶子"
      "enable":"生效"
      "sort_num":"排序"
  initPg: ->
    t = this
    o = t.options
    await SysList.prototype.initPg.apply t,arguments
    return
  delById: (id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "treDelNdById",[id]
    rltSet
  srchOpt2Iez: (optEl)->
    t = this
    o = t.options
    return if !optEl
    iez = undefined
    value = optEl.get "value"
    #打开方式
    if value is "t.open_op"
      iez = new Element "Select",{"h:apply":"Select","class":"select_ele",html:"""
      <option value="tab">tab</option>
      <option value="modal">modal</option>
      """}
    else
      iez = SysList.prototype.srchOpt2Iez.apply t,arguments
    iez
  ###
  srchValueLbl: (srch_value)->
    t = this
    o = t.options
    srch_pop = srch_value.getParent ".srch_pop"
    srch_name = srch_pop.getE ".srch_name"
    optArr = srch_value.getEs "option"
    optEl = optArr[srch_value.selectedIndex]
    return if !optEl
    valueLbl = ""
    if "m.open_op" is srch_pop.get "h:srch_name"
      valueLbl = optEl.get "html"
    else
      valueLbl = SysList.prototype.srchValueLbl.apply t,arguments
    valueLbl
  ###
