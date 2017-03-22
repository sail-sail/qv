{SysList} = require "../sys/SysList"

#订单明细列表
PrnClzz = SysList
exports.SodList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Sod"
    headArr: ["so_id","pt_id","pt_sc_id","qty","create_time"]
    headObj:
      "so_id":"订单编号"
      "pt_id":"产品"
      "pt_sc_id":"规格"
      "qty":"数量"
      "create_time":"创建时间"
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await SysList.prototype.initPg.apply t,arguments
    if o.usr._role and o.usr._role.id is 3
      addPg = elt.getE "[h:but=addPg]"
      addPg.hide() if addPg
    rvObj
  