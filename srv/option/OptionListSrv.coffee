{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.OptionListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "option"
  