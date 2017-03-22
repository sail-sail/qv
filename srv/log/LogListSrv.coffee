{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.LogListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "log"
  