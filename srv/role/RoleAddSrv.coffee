{SysSrv} = require "../sys/SysSrv"

exports.RoleAddSrv = new Class
  Extends: SysSrv
  options:
    tab: "role"
    $vdts: ["lbl"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not add!"
    rltSet = await t.saveAddClk reqOpt,entry,keyArr,returning,tab
    rltSet
  lblVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if val.trim() is ""
      can_not_be_empty = await t.getMsg reqOpt,"can_not_be_empty"
      return {err:can_not_be_empty}
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