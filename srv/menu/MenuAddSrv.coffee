{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.MenuAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "menu"
    sort_fld: "sort_num asc"
    enable_fld: "enable"
    $vdts: ["prn_id","page_id"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    eny.prn_id = await t.lblSetVal reqOpt,eny.prn_id,"lbl","id","menu" if eny.hasOwnProperty "prn_id"
    eny.page_id = await t.lblSetVal reqOpt,eny.page_id,"lbl","id","page" if keyArr.hasOwnProperty "page_id"
    return
  prn_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:cannot_empty}
    sql = """
    select count(t.id) count
    from menu t
    where t.#{t.escapeId(key)}=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"#{val} 不存在!"}
    true
  page_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:cannot_empty}
    sql = """
    select count(t.id) count
    from page t
    where t.#{t.escapeId(key)}=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"#{val} 不存在!"}
    true
  #获得菜单对应的孩子
  pageCld: (reqOpt,id)->
    t = this
    sql = """
    select t.*
    from menu t 
    where 
      t.prn_id=$1
      and t.enable=true
    order by t.sort_num asc
    """
    rltSet = await t.callArr reqOpt,sql,[id]
    rltSet
  #获得菜单的根节点,可能有很多个
  pageRoot: (reqOpt)->
    t = this
    sql = """
    select m.*
    from menu m 
    where 
      m.is_root=true
      and m.enable=true
    """
    rltSet = await t.callArr reqOpt,sql
    rltSet
  findMenuByPageId: (reqOpt,page_id)->
    t = this
    sql = "select * from menu where page_id=$1 limit 1 offset 0"
    rltSet = await t.callArr reqOpt,sql,[page_id]
    rltSet[0]
