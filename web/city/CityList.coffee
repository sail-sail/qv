{SysList} = require "../sys/SysList"

#城市列表
PrnClzz = SysList
exports.CityList = new Class
  Extends: PrnClzz
  options:
    enyStr: "City"
    headArr: ["provin_id","lbl","rem"]
    headObj:
      "provin_id":"省份"
      "lbl":"城市"
      "rem":"备注"
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    