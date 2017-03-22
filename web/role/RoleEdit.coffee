{SysEdit} = require "../sys/SysEdit"
{RoleAdd} = require "./RoleAdd"

PrnClzz = RoleAdd
exports.RoleEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  