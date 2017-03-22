{Srv} = require "Srv"

exports.SysEdit = new Class
  options:
    pgType: "edit"
  onDraw: ->
    t = this
    o = t.options
    elt = o.ele
    await t.initEdit()
    await t.PrnClzz.prototype.onDraw.apply t,arguments
    eny = elt.retrieve "eny"
    await t.setPgVal eny
    await t.setPgOldVal eny
    return
  initEdit: ->
    t = this
    o = t.options
    elt = o.ele
    hInclude = elt.get "h:include"
    return if !hInclude
    hInclude = hInclude.trim()
    h_url = elt.get "h:url"
    if hInclude.startsWith "."
      hInclude = h_url.basename("/")+hInclude.substring 1
    win = await Srv.createWindow hInclude
    win = win[0]
    winCld = win.getChildren()
    winCld.inject elt
    await winCld.onDrawAsync()
    return
  confirmButClk: (but,e,headArr)->
    t = this
    o = t.options
    elt = o.ele
    but.set "disabled",true if but
    isPass = await t.runAllVdts()
    #验证不通过
    if !isPass
      but.set "disabled",false if but
      return
    eny = {}
    headArr = headArr or o.headArr
    await t.getPgValEdit eny
    rltSet = await t.confirmRst eny,headArr
    but.set "disabled",false if but
    await t.aftSave rltSet
    return
  getPgValEdit: (eny)-> await this.getPgVal eny
  confirmRst: (eny,headArr)->
    t = this
    o = t.options
    elt = o.ele
    eny0 = elt.retrieve "eny"
    eny.id = eny0.id
    rltSet = await t.PrnClzz.prototype.confirmRst.apply t,[eny,headArr]
    rltSet
  initThisSrv: (clz)->
    t = this
    o = t.options
    elt = o.ele
    clz = clz or o.enyStr.charAt(0).toLowerCase()+o.enyStr.substring(1)+"."+o.enyStr+"EditSrv"
    
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
  setPgVal: (eny,headArr)->
    t = this
    o = t.options
    elt = o.ele
    eny = eny or {}
    headArr = headArr or o.headArr
    
    headArr = headArr.clone()
    imgInputArr = elt.getEs ".ImgInput"
    for iez in imgInputArr
      key = iez.get "h:iez"
      headArr.erase key
      continue if !eny[key]
      uid = await o.thisSrv.ajax "oid2uid",[eny[key]]
      iez.wg().setVal uid if uid
    
    await t.PrnClzz.prototype.setPgVal.apply t,[eny,headArr]
    return
  setPgOldVal: (eny,headArr)->
    t = this
    o = t.options
    elt = o.ele
    headArr = headArr or o.headArr
    headArr = headArr.clone()
    imgInputArr = elt.getEs ".ImgInput"
    for iez in imgInputArr
      key = iez.get "h:iez"
      headArr.erase key
    t.PrnClzz.prototype.setPgOldVal.apply t,[eny,headArr]
    for iez in imgInputArr
      iezWg = iez.wg()
      iezWg.setOldVal await iezWg.getVal()
    return
