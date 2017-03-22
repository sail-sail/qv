{SysList} = require "../sys/SysList"

PrnClzz = SysList
#菜单语言列表
exports.Menu_langList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Menu_lang"
    headArr: ["_menu_id","lang","lbl"]
    headObj:
      "_menu_id":"菜单"
      "lang":"语言"
      "lbl":"名称"
  initPg: ->
    t = this
    await SysList.prototype.initPg.apply t,arguments
    return
  initOptDel: (optTd)->
    t = this
    o = t.options
    dt_tr = optTd.getParent ".dt_tr"
    eny = dt_tr.retrieve "eny"
    if eny.lang is 'en-US'
      optDel = new Element "button",{"class":"optDel"}
      optDel.set "disabled",true
      optDelImg = new Element "img",{"class":"optDelImg",src:"/img/delete_disabled.png"}
      optDelImg.inject optDel
      optDel.inject optTd
      return
    PrnClzz.prototype.initOptDel.apply t,arguments
    