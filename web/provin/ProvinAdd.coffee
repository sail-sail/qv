{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.ProvinAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Provin"
    headArr: ["lbl","rem"]
    headObj:
      "lbl":"名称"
      "rem":"备注"
    $vdts: ["lbl"]
    