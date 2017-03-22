{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.MsgListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "msg"
  