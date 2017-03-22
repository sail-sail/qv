{SysAdd} = require "../sys/SysAdd"

#系统选项
PrnClzz = SysAdd
exports.OptionAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Option"
    headArr: ["code","lbl","rem"]
    headObj:
      "code":"编码"
      "lbl":"名称"
      "rem":"备注"
  