{SysEdit} = require "../sys/SysEdit"
{Qk_rmAdd} = require "./Qk_rmAdd"

PrnClzz = Qk_rmAdd
exports.Qk_rmEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  