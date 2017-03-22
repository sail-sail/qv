{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.PtAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Pt"
    headArr: ["lbl","pr","rem"]
    headObj:
      "lbl":"名称"
      "pr":"单价"
      "rem":"备注"
    $vdts: ["lbl"]
  