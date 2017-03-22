{SysEdit} = require "../sys/SysEdit"
{Mnl_ahtAdd} = require "./Mnl_ahtAdd"

PrnClzz = Mnl_ahtAdd
exports.Mnl_ahtEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  