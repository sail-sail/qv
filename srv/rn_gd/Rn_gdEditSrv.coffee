{Rn_gdAddSrv} = require "./Rn_gdAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = Rn_gdAddSrv
exports.Rn_gdEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    #旧的so_id更新为已发货
    if keyArr.contains "so_id"
      enyTmp = await t.callOne reqOpt,"select so_id from rn_gd where id=$1",[eny.id]
      await t.callSql reqOpt,"update so set state='已发货' where id=$1",[enyTmp.so_id] if enyTmp
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    #新的so_id更新为已退货
    if keyArr.contains "so_id"
      await t.callSql reqOpt,"update so set state='已退货' where id=$1",[eny.so_id]
    rltSet