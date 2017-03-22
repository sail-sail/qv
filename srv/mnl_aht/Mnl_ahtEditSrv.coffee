{Mnl_ahtAddSrv} = require "./Mnl_ahtAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = Mnl_ahtAddSrv
exports.Mnl_ahtEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    rltSet