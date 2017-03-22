{SysListSrv} = require "../sys/SysListSrv"

#客户统计
PrnClzz = SysListSrv
exports.Cus_sttListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "cus_stt"
    usr1But: undefined #选中某个组长的usr.id
  initPg: (reqOpt,argObj)->
    t = this
    o = t.options
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    sql = """
    select t.id,t.code
    from usr t
    where t.role_id=1
    order by t.code asc
    """
    rvObj.usr1Arr = await t.callArr reqOpt,sql
    #填充新日期
    date = new Date()
    dateStr = date.Format "yyyy-MM-dd"
    sql = """
    var plan = plv8.prepare("select id from usr");
    var cursor = plan.cursor();
    var csPlan = plv8.prepare("select count(id) count from cus_stt where dt=$1 and usr_id=$2");
    var csPlan2 = plv8.prepare("insert into cus_stt(dt,usr_id) values($1,$2)");
    var usrEny = undefined;
    try {
      while(usrEny = cursor.fetch()) {
        var count = csPlan.execute(['#{dateStr}',usrEny.id])[0].count;
        if(count > 0) continue;
        csPlan2.execute(['#{dateStr}',usrEny.id]);
      }
    } finally {
      cursor.close();
      plan.free();
      csPlan.free();
      csPlan2.free();
    }
    """
    await t.callPlv8 reqOpt,sql
    rvObj
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
    sql += await t.dgGroupBy reqOpt,tabEd,argArr
    sql += await t.sort2Ody reqOpt,o.sortArr,true
    sql += "\n  t.id asc"
    sql += "\nlimit $1 offset $2" if pgNum > 0
    rltSet = await t.callArr reqOpt,sql,argArr
    
    #合计
    argArr = []
    sql = """
    select 
       sum(t.mrn) mrn
      ,sum(t.aft) aft
      ,sum(t.ngt) ngt
      ,sum(t.no_rpy) no_rpy
      ,sum(t.black) black
      ,sum(t.efft) efft
      ,sum(t.intt) intt
      ,sum(t.bill) bill
      ,sum(t.tt_nm) tt_nm
      ,(case when sum(t.tt_nm)=0 then 0
       else sum(t.bill)::decimal(20,10)/sum(t.tt_nm)::decimal(20,10) end) cnv_rt
    from cus_stt t
    """
    sql += await t.dgJoin reqOpt,tabEd,argArr
    sql += await t.srch2Whr reqOpt,argArr,o.seaArr,true
    enyTt = await t.callOne reqOpt,sql,argArr
    {rltSet:rltSet,enyTt:enyTt}
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    o = t.options
    usr = t.session.usr
    sql = ""
    if o.usr1But
      sql += """
      select t.*
        ,u2.code usr_id
      from #{tabEd} t
      """
    #组长
    else if usr._role.id is 1
      sql += """
      select t.*
        ,u2.code usr_id
      from #{tabEd} t
      """
    else
      sql += """
      select t.*
        ,u.code usr_id
      from #{tabEd} t
      """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    o = t.options
    usr = t.session.usr
    sql = ""
    if o.usr1But
      sql += """
      
      left join usr u2
        on u2.id=t.usr_id
      left join usr u
        on u.id=u2.prn_id
      """
    #组长
    else if usr._role.id is 1
      sql += """
      
      left join usr u2
        on u2.id=t.usr_id
      left join usr u
        on u.id=u2.prn_id
      """
    else
      sql += """
      
      left join usr u
        on u.id=t.usr_id
      """
    sql
  srch2Whr: (reqOpt,argArr,seaArr,isWhr,whr)->
    t = this
    o = t.options
    usr = t.session.usr
    seaArr = seaArr or o.seaArr
    seaArr = seaArr.clone()
    if o.usr1But
      seaObj = {andOr:"and",name:"u.id",opt:"=",value:o.usr1But}
      seaArr.push seaObj
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
  #点击添加
  "@khsj_butClk":{isTran:true}
  khsj_butClk: (reqOpt,jrsVal,sjdxzVal)->
    t = this
    o = t.options
    throw new Error "sjdxzVal must be in mrn,aft,ngt!" if ["mrn","aft","ngt"].indexOf(sjdxzVal) is -1
    usr = t.session.usr
    date = new Date()
    dateStr = date.Format "yyyy-MM-dd"
    eny = await t.callOne reqOpt,"select t.* from #{o.tab} t where t.dt=$1 and t.usr_id=$2",[dateStr,usr.id]
    if !eny
      #日期尚未存在
      mrn = 0
      aft = 0
      ngt = 0
      if sjdxzVal is "mrn"
        mrn = jrsVal
      else if sjdxzVal is "aft"
        aft = jrsVal
      else if sjdxzVal is "ngt"
        ngt = jrsVal
      eny = await t.callOne reqOpt,"insert into #{o.tab}(dt,usr_id,mrn,aft,ngt,tt_nm) values($1,$2,$3,$4,$5,$6) returning *",[dateStr,usr.id,mrn,aft,ngt,jrsVal]
    else
      #日期已经存在
      if sjdxzVal is "mrn"
        await t.callOne reqOpt,"update #{o.tab} set mrn=mrn+$2,tt_nm=tt_nm+$2 where id=$1",[eny.id,jrsVal]
      else if sjdxzVal is "aft"
        await t.callOne reqOpt,"update #{o.tab} set aft=aft+$2,tt_nm=tt_nm+$2 where id=$1",[eny.id,jrsVal]
      else if sjdxzVal is "ngt"
        await t.callOne reqOpt,"update #{o.tab} set ngt=ngt+$2,tt_nm=tt_nm+$2 where id=$1",[eny.id,jrsVal]
    await t.cnv_rtChg reqOpt,eny.id
    rltObj = {str:"添加成功!"}
    rltObj
  no_rpyChg: (reqOpt,id,val)->
    t = this
    o = t.options
    val = val or 0
    await t.callOne reqOpt,"update #{o.tab} set no_rpy=$1 where id=$2",[val,id]
    rltObj = {info:"修改成功!"}
    rltObj
  #拉黑
  blackChg: (reqOpt,id,val)->
    t = this
    o = t.options
    val = val or 0
    await t.callOne reqOpt,"update #{o.tab} set black=$1 where id=$2",[val,id]
    rltObj = {info:"修改成功!"}
    rltObj
  efftChg: (reqOpt,id,val)->
    t = this
    o = t.options
    val = val or 0
    await t.callOne reqOpt,"update #{o.tab} set efft=$1 where id=$2",[val,id]
    rltObj = {info:"修改成功!"}
    rltObj
  inttChg: (reqOpt,id,val)->
    t = this
    o = t.options
    val = val or 0
    await t.callOne reqOpt,"update #{o.tab} set intt=$1 where id=$2",[val,id]
    rltObj = {info:"修改成功!"}
    rltObj
  "@billChg":{isTran:true}
  billChg: (reqOpt,id,val)->
    t = this
    o = t.options
    val = val or 0
    await t.callOne reqOpt,"update #{o.tab} set bill=$1 where id=$2",[val,id]
    await t.cnv_rtChg reqOpt,id
    rltObj = {info:"修改成功!"}
    rltObj
  #转化率
  "@cnv_rtChg":{_private: true}
  cnv_rtChg: (reqOpt,id)->
    t = this
    o = t.options
    eny = await t.callOne reqOpt,"select tt_nm from #{o.tab} where id=$1",[id]
    return if !eny or eny.tt_nm is 0
    await t.callSql reqOpt,"update #{o.tab} set cnv_rt=bill::decimal(20,10)/tt_nm::decimal(20,10) where id=$1",[id]
    return
  #admin选择不同的组长
  usr1ButClk: (reqOpt,id,sltd)->
    t = this
    o = t.options
    usr = t.session.usr
    return if usr.code isnt "admin"
    if sltd
      o.usr1But = id
    else
      o.usr1But = undefined
    return