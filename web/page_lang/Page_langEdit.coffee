{SysEdit} = require "../sys/SysEdit"
{Page_langAdd} = require "./Page_langAdd"

PrnClzz = Page_langAdd
exports.Page_langEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    return