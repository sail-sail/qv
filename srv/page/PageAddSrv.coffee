{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.PageAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "page"
    $vdts: ["code"]
  codeVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if val.trim() is ""
      code_can_not_be_empty = await t.getMsg reqOpt,"code_can_not_be_empty"
      return {err:code_can_not_be_empty}
    argArr = []
    sql = "select count(id) count from page where code=$1"
    argArr.push val
    if o.pgType is "edit"
      argArr.push id
      sql += " and id!=$"+argArr.length
    eny = await t.callOne reqOpt,sql,argArr
    if eny.count > 0
      code_val_exist = await t.getMsg reqOpt,"code_val_exist",{val:val}
      return {err:code_val_exist}
    true
  