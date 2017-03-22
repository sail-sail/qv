{SysSrv} = require "../sys/SysSrv"

exports.Menu_langAddSrv = new Class
  Extends: SysSrv
  options:
    tab: "menu_lang"
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,entry,keyArr,returning,tab)->
    t = this
    o = t.options
    usr = t.session.usr
    if usr.code isnt "admin"
      throw new Error "The #{usr.code} can not add menu_lang!"
    rltSet = await t.saveAddClk reqOpt,entry,keyArr,returning,tab
    rltSet
    