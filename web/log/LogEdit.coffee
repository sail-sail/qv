{SysEdit} = require "../sys/SysEdit"
{LogAdd} = require "./LogAdd"

PrnClzz = LogAdd
exports.LogEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  