{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.LogAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "log"
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  