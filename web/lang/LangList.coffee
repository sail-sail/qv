{SysList} = require "../sys/SysList"

PrnClzz = SysList
#语言列表
exports.LangList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Lang"
    headArr: ["code","lbl"]
    headObj:
      "code":"编码"
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
    if eny.code is 'en-US'
      optDel = new Element "button",{"class":"optDel"}
      optDel.set "disabled",true
      optDelImg = new Element "img",{"class":"optDelImg",src:"/img/delete_disabled.png"}
      optDelImg.inject optDel
      optDel.inject optTd
      return
    PrnClzz.prototype.initOptDel.apply t,arguments