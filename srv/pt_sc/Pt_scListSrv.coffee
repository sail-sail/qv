{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.Pt_scListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "pt_sc"
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    sql = """
    select t.*
      ,p.lbl pt_id
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    sql = """
    
    left join pt p
      on p.id=t.pt_id
    """
    sql
  #减去产品规格库存
  "@lessQty":{_private:true}
  lessQty: (reqOpt,eny)->
    t = this
    sql = "update pt_sc set qty=qty-@num where id=@id"
    await t.callOne reqOpt,sql,eny
    sql = "select ps.*,p.lbl _pt_id from pt_sc ps left join pt p on p.id=ps.pt_id where ps.id=@id"
    pt_scEny = await t.callOne reqOpt,sql,eny
    if pt_scEny.min_qty isnt 0
      if pt_scEny.min_qty > pt_scEny.qty
        err = new String "产品 #{pt_scEny._pt_id} 规格 #{pt_scEny.lbl} 的当前库存 #{pt_scEny.qty} 不能低于最低库存 #{pt_scEny.min_qty} !"
        err.is_out = true
        #throw err
    return
    
  