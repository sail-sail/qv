{SysList} = require "../sys/SysList"

#退货列表
PrnClzz = SysList
exports.Rn_gdList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Rn_gd"
    headArr: ["so_id","usr_id","so_create_time","so_amt","so_trust_amt","amt","create_time","create_usr","rem"]
    headObj:
      "so_id":"快递单号"
      "usr_id":"客服"
      "amt":"金额"
      "create_time":"创建时间"
      "create_usr":"创建人"
      "rem":"备注"
      "so_create_time":"订单时间"
      "so_amt":"订单金额"
      "so_trust_amt":"订单代收"
  initPg: ->
    t = this
    await SysList.prototype.initPg.apply t,arguments
    