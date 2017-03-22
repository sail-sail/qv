{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.Mth_tgAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Mth_tg"
    headArr: ["usr_id","pn_tg","tm_tg"]
    headObj:
      "usr_id":"用户"
      "pn_tg":"个人目标"
      "tm_tg":"团队目标"
    $vdts: ["usr_id"]