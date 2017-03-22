require "./SysAdd.css"
{SysWin} = require "SysWin"
{Srv} = require "Srv"

#增加页面基类
PrnClzz = SysWin
exports.SysAdd = new Class
  Extends: PrnClzz
  options:
    pgType: "add"
    enyStr: ""
    headArr: []
    #所有需要验证的控件
    $vdts: []
    hasChgEvt: false
    I18NEny:
      "save":"保存"
      "cancel":"取消"
      "save_success":"保存成功!"
      "data_has_not_been_saved":"数据尚未保存! 是否继续退出?"
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    o.usr = window._usr
    t.initStoreMd()
    t.initAvalon()
    t.initThisSrv()
    afterInitThisSrv = elt.retrieve "afterInitThisSrv"
    await afterInitThisSrv.apply t if afterInitThisSrv
    await t.initPg0()
    await t.initI18N()
    await t.initPg()
    t.initButEvt ["cancelBut","confirmBut"]
    t.initPgEvt()
    return
  initPg: ->
    t = this
    o = t.options
    #初始化验证
    t.initVdts()
    return
  runAllVdts: (keyArr)->
    t = this
    o = t.options
    elt = o.ele
    isPass = true
    keyArr = o.$vdts if !keyArr
    for key in keyArr
      iez = elt.getE "[h:iez='#{key}']"
      iezWg = iez.wg()
      isPass = await iezWg.runVdts()
      if !isPass
        iezWg.focusErrBox()
        return false
    isPass
  #初始化验证
  initVdts: (keyArr)->
    t = this
    o = t.options
    elt = o.ele
    keyArr = o.$vdts if !keyArr
    eny = undefined
    if o.pgType is "edit"
      eny = elt.retrieve "eny"
    for key in keyArr
      iez = elt.getE "[h:iez='#{key}']"
      iezWg = iez.wg()
      iezWg.addVdt ->
        iezTmp = $ this
        keyTmp = iezTmp.get "h:iez"
        valTmp = await this.getVal {cmpOldVal:false}
        vdtCbFn = t["#{keyTmp}Vdt"] or t._sys_Vdt
        args = [keyTmp,valTmp]
        args.push eny.id if o.pgType is "edit"
        await vdtCbFn.apply t,args
    return
  _sys_Vdt: (key,val,id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "#{key}Vdt",[key,val,id]
    rltSet
  initThisSrv: (clz)->
    t = this
    o = t.options
    elt = o.ele
    clz = clz or o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)+"."+o.enyStr+"AddSrv"
    
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
  #初始化页面按钮事件,例如ctrl+s 保存
  initPgEvt: ->
    t = this
    o = t.options
    elt = o.ele
    elt.addEvent "keydown",(e)->
      code = e.code
      if e.control and code is 83
        e.stop()
        confirmBut = elt.getE ".confirmBut"
        t.confirmButClk confirmBut
      else if code is 27
        e.stop()
        cancelBut = elt.getE ".cancelBut"
        t.cancelButClk cancelBut
      return
    elt.addEvent "change",(e)->
      o.hasChgEvt = true
      return
    return
  #模态窗口显示之后调用此方法
  aftDoModal: ->
    t = this
    o = t.options
    elt = o.ele
    #调整模态窗口显示的位置
    left = 0
    top = 0
    do_modal_win = elt.getParent ".do_modal_win"
    do_modal_div = do_modal_win.getParent ".do_modal_div"
    bdSz = do_modal_div.measure -> this.getSize()
    winSz = do_modal_win.measure -> this.getSize()
    left = (bdSz.x-winSz.x)/2
    top = (bdSz.y-winSz.y)/3
    do_modal_win.setStyles {left:left,top:top,"max-width":bdSz.x,"max-height":bdSz.y}
    t.frtElFcu()
    return
  #first element focus 页面打开后第一个控件获得焦点
  frtElFcu: ->
    t = this
    o = t.options
    elt = o.ele
    iez = elt.getE "input[h:iez]:not([readonly])"
    iez.focus() if iez
    return
  confirmButClk: (but,e,headArr)->
    t = this
    o = t.options
    elt = o.ele
    e.preventDefault() if e
    but.set "disabled",true if but
    isPass = await t.runAllVdts()
    #验证不通过
    if !isPass
      but.set "disabled",false if but
      return
    eny = {}
    headArr = headArr or o.headArr
    await t.getPgVal eny,{cmpOldVal:false}
    rltSet = await t.confirmRst eny,headArr
    but.set "disabled",false if but
    await t.aftSave rltSet
    return
  confirmRst: (eny,headArr)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "confirmButClk",[eny,headArr]
    rltSet
  #保存成功之后,关闭页面
  aftSave: (rltSet)->
    t = this
    o = t.options
    elt = o.ele
    if rltSet
      window.ncWg.addNotice "info",o.I18NEny["save_success"],2
      cancelBut = elt.getE ".cancelBut"
      await t.cancelButClk cancelBut,undefined,false
    return
  cancelButClk: (but,e,isCkd)->
    t = this
    o = t.options
    elt = o.ele
    e.preventDefault() if e
    if isCkd isnt false
      if o.hasChgEvt
        return if !window.confirm o.I18NEny["data_has_not_been_saved"]
    do_modal_div = elt.getParent ".do_modal_div"
    but.set "disabled",true if but
    await t.closePage()
    but.set "disabled",false if but
    do_modal_div.destroy()
    return
  closePage: ->
    t = this
    o = t.options
    await PrnClzz.prototype.closePage.apply t,arguments
    return
