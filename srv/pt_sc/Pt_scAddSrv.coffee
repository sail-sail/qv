{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.Pt_scAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "pt_sc"
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    eny.pt_id = await t.lblSetVal reqOpt,eny.pt_id,"lbl","id","pt" if eny.hasOwnProperty "pt_id"
    return
  #产品规格
  initPc_td: (reqOpt)->
    t = this
    o = t.options
    rltSet = await t.callArr reqOpt,"select * from pt_sc"
    rltSet