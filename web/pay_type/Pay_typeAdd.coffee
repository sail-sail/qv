{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.Pay_typeAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Pay_type"
    headArr: ["lbl","rem"]
    headObj:
      "lbl":"名称"
      "rem":"备注"
    $vdts: ["lbl"]
  lblVdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "lblVdt",[key,val,id]
    rltSet
  