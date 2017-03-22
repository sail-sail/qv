
exports.SysEditSrv = new Class
  options:
    pgType: "edit"
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.update reqOpt,entry,keyArr,returning,tab
    rltSet