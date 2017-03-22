{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.Rn_gdListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "rn_gd"
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    usr = t.session.usr
    sql = ""
    #组长
    if usr._role.id is 1
      sql += """
      select t.*
        ,s.cr_no so_id
        ,u2.code usr_id
        ,s.create_time so_create_time
        ,s.amt so_amt
        ,s.trust_amt so_trust_amt
      from #{tabEd} t
      """
    else
      sql += """
      select t.*
        ,s.cr_no so_id
        ,u.code usr_id
        ,s.create_time so_create_time
        ,s.amt so_amt
        ,s.trust_amt so_trust_amt
      from #{tabEd} t
      """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    usr = t.session.usr
    sql = """
    
    left join so s
      on s.id=t.so_id
    """
    #组长
    if usr._role.id is 1
      sql += """
      
      left join usr u2
        on u2.id=s.usr_id
      left join usr u
        on u.id=u2.prn_id
      """
    else
      sql += """
      
      left join usr u
        on u.id=s.usr_id
      """
    sql
  srch2Whr: (reqOpt,argArr,seaArr,isWhr,whr)->
    t = this
    o = t.options
    usr = t.session.usr
    seaArr = seaArr or o.seaArr
    seaArr = seaArr.clone()
    #客服
    if usr._role.id is 2
      seaObj = {andOr:"and",name:"u.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    #组长
    else if usr._role.id is 1
      seaObj = {andOr:"and",name:"u.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    whr = await PrnClzz.prototype.srch2Whr.apply t,[reqOpt,argArr,seaArr,isWhr,whr]
    whr
  #通过id删除一条记录
  "@delById":{isTran: true}
  delById: (reqOpt,id,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    enyTmp = await t.callOne reqOpt,"select so_id from rn_gd where id=$1",[id]
    await t.callSql reqOpt,"update so set state='已发货' where id=$1",[enyTmp.so_id] if enyTmp
    rltSet = await t.callSql reqOpt,"delete from #{tabEd} where id=$1",[id]
    rltSet
  