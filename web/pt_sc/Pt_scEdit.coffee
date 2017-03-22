{SysEdit} = require "../sys/SysEdit"
{Pt_scAdd} = require "./Pt_scAdd"

PrnClzz = Pt_scAdd
exports.Pt_scEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  