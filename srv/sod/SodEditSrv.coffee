{SodAddSrv} = require "./SodAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"
{Pt_scListSrv} = require "../pt_sc/Pt_scListSrv"

PrnClzz = SodAddSrv
exports.SodEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    #旧的数量
    sql = "select qty from sod where id=@id"
    old_eny = await t.callOne reqOpt,sql,eny
    old_qty = old_eny.qty
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    sql = "select qty from sod where id=@id"
    new_eny = await t.callOne reqOpt,sql,eny
    new_qty = new_eny.qty
    #减去产品库存
    num = new_qty-old_qty
    await Pt_scListSrv.prototype.lessQty.apply t,[reqOpt,{id:eny.pt_sc_id,num:num}]
    rltSet