{SysEdit} = require "/sys/SysEdit"
{PageAdd} = require "/page/PageAdd"

PrnClzz = PageAdd
exports.PageEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  