{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.Mnl_ahtAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Mnl_aht"
    headArr: ["tme","amt","rem"]
    headObj:
      "tme":"时间"
      "amt":"金额"
      "rem":"备注"
    $vdts: ["tme"]
    