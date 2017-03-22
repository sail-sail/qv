{SysList} = require "../sys/SysList"

#快捷备注
PrnClzz = SysList
exports.Qk_rmList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Qk_rm"
    headArr: ["lbl","sort_num","rem"]
    headObj:
      "lbl":"名称"
      "sort_num":"排序"
      "rem":"备注"
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    