{Pay_typeAddSrv} = require "./Pay_typeAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = Pay_typeAddSrv
exports.Pay_typeEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    rltSet