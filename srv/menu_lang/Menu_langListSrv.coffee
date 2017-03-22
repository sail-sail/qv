{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.Menu_langListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "menu_lang"
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    sql = """
    select t.*
      ,m.lbl _menu_id
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    sql += """
    
    left join menu m
      on m.id=t.menu_id
    """
    sql
  dataCount: (reqOpt,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    argArr = []
    sql = """
    select count(t.id) as count
    from #{tabEd} t
    """
    sql += await t.dgJoin reqOpt,tabEd,argArr
    sql += t.srch2Whr reqOpt,argArr,o.seaArr,true
    eny = await t.callOne reqOpt,sql,argArr
    {count:eny.count}
  delById: (id)->
    t = this
    o = t.options
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "#{usr.code} can not delete menu_lang!"
    await PrnClzz.prototype.delById.apply t,arguments
  