{LangAddSrv} = require "./LangAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = LangAddSrv
exports.LangEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not edit lang!"
    rltSet = await t.update reqOpt,entry,keyArr,returning,tab
    rltSet