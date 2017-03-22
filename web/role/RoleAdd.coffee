{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.RoleAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Role"
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
  