{SysAdd} = require "../sys/SysAdd"

#页面语言增加
exports.Page_langAdd = new Class
  Extends: SysAdd
  options:
    enyStr: "Page_lang"
    headArr: ["page_id","lang","lbl"]
    headObj:
      "_page_id":"页面"
      "lang":"语言"
      "lbl":"名称"
      