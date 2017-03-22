require "./SoAdd.css"
{SysAdd} = require "../sys/SysAdd"

PrnClzz = SysAdd
exports.SoAdd = new Class
  Extends: PrnClzz
  options:
    enyStr: "So"
    headArr: ["id","cr_no","state","usr_id","cm_nm","courier_id","pay_type_id","amt","trust_amt","mbp","cy_thg","qk","addr","rem"]
    headObj:
      "id":"订单编号"
      "cr_no":"快递单号"
      "state":"状态"
      "usr_id":"用户"
      "cm_nm":"客户"
      "courier_id":"快递"
      "pay_type_id":"付款方式"
      "amt":"金额"
      "trust_amt":"代收金额"
      "mbp":"手机"
      "cy_thg":"托寄物内容"
      "qk":"欠款"
      "addr":"地址"
      "create_time":"创建时间"
      "update_time":"修改时间"
      "create_usr":"创建人"
      "update_usr":"修改人"
      "rem":"备注"
    $vdts: ["mbp","addr","courier_id","pay_type_id"]
  initPg: ->
    t = this
    o = t.options
    elt = o.ele
    rvObj = await PrnClzz.prototype.initPg.apply t,arguments
    #客户不允许修改金额跟订单号
    if o.usr._role and o.usr._role.id is 2
      cr_noEl = elt.getE "[h:iez=cr_no]"
      cr_noEl.set "readonly",true
      stateEl = elt.getE "[h:iez=state]"
      stateEl.set "disabled",true
      if o.pgType is "edit"
        amtEl = elt.getE "[h:iez=amt]"
        trust_amtEl = elt.getE "[h:iez=trust_amt]"
        amtEl.set "disabled",true
        trust_amtEl.set "disabled",true
        cr_noEl = elt.getE "[h:iez=cr_no]"
        cr_noEl.set "disabled",true
    else if o.usr._role and o.usr._role.id is 3
      iezArr = elt.getEs "[h:iez]"
      for iez in iezArr
        cont = iez.get "h:iez"
        continue if cont is "cr_no" or cont is "state" or cont is "rem"
        iez.set "disabled",true
    #组长不允许修改金额跟订单号
    else if o.usr._role and o.usr._role.id is 1
      if o.pgType is "edit"
        amtEl = elt.getE "[h:iez=amt]"
        trust_amtEl = elt.getE "[h:iez=trust_amt]"
        amtEl.set "disabled",true
        trust_amtEl.set "disabled",true
        cr_noEl = elt.getE "[h:iez=cr_no]"
        cr_noEl.set "disabled",true
    #快递
    await t.initCourier_id()
    await t.initPay_type_id()
    #客服
    if o.usr.code isnt "admin"
      if o.usr._role.id is 2 or o.usr._role.id is 1
        t.initButEvt ["sod_add_row"]
        t.sod_add_rowClk()
      else
        sod_add_row = elt.getE "[h:but=sod_add_row]"
        sod_add_row.hide() if sod_add_row
    else
      t.initButEvt ["sod_add_row"]
      t.sod_add_rowClk()
    await t.initQk_rm()
    rvObj
  #快捷备注
  initQk_rm: ->
    t = this
    o = t.options
    elt = o.ele
    remEl = elt.getE "[h:iez='rem']"
    qk_rm_div = elt.getE ".qk_rm_div"
    rltSet = await o.thisSrv.ajax "initQk_rm"
    for eny in rltSet
      span = new Element "button.qk_rm"
      span.set "text",eny.lbl
      span.store "eny",eny
      span.setStyles {"margin-left":10}
      span.inject qk_rm_div
      span.addEvent "click",->
        val = remEl.get "value"
        val += " " if val
        remEl.set "value",val+this.retrieve("eny").lbl
        remEl.focus()
        return
    return
  getPgVal: (eny,valOpt)->
    t = this
    o = t.options
    elt = o.ele
    eny = await PrnClzz.prototype.getPgVal.apply t,arguments
    sod_list_div = elt.getE ".sod_list_div"
    sod_list_tbl = sod_list_div.getE ".sod_list_tbl"
    tbody = sod_list_tbl.getE "tbody"
    trArr = tbody.getEs "tr"
    eny.sodArr = []
    for tr in trArr
      sodEny = {}
      pt_idVal = tr.getE(".sod_pt_id").get "value"
      pt_sc_idVal = tr.getE(".sod_pt_sc_id").get "value"
      qtyVal = Number tr.getE(".sod_qty").get "value"
      continue if qtyVal <= 0
      sodEny.pt_id = pt_idVal
      sodEny.pt_sc_id = pt_sc_idVal
      sodEny.qty = qtyVal
      eny.sodArr.push sodEny
    eny
  #增加一行
  sod_add_rowClk: (but)->
    t = this
    o = t.options
    elt = o.ele
    sod_list_div = elt.getE ".sod_list_div"
    sod_list_tbl = sod_list_div.getE ".sod_list_tbl"
    tbody = sod_list_tbl.getE "tbody"
    tr = new Element "tr"
    #操作
    td = new Element "td"
    button_del = new Element "button.button_del",{text:"移除"}
    button_del.setStyle "border","none"
    button_del.inject td
    button_del.addEvent "click",->
      tr.destroy()
      return
    td.inject tr
    #产品
    td = new Element "td"
    td.inject tr
    pt_idEl = new Element "select.Select.sod_pt_id"
    pt_idEl.setStyle "border","none"
    pt_idEl.addEvent "change",->
      await t.initPt_sc_id tr,this.get "value"
      return
    rltSet = await o.thisSrv.ajax "initPt_id"
    for eny in rltSet
      option = new Element "option",{text:eny.lbl,value:eny.id}
      option.store "eny",eny
      option.inject pt_idEl
    pt_idEl.inject td
    #规格
    td = new Element "td"
    td.inject tr
    pt_sc_idEl = new Element "select.Select.sod_pt_sc_id"
    pt_sc_idEl.setStyle "border","none"
    pt_sc_idEl.inject td
    await t.initPt_sc_id tr,pt_idEl.get "value"
    #qty
    td = new Element "td"
    td.inject tr
    qtyEl = new Element "input[type=number].sod_qty"
    qtyEl.setStyle "border","none"
    qtyEl.set "value",1
    qtyEl.inject td
    tr.inject tbody
    do_modal_div = elt.getParent ".do_modal_div"
    t.rePoModal do_modal_div
    return
  initPt_sc_id: (tr,pt_idVal)->
    t = this
    o = t.options
    pt_sc_idEl = tr.getE ".sod_pt_sc_id"
    pt_sc_idEl.destroyChd()
    rltSet = await o.thisSrv.ajax "initPt_sc_id",[pt_idVal]
    for eny in rltSet
      option = new Element "option",{text:eny.lbl,value:eny.id}
      option.store "eny",eny
      option.inject pt_sc_idEl
    return
  #选择快递
  initCourier_id: ->
    t = this
    o = t.options
    elt = o.ele
    courier_idEl = elt.getE "[h:iez=courier_id]"
    rltSet = await o.thisSrv.ajax "initCourier_id"
    courier_idEl.destroyChd()
    for eny in rltSet
      option = new Element "option",{text:eny.lbl,value:eny.lbl}
      option.store "eny",eny
      option.inject courier_idEl
    return
  #支付类型
  initPay_type_id: ->
    t = this
    o = t.options
    elt = o.ele
    pay_type_idEl = elt.getE "[h:iez=pay_type_id]"
    rltSet = await o.thisSrv.ajax "initPay_type_id"
    pay_type_idEl.destroyChd()
    for eny in rltSet
      continue if eny.lbl is "欠款"
      option = new Element "option",{text:eny.lbl,value:eny.lbl}
      option.store "eny",eny
      option.inject pay_type_idEl
    return
  