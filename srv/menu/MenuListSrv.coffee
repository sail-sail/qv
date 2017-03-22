{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.MenuListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "menu"
  dataGrid: (reqOpt,pgOffset,pgNum,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    argArr = []
    argArr.push pgNum,pgOffset if pgNum > 0
    sql = ""
    sql += await t.dgSelect reqOpt,tabEd,argArr
    sql += await t.dgJoin reqOpt,tabEd,argArr
    sql += await t.srch2Whr reqOpt,argArr,o.seaArr,true
    sql += await t.sort2Ody reqOpt,o.sortArr,true
    sql += "\n  t.sort_num asc"
    sql += "\nlimit $1 offset $2" if pgNum > 0
    rltSet = await t.callArr reqOpt,sql,argArr
    {rltSet:rltSet}
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    sql = """
    select t.*
      ,tprn.lbl prn_id
      ,p.lbl page_id
      ,t.open_op open_op
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    sql = """
    
    left join menu tprn
      on tprn.id=t.prn_id
    left join page p
      on p.id=t.page_id
    """
    sql
  impxlx_lbl2val: (reqOpt,key,eny,type)->
    t = this
    val = eny[key]
    return if val is "-"
    if key is "_prn_id"
      return val if val is 0
      enyTmp = await t.callOne reqOpt,"select id from menu where prn_id=$1",[val]
      return enyTmp.id
    if key is "_page_id"
      return val if val is 0
      enyTmp = await t.callOne reqOpt,"select id from page where page_id=$1",[val]
      return enyTmp.id
    val