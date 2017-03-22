{SysListSrv} = require "../sys/SysListSrv"

PrnClzz = SysListSrv
exports.RoleListSrv = new Class
  Extends: PrnClzz
  options:
    tab: "role"
  