{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.Page_langListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "page_lang"
  dgSelect: (reqOpt,tabEd,argArr)->
    sql = """
    select t.*
      ,p.lbl _page_id
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    sql = """
    
    left join page p
      on p.id=t.page_id
    """
    sql
  delById: (id)->
    t = this
    o = t.options
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "#{usr.code} can not delete page_lang!"
    await PrnClzz.prototype.delById.apply t,arguments
  