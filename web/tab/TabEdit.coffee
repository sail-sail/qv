{SysEdit} = require "/sys/SysEdit"
{TabAdd} = require "/tab/TabAdd"

PrnClzz = TabAdd
exports.TabEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  