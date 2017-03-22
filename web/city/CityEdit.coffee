{SysEdit} = require "../sys/SysEdit"
{CityAdd} = require "./CityAdd"

PrnClzz = CityAdd
exports.CityEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  