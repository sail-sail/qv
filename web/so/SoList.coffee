require "./SoList.css"
{SysList} = require "../sys/SysList"

#订单列表
PrnClzz = SysList
exports.SoList = new Class
  Extends: PrnClzz
  options:
    enyStr: "So"
    headArr: ["acc_state","crr_state","cr_no","state","usr_id","cm_nm","courier_id","pay_type_id","amt","trust_amt","mbp","_sodEnyArr","addr","create_time","create_usr","rem"]
    headObj:
      "id":"编号"
      "acc_state":"财务"
      "crr_state":"快递"
      "cr_no":"快递单号"
      "state":"状态"
      "usr_id":"客服"
      "cm_nm":"客户"
      "courier_id":"快递"
      "pay_type_id":"付款"
      "amt":"金额"
      "trust_amt":"代收"
      "mbp":"手机"
      "_sodEnyArr":"明细"
      "addr":"地址"
      "create_time":"创建"
      "create_usr":"创建人"
      "update_time":"修改时间"
      "update_usr":"修改人"
      "rem":"备注"
      "xudan":"续单"
      "qk":"欠款"
      "cy_thg":"托寄物"
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    grid_thead = grid_tbl.getE ".grid_thead"
    addPg = elt.getE "[h:but=addPg]"
    if o.usr._role and o.usr._role.id is 3
      addPg.hide() if addPg
    if o.usr.code isnt "admin" and o.usr._role.id isnt 4
      acc_state_th = grid_thead.getE ".acc_state_th"
      acc_state_th.hide()
      acc_state_srch = elt.getE ".srch_pop .acc_state_srch"
      acc_state_srch.hide()
    if o.usr._role.id is 4
      optLbl = grid_thead.getE ".optLbl"
      optLbl.hide() if optLbl
      addPg.hide() if addPg
    #快递
    if o.usr.code isnt "admin" and o.usr._role.id isnt 4
      crr_state_th = grid_thead.getE ".crr_state_th"
      crr_state_th.hide()
      crr_state_srch = elt.getE ".srch_pop .crr_state_srch"
      crr_state_srch.hide()
    #财务每天已核统计
    acc_day_ttl = elt.getE ".acc_day_ttl"
    acc_date = elt.getE ".acc_date"
    if o.usr.code isnt "admin" and o.usr._role.id isnt 4
      acc_day_ttl.hide()
    acc_date.addEvent "change",->
      await t.acc_dateChg()
      return
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    t.initButEvt ["shunfengTpl","srch_but1"]
    rvObj
  #查询
  srch_but1Clk: (but)->
    t = this
    o = t.options
    elt = o.ele
    but.set "disabled",true if but
    #删除所有查询条件
    srch_itemArrEl = elt.getE ".srch_itemArr"
    if srch_itemArrEl
      srch_itemArr = srch_itemArrEl.getEs ".srch_item"
      await t.srch_itemClk srch_item for srch_item in srch_itemArr
    elt.getEs("._srch_eny_but_active").removeClass "_srch_eny_but_active"
    srch_cr_noEl = elt.getE ".srch_cr_no"
    srch_cr_noVal = srch_cr_noEl.get "value"
    srch_cr_noVal = srch_cr_noVal.trim()
    if srch_cr_noVal
      seaObj = {andOr:"and",name:"t.cr_no",opt:"=",value:srch_cr_noVal}
      seaObj.andOrLbl = "并且"
      seaObj.nameLbl = "单号"
      seaObj.optLbl = "等于"
      await t.srchAdd seaObj
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    but.set "disabled",false if but
    return
  srchOpt2Iez: (optEl)->
    t = this
    o = t.options
    return if !optEl
    iez = undefined
    key = optEl.get "value"
    if key is "t.state"
      iez = new Element "select",{"h:apply":"Select","class":"select_ele",html:"""
      <option value="未发货">未发货</option>
      <option value="已发货">已发货</option>
      <option value="已退货">已退货</option>
      """}
    else if key is "t.acc_state"
      iez = new Element "select",{"h:apply":"Select","class":"select_ele",html:"""
      <option value="未核">未核</option>
      <option value="已核">已核</option>
      """}
    else if key is "t.crr_state"
      iez = new Element "select",{"h:apply":"Select","class":"select_ele",html:"""
      <option value="未付">未付</option>
      <option value="到付">到付</option>
      """}
    else
      iez = PrnClzz.prototype.srchOpt2Iez.apply t,arguments
    iez
  shunfengTplClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    uid = await o.thisSrv.ajax "shunfengTpl"
    if t.isElectron()
      href = o.thisSrv.downloadByUid uid,false
      mreq = global.require
      fs = mreq "fs"
      os = mreq "os"
      child_process = mreq "child_process"
      cwd = process.cwd()
      request = mreq "#{cwd}/resources/app/node_modules/request"
      uuid = mreq "#{cwd}/resources/app/node_modules/uuid"
      tmpdir = os.tmpdir()
      uuidStr = uuid.v4()
      tmpfile = tmpdir+"/"+uuidStr
      wst = fs.createWriteStream(tmpfile)
      request.get(window.location.origin+href).pipe wst
      wst_on = Promise.fromStandard wst.on,wst
      await wst_on "finish"
      stdout = await new Promise (resolve,reject)->
        cwd2 = "#{cwd}/resources/app/node_modules/to_xls/"
        child_process.exec cwd2+"/to_xls \"#{tmpfile}\"",{cwd:cwd2,maxBuffer:2000*1024},(err,stdout,stderr)->
          if err
            reject err
            return
          if stderr
            reject stderr
            return
          resolve stdout
          return
        return
      readFileAsync = Promise.fromStandard fs.readFile,fs
      buf = await readFileAsync stdout
      buf2 = buf.toString "base64"
      uid = await o.thisSrv.ajax "upxls",[buf2]
      o.thisSrv.downloadByUid uid
    else
      o.thisSrv.downloadByUid uid
    return
  initOptDel: (optTd)->
    t = this
    o = t.options
    elt = o.ele
    rvObj = undefined
    if o.usr.code is "admin"
      rvObj = PrnClzz.prototype.initOptDel.apply t,arguments
    rvObj
  initOptEdit: (optTd)->
    t = this
    o = t.options
    elt = o.ele
    if o.usr.code is "admin"
      rvObj = PrnClzz.prototype.initOptEdit.apply t,arguments
      return rvObj
    tr = optTd.getParent "tr"
    eny = tr.retrieve "eny"
    rvObj = undefined
    if eny.state is "未发货"
      rvObj = PrnClzz.prototype.initOptEdit.apply t,arguments
    rvObj
  #点击快递
  crr_stateClk: (but)->
    t = this
    o = t.options
    tr = but.getParent "tr"
    eny = tr.retrieve "eny"
    if eny.crr_state is "未付"
      rvObj = await o.thisSrv.ajax "crr_stateClk",[eny.id,"到付"]
      if rvObj.suc
        eny.crr_state = "到付"
        but.set "text","到付"
        but.setStyle "color","gray"
        window.ncWg.addNotice "info",rvObj.msg,2 if rvObj.msg
      else
        window.ncWg.addNotice "error",rvObj.msg,4 if rvObj.msg
    else if eny.crr_state is "到付"
      rvObj = await o.thisSrv.ajax "crr_stateClk",[eny.id,"未付"]
      if rvObj.suc
        eny.crr_state = "未付"
        but.set "text","未付"
        but.setStyle "color","red"
        window.ncWg.addNotice "info",rvObj.msg,2 if rvObj.msg
      else
        window.ncWg.addNotice "error",rvObj.msg,4 if rvObj.msg
    return
  #点击财务状态
  acc_stateClk: (but)->
    t = this
    o = t.options
    tr = but.getParent "tr"
    eny = tr.retrieve "eny"
    if eny.acc_state is "未核"
      rvObj = await o.thisSrv.ajax "acc_stateClk",[eny.id,"已核"]
      if rvObj.suc
        eny.acc_state = "已核"
        but.set "text","已核"
        but.setStyle "color","gray"
        window.ncWg.addNotice "info",rvObj.msg,2 if rvObj.msg
      else
        window.ncWg.addNotice "error",rvObj.msg,4 if rvObj.msg
    else if eny.acc_state is "已核"
      rvObj = await o.thisSrv.ajax "acc_stateClk",[eny.id,"未核"]
      if rvObj.suc
        eny.acc_state = "未核"
        but.set "text","未核"
        but.setStyle "color","red"
        window.ncWg.addNotice "info",rvObj.msg,2 if rvObj.msg
      else
        window.ncWg.addNotice "error",rvObj.msg,4 if rvObj.msg
    await t.acc_dateChg()
    return
  initTd: (tr,key,eny2)->
    t = this
    o = t.options
    td = undefined
    if key is "acc_state"
      eny = tr.retrieve "eny"
      val = eny[key]
      td = new Element "td"
      td.hide() if o.usr.code isnt "admin" and o.usr._role.id isnt 4
      td.addClass "initTd_#{key}"
      but = new Element "button",{text:val,"style":"padding-left:3px;padding-right:4px;"}
      but.inject td
      if eny.acc_state is "未核"
        but.setStyle "color","red"
      else
        but.setStyle "color","gray"
      but.addEvent "click",(e)->
        e.stop()
        await t.acc_stateClk this
        return
      td.inject tr
    else if key is "crr_state"
      eny = tr.retrieve "eny"
      val = eny[key]
      td = new Element "td"
      td.hide() if o.usr.code isnt "admin" and o.usr._role.id isnt 4
      td.addClass "initTd_#{key}"
      but = new Element "button",{text:val,"style":"padding-left:3px;padding-right:4px;"}
      but.inject td
      if eny.crr_state is "未付"
        but.setStyle "color","red"
      else
        but.setStyle "color","gray"
      but.addEvent "click",(e)->
        e.stop()
        await t.crr_stateClk this
        return
      td.inject tr
    #快递单号
    else if key is "cr_no" and o.usr._role.id isnt 4
      eny = tr.retrieve "eny"
      val = eny[key]
      td = new Element "td"
      td.addClass "initTd_#{key}"
      input = new Element "input[type=text].iez_cr_no"
      input.setStyles {"width":95,border:"none"}
      edtBut = new Element "button",{text:"改单"}
      if o.usr._role
        if o.usr._role.id is 2 or o.usr._role.id is 1
          input.set "readonly",true
          edtBut.hide()
      edtBut.hide() if String.isEmpty val
      input.set "readonly",true if edtBut.isDisplayed()
      edtBut.setStyles {color:"gray"}
      edtBut.addEvent "click",->
        input.set "readonly",false
        input.selectRange 0,input.get("value").length
        return
      copyBut = new Element "button",{text:"复制"}
      copyBut.setStyles {color:"gray","margin-left":"5px"}
      copyBut.addEvent "click",->
        input.selectRange 0,input.get("value").length
        document.execCommand "copy"
        return
      div = new Element "div"
      div.inject td
      input.inject div
      edtBut.inject td
      copyBut.inject td
      input.set "value",val
      input.addEvent "mouseup",->
        this.selectRange 0,this.get("value").length
        return
      input.addEvent "change",->
        val2 = this.get("value").trim()
        rltSet = await o.thisSrv.ajax "cr_noChg",[eny.id,val2]
        if rltSet
          initTd_state = tr.getE ".initTd_state"
          state = undefined
          if val2
            state = "已发货"
            this.set "readonly",true
            edtBut.show()
          else
            state = "未发货"
            this.set "readonly",false
            edtBut.hide()
          eny.state = state
          initTd_state.set "text",state
        return
      input.addEvent "keyup",(e)->
        code = e.code
        if code is 13
          nxtTr = this.getParent("tr").getNext "tr"
          if nxtTr
            nxtCr_noIez = nxtTr.getE ".iez_cr_no"
            nxtCr_noIez.selectRange 0,nxtCr_noIez.get("value").length
        return
      td.inject tr
    #if key is "cr_no"
    #订单明细
    else if key is "_sodEnyArr"
      eny = tr.retrieve "eny"
      _sodEnyArr = eny._sodEnyArr
      td = new Element "td"
      td.addClass "initTd_#{key}"
      str = ""
      if _sodEnyArr
        if _sodEnyArr.length > 0
          str = _sodEnyArr[0].pt_id+" "+_sodEnyArr[0].pt_sc_id+" "+_sodEnyArr[0].qty
        span = new Element "span",{text:str}
        span.inject td
        if _sodEnyArr.length > 1
          span = new Element "span",{style:"color:red;font-size:10px;",text:" (更多)"}
          span.inject td
      td.inject tr
    else if key is "state"
      eny = tr.retrieve "eny"
      td = PrnClzz.prototype.initTd.apply t,arguments
      td.setStyle "color","red" if eny.state is "已退货"
    else
      td = PrnClzz.prototype.initTd.apply t,arguments
    td
  #财务每天已核统计,日期change事件
  acc_dateChg: ->
    t = this
    o = t.options
    elt = o.ele
    acc_span = elt.getE ".acc_span"
    acc_date = elt.getE ".acc_date"
    acc_dateVal = acc_date.get "value"
    if !acc_dateVal
      acc_span.set "text",0
      return
    rvObj = await o.thisSrv.ajax "acc_dateChg",[acc_dateVal]
    acc_span.set "text",rvObj.amt
    return
  trSld: (tr)->
    t = this
    o = t.options
    elt = o.ele
    hsChg = await PrnClzz.prototype.trSld.apply t,arguments
    return hsChg if !hsChg
    acc_day_ttl = elt.getE ".acc_day_ttl"
    if acc_day_ttl.isDisplayed()
      acc_date = elt.getE ".acc_date"
      oldVal = acc_date.get "value"
      if !tr
        acc_date.set "value",""
      else
        eny = tr.retrieve "eny"
        acc_date.set "value",eny._create_time.substring 0,eny._create_time.length-9 if eny
      newVal = acc_date.get "value"
      await t.acc_dateChg() if oldVal isnt newVal
    hsChg
    