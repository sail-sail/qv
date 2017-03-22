{SysSrv} = require "../sys/SysSrv"
{UsrAddSrv} = require "./UsrAddSrv"

PrnClzz = SysSrv
exports.Et_pswSrv = new Class
  Extends: PrnClzz
  options:
    tab: "usr"
    $vdts: ["password"]
  et_psw: (reqOpt,old_psw,psw)->
    t = this
    o = t.options
    usr = t.session.usr
    await t.runAllVdts reqOpt,{psw:psw}
    eny = await t.callOne reqOpt,"select count(id) count from usr where id=$1 and password=$2",[usr.id,old_psw]
    if eny.count is 0
       return {err:"原密码错误,请重新输入!"}
    await t.callSql reqOpt,"update usr set password=$2 where id=$1",[usr.id,psw]
    true
  passwordVdt: (reqOpt,key,val)-> await UsrAddSrv.prototype.passwordVdt.apply this,arguments