{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.Rn_gdAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Rn_gd"
    headArr: ["so_id","amt","rem"]
    headObj:
      "so_id":"快递单号"
      "amt":"金额"
      "rem":"备注"
    $vdts: ["so_id"]
  
    