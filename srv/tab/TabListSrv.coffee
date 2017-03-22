{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.TabListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "tab"
  