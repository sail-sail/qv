{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.Pt_scAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "Pt_sc"
    headArr: ["pt_id","lbl","qty","min_qty","max_qty","sort_num","rem"]
    headObj:
      "pt_id":"产品"
      "lbl":"规格"
      "qty":"库存数量"
      "min_qty":"最低库存"
      "max_qty":"最高库存"
      "sort_num":"排序"
      "rem":"备注"
  