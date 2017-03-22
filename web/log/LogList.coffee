require "./LogList.css"
{SysList} = require "../sys/SysList"
requireAsync = Promise.fromCallback require.async

#日志列表
PrnClzz = SysList
exports.LogList = new Class
  Extends: PrnClzz
  options:
    enyStr: "Log"
    headArr: ["pg","usr","ip","act","bef","aft","rem","create_time"]
    headObj:
      "pg":"页面"
      "usr":"用户"
      "ip":"IP地址"
      "bef":"操作前"
      "act":"操作"
      "aft":"操作后"
      "rem":"备注"
      "create_time":"创建时间"
  initPg: ->
    t = this
    await PrnClzz.prototype.initPg.apply t,arguments
  #操作
  initOptTd: (tr)->
  initTd: (tr,key,eny)->
    t = this
    o = t.options
    td = new Element "td"
    td.inject tr
    eny = eny or tr.retrieve "eny"
    val = eny[key]
    if (key is "bef" or key is "aft") and val
      val2 = ""
      if !eny.keys
        key2Arr = Object.keys val
        num = 0
        for key2 in key2Arr
          break if num > 2
          continue if String.isEmpty val[key2]
          val2 += val[key2]+" "
          num++
      else
        key2Arr = eny.keys
        for key2 in key2Arr
          val2 += val[key2]+" "
      val2 += "..."
      but = new Element "button.log_keys_but",{text:val2}
      but.inject td
      but.addEvent "click",->
        await t.eny_butClk this,key
        return
    else
      val2 = undefined
      if val?
        val2 = val
      else
        val2 = ""
      td.set "text",val2
    td.addClass "initTd_#{key}"
    td
  eny_butClk: (but,key)->
    t = this
    o = t.options
    td = but.getParent "td"
    eny_but_div = td.getE ".eny_but_div"
    return if eny_but_div
    tr = td.getParent "tr"
    eny = tr.retrieve "eny"
    val = eny[key]
    head_obj = eny.head_obj
    eny_but_div = new Element "div.eny_but_div"
    eny_but_div.inject but,"after"
    titile_div = new Element "div.titile_div"
    titile_div.inject eny_but_div
    close_div = new Element "div.close_div",{text:"X"}
    close_div.inject titile_div
    close_div.addEvent "click",->
      eny_but_div.destroy()
      return
    new Drag eny_but_div,{
      handle: titile_div
      modifiers:{x:'left',y:'top'}
    }
    content_div = new Element "div.content_div"
    content_div.inject eny_but_div
    key2Arr = Object.keys val
    headObj = undefined
    if head_obj and head_obj[0] and head_obj[1]
      clzz = await requireAsync head_obj[0]
      ho1Arr = head_obj[1].split "."
      for ho1 in ho1Arr
        clzz = clzz[ho1]
        break if !clzz
      headObj = clzz
    for key2 in key2Arr
      item_div = new Element "div.item_div"
      item_div.inject content_div
      key3 = key2
      key3 = headObj[key2] if headObj and headObj[key2]?
      td1_div = new Element "div.td1_div",{text:key3+":"}
      td1_div.inject item_div
      td2_div = new Element "div.td2_div",{text:val[key2]}
      td2_div.inject item_div
    eny_but_div.position {relativeTo:but,position:"topRight"}
    return