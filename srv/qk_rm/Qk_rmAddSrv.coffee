{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.Qk_rmAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "qk_rm"
    $vdts: ["lbl"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  lblVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err: cannot_empty}
    argArr = []
    sql = "select count(id) count from #{o.tab} where #{t.escapeId(key)}=$1"
    argArr.push val
    if o.pgType is "edit"
      argArr.push id
      sql += " and id!=$#{argArr.length}"
    eny = await t.callOne reqOpt,sql,argArr
    if eny.count > 0
      val_exist = await t.getMsg reqOpt,"val_exist",{val:val}
      return {err:val_exist}
    true