{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.LogAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Log"
    headArr: ["pg","usr","ip","act","bef","aft","keys","head_obj","rem","create_time"]
    headObj:
      "pg":"页面"
      "usr":"用户"
      "ip":"IP地址"
      "act":"操作"
      "bef":"操作前"
      "aft":"操作后"
      "keys":"简介"
      "head_obj":"头部描述"
      "rem":"备注"
      "create_time":"创建时间"
      