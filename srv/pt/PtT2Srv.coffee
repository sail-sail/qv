{SysSrv} = require "../sys/SysSrv"

PrnClz = SysSrv
exports.PtT2Srv = new Class
  Extends: PrnClz
  options:
    tab: "pt"
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
    ptListSrv = await t._srvClz "PtT2.pt.PtListSrv||pt.PtListSrv"
    pt_scListSrv = await t._srvClz "PtT2.pt_sc.Pt_scListSrv||pt_sc.Pt_scListSrv"
    pt_scSrch2Whr = pt_scListSrv.srch2Whr
    pt_scListSrv.srch2Whr = (reqOpt,argArr,seaArr,isWhr,whr)->
      if !o.sld_eny or !o.sld_eny.id
        errMsg = new String "请先选择一行"
        errMsg.is_out = true
        throw errMsg
      argArr.push o.sld_eny.id
      whr = whr or " "
      if isWhr
        whr += "\nwhere "
        isWhr = false
      whr += " t.pt_id=$#{argArr.length}"
      whr = await pt_scSrch2Whr.apply this,[reqOpt,argArr,seaArr,isWhr,whr]
      whr
    #级联删除
    ptDelById = ptListSrv.delById
    ptListSrv.delById = (reqOpt,id,tab)->
      rltSet = await ptDelById.apply this,arguments
      sql = "delete from pt_sc where pt_id=$1"
      await t.callSql reqOpt,sql,[id]
      rltSet
    return
  #父页面选中一行时,给子页面增加筛选条件
  prn_trSld: (reqOpt,sld_eny)->
    t = this
    o = t.options
    ptListSrv = await t._srvClz "PtT2.pt.PtListSrv||pt.PtListSrv"
    o.sld_eny = await ptListSrv.findById reqOpt,sld_eny.id
    return
      