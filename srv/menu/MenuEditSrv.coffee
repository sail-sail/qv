{MenuAddSrv} = require "./MenuAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = MenuAddSrv
exports.MenuEditSrv = new Class
  Extends: PrnClzz
  Implements: [SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    rltSet