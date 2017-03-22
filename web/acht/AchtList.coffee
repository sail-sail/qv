require "./AchtList.css"
{SysList} = require "../sys/SysList"

#业绩列表
PrnClzz = SysList
exports.AchtList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Acht"
    headArr: ["usr","count","xindan","xudan","amt","wechat","alipay","trust_amt","icbc","postal","arrear","rn_gd"]
    headObj:
      "usr":"客服"
      "cm_nm":"客户"
      "count":"总单数"
      "xindan":"新单数"
      "xudan":"续单数"
      "amt":"总金额"
      "wechat":"微信(明细)"
      "alipay":"支付宝(明细)"
      "trust_amt":"代收(明细)"
      "icbc":"建行(明细)"
      "postal":"邮政(明细)"
      "arrear":"欠款(明细)"
      "rn_gd":"退货(明细)"
      "create_time":"创建时间"
    eny2: {}
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    if o.usr.code is "admin"
      t.initUsr1Arr()
    srch_but1 = elt.getE ".srch_but1"
    srch_but1.addEvent "click",->
      await t.srch_but1Clk this
      return
    rvObj
  #点击查询
  srch_but1Clk: (but)->
    t = this
    o = t.options
    elt = o.ele
    
    #删除所有查询条件
    srch_itemArrEl = elt.getE ".srch_itemArr"
    if srch_itemArrEl
      srch_itemArr = srch_itemArrEl.getEs ".srch_item"
      await t.srch_itemClk srch_item for srch_item in srch_itemArr
    
    begin_dateEl = elt.getE ".begin_date"
    end_dateEl = elt.getE ".end_date"
    begin_dateVal = begin_dateEl.get "value"
    if begin_dateVal
      seaObj = {andOr:"and",name:"t.create_time",opt:">=",value:begin_dateVal}
      seaObj.andOrLbl = "并且"
      seaObj.nameLbl = "创建时间"
      seaObj.optLbl = "大于等于"
      await t.srchAdd seaObj
    end_dateVal = end_dateEl.get "value"
    if end_dateVal
      seaObj = {andOr:"and",name:"t.create_time",opt:"<",value:end_dateVal}
      seaObj.andOrLbl = "并且"
      seaObj.nameLbl = "创建时间"
      seaObj.optLbl = "小于"
      await t.srchAdd seaObj
    
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    return
  initUsr1Arr: ->
    t = this
    o = t.options
    elt = o.ele
    usr1_div = elt.getE ".usr1_div"
    usr1_div.destroyChd()
    usr1Arr = o.pg_rltSet.usr1Arr
    for eny in usr1Arr
      but = new Element "button.usr1_but",{text:eny.code}
      but.store "eny",eny
      but.inject usr1_div
      but.addEvent "click",->
        await t.usr1ButClk this
        return
    return
  usr1ButClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    usr1_div = but.getParent ".usr1_div"
    eny = but.retrieve "eny"
    sltd = false
    sltdStr = "usr1But_sltd"
    if but.hasClass sltdStr
      sltd = false
      await o.thisSrv.ajax "usr1ButClk",[eny.id,sltd]
      but.removeClass sltdStr
    else
      sltd = true
      usr1_div.getEs(".usr1_but").removeClass sltdStr
      but.addClass sltdStr
      await o.thisSrv.ajax "usr1ButClk",[eny.id,sltd]
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    return
  rltSetGrid: (pgOffset,pgNum)->
    t = this
    o = t.options
    rvObj = await PrnClzz.prototype.rltSetGrid.apply t,arguments
    o.eny2 = rvObj.eny2
    rvObj
  initTd: (tr,key)->
    t = this
    o = t.options
    eny = tr.retrieve "eny"
    td = PrnClzz.prototype.initTd.apply t,arguments
    if eny["-eny_tt"]
      td.setStyle "color","red"
      return td
    if key is "usr"
      td.addEvent "click",->
        await t.usr_tdClk this
        return
    td
  usr_tdClk: (td)->
    t = this
    o = t.options
    body = document.body
    bodyWg = body.wg()
    main_tabbox = body.getE ".main_tabbox"
    oldWin = main_tabbox.getE "[h:pg='SoT2']"
    if oldWin
      oldWinWg = oldWin.wg()
      tabWg = oldWinWg.getTabWg()
      await oldWinWg.closePage()
      tabWg.deleteTab()
    tr = td.getParent "tr"
    eny = tr.retrieve "eny"
    befOnDraw = ->
      this.store "frtDtGrid",false
      return
    win = await bodyWg.menuClkByPg td,eny,"SoT2","tab",{befOnDraw:befOnDraw}
    prnWin = win.getE "[h:pg]"
    prnWinWg = prnWin.wg()
    seaObj = undefined
    #组长
    if o.usr._role.id is 1
      seaObj = {andOr:"and",name:"u2.code",opt:"=",value:eny.usr}
    else
      seaObj = {andOr:"and",name:"u.code",opt:"=",value:eny.usr}
    seaObj.andOrLbl = "并且"
    seaObj.nameLbl = "客服"
    seaObj.optLbl = "等于"
    await prnWinWg.srchAdd seaObj
    await prnWinWg.dataCount()
    await prnWinWg.cur_pgChg true
    await prnWinWg.trSldFrt()
    return
  dataGrid: (pgOffset,pgNum)->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    tbody = grid_tbl.getFirst "tbody"
    rltObj = await t.rltSetGrid pgOffset,pgNum
    t.emptyGrid()
    return if !rltObj or !rltObj.rltSet
    rltSet = rltObj.rltSet
    eny_tt = {"-eny_tt":true,usr:"合计:",wechat:0,alipay:0,trust_amt:0,icbc:0,postal:0,arrear:0,rn_gd:0}
    for i in [0...rltSet.length]
      eny = rltSet[i]
      eny_tt.wechat += eny.wechat
      eny_tt.alipay += eny.alipay
      eny_tt.trust_amt += eny.trust_amt
      eny_tt.icbc += eny.icbc
      eny_tt.postal += eny.postal
      eny_tt.arrear += eny.arrear
      eny_tt.rn_gd += eny.rn_gd
      t.initTr eny,tbody
    t.initTr eny_tt,tbody
    return
  