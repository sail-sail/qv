{MsgAddSrv} = require "./MsgAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = MsgAddSrv
exports.MsgEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not edit msg!"
    rltSet = await t.update reqOpt,entry,keyArr,returning,tab
    rltSet