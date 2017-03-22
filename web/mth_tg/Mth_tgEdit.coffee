{SysEdit} = require "../sys/SysEdit"
{Mth_tgAdd} = require "./Mth_tgAdd"

PrnClzz = Mth_tgAdd
exports.Mth_tgEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  