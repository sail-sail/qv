require "./SysWin.css"
{Component} = require "Component"
{Srv} = require "Srv"

#主窗口基类
exports.SysWin = new Class
  Extends: Component
  options:
    usr: {}
    I18NEny: {}
    pageEny: {}
    menuEny: {}
    #默认undefined表示此页面不在T2中,prn T2中的父, cld T2中的子页面
    t2Type: undefined
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    o.usr = window._usr
    t.initStoreMd()
    t.initAvalon()
    await t.initThisSrv() if t.initThisSrv
    afterInitThisSrv = elt.retrieve "afterInitThisSrv"
    await afterInitThisSrv.apply t if afterInitThisSrv
    await t.initPg0()
    await t.initI18N()
    await t.initPg()
    return
  initPg0: ->
    t = this
    o = t.options
    elt = o.ele
    pg = elt.get "h:pg"
    menuEny = elt.retrieve "menuEny"
    isMainFrame = elt.retrieve "isMainFrame"
    argObj = {pg:pg}
    argObj.menuId = menuEny.id if menuEny
    argObj.isMainFrame = isMainFrame if isMainFrame
    rltSet = await o.thisSrv.ajax "initPg",[argObj]
    rltSet
  initPg: ->
  getMsgArr: (keys,lang)->
    t = this
    o = t.options
    elt = o.ele
    uuidKey = "getMsgArr:4c199c9f-16f2-4051-b3e2-553221395c9a"
    key = JSON.encode [uuidKey,keys,lang]
    rltSet = window.sessionStorage.getItem key
    try
      rltSet = JSON.decode rltSet if rltSet
    catch err
    return rltSet if rltSet
    rltSet = await o.thisSrv.ajax "getMsgArr",[keys,lang]
    window.sessionStorage.setItem key,JSON.encode rltSet if rltSet
    rltSet
  getMsg: (key,lang,argObj)->
    t = this
    o = t.options
    elt = o.ele
    msgStr = ""
    rltSet = await t.getMsgArr [key],lang
    msgStr = rltSet[0].lbl if rltSet and rltSet[0]
    if msgStr and argObj
      msgStr = msgStr.substitute argObj
    msgStr
  initI18N: (lang)->
    t = this
    o = t.options
    elt = o.ele
    headObj = o.headObj
    if headObj
      keys = []
      for key of headObj
        continue if key.startsWith "$"
        if key isnt "optLbl"
          keys.push o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)+"."+key
        else
          keys.push key
      if keys.length isnt 0
        rltSet = await t.getMsgArr keys,lang
        headObj2 = {}
        for msgEny in rltSet
          continue if !msgEny.lbl?
          keyTmp2 = msgEny.code.replace(o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)+".","")
          lbl2 = undefined
          lbl2 = await t.headObjAfter(keyTmp2,msgEny.lbl) if t.headObjAfter
          if lbl2?
            headObj2[keyTmp2] = msgEny.lbl2
          else
            headObj2[keyTmp2] = msgEny.lbl
        #o.headObj = headObj2 #暂时停止I18N赋值
    I18NEny = o.I18NEny
    if I18NEny
      keys = []
      for key of I18NEny
        continue if key.startsWith "$"
        keys.push key
      if keys.length isnt 0
        rltSet = await t.getMsgArr keys,lang
        I18NEny2 = {}
        for msgEny in rltSet
          continue if !msgEny.lbl?
          lbl2 = undefined
          lbl2 = await t.I18NEnyAfter(msgEny.code,msgEny.lbl) if t.I18NEnyAfter
          if lbl2?
            I18NEny2[msgEny.code] = msgEny.lbl2
          else
            I18NEny2[msgEny.code] = msgEny.lbl
        #o.I18NEny = I18NEny2 #暂时停止I18N赋值
    return
  initStoreMd: ->
    t = this
    o = t.options
    elt = o.ele
    storeMd = elt.retrieve "storeMd"
    return if !storeMd
    for key of storeMd
      t[key] = storeMd[key] if storeMd[key]
    return
  initAvalon: ->
    t = this
    o = t.options
    elt = o.ele
    o["$id"] = String.uniqueID()
    elt.set "ms-controller",o["$id"]
    t.options = avalon.define t.options
    avalon.scan elt
    return
  #会话超时,由后台的action调用
  sttConfirm: ->
    t = this
    o = t.options
    elt = o.ele
    stwin = $(document.body).getE ".session_timeout_win"
    do_modal_div = stwin.getParent ".do_modal_div"
    confirm_ok = stwin.getE ".confirm_ok"
    if !do_modal_div.retrieve "initEvent"
      confirm_ok.addEvent "click",->
        window.location.reload()
        return
      do_modal_div.store "initEvent","1"
      confirm_cancel = stwin.getE ".confirm_cancel"
      confirm_cancel.addEvent "click",->
        do_modal_div.hide()
        return
    do_modal_div.show()
    confirm_ok.focus()
    return
  #获得包含此页面的选项卡
  getLinkTab: ->
    t = this
    o = t.options
    elt = o.ele
    tabpanel = elt.getParent ".tabpanel"
    return null if !tabpanel
    tabpanelWg = tabpanel.wg()
    tabpanelWg.getLinkTab()
  getTabWg: ->
    t = this
    tab = t.getLinkTab()
    return if !tab
    tab.wg()
  #获得页面上控件h:iez的值,当值没有被修改时,会返回undefined
  getPgVal: (eny,valOpt)->
    t = this
    o = t.options
    elt = o.ele
    eny = eny or {}
    iezArr = elt.getEs "[h:iez]"
    for iez in iezArr
      iezWg = iez.wg()
      continue if !iezWg
      key = iez.get "h:iez"
      val = await iezWg.getVal valOpt
      eny[key] = val if val isnt undefined
    eny
  #设置页面上控件h:iez的值,当传入undefined时,自动使用默认值oldValue
  setPgVal: (eny,headArr)->
    t = this
    o = t.options
    elt = o.ele
    eny = eny or {}
    headArr = headArr or o.headArr
    for key in headArr
      iez = elt.getE "[h:iez="+key+"]"
      continue if !iez
      iezWg = iez.wg()
      continue if !iezWg
      val = eny[key]
      await iezWg.setVal val
    return
  setPgOldVal: (eny,headArr)->
    t = this
    o = t.options
    elt = o.ele
    eny = eny or {}
    headArr = headArr or o.headArr
    for key in headArr
      iez = elt.getE "[h:iez="+key+"]"
      continue if !iez
      iezWg = iez.wg()
      continue if !iezWg
      val = eny[key]
      iezWg.setOldVal val
    return
  closePage: ->
    t = this
    o = t.options
    elt = o.ele
    winArr = elt.getEs "[h:include]>[h:pg]"
    for win in winArr
      winWg = win.wg()
      continue if !winWg
      await winWg.closePage()
    delete avalon.vmodels[o["$id"]] if o["$id"]
    await o.thisSrv.closeSrv() if o.thisSrv
    return
  initButEvt: (butArr,sldArr)->
    t = this
    o = t.options
    elt = o.ele
    butArr.each (item,i)->
      sldStr = sldArr and sldArr[i] or "[h:but="+item+"]"
      but = elt.getE sldStr
      if !but
        #alert item+" h:but dose not exist!"
        return
      but.store "clickMethod",{t:t,method:t[item+"Clk"]} if t[item+"Clk"]
      but.addEvent "click",(e)->
        if !t[item+"Clk"]
          alert item+"Clk"
          return
        await t[item+"Clk"] this,e
        return
      return
    return
  #处理h:include标签
  hInclude: ->
    t = this
    o = t.options
    elt = o.ele
    pg = elt.get "h:pg"
    incArr = elt.getEs "[h:include]"
    fromBut = elt.retrieve "fromBut"
    for inc,i in incArr
      key = inc.get "h:include"
      continue if !key
      if key.charAt(0) is "."
        h_url = elt.get "h:url"
        if key.charAt(1) is "."
          key = h_url.basename("/").basename("/")+key.substring 2
        else
          key = h_url.basename("/")+key.substring 1
      win = await Srv.createWindow key
      win = win[0]
      win.eliminate "fromBut"
      win.store "fromBut",fromBut
      win.store "menuEny",elt.retrieve "menuEny"
      #子页面刚打开时,不初始化表格数据
      win.store "frtDtGrid",false
      win.inject inc,"top"
      await win.onDrawAsync()
      winWg = win.wg()
      winWg.options.pageEny = elt.retrieve "pageEny"
    return
  #把窗口变成模态窗口
  doModal: (winWg,lbl,mdlOpt)->
    t = this
    height = mdlOpt and mdlOpt.height
    width = mdlOpt and mdlOpt.width
    isHide = mdlOpt and mdlOpt.isHide
    hideCloseBut = mdlOpt and mdlOpt.hideCloseBut
    lbl = lbl or ""
    body = document.body
    oldWinWg = winWg
    do_modal_div = new Element "div",{"class":"do_modal_div"}
    do_modal_div.hide() if isHide is true
    do_modal_titlebar = new Element "div",{"class":"do_modal_titlebar",html: "<div class='do_modal_title'>"+lbl+"</div>"+"<div class='do_modal_close_but'>X</div>"+"<div class='clear'></div>"}
    do_modal_win = new Element "div",{"class":"do_modal_win"}
    do_modal_titlebar.inject do_modal_win
    do_modal_win.inject do_modal_div
    do_modal_win.grab $ winWg
    
    if mdlOpt and mdlOpt.elt
      do_modal_div.inject mdlOpt.elt,"bottom"
    else
      do_modal_div.inject body,"bottom"
    
    if typeOf(winWg) is "element"
      winWg.befOnDraw = mdlOpt.befOnDraw if mdlOpt and mdlOpt.befOnDraw
      await winWg.onDrawAsync()
      winWg = winWg.wg()
    closeBut = do_modal_titlebar.getE ".do_modal_close_but"
    do_modal_titlebar.addEvent "dblclick",->
      if closeBut.getStyle("display") isnt "none"
        if mdlOpt and mdlOpt.closeFn
          mdlOpt.closeFn winWg or oldWinWg
        else
          if winWg
            await winWg.closePage()
          else
            do_modal_div.destroy()
      return
    closeBut.hide() if hideCloseBut is true
    if winWg
      closeBut and closeBut.addEvent "click",->
        if mdlOpt and mdlOpt.closeFn
          mdlOpt.closeFn winWg or oldWinWg
        else
          winWg.closePage()
        return
    else
      closeBut and closeBut.addEvent "click",->
        if mdlOpt and mdlOpt.closeFn
          mdlOpt.closeFn winWg or oldWinWg
        else
          do_modal_div.destroy()
        return
    $(oldWinWg).setStyle "height",height if height
    $(oldWinWg).setStyle "width",width if width
    new Drag do_modal_win,{handle:do_modal_titlebar,modifiers:{x:'left',y:'top'}}
    left = 0
    top = 0
    do_modal_div.show()
    do_modal_win.show()
    t.rePoModal do_modal_div
    do_modal_div
  rePoModal: (do_modal_div)->
    return if !do_modal_div
    body = document.body
    do_modal_win = do_modal_div.getE ".do_modal_win"
    bdSz = body.getSize()
    winSz = do_modal_win.getSize()
    left = (bdSz.x-winSz.x)/2
    top = (bdSz.y-winSz.y)/3
    do_modal_win.setStyles {left:left,top:top,"max-width":bdSz.x,"max-height":bdSz.y}
    return
  isElectron: -> 'undefined' isnt typeof(process) and process.versions and process.versions.electron
  