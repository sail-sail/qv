{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.Pay_typeListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "pay_type"
  