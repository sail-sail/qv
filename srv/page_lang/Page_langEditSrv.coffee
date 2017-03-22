{Page_langAddSrv} = require "./Page_langAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = Page_langAddSrv
exports.Page_langEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not edit page_lang!"
    rltSet = await t.update reqOpt,entry,keyArr,returning,tab
    rltSet