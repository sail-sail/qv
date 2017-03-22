{SysSrv} = require "../sys/SysSrv"
fsAsync = require "fsAsync"

exports.UsrAddSrv = new Class
  Extends: SysSrv
  options:
    tab: "usr"
    $vdts: ["code","password","prn_id","role_id"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    #非管理员不允许增加用户
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not add user!"
    eny.acc_img = await t.uid2buf4pg reqOpt,eny.acc_img
    eny.img = await t.uid2buf4pg reqOpt,eny.img
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    if eny.hasOwnProperty "prn_id"
      if String.isEmpty eny.prn_id
        eny.prn_id = 0
      else
        eny.prn_id = await t.lblSetVal reqOpt,eny.prn_id,"lbl","id","usr"
    if eny.hasOwnProperty "role_id"
      if String.isEmpty eny.role_id
        eny.role_id = 0
      else
        eny.role_id = await t.lblSetVal reqOpt,eny.role_id,"lbl","id","role"
    return
  codeVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    if val.trim() is ""
      username_cannot_empty = await t.getMsg reqOpt,"username_cannot_empty"
      return {err:username_cannot_empty}
    argArr = []
    sql = "select count(t.id) count from usr t where t.code=$1"
    argArr.push val
    if o.pgType is "edit"
      argArr.push id
      sql += " and id!=$"+argArr.length
    eny = await t.callOne reqOpt,sql,argArr
    if eny.count > 0
      username_val_exist = await t.getMsg reqOpt,"username_val_exist",{val:val}
      return {err:username_val_exist}
    true
  passwordVdt: (reqOpt,key,val)->
    t = this
    o = t.options
    valTrim = val.trim()
    if valTrim is ""
      password_cannot_empty = await t.getMsg reqOpt,"password_cannot_empty"
      return {err:password_cannot_empty}
    if valTrim.length > 12 or valTrim.length < 6
      password_must_6_12_length = await t.getMsg reqOpt,"password_must_6_12_length"
      return {err:password_must_6_12_length}
    true
  treeRoot: (reqOpt,tab)->
    t = this
    o = t.options
    sql = """
    select t.*
    from usr t
    where 
      t.role_id=1
    """
    rltSet = await t.callArr reqOpt,sql
    rltSet
  prn_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    return true if String.isEmpty val
    sql = "select count(t.id) count from usr t where t.lbl=$1"
    eny = await t.callOne reqOpt,sql,[val]
    if eny.count is 0
      return {err:"#{val} 不存在!"}
    true
  role_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    return true if String.isEmpty val
    sql = "select count(t.id) count from role t where t.lbl=$1"
    eny = await t.callOne reqOpt,sql,[val]
    if eny.count is 0
      return {err:"#{val} 不存在!"}
    true
