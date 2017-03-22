{SoAddSrv} = require "./SoAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = SoAddSrv
exports.SoEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    #修改前
    bef_sql = """
    select t.*
      ,u.code usr_id 
    from #{o.tab} t 
    left join usr u 
      on u.id=t.usr_id 
    where t.id=$1
    """
    befEny = await t.callOne reqOpt,bef_sql,[eny.id]
    keyArr = keyArr or []
    keyArr.push "update_usr" if !keyArr.contains "update_usr"
    eny.update_usr = usr.code
    if eny.cm_nm and keyArr.contains "cm_nm"
      eny.cm_nm = String(eny.cm_nm).trim()
    if eny.mbp and keyArr.contains "mbp"
      eny.mbp = String(eny.mbp).trim()
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    #续单
    eny2 = await t.callOne reqOpt,"select * from so where id=$1",[eny.id]
    xudanObj = await t.callOne reqOpt,"select count(id) count from so where id<$1 and mbp=$2",[eny2.id,eny2.mbp]
    xudan = xudanObj.count > 0
    await t.callSql reqOpt,"update so set xudan=$1 where id=$2",[xudan,eny2.id]
    #修改后
    aftEny = await t.callOne reqOpt,bef_sql,[eny.id]
    await t.log reqOpt,{pg:"SoEdit",act:"修改",bef:befEny,aft:aftEny,keys:["cr_no","usr_id","cm_nm"],head_obj:["../so/SoList","SoList.prototype.options.headObj"]}
    rltSet