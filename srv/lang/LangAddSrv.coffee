{SysSrv} = require "../sys/SysSrv"

exports.LangAddSrv = new Class
  Extends: SysSrv
  options:
    tab: "lang"
    $vdts: ["code"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not add lang!"
    rltSet = await t.saveAddClk reqOpt,entry,keyArr,returning,tab
    rltSet
  codeVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if val.trim() is ""
      code_can_not_be_empty = await t.getMsg reqOpt,"code_can_not_be_empty"
      return {err:code_can_not_be_empty}
    argArr = []
    sql = "select count(id) count from lang where code=$1"
    argArr.push val
    if o.pgType is "edit"
      argArr.push id
      sql += " and id!=$"+argArr.length
    eny = await t.callOne reqOpt,sql,argArr
    if eny.count > 0
      code_val_exist = await t.getMsg reqOpt,"code_val_exist",{val:val}
      return {err:code_val_exist}
    true