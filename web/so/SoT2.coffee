{Srv} = require "Srv"
{SysT2} = require "../sys/SysT2"

#订单标签页
PrnClzz = SysT2
exports.SoT2 = new Class
  Extends: PrnClzz
  options:
    enyStr: "So"
    sld_eny: {}
  onDraw: ->
    t = this
    await PrnClzz.prototype.onDraw.apply t,arguments
  hInclude: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.hInclude.apply t,arguments
    sodListWin = elt.getE "[h:pg=SodList]"
    sodListWinWg = sodListWin.wg()
    initOptEditWin = sodListWinWg.initOptEditWin
    sodListWinWg.initOptEditWin = (winWg,type)->
      rvObj0 = await initOptEditWin.apply this,arguments
      win = $ winWg
      so_idEl = win.getE "[h:iez=so_id]"
      if so_idEl
        so_idEl.set "disabled",true
        so_idWg = so_idEl.wg()
        await so_idWg.setVal o.sld_eny.id
      so_idPl = win.getE "[h:pop=so_id]"
      so_idPl.hide() if so_idPl
      rvObj0
    rvObj
  