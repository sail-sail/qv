{SysList} = require "/sys/SysList"

PrnClzz = SysList
#表列表
exports.TabList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Tab"
    headArr: ["code","lbl","is_log","create_time","rem"]
    headObj:
      "code":"表"
      "lbl":"标签"
      "is_log":"记录日志"
      "create_time":"创建时间"
      "rem":"备注"
  