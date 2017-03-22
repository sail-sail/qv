{SysWin} = require "SysWin"
{Srv} = require "Srv"

exports.MainFrame = new Class
  Extends: SysWin
  options:
    thisSrv: undefined
    usr: {_role:{}}
    I18NEny:
      "logo_title":""
      "session_timeout_msg":"登录超时,请重新登录!"
      "select":"选择"
      "empty":"清空"
      "confirm":"确定"
      "cancel":"取消"
      "current_user":"当前用户"
      "homepage":"主页"
      "edit_password":"修改密码"
      "logout":"退出登录"
      "system_menu":"系统菜单"
      "select_one_row":"请选择一行!"
  I18NEnyAfter: (key,val)->
    if key is "logo_title"
      document.title = val
    return
  initThisSrv: ->
    t = this
    o = t.options
    elt = o.ele
    o.thisSrv = new Srv {clz:"sys.MainFrameSrv"}
    o.thisSrv.options.ele = elt
    return
  onDraw: ->
    t = this
    o = t.options
    t.initAvalon()
    t.initThisSrv()
    await t.initLogin()
    ###debug $(document).addEvent "keydown",(e)->
      code = e.code
      uid = 'b2730998-8286-469c-ac16-97757ff76956'
      if code is 117
        try
          thisSrv = new Srv {clz:"sys.MainFrameSrv"}
          rltSet = await thisSrv.ajax "_clearCache",[uid]
          window.ncWg.addNotice "info",rltSet,1
        catch err
          console.error err
        e.stop()
      else if code is 118
        for key of seajs.cache
          delete seajs.cache[key]
        for key of seajs.data.fetchedList
          delete seajs.data.fetchedList[key]
        window.ncWg.addNotice "info","js清空",1
      else if code is 119
        links = $$ "link"
        for link in links
          href = link.get "href"
          link.set "href",href
      return###
    return
  initLogin: ->
    t = this
    o = t.options
    elt = o.ele
    loginWin = await Srv.createWindow "/usr/Login.html"
    loginWin = loginWin[0]
    loginWin.inject elt
    await loginWin.onDrawAsync()
    loginWinWg = loginWin.wg()
    loginWinWg.lgnSucc = ->
      await this.closePage()
      elt.getE(".main_bl_layout").setStyle "visibility"
      loginWin.destroy()
      loginWin = undefined
      await t.initFrm()
      return
    await loginWinWg.afterDraw() if loginWinWg.afterDraw
    return
  ###
    通过页面实体类打开页面
      @menuEny 表 menu 的实体类
      @pageEny 表 page 的实体类
      @open_op 表 menu.open_op 打开页面的方式 tab选项卡, module模态窗口
      @opt 选项,高度宽度等,例如: {width:600,height:550}
      @return 返回被打开的页面win
  ###
  menuPg: (but,menuEny,pageEny,open_op,opt)->
    t = this
    o = t.options
    elt = o.ele
    page = pageEny.code
    if page and open_op is "tab"
      win = elt.getE ".main_tabbox>.tabpanels>.tabpanel>[h:pg=#{page}]"
      if win
        win.eliminate "fromBut"
        win.store "fromBut",but
        winWg = win.wg()
        tabWg = winWg.getTabWg()
        tabWg.select() if tabWg
        return win
    url = pageEny.url
    return if String.isEmpty url
    lbl = pageEny.lbl
    win = await Srv.createWindow url
    win = win[0]
    win.store "menuEny",menuEny
    win.store "fromBut",but
    win.set "h:pg",page if page
    win.store "pageEny",pageEny
    if opt and opt.storeMd
      win.store "storeMd",opt.storeMd
    if opt and opt.isMainFrame
      win.store "isMainFrame",true
    win.befOnDraw = opt.befOnDraw if opt and opt.befOnDraw
    if open_op is "tab"
      main_tabbox = elt.getE ".main_tabbox"
      main_tabboxWg = main_tabbox.wg()
      main_tabboxWg.hasNotTab = ->
      tabObj = await main_tabboxWg.addTabAsync lbl,true
      win.hide()
      tabObj.tabpanel.grab win
      tabWg = tabObj.tab.wg()
      tabWg.select()
      await win.onDrawAsync()
      winWg = win.wg()
      winWg.options.menuEny = menuEny
      winWg.options.pageEny = pageEny
      win.show()
      tmpFn = ->
        await winWg.closePage()
        tabWg.deleteTab()
        tabWg = undefined
        winWg = undefined
        win = undefined
        return
      tabWg.addEvent "close",->
        tmpFn()
        return
      tabObj.tab.addEvent "dblclick",->
        tmpFn()
        return
    else if open_op is "modal"
      opt = opt or {}
      opt.isHide = true
      do_modal_div = await t.doModal win,lbl,opt
      await win.onDrawAsync()
      winWg = win.wg()
      winWg.options.menuEny = menuEny
      winWg.options.pageEny = pageEny
      do_modal_div.show()
      await winWg.aftDoModal() if winWg.aftDoModal
      closePage = winWg.closePage
      winWg.closePage = ->
        rv = await closePage.apply this,arguments
        do_modal_div.destroy()
        do_modal_div = undefined
        winWg = undefined
        win = undefined
        rv
    win
  #通过菜单实体类打开页面
  menuClk: (but,e,opt)->
    t = this
    o = t.options
    elt = o.ele
    menuEny = but.retrieve "eny"
    opt = opt or {}
    opt.isMainFrame = true
    win = await t.menuClk0 but,menuEny,opt
    win
  menuClk0: (but,menuEny,opt)->
    t = this
    o = t.options
    elt = o.ele
    open_op = menuEny.open_op or "tab"
    page_id = menuEny.page_id
    return if !page_id
    pageEny = await o.thisSrv.ajax "findPageById",[page_id]
    return if !pageEny
    win = await t.menuPg but,menuEny,pageEny,open_op,opt
    win
  menuClkByPg: (but,menuEny,pgCode,open_op,opt)->
    t = this
    o = t.options
    elt = o.ele
    rltSet = await o.thisSrv.ajax "findPageByCode",[pgCode]
    return if !rltSet or !rltSet[0]
    open_op = open_op or "tab"
    win = await t.menuPg but,menuEny,rltSet[0],open_op,opt
    win
  et_pswClk: (but,e)->
    t = this
    o = t.options
    elt = o.ele
    return if but.get "disabled"
    but.set "disabled",true
    await t.menuClkByPg but,null,"Et_psw","modal",{elt:elt,width:450,height:400}
    but.set "disabled",false
    return
  exit_loginClk: (but,e)->
    t = this
    o = t.options
    elt = o.ele
    localStorage.removeItem "Login.rembPhoneVal.1" if !t.isElectron()
    return if but.get "disabled"
    but.set "disabled",true
    await o.thisSrv.ajax "_clearSession"
    window.close()
    window.location.reload()
    return
  fgt_pswClk: (but,e)->
    t = this
    o = t.options
    elt = o.ele
    localStorage.removeItem "Login.rembPhoneVal.1"
    but.set "disabled",true
    await o.thisSrv.ajax "_clearSession"
    window.location.reload()
    return
  initFrm: ->
    t = this
    o = t.options
    elt = o.ele
    o.usr = window._usr
    
    await t.initI18N()
    
    et_psw = elt.getE ".main_bl_layout>.bl_noth_cont .mfToolbar .et_psw"
    et_psw.addEvent "click",(e)->
      t.et_pswClk this,e
      return
    exit_login = elt.getE ".main_bl_layout>.bl_noth_cont .mfToolbar .exit_login"
    exit_login.addEvent "click",(e)->
      t.exit_loginClk this,e
      return
    fgt_psw = elt.getE ".main_bl_layout>.bl_noth_cont .mfToolbar .fgt_psw"
    fgt_psw.addEvent "click",(e)->
      t.fgt_pswClk this,e
      return
    
    menu_tree = elt.getE ".menu_tree"
    menu_treeWg = menu_tree.wg()
    menu_treeWg.treAllPrnId = (eny)->
      rltSet = await o.thisSrv.ajax "treAllPrnId",[eny.id,"menu"]
      rltSet
    menu_treeWg.getLbl = (tree_li)->
      menuEny = tree_li.retrieve "eny"
      lbl = menuEny.lbl or ""
      lbl
    menu_treeWg.isLeaf = (tree_li)->
      menuEny = tree_li.retrieve "eny"
      menuEny.is_leaf
    menu_treeWg.getChildren = (tree_li,hLvl)->
      lis = []
      rltSet = []
      if hLvl is 0
        rltSet = await o.thisSrv.ajax "menuRoot"
      else
        eny = tree_li.retrieve "eny"
        rltSet = await o.thisSrv.ajax "menuCld",[eny.id]
      for eny in rltSet
        li = new Element "div"
        li.store "eny",eny
        li.addEvent "click",(e)->
          t.menuClk this,e
          return
        lis.push li
      lis
    await menu_treeWg.dataTree()
    await t.initMain_pgEvt()
    return
  initMain_pgEvt: ->
    t = this
    o = t.options
    elt = o.ele
    main_pg = elt.getE ".main_bl_layout>.bl_noth_cont .mfToolbar .main_pg"
    main_pg.addEvent "click",(e)->
      t.main_pgClk this,e
      return
    await t.main_pgClk main_pg
    return
  main_pgClk: (but,e)->
    t = this
    o = t.options
    elt = o.ele
    return if but.get "disabled"
    but.set "disabled",true
    await t.menuClkByPg but,null,"Main_pg","tab",{elt:elt}
    but.set "disabled",false
    return