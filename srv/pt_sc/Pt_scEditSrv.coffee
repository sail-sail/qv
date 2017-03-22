{Pt_scAddSrv} = require "./Pt_scAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = Pt_scAddSrv
exports.Pt_scEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    rltSet