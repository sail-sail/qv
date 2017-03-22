{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.UsrListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "usr"
  dgSelect: (reqOpt,tabEd,argArr)->
    sql = """
    select t.*
      ,t2.lbl prn_id
      ,r.lbl role_id
    from #{tabEd} t
    """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    sql = """
    
    left join usr t2
      on t2.id=t.prn_id
    left join role r
      on r.id=t.role_id
    """
    sql
  srch2Whr: (reqOpt,argArr,seaArr,isWhr,whr)->
    t = this
    o = t.options
    usr = t.session.usr
    seaArr = seaArr or o.seaArr
    seaArr = seaArr.clone()
    #客服
    if usr._role and usr._role.id is 2
      seaObj = {andOr:"and",name:"t.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    else if usr._role and usr._role.id is 3
      seaObj = {andOr:"and",name:"t.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    #财务
    else if usr._role and usr._role.id is 4
      seaObj = {andOr:"and",name:"t.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    #组长
    else if usr._role and usr._role.id is 1
      seaObj = {andOr:"and",name:"t2.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    await PrnClzz.prototype.srch2Whr.apply t,[reqOpt,argArr,seaArr,isWhr,whr]