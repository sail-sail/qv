{UsrAddSrv} = require "./UsrAddSrv"
fsAsync = require "fsAsync"
{SysEditSrv} = require "../sys/SysEditSrv"

PrnClzz = UsrAddSrv
exports.UsrEditSrv = new Class
  Extends: PrnClzz
  Implements:[SysEditSrv]
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    usr = t.session.usr
    #admin不允许修改编码
    if eny.id is 1
      keyArr.erase "code"
    eny.acc_img = await t.uid2buf4pg reqOpt,eny.acc_img
    eny.img = await t.uid2buf4pg reqOpt,eny.img
    rltSet = await t.update reqOpt,eny,keyArr,returning,tab
    if usr.id is eny.id
      t.session.usr = await t.callOne reqOpt,"select * from usr where id=$1",[usr.id]
    rltSet