{SysSrv} = require "../sys/SysSrv"

PrnClz = SysSrv
exports.SoT2Srv = new Class
  Extends: PrnClz
  options:
    tab: "so"
    sld_eny: {}
  onDraw: ->
    t = this
    rvObj = await PrnClz.prototype.onDraw.apply t,arguments
    await t.hInclude()
    rvObj
  "@hInclude":{_private:true}
  hInclude: ->
    t = this
    o = t.options
    return if !t._srvClz
    soListSrv = await t._srvClz "SoT2.so.SoListSrv||so.SoListSrv"
    sodListSrv = await t._srvClz "SoT2.sod.SodListSrv||sod.SodListSrv"
    sodSrch2Whr = sodListSrv.srch2Whr
    sodListSrv.srch2Whr = (reqOpt,argArr,seaArr,isWhr,whr)->
      if !o.sld_eny or !o.sld_eny.id
        errMsg = new String "请先选择一行"
        errMsg.is_out = true
        throw errMsg
      argArr.push o.sld_eny.id
      whr = whr or " "
      if isWhr
        whr += "\nwhere "
        isWhr = false
      whr += " t.so_id=$#{argArr.length}"
      whr = await sodSrch2Whr.apply this,[reqOpt,argArr,seaArr,isWhr,whr]
      whr
    #级联删除
    soDelById = soListSrv.delById
    soListSrv.delById = (reqOpt,id,tab)->
      rltSet = await soDelById.apply this,arguments
      sql = "delete from sod where so_id=$1"
      await t.callSql reqOpt,sql,[id]
      rltSet
    return
  #父页面选中一行时,给子页面增加筛选条件
  prn_trSld: (reqOpt,sld_eny)->
    t = this
    o = t.options
    soListSrv = await t._srvClz "SoT2.so.SoListSrv||so.SoListSrv"
    o.sld_eny = {} if !sld_eny or !sld_eny.id
    o.sld_eny = await soListSrv.findById reqOpt,sld_eny.id
    return
      