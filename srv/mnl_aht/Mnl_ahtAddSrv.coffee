{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.Mnl_ahtAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "mnl_aht"
    $vdts: ["tme"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  tmeVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      can_not_be_empty = await t.getMsg reqOpt,"can_not_be_empty"
      return {err:"时间#{can_not_be_empty}"}
    true