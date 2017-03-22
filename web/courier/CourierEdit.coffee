{SysEdit} = require "../sys/SysEdit"
{CourierAdd} = require "./CourierAdd"

PrnClzz = CourierAdd
exports.CourierEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  