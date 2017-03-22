{SysListSrv} = require "../sys/SysListSrv"
{Pt_scListSrv} = require "../pt_sc/Pt_scListSrv"

PrnClzz = SysListSrv
exports.SodListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "sod"
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    sql = """
    select t.*
      ,p.lbl pt_id
      ,pc.lbl pt_sc_id
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    sql = """
    
    left join pt p
      on p.id=t.pt_id
    left join pt_sc pc
      on pc.id=t.pt_sc_id
    """
    sql
  #通过id删除一条记录
  "@delById":{isTran: true}
  delById: (reqOpt,id,tab)->
    t = this
    o = t.options
    sql = "select qty,pt_sc_id from sod where id=@id"
    eny = await t.callOne reqOpt,sql,{id:id}
    qty = eny.qty
    await Pt_scListSrv.prototype.lessQty.apply t,[reqOpt,{id:eny.pt_sc_id,num:-qty}] if qty > 0
    rltSet = await PrnClzz.prototype.delById.apply t,arguments
    rltSet
  