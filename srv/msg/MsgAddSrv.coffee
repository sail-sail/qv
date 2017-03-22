{SysSrv} = require "../sys/SysSrv"

exports.MsgAddSrv = new Class
  Extends: SysSrv
  options:
    tab: "msg"
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not add msg!"
    rltSet = await t.saveAddClk reqOpt,entry,keyArr,returning,tab
    rltSet
  