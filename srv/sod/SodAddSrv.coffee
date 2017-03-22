{SysSrv} = require "../sys/SysSrv"
{Pt_scListSrv} = require "../pt_sc/Pt_scListSrv"

PrnClzz = SysSrv
exports.SodAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "sod"
    $vdts: ["so_id","pt_id","pt_sc_id","qty"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    returning = "*"
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    new_eny = rltSet[0]
    #减去产品库存
    await Pt_scListSrv.prototype.lessQty.apply t,[reqOpt,{id:new_eny.pt_sc_id,num:new_eny.qty}] if new_eny.qty > 0
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    eny.pt_id = await t.lblSetVal reqOpt,eny.pt_id,"lbl","id","pt" if eny.hasOwnProperty "pt_id"
    eny.pt_sc_id = await t.lblSetVal reqOpt,eny.pt_sc_id,"lbl","id","pt_sc" if eny.hasOwnProperty "pt_sc_id"
    return
  so_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:"订单编号#{cannot_empty}"}
    sql = """
    select count(t.id) count
    from so t
    where t.id=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"订单 #{val} 不存在!"}
    true
  pt_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:"产品#{cannot_empty}"}
    sql = """
    select count(t.id) count
    from pt t
    where t.lbl=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"产品 #{val} 不存在!"}
    true
  pt_sc_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:"规格#{cannot_empty}"}
    sql = """
    select count(t.id) count
    from pt_sc t
    where t.lbl=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"规格 #{val} 不存在!"}
    true
  qtyVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    return {err:"数量必须大于0"} if Number(val) <= 0
    true
  initPt_sc_id: (reqOpt,pt_idVal)->
    t = this
    sql = """
    select t.*
    from pt_sc t
    left join pt p
      on p.id=t.pt_id
    where p.lbl=@pt_idVal
    """
    rltSet = await t.callArr reqOpt,sql,{pt_idVal:pt_idVal}
    rltSet
  initPt_id: (reqOpt)->
    t = this
    rltSet = await t.callArr reqOpt,"select * from pt"
    rltSet