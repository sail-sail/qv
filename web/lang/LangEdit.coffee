{SysEdit} = require "../sys/SysEdit"
{LangAdd} = require "./LangAdd"

PrnClzz = LangAdd
exports.LangEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    return