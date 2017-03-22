{SysAdd} = require "/sys/SysAdd"

PrnClzz = SysAdd
#部门增加
exports.PageAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Page"
    headArr: ["code","lbl"]
    headObj:
      "code":"编码"
      "lbl":"名称"
      "url":"地址"
    $vdts: ["code"]
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    await PrnClzz.prototype.initPg.apply t,arguments
    return
  codeVdt: (key,val,id)->
    t = this
    o = t.options
    if val.trim() is ""
      return {err:"编码不能为空!",time:2}
    rltSet = await o.thisSrv.ajax "codeVdt",[key,val,id]
    rltSet
  urlVdt: (key,val,id)->
    t = this
    o = t.options
    if val.trim() is ""
      return {err:"地址不能为空!",time:2}
    true
  
