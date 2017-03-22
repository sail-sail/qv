{Mth_tgAddSrv} = require "./Mth_tgAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = Mth_tgAddSrv
exports.Mth_tgEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    rltSet