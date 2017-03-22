{SysEdit} = require "../sys/SysEdit"
{Rn_gdAdd} = require "./Rn_gdAdd"

PrnClzz = Rn_gdAdd
exports.Rn_gdEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  