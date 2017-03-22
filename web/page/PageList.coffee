{SysList} = require "../sys/SysList"

#页面列表
PrnClzz = SysList
exports.PageList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Page"
    headArr: ["code","lbl"]
    headObj:
      "code":"编码"
      "lbl":"名称"
      "url":"地址"
  initPg: ->
    t = this
    o = t.options
    await PrnClzz.prototype.initPg.apply t,arguments
    return
  initOptDel: (optTd)->