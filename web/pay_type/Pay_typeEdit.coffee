{SysEdit} = require "../sys/SysEdit"
{Pay_typeAdd} = require "./Pay_typeAdd"

PrnClzz = Pay_typeAdd
exports.Pay_typeEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  