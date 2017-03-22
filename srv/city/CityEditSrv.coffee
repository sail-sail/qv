{CityAddSrv} = require "./CityAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = CityAddSrv
exports.CityEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    rltSet