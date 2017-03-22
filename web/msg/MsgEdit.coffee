{SysEdit} = require "../sys/SysEdit"
{MsgAdd} = require "./MsgAdd"

PrnClzz = MsgAdd
exports.MsgEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    return