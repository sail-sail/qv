{Srv} = require "Srv"
{SysT2} = require "../sys/SysT2"

#产品标签页
PrnClzz = SysT2
exports.PtT2 = new Class
  Extends: PrnClzz
  options:
    enyStr: "Pt"
    sld_eny: {}
  onDraw: ->
    t = this
    await PrnClzz.prototype.onDraw.apply t,arguments
  hInclude: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.hInclude.apply t,arguments
    pt_scListWin = elt.getE "[h:pg=Pt_scList]"
    pt_scListWinWg = pt_scListWin.wg()
    initOptEditWin = pt_scListWinWg.initOptEditWin
    pt_scListWinWg.initOptEditWin = (winWg,type)->
      rvObj0 = await initOptEditWin.apply this,arguments
      win = $ winWg
      pt_idEl = win.getE "[h:iez=pt_id]"
      if pt_idEl
        pt_idEl.set "disabled",true
        pt_idWg = pt_idEl.wg()
        await pt_idWg.setVal o.sld_eny.lbl
      pt_idPl = win.getE "[h:pop=pt_id]"
      pt_idPl.hide() if pt_idPl
      rvObj0
    rvObj
  