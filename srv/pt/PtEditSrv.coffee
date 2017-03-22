{PtAddSrv} = require "./PtAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = PtAddSrv
exports.PtEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,entry,keyArr,returning,tab
    rltSet