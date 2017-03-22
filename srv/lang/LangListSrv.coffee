{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.LangListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "lang"
  