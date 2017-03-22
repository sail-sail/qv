{Qk_rmAddSrv} = require "./Qk_rmAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = Qk_rmAddSrv
exports.Qk_rmEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    rltSet