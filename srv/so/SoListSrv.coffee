{SysListSrv} = require "../sys/SysListSrv"
{Pt_scListSrv} = require "../pt_sc/Pt_scListSrv"
fsAsync = require "fsAsync"
ejsexcel = require "ejsexcel"

PrnClzz = SysListSrv
exports.SoListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "so"
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
    sql += await t.sort2Ody reqOpt,o.sortArr,true
    sql += "\n  t.id desc"
    sql += "\nlimit $1 offset $2" if pgNum > 0
    
    sql = """
    var plan = plv8.prepare("#{t.plv8Block(sql,argArr)}");
    var cursor = plan.cursor();
    var eny = undefined;
    var sql1 = "select t.*,p.lbl pt_id,ps.lbl pt_sc_id ";
    sql1 += "from sod t left join pt p on p.id=t.pt_id ";
    sql1 += "left join pt_sc ps on ps.id=t.pt_sc_id where t.so_id=$1";
    var sql1Plan = plv8.prepare(sql1);
    try {
      while(eny = cursor.fetch()) {
        if(eny.create_time) {
          eny._create_time = eny.create_time;
          eny.create_time = eny.create_time.FormatUTC("yy-MM-dd");
        }
        eny._sodEnyArr = sql1Plan.execute([eny.id]);
        rltSet_rv.push(eny);
      }
    } finally {
      sql1Plan.free();
      cursor.close();
      plan.free();
    }
    """
    rltSet = await t.callPlv8 reqOpt,sql
    {rltSet:rltSet}
  dgSelect: (reqOpt,tabEd,argArr)->
    t = this
    usr = t.session.usr
    sql = ""
    #组长
    if usr._role.id is 1
      sql += """
      select t.*
        ,u2.code usr_id
        ,c.lbl courier_id
        ,pt.lbl pay_type_id
      from #{tabEd} t
      """
    else
      sql += """
      select t.*
        ,u.code usr_id
        ,c.lbl courier_id
        ,pt.lbl pay_type_id
      from #{tabEd} t
      """
    sql
  dgJoin: (reqOpt,tabEd,argArr)->
    t = this
    usr = t.session.usr
    sql = ""
    sql += """
    
    left join courier c
      on c.id=t.courier_id
    left join pay_type pt
      on pt.id=t.pay_type_id
    """
    #组长
    if usr._role.id is 1
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
    #客服
    if usr._role.id is 2
      seaObj = {andOr:"and",name:"u.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    #组长
    else if usr._role.id is 1
      seaObj = {andOr:"and",name:"u.id",opt:"=",value:usr.id}
      seaArr.push seaObj
      seaObj = {andOr:"or",name:"u2.id",opt:"=",value:usr.id}
      seaArr.push seaObj
    else if usr._role.id is 3 #发货员
      seaObj = {andOr:"and",name:"t.acc_state",opt:"=",value:"已核"}
      seaArr.push seaObj
    whr = await PrnClzz.prototype.srch2Whr.apply t,[reqOpt,argArr,seaArr,isWhr,whr]
    whr
  dataCount: (reqOpt,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    tab = tab or o.tab
    tabEd = t.escapeId tab
    argArr = []
    sql = """
    select count(t.id) as count
    from #{tabEd} t
    """
    sql += await t.dcJoin reqOpt,tabEd,argArr
    sql += await t.srch2Whr reqOpt,argArr,o.seaArr,true
    eny = await t.callOne reqOpt,sql,argArr
    {count:eny.count}
  delById: (reqOpt,id,tab)->
    t = this
    o = t.options
    #删除前
    befEny = await t.callOne reqOpt,"select * from #{o.tab} where id=$1",[id]
    rvObj = await PrnClzz.prototype.delById.apply t,arguments
    #查找此订单下面的所有订单明细,减去所有订单明细的产品数量,数量为负数
    sql = """
    select t.* from sod t
    where t.so_id=@id
    """
    sod_enyArr = await t.callArr reqOpt,sql,{id:id}
    for sod_eny in sod_enyArr
      qty = sod_eny.qty
      await Pt_scListSrv.prototype.lessQty.apply t,[reqOpt,{id:sod_eny.pt_sc_id,num:-qty}] if qty > 0
    await t.log reqOpt,{pg:"SoList",act:"删除",bef:befEny,keys:["cr_no","usr_id","cm_nm"],head_obj:["../so/SoList","SoList.prototype.options.headObj"]}
    rvObj
  #顺丰未发货订单
  shunfengTpl: (reqOpt)->
    t = this
    o = t.options
    sql = """
    select t.*
    from so t
    left join courier c
      on c.id=t.courier_id
    where c.lbl='顺丰' and t.state='未发货'
    """
    rltSet = await t.callArr reqOpt,sql
    buf = await fsAsync.readFileAsync "#{__dirname}/shunfengTpl.xlsx"
    buf2 = await ejsexcel.renderExcel buf,{rltSet:rltSet}
    name = "顺丰未发货订单.xlsx"
    uid = await t.buf2uid reqOpt,buf2,name,(path2)-> await fsAsync.unlinkAsync path2
    uid
  "@cr_noChg":{isTran:true}
  cr_noChg: (reqOpt,id,val2)->
    t = this
    state = undefined
    if val2
      state = "已发货"
    else
      state = "未发货"
    await t.callSql reqOpt,"update so set cr_no=@cr_no,state=@state where id=@id",{id:id,cr_no:val2,state:state}
    true
  upxls: (reqOpt,buf2)->
    t = this
    buf =  Buffer.from buf2,"base64"
    uid = await t.buf2uid reqOpt,buf,"顺丰未发货订单.xls"
    uid
  #点击财务状态
  acc_stateClk: (reqOpt,id,val)->
    t = this
    o = t.options
    usr = t.session.usr
    return {suc:false,msg:"无修改权限"} if usr.code isnt "admin" and usr._role.id isnt 4
    return {suc:false,msg:"ID号错误"} if !id
    sql = "update so set acc_state=$2 where id=$1"
    await t.callSql reqOpt,sql,[id,val]
    {suc:true,msg:"修改成功"}
  #点击快递
  crr_stateClk: (reqOpt,id,val)->
    t = this
    o = t.options
    usr = t.session.usr
    return {suc:false,msg:"无修改权限"} if usr.code isnt "admin" and o.usr._role.id isnt 4
    return {suc:false,msg:"ID号错误"} if !id
    sql = "update so set crr_state=$2 where id=$1"
    await t.callSql reqOpt,sql,[id,val]
    {suc:true,msg:"修改成功"}
  #财务每天已核统计,日期change事件
  acc_dateChg: (reqOpt,val)->
    t = this
    o = t.options
    val += " 00:00:00"
    sql = "select sum(amt)+sum(trust_amt) amt from so where acc_state='已核' and create_time>=$1 and create_time<$2"
    date1 = new Date(val)
    date2 = date1.clone()
    date2.setDate date2.getDate()+1
    date1 = date1.Format "yyyy-MM-dd 00:00:00.0"
    date2 = date2.Format "yyyy-MM-dd 00:00:00.0"
    eny = await t.callOne reqOpt,sql,[date1,date2]
    amt = eny.amt or 0
    {amt:amt}