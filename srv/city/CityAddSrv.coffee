{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.CityAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "city"
    $vdts: ["lbl"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    eny.provin_id = await t.lblSetVal reqOpt,eny.provin_id,"lbl","id","provin" if eny.hasOwnProperty "provin_id"
    return
  lblVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if String.isEmpty val
      cannot_empty = await t.getMsg reqOpt,"cannot_empty"
      return {err:cannot_empty}
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
  initProvin_id: (reqOpt)->
    t = this
    rltSet = await t.callArr reqOpt,"select * from provin order by id asc"
    rltSet