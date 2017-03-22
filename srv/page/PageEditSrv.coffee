{PageAddSrv} = require "./PageAddSrv"
{SysEditSrv} = require "../sys/SysEditSrv"

exports.PageEditSrv = new Class
  Extends: PageAddSrv
  Implements: [SysEditSrv]
  