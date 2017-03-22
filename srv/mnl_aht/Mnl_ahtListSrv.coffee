{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.Mnl_ahtListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "mnl_aht"
  dataGrid: (reqOpt,pgOffset,pgNum,tab)->
    t = this
    o = t.options
    rvObj = await PrnClzz.prototype.dataGrid.apply t,arguments
    tab = tab or o.tab
    tabEd = t.escapeId tab
    #合计金额
    argArr = []
    sql = ""
    sql += "select sum(t.amt) amt_sum from #{tabEd} t"
    sql += await t.dgJoin reqOpt,tabEd,argArr
    sql += await t.srch2Whr reqOpt,argArr,o.seaArr,true
    eny = await t.callOne reqOpt,sql,argArr
    rvObj.amt_sum = eny.amt_sum
    rvObj