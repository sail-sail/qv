{SysEdit} = require "../sys/SysEdit"
{SoAdd} = require "./SoAdd"

PrnClzz = SoAdd
exports.SoEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    sod_list_div = elt.getE ".sod_list_div"
    sod_list_div.hide() if sod_list_div
    rvObj
  