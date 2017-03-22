require "./Cus_sttList.css"
{SysList} = require "../sys/SysList"

#客户统计
PrnClzz = SysList
exports.Cus_sttList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Cus_stt"
    headArr: ["dt","usr_id","mrn","aft","ngt","no_rpy","black","efft","intt","bill","tt_nm","cnv_rt"]
    headObj:
      "dt":"日期"
      "usr_id":"客服"
      "mrn":"早上"
      "aft":"下午"
      "ngt":"晚上"
      "no_rpy":"不回复"
      "black":"拉黑"
      "efft":"有效"
      "intt":"意向"
      "bill":"开单"
      "tt_nm":"总人数"
      "cnv_rt":"转化率"
  initPg: ->
    t = this
    o = t.options
    t.initKhsjtj_div()
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    if o.usr.code is "admin"
      t.initUsr1Arr()
    rvObj
  #修改按钮
  initOptEdit: (optTd)->
  initKhsjtj_div: ->
    t = this
    o = t.options
    elt = o.ele
    t.initSjdxz()
    khsjtj_div = elt.getE ".khsjtj_div"
    #添加
    khsj_but = khsjtj_div.getE "[h:but=khsj_but]"
    khsj_but.addEvent "click",->
      await t.khsj_butClk this
      return
    return
  #点击添加
  khsj_butClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    but.set "disabled",true
    khsjtj_div = elt.getE ".khsjtj_div"
    #加人数
    jrs = khsjtj_div.getE ".jrs"
    #时间段选择
    sjdxz = khsjtj_div.getE ".sjdxz"
    jrsVal = Number jrs.get "value"
    sjdxzVal = sjdxz.get "value"
    if jrsVal < 0
      ncWg.addNotice "error","加人数 必须大于等于0!",5
      return
    rltObj= await o.thisSrv.ajax "khsj_butClk",[jrsVal,sjdxzVal]
    if rltObj and rltObj.str
      ncWg.addNotice "info",rltObj.str,3
    jrs.set "value",0
    #强制刷新表格到第一页
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    num = 10
    but.set "text","添加 #{num}"
    but.setStyle "color","gray"
    inter = setInterval(->
      num--
      if num <= 0
        clearInterval inter
        but.set "disabled",false
        but.setStyle "color","blue"
        but.set "text","添加"
        return
      but.set "text","添加 #{num}"
      return
    ,1000)
    return
  initTd: (tr,key,eny)->
    t = this
    o = t.options
    td = new Element "td"
    td.inject tr
    eny = eny or tr.retrieve "eny"
    val = eny[key]
    if key is "dt"
      val = (Date.fromISO(val)).Format "yyyy-MM-dd"
      td.set "text",val
    else if key is "cnv_rt"
      val = (val*100).round(2)+"%"
      td.set "text",val
    else if key is "no_rpy"
      td.setStyle "position","relative"
      input = new Element "input[type='number'].ipt_no_rpy"
      input.setStyles {width:"100%","border":"none","position":"absolute",top:0,left:0,bottom:0}
      input.set "value",val
      input.addEvent "change",->
        await t.no_rpyChg this
        return
      input.addEvent "focus",->
        this.selectRange 0,this.get("value").length
        return
      input.inject td
    else if key is "black"
      td.setStyle "position","relative"
      input = new Element "input[type='number'].ipt_black"
      input.setStyles {width:"100%","border":"none","position":"absolute",top:0,left:0,bottom:0}
      input.set "value",val
      input.addEvent "change",->
        await t.blackChg this
        return
      input.addEvent "focus",->
        this.selectRange 0,this.get("value").length
        return
      input.inject td
    else if key is "efft"
      td.setStyle "position","relative"
      input = new Element "input[type='number'].ipt_efft"
      input.setStyles {width:"100%","border":"none","position":"absolute",top:0,left:0,bottom:0}
      input.set "value",val
      input.addEvent "change",->
        await t.efftChg this
        return
      input.addEvent "focus",->
        this.selectRange 0,this.get("value").length
        return
      input.inject td
    else if key is "intt"
      td.setStyle "position","relative"
      input = new Element "input[type='number'].ipt_intt"
      input.setStyles {width:"100%","border":"none","position":"absolute",top:0,left:0,bottom:0}
      input.set "value",val
      input.addEvent "change",->
        await t.inttChg this
        return
      input.addEvent "focus",->
        this.selectRange 0,this.get("value").length
        return
      input.inject td
    else if key is "bill"
      td.setStyle "position","relative"
      input = new Element "input[type='number'].ipt_bill"
      input.setStyles {width:"100%","border":"none","position":"absolute",top:0,left:0,bottom:0}
      input.set "value",val
      input.addEvent "change",->
        await t.billChg this
        return
      input.addEvent "focus",->
        this.selectRange 0,this.get("value").length
        return
      input.inject td
    else
      td.set "text",val
    td.addClass "initTd_#{key}"
    td
  #不回复
  no_rpyChg: (iez)->
    t = this
    o = t.options
    tr = iez.getParent "tr"
    eny = tr.retrieve "eny"
    val = iez.get "value"
    rltObj = await o.thisSrv.ajax "no_rpyChg",[eny.id,val]
    ncWg.addNotice "info",rltObj.info,2 if rltObj and rltObj.info
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    return
  #拉黑
  blackChg: (iez)->
    t = this
    o = t.options
    tr = iez.getParent "tr"
    eny = tr.retrieve "eny"
    val = iez.get "value"
    rltObj = await o.thisSrv.ajax "blackChg",[eny.id,val]
    ncWg.addNotice "info",rltObj.info,2 if rltObj and rltObj.info
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    return
  #有效
  efftChg: (iez)->
    t = this
    o = t.options
    tr = iez.getParent "tr"
    eny = tr.retrieve "eny"
    val = iez.get "value"
    rltObj = await o.thisSrv.ajax "efftChg",[eny.id,val]
    ncWg.addNotice "info",rltObj.info,2 if rltObj and rltObj.info
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    return
  #意向
  inttChg: (iez)->
    t = this
    o = t.options
    tr = iez.getParent "tr"
    eny = tr.retrieve "eny"
    val = iez.get "value"
    rltObj = await o.thisSrv.ajax "inttChg",[eny.id,val]
    ncWg.addNotice "info",rltObj.info,2 if rltObj and rltObj.info
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    return
  #开单
  billChg: (iez)->
    t = this
    o = t.options
    tr = iez.getParent "tr"
    eny = tr.retrieve "eny"
    val = iez.get "value"
    rltObj = await o.thisSrv.ajax "billChg",[eny.id,val]
    ncWg.addNotice "info",rltObj.info,2 if rltObj and rltObj.info
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    return
  #初始化时间段
  initSjdxz: (sjdxz)->
    t = this
    o = t.options
    elt = o.ele
    khsjtj_div = elt.getE ".khsjtj_div"
    sjdxz = khsjtj_div.getE ".sjdxz"
    date = new Date()
    hour = date.getHours()
    if hour <= 3 or hour >= 18
      sjdxz.set "value","ngt"
    else if hour > 3 and hour <= 12
      sjdxz.set "value","mrn"
    else if hour > 12 and hour < 18
      sjdxz.set "value","aft"
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
  #合计
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
    for i in [0...rltSet.length]
      eny = rltSet[i]
      t.initTr eny,tbody
    #合计
    enyTt = rltObj.enyTt
    tr = new Element "tr"
    tr.inject tbody
    td = new Element "td",{text:"合计:",colspan:3}
    td.setStyles {color:"blue"}
    td.inject tr
    enyTt.cnv_rt = (enyTt.cnv_rt*100).round(2)+"%"
    for key in ["mrn","aft","ngt","no_rpy","black","efft","intt","bill","tt_nm","cnv_rt"]
      td = new Element "td",{text:enyTt[key]}
      td.setStyles {color:"red"}
      td.inject tr
    return