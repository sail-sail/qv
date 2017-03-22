{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.Qk_rmAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Qk_rm"
    headArr: ["lbl","sort_num","rem"]
    headObj:
      "lbl":"名称"
      "sort_num":"排序"
      "rem":"备注"
    $vdts: ["lbl"]
    