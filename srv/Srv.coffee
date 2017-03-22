fs = require "fs"
path = require "path"
querystring = require "querystring"
uuid = require "uuid"
fsAsync = require "fsAsync"
{XMLHttpRequest} = require "xmlhttprequest"
{Dumper} = require "Dumper"
{Dao} = require "../dao/Dao"
Util = require "../util/Util"

ResFile = require "../util/ResFile"

exports.Srv = new Class
  Implements: [Events, Options]
  #session会话
  session: {}
  #保存当前会话的状态
  _state:
    download:{}
    _reqTimeout: {}
  options:
    #本类的名称sys.MenuSrv
    srvPath: "Srv"
    #本类对应的Dao
    dao: null
  initialize: (options) ->
    t = this
    t.setOptions options
    return
  onDraw: ->
    t = this
    o = t.options
    o.dao = Dao.getInstance()
    t.escapeId = o.dao.escapeId
    t.literalId = o.dao.literalId
    t.plv8Block = o.dao.plv8Block
    return
  #外界主动清除session
  _clearSession: (reqOpt)->
    t = this
    o = t.options
    session = t.session
    if session isnt undefined and session._sess_time isnt undefined
      clearTimeout session._sess_time
    if reqOpt._sid
      delete t._srvFactory[reqOpt._sid]
    ""
  #页面关闭,释放内存_state
  closeSrv: (reqOpt)->
    t = this
    o = t.options
    delete t._srvFactory[reqOpt._sid][reqOpt.srvKey] if reqOpt._sid and t._srvFactory[reqOpt._sid]
    ""
  callPlv8: (reqOpt,sql)->
    t = this
    keyName = String.uniqueID()
    sql = """
    do $$
    var rltSet_rv = rltSet_gl["#{keyName}"] = [];
    #{sql}
    $$ language plv8
    """
    isInConn2 = !reqOpt.conn2
    if isInConn2
      reqOpt.conn2 = await t.getConn reqOpt
    rltSet = []
    try
      await t.callSql reqOpt,sql
    finally
      try
        glObj = await t.callOne reqOpt,"select qk_rltSet_gl('#{keyName}') obj"
        rltSet = glObj.obj
      finally
        await t.endConn reqOpt if isInConn2
    rltSet
  callFld: (reqOpt,sql,argArr,rsNum,fld)->
    t = this
    o = t.options
    rltSet = await t.callSql reqOpt,sql,argArr,rsNum
    rltSet = rltSet.rows
    eny = rltSet[0]
    eny[fld]
  callOne: (reqOpt,sql,argArr,rsNum)->
    t = this
    o = t.options
    rltSet = await t.callSql reqOpt,sql,argArr,rsNum
    rltSet = rltSet.rows
    eny = rltSet[0]
    eny
  callArr: (reqOpt,sql,argArr,rsNum)->
    t = this
    o = t.options
    rltSet = await t.callSql reqOpt,sql,argArr,rsNum
    rltSet = rltSet.rows
    rltSet
  #sp存储过程名称,spArg存储过程参数,rsNum存储过程返回的结果集个数
  callSp: (reqOpt,sp,spArg,rsNum) ->
    t = this
    o = t.options
    dao = o.dao
    rltSet = await dao.callSp reqOpt,sp,spArg,rsNum
    rltSet
  callSql: (reqOpt,sql,argArr,rsNum)->
    t = this
    o = t.options
    throw new Error "Srv.callSql the first argument must be reqOpt!" if reqOpt and reqOpt.reqOpt_ibmkx5s8 isnt true
    rltSet = await o.dao.callSql reqOpt,sql,argArr,rsNum
    rltSet
  getConn: (reqOpt)->
    t = this
    o = t.options
    o.dao.getConn reqOpt
  endConn: (reqOpt)->
    t = this
    o = t.options
    o.dao.endConn reqOpt
  destroyConn: (reqOpt)->
    t = this
    o = t.options
    o.dao.destroyConn reqOpt
  beginTran: (reqOpt)->
    t = this
    o = t.options
    o.dao.beginTran reqOpt
  commitTran: (reqOpt)->
    t = this
    o = t.options
    o.dao.commitTran reqOpt
  rollbackTran: (reqOpt)->
    t = this
    o = t.options
    o.dao.rollbackTran reqOpt
  setAutoCommit: (reqOpt)->
    t = this
    o = t.options
    o.dao.setAutoCommit reqOpt
  "@_sessionId":{notSid:true}
  _sessionId: ->
    t = this
    o = t.options
    _sid = uuid.v4()
    _sid
  #图片上传控件
  imgInput: (reqOpt,file)->
    t = this
    o = t.options
    uid = await t.buf2uid reqOpt,file.path,file.name
    uid
  #把需要下载的文件或buffer转为uid
  "@buf2uid":{_private: true}
  buf2uid: (reqOpt,buf,name,callback)->
    t = this
    uid = String.uniqueID()
    if typeOf(buf) is "string"
      t._state.download[uid] = {buffer:buf,name:name,callback:callback}
      return uid
    tmpFileName = await Util.writeTmpFile buf
    t._state.download[uid] = {name:name,buffer:tmpFileName,callback:callback}
    uid
  #通过uid下载文件
  downloadByUid: (reqOpt,uid,attachment)->
    t = this
    o = t.options
    res = reqOpt.res
    req = reqOpt.req
    reqOpt.res_auto_end = false
    if uid is null or uid is undefined or uid.trim() is ""
      res.end()
      return
    download = t._state.download
    path2 = download[uid].buffer
    remove = download[uid].remove
    gzip = download[uid].gzip
    attachment = download[uid].attachment or "attachment"
    throw new Error "attachment must be attachment or inline!" if attachment isnt "attachment" and attachment isnt "inline"
    throw req.url if path2 is undefined or path2 is null
    name = download[uid].name or "download"
    #中文文件名乱码问题
    name = encodeURIComponent name
    extname = path.extname(name).substring 1
    if extname
      extname = extname.toLowerCase()
      res.setHeader "Content-Type", ResFile.mime[extname] if ResFile.mime[extname]
    res.setHeader "Content-Disposition",attachment+"; filename="+name+"; charset=UTF-8"
    throw "t._state.download path2 cannot be buffer! it must be string!" if typeOf(path2) isnt "string"
    #Content-Encoding  ctEn
    if attachment is "inline" and gzip isnt false
      buffer2 = await fsAsync.readFileAsync path2
      gf = await ResFile.gzipFn req.headers["accept-encoding"],extname,buffer2
      buffer2 = gf.zipBuf
      ctEn = gf.zipType
      ResFile.md5Etag buffer2,ctEn,req,res
    else
      await new Promise (resolve,reject)->
        readstream = fs.createReadStream path2
        readstream.on "data",(chunk)->
          res.write chunk
          return
        readstream.on "end",->
          res.end()
          resolve()
          return
        readstream.on "error",(err)->
          reject err
          return
        return
    callback = download[uid].callback
    if callback
      await callback path2
    if remove is true
      delete download[uid]
    return
  #清空缓存
  _clearCache: (reqOpt,uid)->
    throw "_clearCache is not defined!" if uid isnt "b2730998-8286-469c-ac16-97757ff76956"
    keys = Object.keys require.cache
    outKeyArr = ["/dao/","/node_modules/","/node-inspector/"]
    for key in keys
      keyTmp = key.replace /\\/gm,"/"
      has = false
      for outKey in outKeyArr
        if keyTmp.indexOf(outKey) isnt -1
          has = true
          break
      if !has
        console.log key
        delete require.cache[key]
    "success"
  getClientIp: (reqOpt)->
    ip = reqOpt.req.headers['x-forwarded-for'] or reqOpt.req.connection.remoteAddress or reqOpt.req.socket.remoteAddress or reqOpt.req.connection.socket.remoteAddress
    ip = ip.replace "::ffff:","" if ip
    ip
  getLanguage: (reqOpt)->
    t = this
    o = t.options
    req = reqOpt.req
    headers = req.headers
    language = headers["accept-language"]
    if language
      language = language.split(";")
      if language.length > 0
        language = language[0]
        if language
          language = language.split(",")
          language = language[0]  if language.length > 0
    language
  ajaxMd: (url,pms,optObj)->
    t = this
    json = {}
    json.pms = JSON.encode pms if pms
    method = "GET"
    method = "POST" if json.pms and json.pms.length > 2000
    rvObj = await t.ajax url,json,method,optObj
    throw error if rvObj.error
    console.log rvObj.info if rvObj.info
    console.warn rvObj.warn if rvObj.warn
    rvObj.d
  ajax: (url,json,method,optObj)->
    t = this
    o = t.options
    console.log "Srv.ajax:"
    console.log arguments
    if !String.isEmpty method
      method = method.toUpperCase()
      method = "GET" if method isnt "GET" and method isnt "POST"
    else
      method = "GET"
    parms = json
    jsonType = typeOf json
    if Buffer.isBuffer json
      parms = json
    else if jsonType is "object" or jsonType is "array"
      parms = querystring.stringify json
    else if jsonType is "string"
      parms = json
    return await new Promise (resolve,reject)->
      xhr = new XMLHttpRequest()
      xhr.onreadystatechange = ->
        if this.readyState is 4
          status = this.status
          statusText = this.statusText
          if status isnt 200
            reject statusText
            return
          try
            responseText = this.responseText
            jsonRv = undefined
            if optObj and optObj.returnBuffer
              jsonRv = responseText
            else
              jsonRv = JSON.decode responseText.toString()
            resolve jsonRv
          catch err
            reject statusText
            return
        return
      xhr.open method,url
      if optObj and optObj.header
        for key of optObj.header
          xhr.setRequestHeader key,optObj.header[key]
      xhr.setRequestHeader "Content-type","application/x-www-form-urlencoded" if !optObj or !optObj.header or !optObj.header["Content-type"]
      xhr.send parms,optObj and optObj.myOptions
      return
  #执行srv的方法
  "@_applyMd":{_private: true}
  _applyMd: (reqOpt,mdStr,pms)->
    t = this
    o = t.options
    srvPath = reqOpt.srvPath
    Dumper.setMaxDepth 100
    Dumper.setNewLine ""
    Dumper.setIndentText ""
    console.log ""
    if pms is undefined
      console.log Dumper.write [srvPath,mdStr]
    else
      console.log Dumper.write [srvPath,mdStr,pms]
    o.srvPath = srvPath
    reqOpt.mdStr = mdStr
    reqOpt.pms = pms
    uid = undefined
    rqt = t._state._reqTimeout
    aMdObj = t["@"+mdStr]
    if mdStr is "_reqTimoutByUid"
      uid = pms[0]
      throw "_reqTimoutByUid pms[0] must be string" if uid is undefined
      tk = rqt[uid]
      tk = "" if tk is undefined
    else
      method = t[mdStr]
      throw srvPath+" has not method "+mdStr if method is undefined
      throw srvPath+"/"+mdStr+" is _private" if aMdObj isnt undefined and aMdObj._private is true
      throw srvPath+"/"+mdStr+" is protected" if (method.$origin and method.$origin.$protected is true) or method.$protected is true
      if pms isnt undefined
        pmsType = typeOf pms
        if pmsType isnt "array" and pmsType isnt "arguments"
          pms = [reqOpt,pms]
        else
          pms.unshift reqOpt
      else
        pms = [reqOpt]
      #开启事务
      if aMdObj and aMdObj.isTran
        reqOpt.isTran = true
        await t.getConn reqOpt
        try
          await t.beginTran reqOpt
        catch er2
          t.endConn reqOpt
          throw er2
      tk = method.apply t,pms
      if !tk instanceof Promise
        await t.commitTran reqOpt if reqOpt.isTran
        return tk
    tmk = undefined
    isTimeout = false
    taskTm = new Promise (resolve,reject)->
      tmk = setTimeout(->
        isTimeout = true
        resolve()
        return
      ,60000)
      return
    rv = await Promise.race [taskTm,tk]
    clearTimeout tmk if tmk isnt undefined
    if isTimeout
      uid = String.uniqueID() if uid is undefined
      reqOpt.action = ["_reqTimoutByUid",uid]
      rqt[uid] = tk
      return ""
    delete rqt[uid]
    await t.commitTran reqOpt if reqOpt.isTran
    rv
  #清除ascii表里面的控制字符
  clearCtrlChar: (str)->
    str2 = ""
    for i in [0...str.length]
      charTmp = str.charCodeAt i
      continue if charTmp <= 31 and charTmp isnt 9 and charTmp isnt 10 or charTmp is 127
      str2 += str.charAt i
    str2
  includeFtl: (reqOpt,url)->
    t = this
    o = t.options
    htmlStr = ""
    url2 = global._PROJECT_PATH+url
    htmlStr = await fsAsync.readFileAsync url2,"utf-8"
    debug_open = "<%"
    debug_close = "%>"
    uuidStr = "29ce888385c9de594b790798e81332ae"
    htmlStr = htmlStr.replace /'/g,uuidStr
    reg = new RegExp debug_open.escapeRegExp()+"([\\s\\S]*?)"+debug_close.escapeRegExp(),"g"
    htmlStr = htmlStr.replace reg,(str)->
      str = str.trim()
      len = str.length
      openLen = debug_open.length
      closeLen = debug_close.length
      str = str.substring(openLen,len-closeLen).trim()
      str = str.replace new RegExp(uuidStr,"g"),"'"
      if str.startsWith "="
        str = str.substring 1
        str = "'+#{str}+'"
      else
        str = "';#{str};_out_+='"
      str
    htmlStr = htmlStr.replace(new RegExp(uuidStr,"g"),"\\'").replace(/\n/g,"\\n").replace(/\r/g,"\\r").replace(/\t/g,"\\t")
    htmlStr = """
    var _out_='';
    _out_+='#{htmlStr}';
    _out_;
    """
    htmlStr
