{Component} = require "Component"
{Srv} = require "Srv"

exports.InputElement = new Class
  Extends: Component
  options:
    vdtArr: []
    vdt_err_box: undefined
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    elt.addClass "InputElement"
    elt.addEvent "blur",(e)->
      prnEl = elt.getParent()
      return if prnEl and prnEl.getE("[h:iez]:focus") is elt
      t.onBlur t,e
      return
    oldVal = await t.getVal()
    t.setOldVal oldVal
    return
  onBlur: (iez,e)->
    t = this
    o = t.options
    await t.runVdts()
    return
  #增加验证
  addVdt: (callback)->
    t = this
    o = t.options
    elt = o.ele
    idx = o.vdtArr.indexOf callback
    if idx is -1
      o.vdtArr.push callback
    else
      o.vdtArr[idx] = callback
    return
  runVdts: ->
    t = this
    o = t.options
    elt = o.ele
    vdtArr = o.vdtArr
    if vdtArr
      for vdt in vdtArr
        rv = await vdt.apply t
        continue if rv is true
        if rv
          t.addErrBox rv.err,rv.time if rv.err
          return false if !rv["continue"]
    true
  getVdts: -> this.options.vdtArr
  clearVdt: -> this.options.vdtArr = []
  focusErrBox: ->
    t = this
    o = t.options
    elt = o.ele
    elt.focus()
    elt.selectRange 0,elt.get("value").length if elt.get "value"
    return
  addErrBox: (str,time,injIez)->
    t = this
    o = t.options
    elt = o.ele
    t.delErrBox()
    elt.addClass "vdt_err_input"
    vdt_err_box = new Element "div.vdt_err_box",{text:str}
    vdt_err_box.hide()
    injIez = injIez or elt
    vdt_err_box.inject injIez,"after"
    o.vdt_err_box = vdt_err_box
    vdt_err_box.position {
      relativeTo: elt
      position:"bottomLeft"
    }
    vdt_err_box.show()
    time = 2 if time is null or time is undefined
    if time > 0
      fxTimer = setTimeout(->
        vdtTop = vdt_err_box.getStyle("top").toInt()
        new Fx.Elements(vdt_err_box,{duration:"short"}).start(
          0:{top:[vdtTop,vdtTop+15],opacity:[1,0]}
        ).addEvents(
          complete: ->
            vdt_err_box.destroy()
            clearTimeout fxTimer
            return
        )
        return
      ,time*1000)
    return
  delErrBox: ->
    t = this
    o = t.options
    elt = o.ele
    elt.removeClass "vdt_err_input"
    o.vdt_err_box.destroy() if o.vdt_err_box
    o.vdt_err_box = undefined
    return
  getOldVal: ->
    t = this
    o = t.options
    elt = o.ele
    val = elt.retrieve "oldValue"
    val
  #设置默认值
  setOldVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    elt.store "oldValue",val
    t
  ###
    获取控件的值,默认跟旧值比较,如果跟旧值oldVal相等,则返回undefined,否则返回当前控件的值
      若opt.cmpOldVal 为 false,则代表不跟oldval比较,直接返回当前控件的值
  ###
  getVal: (opt)->
    t = this
    o = t.options
    elt = o.ele
    val = elt.get "value"
    if !opt or opt.cmpOldVal isnt false
      oldVal = t.getOldVal()
      return if val is oldVal
    val
  setVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    val = elt.set "value",val
    return
InputElement = exports.InputElement

exports.TextInput = new Class
  Extends: InputElement
TextInput = exports.TextInput

exports.DateInput = new Class
  Extends: InputElement
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    oldVal = await t.getVal()
    t.setOldVal oldVal
    return
  getVal: (opt)->
    t = this
    o = t.options
    elt = o.ele
    val = elt.get "value"
    val = null if val.trim() is ""
    if !opt or opt.cmpOldVal isnt false
      oldVal = t.getOldVal()
      return if val is oldVal
    val
  setVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    if String.isEmpty val
      val = "1900-01-01"
    else
      dDate = Date.fromISO val
      if dDate
        val = dDate.Format "yyyy-MM-dd"
      else
        val = "1900-01-01"
    elt.set "value",val
    return
DateInput = exports.DateInput

exports.NumberInput = new Class
  Extends: InputElement
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    elt.addClass "NumberInput"
    await InputElement.prototype.onDraw.apply t,arguments
    return
  getVal: (opt)->
    t = this
    o = t.options
    elt = o.ele
    val = Number elt.get "value"
    if !opt or opt.cmpOldVal isnt false
      oldVal = t.getOldVal()
      return if val is oldVal
    val
  setVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    if val? and Number(val)?
      val = Number val
    val = elt.set "value",val
    return
  setOldVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    if val? and Number(val)?
      val = Number val
    elt.store "oldValue",val
    return
NumberInput = exports.NumberInput

exports.PopInput = new Class
  Extends: InputElement
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    elt.addClass "PopInput"
    iezKey = elt.get "h:iez"
    img = elt.getParent().getE "[h:pop='#{iezKey}']"
    if !img
      img = new Element "img",{src:"/img/search.png","h:pop":iezKey,"class":"PopInput_img"}
      img.hide() if elt.get("disabled") or !elt.isDisplayed()
      img.inject elt,"after"
    pop_clk_evt = img.get "h:pop_clk_evt"
    if !pop_clk_evt
      img.addEvent "click",(e)->
        t.imgClk this,e
        return
      img.set "h:pop_clk_evt","1"
    await InputElement.prototype.onDraw.apply this,arguments
    return
  imgClk: (but,e,opt)->
    t = this
    o = t.options
    elt = o.ele
    bodyWg = $(document.body).wg()
    form_pg = elt.get "h:form_pg"
    win0 = elt.getParent "[h:pg]"
    but.set "disabled",true if but
    menuEny = win0.retrieve "menuEny"
    win = await bodyWg.menuClkByPg but,menuEny,form_pg,"modal",{elt:win0,befOnDraw:opt and opt.befOnDraw}
    but.set "disabled",false if but
    do_modal_div = win.getParent ".do_modal_div"
    grid_div = win.getE ".grid_div"
    grid_div.set "tabindex","1"
    win.set "tabindex","1"
    grid_div.focus()
    winWg = win.wg()
    sld_but_div = new Element "div",{"class":"sld_but_div",html:"""
    <button class="emptyPop">#{bodyWg.options.I18NEny.empty}</button>
    <button class="cancelPop">#{bodyWg.options.I18NEny.cancel}</button>
    <button class="confirmPop">#{bodyWg.options.I18NEny.confirm}</button>
    """}
    sld_but_div.inject win
    cancelPop = sld_but_div.getE ".cancelPop"
    cancelPop.addEvent "click",(e)->
      e.preventDefault() if e
      this.set "disabled",true
      winWg.closePage().then ->
        do_modal_div.destroy()
        return
      return
    confirmPop = sld_but_div.getE ".confirmPop"
    confirmPop.addEvent "click",(e)->
      e.preventDefault() if e
      dt_tr_sld = grid_div.getE ".dt_tr_sld"
      if !dt_tr_sld
        window.ncWg.addNotice "info",bodyWg.options.I18NEny.select_one_row,2
        return
      this.set "disabled",true
      sld_eny = dt_tr_sld.retrieve "eny"
      await t.selectTr sld_eny,dt_tr_sld,win
      await winWg.closePage()
      do_modal_div.destroy()
      return
    emptyPop = sld_but_div.getE ".emptyPop"
    emptyPop.addEvent "click",->
      t.emptyVal()
      cancelPop.fireEvent "click"
      return
    grid_div.addEvent "dblclick",->
      confirmPop.fireEvent "click"
      return
    win.addEvent "keyup",(e)->
      code = e.code
      if code is 13
        confirmPop.fireEvent "click"
      return
    return
  emptyVal: ->
    t = this
    o = t.options
    elt = o.ele
    elt.set "value",""
    return
  selectTr: (sld_eny,dt_tr_sld,win)->
    t = this
    o = t.options
    elt = o.ele
    
    fld = elt.get "h:fld"
    fld = fld or "id"
    lblFld = elt.get "h:lbl_fld"
    lblFld = lblFld or "lbl"
    
    lbl = sld_eny[lblFld]
    elt.set "value",lbl
    win = elt.getParent "[h:pg]"
    winWg = win.wg()
    winWg.options.hasChgEvt = true
    return
  getVal: (opt)->
    t = this
    o = t.options
    elt = o.ele
    val = elt.get "value"
    if !opt or opt.cmpOldVal isnt false
      oldVal = t.getOldVal()
      return if val is oldVal
    val
  setVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    elt.set "value",val
    return
PopInput = exports.PopInput

exports.Select = new Class
  Extends: InputElement
Select = exports.Select

exports.ImgInput = new Class
  Extends: InputElement
  options:
    defaultImg: ""
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    await t.initImgInput()
    return
  initImgInput: ->
    t = this
    o = t.options
    elt = o.ele
    elt.addClass "ImgInput"
    elt.set "src",o.defaultImg
    InputElement.prototype.onDraw.apply t,arguments
    accept = "image/gif,image/jpg,image/png"
    inputFile = new Element "input",{type:"file","class":"img_inputFile",accept:accept}
    inputFile.inject elt
    inputFile.addEvent "change",(e)->
      t.inputFileChg this
      return
    elt.addEvent "click",(e)->
      inputFile.click()
      return
    return
  inputFileChg: (input)->
    t = this
    o = t.options
    elt = o.ele
    return if input.files.length is 0
    win0 = elt.getParent "[h:pg]"
    return if !win0
    win0Wg = win0.wg()
    thisSrv = win0Wg.options.thisSrv
    o.thisSrv = thisSrv
    uid = await thisSrv.ajax "imgInput",[],{uploadFile:input.files[0]}
    t.setVal uid
    return
  setVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    elt.set "value",val
    if val
      if !o.thisSrv
        win0 = elt.getParent "[h:pg]"
        o.thisSrv = win0.wg().options.thisSrv if win0
      src = o.thisSrv.downloadByUid val,false
      elt.set "src",src
    else
      elt.set "src",o.defaultImg
    return
  getVal: (opt)->
    t = this
    o = t.options
    elt = o.ele
    val = elt.get "value"
    if !opt or opt.cmpOldVal isnt false
      oldVal = t.getOldVal()
      return if val is oldVal
    val
ImgInput = exports.ImgInput

exports.Checkbox = new Class
  Extends: InputElement
  getOldVal: ->
    t = this
    o = t.options
    elt = o.ele
    val = elt.retrieve "oldValue"
    val
  #设置默认值
  setOldVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    val = Boolean val
    elt.eliminate "oldValue"
    elt.store "oldValue",val
    t
  getVal: (opt)->
    t = this
    o = t.options
    elt = o.ele
    val = elt.checked
    if !opt or opt.cmpOldVal isnt false
      oldVal = t.getOldVal()
      return if val is oldVal
    val
  setVal: (val)->
    t = this
    o = t.options
    elt = o.ele
    val = Boolean val
    elt.checked = val
    return
Checkbox = exports.Checkbox
