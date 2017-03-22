{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.Mth_tgListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "mth_tg"
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    sql = ""
    sql += """
    select t.*
      ,u.code usr_id
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    usr = t.session.usr
    sql = ""
    sql += """
    
    left join usr u
      on u.id=t.usr_id
    """
    sql