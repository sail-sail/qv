{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.CityAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "City"
    headArr: ["provin_id","lbl","rem"]
    headObj:
      "provin_id":"省份"
      "lbl":"城市"
      "rem":"备注"
    $vdts: ["lbl"]
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    await t.initProvin_id()
    rvObj
  initProvin_id: ->
    t = this
    o = t.options
    elt = o.ele
    provin_idEl = elt.getE "[h:iez=provin_id]"
    rltSet = await o.thisSrv.ajax "initProvin_id"
    provin_idEl.destroyChd()
    for eny in rltSet
      option = new Element "option",{text:eny.lbl,value:eny.lbl}
      option.store "eny",eny
      option.inject provin_idEl
    return
    