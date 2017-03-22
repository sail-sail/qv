{SysList} = require "../sys/SysList"

#手工业绩列表
PrnClzz = SysList
exports.Mnl_ahtList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Mnl_aht"
    headArr: ["tme","amt","rem"]
    headObj:
      "tme":"时间"
      "amt":"金额"
      "rem":"备注"
    #合计金额
    amt_sum: 0
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  rltSetGrid: (pgOffset,pgNum)->
    t = this
    o = t.options
    rvObj = await PrnClzz.prototype.rltSetGrid.apply t,arguments
    o.amt_sum = Number rvObj.amt_sum
    rvObj
  initTd: (tr,key,eny2)->
    t = this
    o = t.options
    td = undefined
    if key is "tme"
      eny = tr.retrieve "eny"
      eny2 = eny
      if eny.tme
        val = new Date eny.tme
        val = val.Format "yyyy-MM-dd"
        eny2 = Object.clone eny2
        eny2.tme = val
      td = PrnClzz.prototype.initTd.apply t,[tr,key,eny2]
      td.inject tr
    else
      td = PrnClzz.prototype.initTd.apply t,arguments
    td