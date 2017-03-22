{SysSrv} = require "../sys/SysSrv"

###
do $$
	var plan = plv8.prepare("select id from so where state='已发货'");
	var cursor = plan.cursor();
	try {
		while(eny = cursor.fetch()) {
			var count = plv8.execute("select count(id) count from rn_gd where so_id=$1",[eny.id])[0].count;
			if(count === 0) continue;
			plv8.execute("update so set state='已退货' where id=$1",[eny.id]);
		}
	} finally {
		cursor.close();
    	plan.free();
	}
$$ language plv8;
###
PrnClzz = SysSrv
exports.Rn_gdAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "rn_gd"
    $vdts: ["so_id"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    eny = eny or {}
    keyArr.push "create_usr" if !keyArr.contains "create_usr"
    eny.create_usr = usr.code
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    #已退货
    await t.callSql reqOpt,"update so set state='已退货' where id=$1",[eny.so_id]
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    eny.so_id = await t.lblSetVal reqOpt,eny.so_id,"cr_no","id","so" if eny.hasOwnProperty "so_id"
    return
  so_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:"快递单号#{cannot_empty}"}
    sql = """
    select count(t.id) count
    from so t
    where t.cr_no=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"此快递单号在订单中 #{val} 不存在!"}
    if o.pgType is "add"
      sql = "select count(t.id) count from rn_gd t left join so s on t.so_id=s.id where s.cr_no=$1"
      eny = await t.callOne reqOpt,sql,[val]
      if eny.count > 0
        return {err:"此快递单号 #{val} 已经存在!"}
    true