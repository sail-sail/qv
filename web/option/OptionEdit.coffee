{SysEdit} = require "../sys/SysEdit"
{OptionAdd} = require "./OptionAdd"

PrnClzz = OptionAdd
exports.OptionEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  