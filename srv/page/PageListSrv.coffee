{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.PageListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "page"
  