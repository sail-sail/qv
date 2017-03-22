{Srv} = require "Srv"
{SysWin} = require "./SysWin"

#列表页面基类
PrnClzz = SysWin
exports.SysList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Usr"
    headArr: []
    pg_rltSet: undefined
    headObj:
      "optLbl":"操作"
    I18NEny:
      "and":"并且"
      "or":"或者"
      "confirm":"确定"
      "cancel":"取消"
      "yes":"是"
      "no":"否"
      "add":"增加"
      "edit":"修改"
      "delete":"删除"
      "equal":"等于"
      "greater":"大于"
      "greater_equal":"大于等于"
      "less":"小于"
      "less_equal":"小于等于"
      "begin_with":"始于"
      "end_with":"止于"
      "contain":"包含"
      "increase_search_conditions":"增加搜索条件"
      "sure_to_delete":"确定删除"
      "delete_num_records":"删除 {0} 条记录!"
      "export_excel":"导出"
      "import_excel":"导入"
      "first_page":"首页"
      "prev_page":"上页"
      "next_page":"下页"
      "last_page":"尾页"
      "refresh":"刷新"
    #当前选中的行的实体类
    sld_eny: {}
  onDraw: ->
    t = this
    await PrnClzz.prototype.onDraw.apply t,arguments
  initThisSrv: (clz)->
    t = this
    o = t.options
    elt = o.ele
    clz = clz or o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)+"."+o.enyStr+"ListSrv"
    
    prnClz = ""
    prnWinArr = elt.getParents "[h:pg]"
    for i in [0...prnWinArr.length]
      prnWin = prnWinArr[prnWinArr.length-1-i]
      continue if prnWin is document.body
      prnPg = prnWin.get "h:pg"
      prnClz += prnPg+"."
    clz = prnClz+clz+"||"+clz if prnClz
    
    o.thisSrv = new Srv {clz:clz}
    o.thisSrv.options.ele = elt
    return
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    await t.initSearchList()
    await t.initSort()
    await t.initSortX o.pg_rltSet
    await t.initSrch o.pg_rltSet
    await t.initGrid()
    return
  initPg0: ->
    t = this
    o = t.options
    rltSet = await PrnClzz.prototype.initPg0.apply t,arguments
    o.pg_rltSet = rltSet
    rltSet
  #初始化默认排序
  initSortX: (rltSet)->
    t = this
    o = t.options
    elt = o.ele
    return if !rltSet or !rltSet.sortArr or !rltSet.sortArr.length
    grid_tbl = elt.getE ".grid_tbl"
    grid_thead = grid_tbl.getE ".grid_thead"
    sortArr = rltSet.sortArr
    for sortEny in sortArr
      th = grid_thead.getE "[h:sort_fld='#{sortEny.name}']"
      continue if !th
      dirt_icon = th.getE ".dirt_icon"
      continue if !dirt_icon
      if sortEny.opt is "asc"
        dirt_icon.removeClass "desc_icon"
        dirt_icon.addClass "asc_icon"
        dirt_icon.show()
        await t.syncSort th
      else if sortEny.opt is "desc"
        dirt_icon.addClass "desc_icon"
        dirt_icon.removeClass "asc_icon"
        dirt_icon.show()
        await t.syncSort th
    return
  #初始化快捷查询按钮列表
  initSrch: (rltSet)->
    t = this
    o = t.options
    elt = o.ele
    return if !rltSet or !rltSet.srchArr or !rltSet.srchArr.length
    grid_div0 = elt.getE ".grid_div0"
    srch_eny_div = grid_div0.getFirst ".srch_eny_div"
    if !srch_eny_div
      srch_eny_div = new Element ".srch_eny_div"
      div = new Element "div.srch_eny_lable",{text:""}
      div.setStyles {"color":"gray","line-height":20,"display":"inline-block"}
      div.inject srch_eny_div
      srch_eny_div.inject grid_div0,"top"
    else
      srch_eny_div.getEs("._srch_eny_but_").destroy()
    srchArr2 = {}
    lblArr2 = []
    for srchEny in rltSet.srchArr
      seaObj = {lbl:srchEny.lbl,andOr:srchEny.and_or,name:srchEny.name,opt:srchEny.opt,value:srchEny.value, rem:srchEny.rem}
      seaObj.andOrLbl = srchEny.and_or_lbl
      seaObj.nameLbl = srchEny.name_lbl
      seaObj.optLbl = srchEny.opt_lbl
      if srchEny.value and srchEny.value.startsWith "javascript:"
        r = undefined
        eval srchEny.value.substring 11
        srchEny.value = r
      if srchEny.lbl
        srchArr2[srchEny.lbl] = srchArr2[srchEny.lbl] or []
        srchArr2[srchEny.lbl].push srchEny
        lblArr2.push srchEny.lbl if !lblArr2.contains srchEny.lbl
    dft_button = undefined
    for lbl in lblArr2
      srchEnyArr = srchArr2[lbl]
      button = new Element "button[h:but='_srch_eny_but_#{srchEny.id}']._srch_eny_but_"
      button.set "text",lbl
      button.store "srchEnyArr",srchEnyArr
      button.inject srch_eny_div
      button.addEvent "click",->
        await t.srch_eny_butClk this
        await t.dataCount()
        await t.firstPgClk undefined,undefined,true
        return
      if !dft_button
        for srchEny in srchEnyArr
          if srchEny.dft
            dft_button = button
            break
    if dft_button
      await t.srch_eny_butClk dft_button
    return
  #点击快捷查询按钮
  srch_eny_butClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    grid_div0 = elt.getE ".grid_div0"
    #删除所有的查询条件
    srch_itemArrEl = elt.getE ".srch_itemArr"
    return if !srch_itemArrEl
    srch_itemArr = srch_itemArrEl.getEs ".srch_item"
    for srch_item in srch_itemArr
      await t.srch_itemClk srch_item
    atvCls = "_srch_eny_but_active"
    if but.hasClass atvCls
      but.removeClass atvCls
      return
    srch_eny_div = grid_div0.getE ".srch_eny_div"
    srch_eny_div.getEs(".#{atvCls}").removeClass atvCls
    but.addClass atvCls
    srchEnyArr = but.retrieve "srchEnyArr"
    for srchEny in srchEnyArr
      seaObj = {lbl:srchEny.lbl,andOr:srchEny.and_or,name:srchEny.name,opt:srchEny.opt,value:srchEny.value, rem:srchEny.rem}
      seaObj.andOrLbl = srchEny.and_or_lbl
      seaObj.nameLbl = srchEny.name_lbl
      seaObj.optLbl = srchEny.opt_lbl
      await t.srchAdd seaObj
    return
  #初始化排序事件
  initSort: ->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    thead = grid_tbl.getE "thead"
    thArr = thead.getEs "th"
    for i in [0...thArr.length]
      th = thArr[i]
      epx = undefined
      th.addEvent "mousedown",(e)->
        return if !e or e.rightClick
        epx = e.page.x
        return
      th.addEvent "mouseup",(e)->
        return if !e or e.rightClick
        if !epx or Math.abs(e.page.x-epx) < 5
          t.thClk this,e
        return
      th.addEvent "dblclick",(e)-> e.stop()
      await t.syncSort th if th.get("h:sort_fld") and th.getE(".dirt_icon") and th.getE(".dirt_icon").isDisplayed()
    return
  #扫描表头上的当前排序状态,同步后台上去,刷新表格,被thClk调用
  syncSort: (but)->
    t = this
    o = t.options
    elt = o.ele
    return if but and but.get "disabled"
    dirt_icon = but.getE ".dirt_icon"
    return if !dirt_icon
    sort_fld = but.get "h:sort_fld"
    return if !sort_fld
    but.set "disabled",true if but
    if dirt_icon.hasClass "asc_icon"
      srtObj = {sort_fld:sort_fld,dirt:"asc"}
      await o.thisSrv.ajax "sortAdd",[srtObj]
    else if dirt_icon.hasClass "desc_icon"
      srtObj = {sort_fld:sort_fld,dirt:"desc"}
      await o.thisSrv.ajax "sortAdd",[srtObj]
    else
      await o.thisSrv.ajax "sortDel",[sort_fld]
    but.set "disabled",false if but
    return
  #点击表头,排序
  thClk: (but,e)->
    t = this
    o = t.options
    elt = o.ele
    return if but and but.get "disabled"
    dirt_icon = but.getE ".dirt_icon"
    return if !dirt_icon
    #由升序变为降序
    if dirt_icon.hasClass "asc_icon"
      dirt_icon.removeClass "asc_icon"
      dirt_icon.addClass "desc_icon"
      dirt_icon.show()
    #由降序变为无序
    else if dirt_icon.hasClass "desc_icon"
      dirt_icon.removeClass "desc_icon"
      dirt_icon.removeClass "asc_icon"
      dirt_icon.hide()
    #由无序变为升序
    else
      dirt_icon.removeClass "desc_icon"
      dirt_icon.addClass "asc_icon"
      dirt_icon.show()
    await t.syncSort but
    #刷新表格
    await t.firstPgClk undefined,undefined,true
    return
  #初始化表格搜索条件
  initSearchList:->
    t = this
    o = t.options
    elt = o.ele
    srch = elt.getE ".srch"
    return if !srch
    srch_but = srch.getE ".srch_but"
    return if !srch_but
    srch_but.store "clickMethod",{t:t,method:t["srch_butClk"]} if t["srch_butClk"]
    srch_but.addEvent "click",(e)->
      t.srch_butClk this,e
      return
    return
  closePage: ->
    t = this
    o = t.options
    await PrnClzz.prototype.closePage.apply t,arguments
    return
  #点击增加搜索按钮
  srch_butClk: (but,e)->
    t = this
    o = t.options
    elt = o.ele
    srch = elt.getE ".srch"
    srch_pop = srch.getE ".srch_pop"
    srch_pop = srch_pop.clone()
    srch_pop.set "tabindex",1
    srch_pop.addEvent "keydown",(e)->
      t.srch_popKwn this,e
      return
    srch_cfm = srch_pop.getE ".srch_cfm"
    srch_name = srch_pop.getE ".srch_name"
    await t.srch_nameChg srch_pop
    srch_name.addEvent "change",(e)->
      await t.srch_nameChg srch_pop
      return
    srch_cfm.addEvent "click",(e)->
      t.srch_cfmClk this,e,srch_pop
      return
    srch_pop.show()
    await t.doModal srch_pop,""
    srch_pop.focus()
    return
  srch_nameChg: (srch_pop)->
    t = this
    await t.initSrch_opt srch_pop
    await t.initSrch_value srch_pop
    return
  #Esc按键关闭搜索框,回车为确定
  srch_popKwn: (but,e)->
    t = this
    o = t.options
    code = e.code
    if [27,13].indexOf(code) isnt -1
      e.stop()
    if code is 27
      do_modal_div = but.getParent ".do_modal_div"
      do_modal_div.destroy()
    else if code is 13
      srch_cfm = but.getE ".srch_cfm"
      await t.srch_cfmClk srch_cfm,undefined,but
    return
  #点击确定后,增加搜索条件到表格上
  srch_cfmClk: (but,e,srch_pop)->
    t = this
    o = t.options
    do_modal_div = srch_pop.getParent ".do_modal_div"
    srch_name = srch_pop.getE ".srch_name"
    name = srch_name.get "value"
    if String.isEmpty name
      do_modal_div.destroy()
      return
    srch_and = srch_pop.getE ".srch_and"
    srch_opt = srch_pop.getE ".srch_opt"
    srch_value = srch_pop.getE ".srch_value"
    if !srch_value
      do_modal_div.destroy()
      return
    andOr = srch_and.get "value"
    opt = srch_opt.get "value"
    andOrLbl = srch_and.selectedOptions[0] and srch_and.selectedOptions[0].get "html"
    nameLbl = srch_name.selectedOptions[0] and srch_name.selectedOptions[0].get "html"
    optLbl = srch_opt.selectedOptions[0] and srch_opt.selectedOptions[0].get "html"
    srch_valueWg = srch_value.wg()
    value = ""
    if srch_valueWg
      value = await srch_valueWg.getVal {cmpOldVal:false}
    else
      value = srch_value.get "value"
    valueLbl = await t.srchValueLbl srch_value
    #搜索对象
    seaObj = {andOr:andOr,andOrLbl:andOrLbl,name:name,nameLbl:nameLbl,opt:opt,optLbl:optLbl,value:value,valueLbl:valueLbl}
    but.set "disabled",true if but
    await t.srchAdd seaObj
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    but.set "disabled",false if but
    do_modal_div.destroy()
    return
  srchValueLbl: (srch_value)->
    t = this
    o = t.options
    valueLbl = ""
    srch_valueWg = srch_value.wg()
    if srch_valueWg
      value = await srch_valueWg.getVal {cmpOldVal:false}
    else
      value = srch_value.get "value"
    if srch_value.get("h:apply") is "Select"
      optArr = srch_value.getEs "option"
      optEl = optArr[srch_value.selectedIndex]
      valueLbl = optEl.get "html"
    else
      valueType = typeOf value
      if valueType is "string"
        #valueLbl = value.truncate 4,".."
        valueLbl = value
      else if valueType is "number"
        valueLbl = String value
      else if valueType is "boolean"
        valueLbl = ""
        if value
          valueLbl = o.I18NEny["yes"]
        else
          valueLbl = o.I18NEny["no"]
    valueLbl
  #给前台后台增加搜索条件
  srchAdd: (seaObj,isHide)->
    t = this
    o = t.options
    elt = o.ele
    return if !seaObj or !seaObj.value?
    srch_itemArrEl = elt.getE ".srch_itemArr"
    srch_itemArr = srch_itemArrEl.getEs ".srch_item"
    idx = await o.thisSrv.ajax "srchAdd",[seaObj]
    andOrLbl = seaObj.andOrLbl or seaObj.andOr
    nameLbl = seaObj.nameLbl or seaObj.name
    optLbl = seaObj.optLbl or seaObj.opt
    valueLbl = seaObj.valueLbl or seaObj.value
    srch_item = new Element "div.srch_item",{html:"""
    <div class="srch_item_andOr">#{andOrLbl}</div>
    <div class="srch_item_name">#{nameLbl}</div>
    <span class="srch_item_opt">#{optLbl}</span>
    <div class="srch_item_value">#{valueLbl}</div>
    """}
    srch_item.hide() if isHide
    srch_item.set "title",seaObj.rem or andOrLbl+nameLbl+optLbl+valueLbl
    srch_item.store "srch_idx",idx
    srch_item.store "seaObj",seaObj
    sisLen = srch_itemArr.length
    if sisLen is 0
      srch_item.getE(".srch_item_andOr").hide()
    srch_item.addEvent "click",(e)->
      await t.srch_itemClk this,e
      #刷新表格
      await t.dataCount()
      await t.firstPgClk undefined,undefined,true
      return
    srch_item.inject srch_itemArrEl
    return
  #点击单个搜索条件,前后台删除搜索条件
  srch_itemClk: (but,e)->
    t = this
    o = t.options
    return if but and but.get "disabled"
    srch_itemArrEl = but.getParent ".srch_itemArr"
    idx = but.retrieve "srch_idx"
    but.set "disabled",true if but
    await o.thisSrv.ajax "srchDel",[idx]
    but.set "disabled",false if but
    but.destroy()
    #隐藏第一个搜索条件的andOr控件
    srch_item = srch_itemArrEl.getFirst ".srch_item"
    if srch_item
      srch_item_andOr = srch_item.getE ".srch_item_andOr"
      srch_item_andOr.hide()
    return
  #初始化搜索条件
  initSrch_opt: (srch_pop)->
    t = this
    o = t.options
    srch_name = srch_pop.getE ".srch_name"
    srch_opt = srch_pop.getE ".srch_opt"
    srch_opt.destroyChd()
    srch_value_div = srch_pop.getE ".srch_value_div"
    optArr = srch_name.getEs "option"
    optEl = optArr[srch_name.selectedIndex]
    return if !optEl
    h_type = optEl.get "h:type"
    option = new Element "option",{value:"=",text:o.I18NEny["equal"]}
    option.inject srch_opt
    if h_type is "NumberInput" or h_type is "DateTime" or h_type is "DateInput" or h_type is "TimeInput"
      option = new Element "option",{value:">",text:o.I18NEny["greater"]}
      option.inject srch_opt
      option = new Element "option",{value:">=",text:o.I18NEny["greater_equal"]}
      option.inject srch_opt
      option = new Element "option",{value:"<",text:o.I18NEny["less"]}
      option.inject srch_opt
      option = new Element "option",{value:"<=",text:o.I18NEny["less_equal"]}
      option.inject srch_opt
    else if h_type is "TextInput"
      option = new Element "option",{value:"begin",text:o.I18NEny["begin_with"]}
      option.inject srch_opt
      option = new Element "option",{value:"end",text:o.I18NEny["end_with"]}
      option.inject srch_opt
      option = new Element "option",{value:"like",text:o.I18NEny["contain"]}
      option.inject srch_opt
    return
  #给initSrch_value调用,根据下拉框的选项创建搜索控件
  srchOpt2Iez: (optEl)->
    t = this
    o = t.options
    return if !optEl
    iez = undefined
    h_type = optEl.get "h:type"
    return if !optEl
    if h_type is "TextInput"
      iez = new Element "input",{type:"text","h:apply":"TextInput"}
    else if h_type is "DateInput"
      iez = new Element "input",{type:"date","h:apply":"DateInput"}
    else if h_type is "DateTime"
      iez = new Element "input",{type:"datetime-local","h:apply":"DateTime"}
    else if h_type is "Checkbox"
      iez = new Element "input",{type:"checkbox","h:apply":"Checkbox"}
    else if h_type is "NumberInput"
      iez = new Element "input",{type:"number","h:apply":"NumberInput"}
    else
      iez = new Element "input",{type:"text","h:apply":"TextInput"}
    iez
  #初始化搜索的控件类型
  initSrch_value: (srch_pop)->
    t = this
    o = t.options
    srch_name = srch_pop.getE ".srch_name"
    srch_value_div = srch_pop.getE ".srch_value_div"
    srch_value_div.destroyChd()
    optArr = srch_name.getEs "option"
    optEl = optArr[srch_name.selectedIndex]
    iez = t.srchOpt2Iez optEl
    iez.addClass "srch_value"
    iez.inject srch_value_div
    await iez.onDrawAsync()
    return
  initGrid: ->
    t = this
    o = t.options
    elt = o.ele
    t.initButEvt ["addPg","firstPg","prevPg","nextPg","lastPg","refresh","impxlx","expxlx"]
    await t.frtDtGrid()
    cur_pg = elt.getE ".cur_pg"
    if cur_pg
      cur_pg.addEvent "change",->
        t.cur_pgChg()
        return
      cur_pg.addEvent "keydown",(e)->
        code = e.code
        if code is 13
          t.cur_pgChg()
        return
    pgNumSlt = elt.getE ".pgNumSlt"
    if pgNumSlt
      pgNumSlt.addEvent "change",->
        t.pgNumSltChg this
        return
    return
  #页面刚初始化时,第一次刷新表格
  frtDtGrid: ->
    t = this
    o = t.options
    elt = o.ele
    frtDtGrid = elt.retrieve "frtDtGrid"
    return if frtDtGrid is false
    if frtDtGrid
      await frtDtGrid.apply t,arguments
    else
      await t.dataCount()
      await t.firstPgClk undefined,undefined,true
    return
  #每页显示多少行
  pgNumSltChg: (but)->
    t = this
    o = t.options
    elt = o.ele
    but.set "disabled",true if but
    await t.dataCount()
    await t.firstPgClk undefined,undefined,true
    but.set "disabled",false if but
    return
  #点击刷新按钮
  refreshClk: (but)->
    t = this
    but.set "disabled",true if but
    await t.cur_pgChg true
    but.set "disabled",false if but
    return
  ###
    跳转到当前页码对应的数据
      isRef 如果为true,则强制刷新页面
  ###
  cur_pgChg: (isRef)->
    t = this
    o = t.options
    elt = o.ele
    cur_pg = elt.getE ".cur_pg"
    pdObj = t.getPgOftNum isRef
    #记录偏移量,每页显示记录数
    pgOffset = pdObj.pgOffset
    pgNum = pdObj.pgNum
    if cur_pg
      return if cur_pg.get("value") is cur_pg.get("h:old_value") and isRef isnt true
    await t.dataGrid pgOffset,pgNum
    cur_pg.set "h:old_value",cur_pg.get "value" if cur_pg
    return
  firstPgClk: (but,e,isRef)->
    t = this
    o = t.options
    elt = o.ele
    but = elt.getE "[h:but='firstPg']" if !but
    cur_pg = elt.getE ".cur_pg"
    cur_pg.set "value",1 if cur_pg
    but.set "disabled",true if but
    await t.cur_pgChg isRef
    but.set "disabled",false if but
    return
  nextPgClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    cur_pg = elt.getE ".cur_pg"
    if cur_pg
      pgCur = cur_pg.get("value").toInt()
      cur_pg.set "value",pgCur+1
    but.set "disabled",true if but
    await t.cur_pgChg()
    but.set "disabled",false if but
    return
  prevPgClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    cur_pg = elt.getE ".cur_pg"
    if cur_pg
      pgCur = cur_pg.get("value").toInt()
      cur_pg.set "value",pgCur-1
    but.set "disabled",true if but
    await t.cur_pgChg()
    but.set "disabled",false if but
    return
  lastPgClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    cur_pg = elt.getE ".cur_pg"
    #总页面数
    ttl_pg = elt.getE ".ttl_pg"
    if cur_pg and ttl_pg
      pgCur = cur_pg.get("value").toInt()
      pgTtl = ttl_pg.get("text").toInt()
      cur_pg.set "value",pgTtl
    but.set "disabled",true if but
    await t.cur_pgChg()
    but.set "disabled",false if but
    return
  #给dataCount调用,返回总记录数
  rltSetCount: ->
    t = this
    o = t.options
    rltObj = await o.thisSrv.ajax "dataCount"
    rltObj
  dataCount: ->
    t = this
    o = t.options
    elt = o.ele
    ttl_pg = elt.getE ".ttl_pg"
    return if !ttl_pg
    rltObj = await t.rltSetCount()
    return if !rltObj or !rltObj.count?
    pdObj = t.getPgOftNum()
    #记录偏移量,每页显示记录数
    pgOffset = pdObj.pgOffset
    pgNum = pdObj.pgNum
    pgTtl = Math.ceil rltObj.count/pgNum
    pgTtl = 1 if pgTtl is 0
    ttl_pg.set "text",pgTtl
    return
  #删除一行
  optDelClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    return if !window.confirm o.I18NEny["sure_to_delete"]+"?"
    tr = but.getParent ".dt_tr"
    eny = tr.retrieve "eny"
    but.set "disabled",true if but
    rltSet = await t.delById eny.id
    if rltSet and rltSet.rowCount
      window.ncWg.addNotice "info",o.I18NEny["delete_num_records"].substitute([rltSet.rowCount]),2
      await t.dataCount()
      await t.cur_pgChg true
    but.set "disabled",false if but
    return
  delById: (id)->
    t = this
    o = t.options
    rltSet = await o.thisSrv.ajax "delById",[id]
    rltSet
  #打开编辑页面
  optEditClk: (but,e,pageEny)->
    t = this
    o = t.options
    elt = o.ele
    tr = but.getParent ".dt_tr"
    eny = tr.retrieve "eny"
    if !pageEny
      pageEny = 
        code: o.pageEny.code+"_Edit"
        lbl: o.I18NEny.edit
        url: "/#{o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)}/#{o.enyStr}Edit.html"
        enable: true
    mldOpt = 
      elt:elt
      befOnDraw: ->
        $(this).store "eny",eny
        return
    menuEny = elt.retrieve "menuEny"
    win = await t.menuPg4editPg but,menuEny,pageEny,"modal",mldOpt
    winWg = win.wg()
    await t.initOptEditWin winWg,"edit"
    win
  initOptEditWin: (winWg,type)->
    t = this
    aftSave = winWg.aftSave
    winWg.aftSave = ->
      rvObj = await aftSave.apply this,arguments
      await t.dataCount()
      await t.cur_pgChg true
      rvObj
    return
  #打开增加页面,重写保存成功之后的方法,保存成功之后,刷新表格
  addPgClk: (but,e,pageEny)->
    t = this
    o = t.options
    elt = o.ele
    
    if !pageEny
      pageEny = {
        code: o.pageEny.code+"_Add"
        lbl: o.I18NEny.add
        url: "/#{o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)}/#{o.enyStr}Add.html"
        enable: true
      }
    but.set "disabled",true if but
    menuEny = elt.retrieve "menuEny"
    win = await t.menuPg4addPg but,menuEny,pageEny,"modal",{elt:elt}
    but.set "disabled",false if but
    winWg = win.wg()
    await t.initOptEditWin winWg,"add"
    win
  menuPg4addPg: (but,menuEny,pageEny,openType,optObj)->
    bodyWg = $(document.body).wg()
    win = await bodyWg.menuPg but,menuEny,pageEny,openType,optObj
    win
  menuPg4editPg: (but,menuEny,pageEny,openType,optObj)->
    bodyWg = $(document.body).wg()
    win = await bodyWg.menuPg but,menuEny,pageEny,openType,optObj
    win
  #获得表格分页的偏移量pgOffset跟每页显示记录数pgNum
  getPgOftNum: ->
    t = this
    o = t.options
    elt = o.ele
    cur_pg = elt.getE ".cur_pg"
    ttl_pg = elt.getE ".ttl_pg"
    return {pgOffset:0,pgNum:0} if !cur_pg or !ttl_pg
    pgNumSlt = elt.getE ".pgNumSlt"
    pgTtl = ttl_pg.get("text").toInt()
    pgTtl = 1 if pgTtl is 0
    pgCur = cur_pg.get("value").toInt()
    if isNaN pgCur
      cur_pg.set "value",cur_pg.get "h:old_value"
      return
    if pgCur < 1
      pgCur = 1
      cur_pg.set "value",pgCur
    if pgCur > pgTtl
      pgCur = pgTtl
      cur_pg.set "value",pgCur
    pgNum = 10
    pgNum = Number pgNumSlt.get "value" if pgNumSlt
    pgOffset = (pgCur-1)*pgNum
    {pgOffset:pgOffset,pgNum:pgNum}
  #给dataGrid调用
  rltSetGrid: (pgOffset,pgNum)->
    t = this
    o = t.options
    pgOffset = Number pgOffset
    pgNum = Number pgNum
    rltSet = await o.thisSrv.ajax "dataGrid",[pgOffset,pgNum]
    rltSet
  dataGrid: (pgOffset,pgNum)->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    tbody = grid_tbl.getFirst "tbody"
    #获取数据
    rltObj = await t.rltSetGrid pgOffset,pgNum
    t.emptyGrid()
    return if !rltObj or !rltObj.rltSet
    rltSet = rltObj.rltSet
    for i in [0...rltSet.length]
      eny = rltSet[i]
      t.initTr eny,tbody
    return
  #清空表格
  emptyGrid: ->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    tbody = grid_tbl.getFirst "tbody"
    t.trSld()
    tbody.destroyChd()
    return
  #点击表格中的一行
  trClk: (tr)->
    t = this
    o = t.options
    elt = o.ele
    await t.trSld tr
    return
  #选中第一行
  trSldFrt: ->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    tbody = grid_tbl.getFirst "tbody"
    tr = tbody.getE ".dt_tr"
    await t.trSld tr
    return
  #选中表格中的一行,返回选中的行是否发生了改变
  trSld: (tr)->
    t = this
    o = t.options
    elt = o.ele
    grid_tbl = elt.getE ".grid_tbl"
    tbody = grid_tbl.getFirst "tbody"
    trArr = tbody.getEs ".dt_tr"
    hsChg = false
    if tr
      for trTmp in trArr
        if trTmp is tr
          if !trTmp.hasClass "dt_tr_sld"
            trTmp.addClass "dt_tr_sld"
            o.sld_eny = tr.retrieve "eny"
            hsChg = true
        else
          trTmp.removeClass "dt_tr_sld"
    else
      dt_tr_sldArr = tbody.getEs ".dt_tr_sld"
      if dt_tr_sldArr.length isnt 0
        o.sld_eny = {}
        dt_tr_sldArr.removeClass "dt_tr_sld"
        hsChg = true
    hsChg
  #初始化表格中的一行,dataGrid->initTr
  initTr: (eny,tbody)->
    t = this
    o = t.options
    elt = o.ele
    tr = new Element "tr.dt_tr"
    tr.store "eny",eny
    tr.inject tbody
    tr.addEvent "click",->
      t.trClk this
      return
    
    t.initSltTd tr
    t.initOptTd tr
    
    for j in [0...o.headArr.length]
      t.initTd tr,o.headArr[j]
    tr.inject tbody if tbody
    tr
  #选择
  initSltTd: (tr)->
    t = this
    ###
    sltTd = new Element "td.sltTd"
    sltTd.inject tr
    checkbox = new Element "input[type=checkbox].sltCbx"
    checkbox.inject sltTd
    ###
    return
  #操作
  initOptTd: (tr)->
    t = this
    o = t.options
    grid_tbl = tr.getParent ".grid_tbl"
    optLbl = grid_tbl.getE ".optLbl"
    return if !optLbl
    optTd = new Element "td.optTd"
    optTd.hide() if !optLbl.isDisplayed()
    optTd.inject tr
    t.initOptDel optTd
    t.initOptEdit optTd
    optTd
  #初始化修改按钮
  initOptEdit: (optTd)->
    t = this
    o = t.options
    elt = o.ele
    optEdit = new Element "button",{"class":"optEdit",text:o.I18NEny["edit"]}
    optEdit.addEvent "click",(e)->
      e.stop()
      await t.optEditClk this
      return
    optEdit.inject optTd
    return
  #初始化删除按钮
  initOptDel: (optTd)->
    t = this
    o = t.options
    elt = o.ele
    optDel = new Element "button",{"class":"optDel",text:o.I18NEny["delete"]}
    optDel.addEvent "click",(e)->
      e.stop()
      await t.optDelClk this
      return
    optDel.inject optTd
    return
  initTd: (tr,key,eny)->
    t = this
    o = t.options
    td = new Element "td"
    td.inject tr
    eny = eny or tr.retrieve "eny"
    val = eny[key]
    typ = typeOf val
    if typ is "object" or typ is "array"
      val = JSON.encode val
      td.set "text",val
    else if typ is "boolean"
      if val
        td.set "text",o.I18NEny["yes"]
      else
        td.set "text",o.I18NEny["no"]
    else
      val = "" if val is undefined
      td.set "text",val
    td.addClass "initTd_#{key}"
    td
  #导入Excel
  impxlxClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    fileIez = elt.getFirst ".SysList_impxlx_file"
    if !fileIez
      fileIez = new Element "input",{type:"file","class":"SysList_impxlx_file",style:"display:none;",accept:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"}
      fileIez.addEvent "change",(e)->
        await t.impxlx_fileChg this
        return
      fileIez.inject elt,"top"
    else
      fileIez.value = ""
    fileIez.click()
    return
  impxlx_fileChg: (fileIez)->
    t = this
    o = t.options
    elt = o.ele
    file = fileIez.files[0]
    return if !file
    rltObj = await o.thisSrv.ajax "impxlx_fileChg",[],{uploadFile:file}
    uid = rltObj.uid
    o.thisSrv.downloadByUid uid if uid
    await t.cur_pgChg true
    return
  #导出Excel
  expxlxClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    rltObj = await o.thisSrv.ajax "expxlxClk",[o.$model.headArr,o.$model.headObj]
    uid = rltObj.uid
    o.thisSrv.downloadByUid uid if uid
    return
