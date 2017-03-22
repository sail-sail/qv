{SysEdit} = require "../sys/SysEdit"
{SodAdd} = require "./SodAdd"

PrnClzz = SodAdd
exports.SodEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  