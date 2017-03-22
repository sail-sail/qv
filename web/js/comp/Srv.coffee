sessionIdOp = ops.sessionId

Srv = exports.Srv = new Class
  Implements: [Events, Options]
  options:
    clz: undefined
    ele: undefined
  initialize: (options) ->
    t = this
    #必须指明调用的是哪个Srv
    if String.isEmpty options.clz
      alert "Srv.ajax,11: Srv.option.clz can not be empty!"
      return
    t.setOptions options
    t
  downloadByUid: (uid,_downloadIframe,opt)->
    t = this
    o = t.options
    return null if uid is null or uid is undefined or uid.trim() is ""
    href = "/"+o.clz.replace("||","%7C%7C")+"/downloadByUid?_sid="+ops._sid+"&_v=v&pms=%5B%22"+encodeURIComponent(uid)+"%22"
    if opt and (opt.attachment is "attachment" or opt.attachment is "inline")
      href += "%2C%22"+opt.attachment+"%22"
    href += "%5D"
    if _downloadIframe isnt false
      window.frames["_downloadIframe"].location.href = href
    href
  closeSrv: ->
    t = this
    await t.ajax "closeSrv"
  succJsn: (json,ajaxOpt)->
    t = this
    o = t.options
    if json.error isnt undefined
      ncWg.addNotice "error",json.error,5 if !String.isEmpty json.error
    if json.info
      ncWg.addNotice "info",json.info,2
    if json.warn
      ncWg.addNotice "warn",json.warn,2
    action = json.action
    if action
      if action[0] is "_reqTimoutByUid"
        uid = action[1]
        json = await t.ajax action[0],[uid],{allJson:true}
        await t.succJsn json,ajaxOpt
      else
        eleWg = o.ele.wg()
        argTmp = undefined
        if action[1] isnt undefined
          argTmp = action[1]
          argTmp = [argTmp] if typeOf(argTmp) isnt "array"
        await eleWg[action[0]].apply eleWg,argTmp
    rskData = null
    if ajaxOpt isnt undefined and ajaxOpt.allJson is true
      rskData = json
    else
      rskData = json.d
    rskData
  ajax: (md,pms,ajaxOpt)->
    t = this
    o = t.options
    url = encodeURI "/#{o.clz}/#{md}"
    data = {}
    rop ={url:url,data:data}
    #IE缓存问题
    #rop.noCache = true if Browser.ie is true
    if pms
      pmsStr = JSON.encode pms
      data.pms = pmsStr
    if ajaxOpt isnt undefined and ajaxOpt.ref_time is false
      data.ref_time = "false"
    if sessionIdOp is undefined or sessionIdOp is "js"
      if ops._sid isnt undefined
        data._sid = ops._sid
    rltSetPm = new Promise (resolve,reject)->
      request = null
      hdle =
        failure: (xhr) ->
          if xhr.status is 0
            ncWg.addNotice "error","服务器连接错误!",3
          else
            ncWg.addNotice "error", url+" "+xhr.status+" "+xhr.statusText, 6
          console.error JSON.encode xhr
          resolve null
          return
        complete: ->
          loadWg.tpMl request
          return
        cancel: ->
          resolve null
          return
        success: (json) ->
          jsonRv = await t.succJsn json,ajaxOpt
          if md is "_sessionId"
            if sessionIdOp is undefined or sessionIdOp is "js" or sessionIdOp is "header"
              ops._sid = jsonRv
            else if sessionIdOp is "cookie"
              Cookie.write "_sid",jsonRv
          resolve jsonRv
          return
        error: (text) ->
          ncWg.addNotice "error", text, 5
          resolve text
          return
      formData = undefined
      if ajaxOpt and ajaxOpt.uploadFile and window.FormData
        rop.urlEncoded = false
        keyArr = Object.keys data
        formData = new FormData()
        for key in keyArr
          formData.append key,data[key]
        if typeOf(ajaxOpt.uploadFile) is "array"
          for upFl,i in ajaxOpt.uploadFile
            formData.append String(i),upFl
        else
          formData.append "0",ajaxOpt.uploadFile
        rop.data = undefined
      request = new Request.JSON(rop).addEvents hdle
      request.options.headers["v"] = "v"
      if sessionIdOp is "header" and ops._sid isnt undefined
        request.setHeader "_sid",ops._sid
      if ajaxOpt and ajaxOpt.uploadFile and window.FormData
        request.send {data:formData}
      else
        if pmsStr isnt undefined and pmsStr isnt null and pmsStr.length > 2000 then request.post()
        else request.get()
      ajaxOpt.request = request if ajaxOpt and ajaxOpt._rvRequest is true
      loadWg.stMl request,ajaxOpt
      return
    rltSetPm

exports.Srv.createWindow = (url,ajaxOpt) ->
  ncWg = window.ncWg
  loadWg = window.loadWg
  resultPm = new Promise (resolve,reject)->
    actObj = {
      success: (eles) ->
        els = []
        for ele in eles
          if typeOf(ele) is "element"
            ele.set "h:url",url
            els.push ele
        resolve els
      failure: (xhr) ->
        ncWg.addNotice "error", url+" "+xhr.status+" "+xhr.statusText, 6
        resolve null
        return
      error: (text, error) ->
        ncWg.addNotice "error", text, 5
        resolve null
        return
      complete: ->
        loadWg.tpMl request
        return
    }
    if ajaxOpt and ajaxOpt.txt
      actObj.success = (txt)->
        resolve txt
        return
      request = new Request({url:url}).addEvents actObj
    else
      request = new Request.HTML({url:url}).addEvents actObj
    #delete request.options.headers["X-Requested-With"]
    #delete request.options.headers["XMLHttpRequest"]
    #delete request.options.headers["Accept"]
    #delete request.options.headers["X-Request"]
    request.get()
    loadWg.stMl request
    return
  resultPm
