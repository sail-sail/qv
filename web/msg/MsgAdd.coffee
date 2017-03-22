{SysAdd} = require "../sys/SysAdd"

#国际化消息增加
exports.MsgAdd = new Class
  Extends: SysAdd
  options:
    enyStr: "Msg"
    headArr: ["code","lang","lbl"]
    headObj:
      "code":"编码"
      "lang":"语言"
      "lbl":"名称"
  