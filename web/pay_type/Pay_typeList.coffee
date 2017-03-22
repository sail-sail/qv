{SysList} = require "../sys/SysList"

#快递列表
PrnClzz = SysList
exports.Pay_typeList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Pay_type"
    headArr: ["lbl","rem"]
    headObj:
      "lbl":"名称"
      "rem":"备注"
  initPg: ->
    t = this
    await SysList.prototype.initPg.apply t,arguments
    