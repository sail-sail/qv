{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.CourierAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Courier"
    headArr: ["lbl","rem"]
    headObj:
      "lbl":"名称"
      "rem":"备注"
    $vdts: ["lbl"]
    