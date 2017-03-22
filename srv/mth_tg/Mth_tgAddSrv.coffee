{SysSrv} = require "../sys/SysSrv"

PrnClzz = SysSrv
exports.Mth_tgAddSrv = new Class
  Extends: PrnClzz
  options:
    tab: "mth_tg"
    $vdts: ["usr_id"]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    eny.usr_id = await t.lblSetVal reqOpt,eny.usr_id,"code","id","usr" if eny.hasOwnProperty "usr_id"
    return
  usr_idVdt: (reqOpt,key,val,id)->
    t = this
    o = t.options
    sql = """
    select count(t.id) count
    from usr t
    where t.code=@val
    """
    eny = await t.callOne reqOpt,sql,{val:val}
    if eny.count is 0
      return {err:"客服 #{val} 不存在!"}
    true