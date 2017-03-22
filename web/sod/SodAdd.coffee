{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.SodAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Sod"
    headArr: ["so_id","pt_id","pt_sc_id","qty"]
    headObj:
      "so_id":"订单编号"
      "pt_id":"产品"
      "pt_sc_id":"规格"
      "qty":"数量"
    $vdts: ["so_id","pt_id","pt_sc_id","qty"]
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    await t.initPt_id()
    await t.initPt_sc_id()
    pt_idEl = elt.getE "[h:iez=pt_id]"
    pt_idEl.addEvent "change",->
      await t.initPt_sc_id()
      return
    rvObj
  #规格
  initPt_sc_id: ->
    t = this
    o = t.options
    elt = o.ele
    pt_idEl = elt.getE "[h:iez=pt_id]"
    pt_idWg = pt_idEl.wg()
    pt_idVal = await pt_idWg.getVal {cmpOldVal:false}
    pt_sc_idEl = elt.getE "[h:iez=pt_sc_id]"
    rltSet = await o.thisSrv.ajax "initPt_sc_id",[pt_idVal]
    pt_sc_idEl.destroyChd()
    for eny in rltSet
      option = new Element "option",{text:eny.lbl,value:eny.lbl}
      option.store "eny",eny
      option.inject pt_sc_idEl
    return
  initPt_id: ->
    t = this
    o = t.options
    elt = o.ele
    pt_idEl = elt.getE "[h:iez=pt_id]"
    rltSet = await o.thisSrv.ajax "initPt_id"
    pt_idEl.destroyChd()
    for eny in rltSet
      option = new Element "option",{text:eny.lbl,value:eny.lbl}
      option.store "eny",eny
      option.inject pt_idEl
    return