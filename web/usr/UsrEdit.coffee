{SysEdit} = require "../sys/SysEdit"
{UsrAdd} = require "./UsrAdd"
{Srv} = require "Srv"

PrnClzz = UsrAdd
exports.UsrEdit = new Class
  Extends: PrnClzz
  Implements: [SysEdit]
  PrnClzz: PrnClzz
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
    return