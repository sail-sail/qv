require "./SysT2.css"
{Srv} = require "Srv"
{SysWin} = require "./SysWin"
{SysList} = require "./SysList"

#标签页面基类
PrnClzz = SysWin
exports.SysT2 = new Class
  Extends: PrnClzz
  options:
    enyStr: ""
    sld_eny: {}
    I18NEny:
      "select":"选择"
      "remove":"移除"
      "confirm":"确定"
      "cancel":"取消"
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    rv = await PrnClzz.prototype.onDraw.apply t,arguments
    await t.hInclude()
    await t.initPrnWin()
    rv
  initPrnWin: ->
    t = this
    o = t.options
    elt = o.ele
    winArr = elt.getEs "[h:include]>[h:pg]"
    prnWin = winArr[0]
    return if !prnWin
    prnWinWg = prnWin.wg()
    trSld = prnWinWg.trSld
    prnWinWg.trSld = (tr)->
      hsChg = await trSld.apply this,arguments
      await t.prn_trSld $(this),tr if hsChg
      hsChg
    for win1 in winArr
      win1Wg = win1.wg()
      if prnWin is win1
        win1Wg.options.t2Type = "prn"
      else
        win1Wg.options.t2Type = "cld"
        #子窗口不选择行
        await win1Wg.trSld()
        win1Wg.trSld = (tr)-> false
    #父窗口修改记录,也跟着刷新子窗口表格
    prnWinWg.initOptEditWin = (winWg,type)->
      tt = this
      aftSave = winWg.aftSave
      winWg.aftSave = ->
        rvObj = await aftSave.apply this,arguments
        await tt.dataCount()
        await tt.cur_pgChg true
        for win in winArr
          continue if win is prnWin or !win.isVisible()
          winWgTp = win.wg()
          await winWgTp.dataCount()
          await winWgTp.cur_pgChg true
        rvObj
      return
    optDelClk = prnWinWg.optDelClk
    prnWinWg.optDelClk = (but)->
      rvObj = optDelClk.apply this,arguments
      for win in winArr
        continue if win is prnWin or !win.isVisible()
        winWgTp = win.wg()
        await winWgTp.dataCount()
        await winWgTp.cur_pgChg true
      rvObj
    frtDtGrid = elt.retrieve "frtDtGrid"
    if frtDtGrid isnt false
      if frtDtGrid
        await frtDtGrid.apply t,arguments
      else
        await prnWinWg.dataCount()
        await prnWinWg.cur_pgChg true
        await prnWinWg.trSldFrt()
    return
  initSlt: (pg)->
    t = this
    o = t.options
    elt = o.ele
    win = elt.getE "[h:pg='#{pg}']"
    winWg = win.wg()
    grid_padding = win.getE ".grid_padding"
    return if !grid_padding
    addPg = grid_padding.getE "[h:but='addPg']"
    slt_but = new Element "button.slt_but[h:but=slt_but]",{title:o.I18NEny["select"]}
    if !addPg
      slt_but.inject grid_padding
    else
      slt_but.inject addPg,"after"
    slt_but.addEvent "click",(e)->
      t.slt_butClk this,e,winWg
      return
    return
  slt_butClk: (but,e,winWg)->
    t = this
    o = t.options
    elt = o.ele
    win = $ winWg
    pg = win.get "h:pg"
    body = document.body
    bodyWg = body.wg()
    menuEny = elt.retrieve "menuEny"
    opt = {elt:elt}
    opt.storeMd = {}
    opt.storeMd.initThisSrv = ->
      this.__proto__.initThisSrv.apply this,arguments
      this.options.thisSrv.options.clz = "slt_butClk."+this.options.thisSrv.options.clz
      return
    opt.storeMd.initSltTd = (tr)->
      sltTd = new Element "td.sltTd"
      sltTd.inject tr
      checkbox = new Element "input[type=checkbox].sltCbx"
      checkbox.inject sltTd
      sltTd
    but.set "disabled",true
    winSlt = await bodyWg.menuClkByPg but,menuEny,pg,"modal",opt
    but.set "disabled",false
    if !winSlt
      window.ncWg.addNotice "error"," 字段 page.code 中 "+pg+" 不存在!"
      return
    winSltWg = winSlt.wg()
    grid_div = winSlt.getE ".grid_div"
    grid_tbl = grid_div.getE ".grid_tbl"
    grid_div.set "tabindex","1"
    winSlt.set "tabindex","1"
    grid_div.focus()
    sld_but_div = new Element "div",{"class":"sld_but_div",html:"""
    <button class="cancelPop">#{o.I18NEny["cancel"]}</button>
    <button class="confirmPop">#{o.I18NEny["confirm"]}</button>
    """}
    sld_but_div.inject winSlt
    grid_thead = grid_tbl.getE ".grid_thead"
    thTr = grid_thead.getLast "tr"
    sltLbl = new Element "th",{"class":"sltLbl",text:o.I18NEny["select"]}
    sltLbl.inject thTr,"top"
    cancelPop = sld_but_div.getE ".cancelPop"
    cancelPop.addEvent "click",(e)->
      e.preventDefault() if e
      do_modal_div = winSlt.getParent ".do_modal_div"
      this.set "disabled",true
      await winSltWg.closePage()
      do_modal_div.destroy()
      return
    confirmPop = sld_but_div.getE ".confirmPop"
    confirmPop.addEvent "click",(e)->
      e.preventDefault() if e
      confirmPop.set "disabled",true
      tbody = grid_tbl.getE "tbody"
      sltCbxArr = tbody.getEs ".sltCbx:checked"
      if sltCbxArr.length > 0
        idArr = []
        for sltCbx in sltCbxArr
          dt_tr = sltCbx.getParent ".dt_tr"
          eny = dt_tr.retrieve "eny"
          continue if !eny or !eny.id
          idArr.push eny.id
        await o.thisSrv.ajax "slt_but"+pg,[idArr] if idArr.length > 0
      do_modal_div = winSlt.getParent ".do_modal_div"
      await winSltWg.closePage()
      do_modal_div.destroy()
      await winWg.dataCount()
      await winWg.cur_pgChg true
      return
    winSlt
  initOptRmv: (pg)->
    t = this
    o = t.options
    elt = o.ele
    win = elt.getE "[h:pg='#{pg}']"
    winWg = win.wg()
    initOptTd = winWg.initOptTd
    winWg.initOptTd = (tr)->
      optTd = initOptTd.apply this,arguments
      if !optTd
        optTd = new Element "td.optTd"
        optTd.inject tr,"top"
        optLbl = win.getE ".grid_tbl .grid_thead .optLbl"
        optLbl.show() if optLbl
      optRmv = new Element "button",{"class":"optRmv",title:o.I18NEny["remove"]}
      optRmv.addEvent "click",(e)->
        t.optRmvClk this,e,winWg
        return
      img = new Element "div",{"class":"optRmvImg"}
      img.inject optRmv
      optRmv.inject optTd,"top"
      optTd
    return
  optRmvClk: (but,e,winWg)->
    t = this
    o = t.options
    elt = o.ele
    win = $ winWg
    pg = win.get "h:pg"
    dt_tr = but.getParent ".dt_tr"
    eny = dt_tr.retrieve "eny"
    await o.thisSrv.ajax "optRmv"+pg,[eny.id]
    await winWg.cur_pgChg true if winWg.cur_pgChg
    return
  #父页面的表格选中一行
  prn_trSld: (prnWin,tr)->
    t = this
    o = t.options
    elt = o.ele
    prnWinWg = prnWin.wg()
    prnWinOp = prnWinWg.options
    o.sld_eny = prnWinOp.sld_eny
    winArr = elt.getEs "[h:include]>[h:pg]"
    for win in winArr
      continue if win is prnWin
      winWg = win.wg()
      if !tr
        winWg.emptyGrid()
        continue
      #给子页面强制增加筛选条件,用于跟父页面的外键关联
      await o.thisSrv.ajax "prn_trSld",[{id:o.sld_eny.id}]
      await winWg.dataCount()
      await winWg.firstPgClk undefined,undefined,true
    return
  initThisSrv: (clz)->
    t = this
    o = t.options
    elt = o.ele
    clz = clz or o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)+"."+o.enyStr+"T2Srv"
    
    prnClz = ""
    prnWinArr = elt.getParents "[h:pg]"
    for i in [0...prnWinArr.length]
      prnWin = prnWinArr[prnWinArr.length-1-i]
      continue if prnWin is document.body
      prnPg = prnWin.get "h:pg"
      prnClz += prnPg+"."
    clz = prnClz+clz+"||"+clz if prnClz
    
    o.thisSrv = new Srv clz:clz
    o.thisSrv.options.ele = elt
    return
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    return
