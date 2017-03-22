{SysAdd} = require "/sys/SysAdd"
{Srv} = require "Srv"

PrnClzz = SysAdd
#表增加
exports.TabAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Tab"
    headArr: ["code","lbl","is_log","rem"]
    headObj:
      "code":"表"
      "lbl":"标签"
      "is_log":"记录日志"
      "rem":"备注"
    $vdts: ["code","lbl"]
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
  lblVdt: (key,val,id)->
    t = this
    o = t.options
    if val.trim() is ""
      return {err:"名称不能为空!",time:2}
    true
  
