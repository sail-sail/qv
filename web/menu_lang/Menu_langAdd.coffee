{SysAdd} = require "../sys/SysAdd"

#菜单语言增加
exports.Menu_langAdd = new Class
  Extends: SysAdd
  options:
    enyStr: "Menu_lang"
    headArr: ["menu_id","lang","lbl"]
    headObj:
      "_menu_id":"菜单"
      "lang":"语言"
      "lbl":"名称"
      