{SysList} = require "../sys/SysList"

#月目标绩效列表
PrnClzz = SysList
exports.Mth_tgList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Mth_tg"
    headArr: ["usr_id","pn_tg","tm_tg"]
    headObj:
      "usr_id":"用户"
      "pn_tg":"个人目标"
      "tm_tg":"团队目标"
  initPg: ->
    t = this
    await SysList.prototype.initPg.apply t,arguments
    