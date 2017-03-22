{SysList} = require "../sys/SysList"

#快递列表
PrnClzz = SysList
exports.ProvinList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Provin"
    headArr: ["lbl","rem"]
    headObj:
      "lbl":"名称"
      "rem":"备注"
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    