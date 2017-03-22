{TabAddSrv} = require "./TabAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

exports.TabEditSrv = new Class
  Extends: TabAddSrv
  Implements: [SysEditSrv]
  