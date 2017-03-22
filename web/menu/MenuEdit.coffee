require "/menu/MenuEdit.css"
{SysEdit} = require "/sys/SysEdit"
{MenuAdd} = require "/menu/MenuAdd"

PrnClzz = MenuAdd
exports.MenuEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  