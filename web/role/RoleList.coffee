{SysList} = require "../sys/SysList"

#角色列表
PrnClzz = SysList
exports.RoleList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Role"
    headArr: ["lbl","rem"]
    headObj:
      "lbl":"名称"
      "rem":"备注"
  initPg: ->
    t = this
    await SysList.prototype.initPg.apply t,arguments
  initOptDel: (optTd)->