{SysList} = require "../sys/SysList"

#产品列表
PrnClzz = SysList
exports.PtList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Pt"
    headArr: ["lbl","pr","create_time","update_time","rem"]
    headObj:
      "lbl":"名称"
      "pr":"单价"
      "create_time":"创建时间"
      "update_time":"修改时间"
      "rem":"备注"
  initPg: ->
    t = this
    await SysList.prototype.initPg.apply t,arguments
    