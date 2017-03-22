{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.CourierListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "courier"
  