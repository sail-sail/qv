{SysEdit} = require "../sys/SysEdit"
{PtAdd} = require "./PtAdd"

PrnClzz = PtAdd
exports.PtEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  