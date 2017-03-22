{SysEdit} = require "../sys/SysEdit"
{Menu_langAdd} = require "./Menu_langAdd"

PrnClzz = Menu_langAdd
exports.Menu_langEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    return