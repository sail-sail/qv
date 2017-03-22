{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.CityListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "city"
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    sql = ""
    sql += """
    select t.*
      ,pv.lbl provin_id
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    sql = ""
    sql += """
    
    left join provin pv
      on pv.id=t.provin_id
    """
    sql