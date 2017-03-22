{SysAdd} = require "../sys/SysAdd"

#语言增加
exports.LangAdd = new Class
  Extends: SysAdd
  options:
    enyStr: "Lang"
    headArr: ["code","lbl"]
    headObj:
      "code":"编码"
      "lbl":"名称"
  