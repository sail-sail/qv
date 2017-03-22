{SysList} = require "../sys/SysList"

#系统选项列表
PrnClzz = SysList
exports.OptionList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Option"
    headArr: ["code","lbl","rem"]
    headObj:
      "code":"编码"
      "lbl":"名称"
      "rem":"备注"
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  initOptDel: (optTd)->
    