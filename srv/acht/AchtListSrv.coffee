{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.AchtListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "so"
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
    rvObj
  dataGrid: (reqOpt,pgOffset,pgNum,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    tab = tab or o.tab
    tabEd = t.escapeId tab
    argArr = []
    argArr.push pgNum,pgOffset if pgNum > 0
    sql = ""
    sql += await t.dgSelect reqOpt,tabEd,argArr
    sql += await t.dgJoin reqOpt,tabEd,argArr
    sql += await t.srch2Whr reqOpt,argArr,o.seaArr,true
    sql += await t.dgGroupBy reqOpt,tabEd,argArr
    sql += " order by amt desc"
    sql += " limit $1 offset $2" if pgNum > 0
    rltSet = await t.callArr reqOpt,sql,argArr
    #用户列表
    argArr = []
    sql = "select t.* from usr t"
    if o.usr1But
      argArr.push o.usr1But
      sql += " where t.prn_id=$#{argArr.length}"
    if usr._role.id is 1
      argArr.push usr.id
      sql += " where t.prn_id=$#{argArr.length}"
    else if usr._role.id is 2
      argArr.push usr.id
      sql += " where t.id=$#{argArr.length}"
    usrRltSet = await t.callArr reqOpt,sql,argArr
    rltSet3 = []
    for usrEny in usrRltSet
      has = undefined
      for eny in rltSet
        if usrEny.code is eny.usr
          has = eny
          break
      continue if has
      rltSet3.push {usr:usrEny.code,count:0,amt:0,wechat:0,alipay:0,trust_amt:0,rn_gd:0,icbc:0,postal:0,arrear:0,xindan:0,xudan:0,_empty:true}
    rltSet.append rltSet3
    for eny in rltSet
      continue if eny._empty is true
      tmpKeyArr = ["wechat","alipay","icbc","postal","arrear"]
      tmpLblObj = {wechat:"微信",alipay:"支付宝",icbc:"建行",postal:"邮政",arrear:"欠款"}
      for tmpKey in tmpKeyArr
        argArrTmp = [eny.usr]
        seaArrTmp = o.seaArr.clone()
        sql = """
        select sum(t.amt) amt from so t
        left join usr u
          on u.id=t.usr_id
        left join pay_type p
          on p.id=t.pay_type_id
        where u.code=$1 and t.state!='已退货'
        """
        argArrTmp.push tmpLblObj[tmpKey]
        sql += " and p.lbl=$#{argArrTmp.length}"
        sql += await PrnClzz.prototype.srch2Whr.apply t,[reqOpt,argArrTmp,seaArrTmp,false]
        enyTmp = await t.callOne reqOpt,sql,argArrTmp
        eny[tmpKey] = enyTmp.amt or 0
      #累加欠款2 so.qk
      sql = """
      select sum(t.amt) amt from so t
      left join usr u
        on u.id=t.usr_id
      where u.code=$1 and t.qk=true and t.state!='已退货'
      """
      argArrTmp = [eny.usr]
      sql += await PrnClzz.prototype.srch2Whr.apply t,[reqOpt,argArrTmp,o.seaArr.clone(),false]
      enyTmp = await t.callOne reqOpt,sql,argArrTmp
      eny.arrear += enyTmp.amt or 0
    
    #左下角单数,业绩
    sql2 = "select sum(y.count) count_sum,sum(y.amt) amt_sum from ("
    argArr2 = []
    sql2 += await t.dgSelect reqOpt,tabEd,argArr2
    sql2 += await t.dgJoin reqOpt,tabEd,argArr2
    sql2 += "\nwhere t.state!='已退货'"
    sql2 += await t.srch2Whr reqOpt,argArr2,o.seaArr,false
    sql2 += await t.dgGroupBy reqOpt,tabEd,argArr2
    sql2 += ") y"
    eny2 = await t.callOne reqOpt,sql2,argArr2
    eny2 = eny2 or {count_sum:0,amt_sum:0}
    eny2.count_sum = eny2.count_sum or 0
    eny2.amt_sum = eny2.amt_sum or 0
    
    #--------------------------------------------------------------------------------------------团队当月总业绩
    date = new Date()
    date.setDate 1
    date1 = new Date()
    date1.setMonth date1.getMonth()+1
    date1.setDate 1
    sql4 = """
    select sum(t.amt)+sum(t.trust_amt) amt
    from so t
    left join usr u
      on u.id=t.usr_id
    where t.state='已发货'
    """
    argArr4 = []
    argArr4.push date.Format "yyyy-MM-dd"
    sql4 += " and t.create_time>=$#{argArr4.length}"
    argArr4.push date1.Format "yyyy-MM-dd"
    sql4 += " and t.create_time<$#{argArr4.length}"
    
    if usr.code isnt "admin"
      argArr4.push usr.id
      sql4 += " and u.prn_id=$#{argArr4.length}"
    
    eny4 = await t.callOne reqOpt,sql4,argArr4
    eny2.amt_all = eny4 and eny4.amt or 0
    #--------------------------------------------------------------------------------------------团队当月总业绩
    
    #--------------------------------------------------------------------------------------------个人当月总业绩
    date = new Date()
    date.setDate 1
    date1 = new Date()
    date1.setMonth date1.getMonth()+1
    date1.setDate 1
    sql4 = """
    select sum(t.amt)+sum(t.trust_amt) amt
    from so t
    where t.state='已发货'
    """
    argArr4 = []
    argArr4.push date.Format "yyyy-MM-dd"
    sql4 += " and t.create_time>=$#{argArr4.length}"
    argArr4.push date1.Format "yyyy-MM-dd"
    sql4 += " and t.create_time<$#{argArr4.length}"
    
    argArr4.push usr.id
    sql4 += " and t.usr_id=$#{argArr4.length}"
    
    eny4 = await t.callOne reqOpt,sql4,argArr4
    eny2.amt_usr = eny4 and eny4.amt or 0
    #--------------------------------------------------------------------------------------------个人当月总业绩
    
    eny = await t.callOne reqOpt,"select pn_tg,tm_tg from mth_tg where usr_id=@usr_id",{usr_id:usr.id}
    eny = await t.callOne reqOpt,"select pn_tg,tm_tg from mth_tg where usr_id=0" if !eny
    #团队业绩目标
    eny2.mth_tg_amt = eny and eny.tm_tg
    #个人业绩目标
    eny2.mth_tg_usr = eny and eny.pn_tg
    
    #扣除退货后按金额再次排序
    rltSet.sort (arg0,arg1)-> arg1.amt-arg0.amt
    {rltSet:rltSet,eny2:eny2}
  dgGroupBy: (reqOpt,tabEd,argArr)->
    t = this
    o = t.options
    usr = t.session.usr
    if o.usr1But
      sql = "\ngroup by u2.code"
    else if usr._role.id is 1
      sql = "\ngroup by u2.code"
    else
      sql = "\ngroup by u.code"
    sql
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    o = t.options
    usr = t.session.usr
    sql = ""
    if o.usr1But
      sql += """
      select u2.code usr
        ,count(case when p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true else null end) count
        ,count(
          case when t.xudan and p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true
          else null end
        ) xudan
        ,count(
          case when t.xudan=false and p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true
          else null end
        ) xindan
        ,sum(t.amt)+sum(t.trust_amt) amt
        ,sum(t.trust_amt) trust_amt
      from so t
      """
    #组长
    else if usr._role.id is 1
      sql += """
      select u2.code usr
        ,count(case when p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then 1 else null end) count
        ,count(
          case when t.xudan and p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true
          else null end
        ) xudan
        ,count(
          case when t.xudan=false and p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true
          else null end
        ) xindan
        ,sum(t.amt)+sum(t.trust_amt) amt
        ,sum(t.trust_amt) trust_amt
      from so t
      """
    else
      sql += """
      select u.code usr
        ,count(case when p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true else null end) count
        ,count(
          case when t.xudan and p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true
          else null end
        ) xudan
        ,count(
          case when t.xudan=false and p.lbl!='欠款' and t.qk!=true and t.state!='已退货' then true
          else null end
        ) xindan
        ,sum(t.amt)+sum(t.trust_amt) amt
        ,sum(t.trust_amt) trust_amt
      from so t
      """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    o = t.options
    usr = t.session.usr
    sql = ""
    sql += """
    
    left join pay_type p
      on p.id=t.pay_type_id
    """
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
    else if usr._role.id is 2
      seaObj = {andOr:"and",name:"u.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    #组长
    else if usr._role.id is 1
      seaObj = {andOr:"and",name:"u.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    whr = await PrnClzz.prototype.srch2Whr.apply t,[reqOpt,argArr,seaArr,isWhr,whr]
    whr
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
  