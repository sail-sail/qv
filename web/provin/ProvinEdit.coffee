{SysEdit} = require "../sys/SysEdit"
{ProvinAdd} = require "./ProvinAdd"

PrnClzz = ProvinAdd
exports.ProvinEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  