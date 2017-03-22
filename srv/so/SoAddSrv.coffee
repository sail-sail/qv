{SysSrv} = require "../sys/SysSrv"
{Pt_scListSrv} = require "../pt_sc/Pt_scListSrv"

PrnClzz = SysSrv
exports.SoAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "so"
    $vdts: ["mbp","addr","courier_id","pay_type_id"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    eny = eny or {}
    keyArr = keyArr or []
    keyArr.push "usr_id" if !keyArr.contains "usr_id"
    keyArr.push "create_usr" if !keyArr.contains "create_usr"
    eny.usr_id = usr.id
    eny.create_usr = usr.code
    #快捷备注
    eny.rem = eny.rem or ""
    sodArr = eny.sodArr
    if sodArr and sodArr.length
      remPix = ""
      for sodEny in sodArr
        continue if Number(sodEny.qty) <= 0
        enyPsc = await t.callOne reqOpt,"select lbl from pt_sc where id=@pt_sc_id",sodEny
        remPix += sodEny.qty+"*"+enyPsc.lbl+" "
      eny.rem = remPix+eny.rem
    #客户,电话 去除两边空格
    if eny.cm_nm and keyArr.contains "cm_nm"
      eny.cm_nm = String(eny.cm_nm).trim()
    if eny.mbp and keyArr.contains "mbp"
      eny.mbp = String(eny.mbp).trim()
    #欠款
    if eny.qk and keyArr.contains "qk"
      eny.cr_no = "qk"
      keyArr.push "cr_no" if !keyArr.contains "cr_no"
      eny.state = "已发货"
      keyArr.push "state" if !keyArr.contains "state"
    else
      pay_typeEny = await t.callOne reqOpt,"select * from pay_type where lbl=$1",[eny.pay_type_id]
      if pay_typeEny and pay_typeEny.lbl is "欠款"
        eny.cr_no = "qk"
        keyArr.push "cr_no" if !keyArr.contains "cr_no"
        eny.state = "已发货"
        keyArr.push "state" if !keyArr.contains "state"
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,"*",tab
    #续单
    xudanObj = await t.callOne reqOpt,"select count(id) count from so where id<$1 and mbp=$2",[rltSet[0].id,rltSet[0].mbp]
    xudan = xudanObj.count > 0
    await t.callSql reqOpt,"update so set xudan=$1 where id=$2",[xudan,rltSet[0].id]
    if sodArr and sodArr.length
      #减去产品库存
      num = 0
      for sodEny in sodArr
        continue if Number(sodEny.qty) <= 0
        num += Number sodEny.qty
      await Pt_scListSrv.prototype.lessQty.apply t,[reqOpt,{id:sodEny.pt_sc_id,num:num}] if num > 0
      
      sql = "insert into sod(so_id,pt_id,pt_sc_id,qty) values (@so_id,@pt_id,@pt_sc_id,@qty)"
      for sodEny in sodArr
        continue if Number(sodEny.qty) <= 0
        sodEny.so_id = rltSet[0].id
        await t.callSql reqOpt,sql,sodEny
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    eny.courier_id = await t.lblSetVal reqOpt,eny.courier_id,"lbl","id","courier" if eny.hasOwnProperty "courier_id"
    eny.pay_type_id = await t.lblSetVal reqOpt,eny.pay_type_id,"lbl","id","pay_type" if eny.hasOwnProperty "pay_type_id"
    return
  mbpVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:cannot_empty}
    if String(val).length isnt 11
      return {err:"必须是有效的11位号码!"}
    true
  addrVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:cannot_empty}
    true
  courier_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:cannot_empty}
    sql = """
    select count(t.id) count
    from courier t
    where t.lbl=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"#{val} 不存在!"}
    true
  pay_type_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:cannot_empty}
    sql = """
    select count(t.id) count
    from pay_type t
    where t.lbl=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"#{val} 不存在!"}
    true
  initCourier_id: (reqOpt)->
    t = this
    rltSet = await t.callArr reqOpt,"select * from courier order by id asc"
    rltSet
  initPay_type_id: (reqOpt)->
    t = this
    rltSet = await t.callArr reqOpt,"select * from pay_type order by id asc"
    rltSet
  initPt_id: (reqOpt)->
    t = this
    rltSet = await t.callArr reqOpt,"select * from pt order by id asc"
    rltSet
  initPt_sc_id: (reqOpt,pt_idVal)->
    t = this
    pt_idVal = Number pt_idVal
    pt_idVal = pt_idVal or 0
    rltSet = await t.callArr reqOpt,"select * from pt_sc where pt_id=@pt_idVal order by sort_num asc",{pt_idVal:pt_idVal}
    rltSet
  initQk_rm: (reqOpt)->
    t = this
    rltSet = await t.callArr reqOpt,"select * from qk_rm order by sort_num asc"
    rltSet
  