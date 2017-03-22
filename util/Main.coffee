console.time "Start Server"
http = require "http"
http.globalAgent.maxSockets = Infinity
url = require "url"
fsAsync = require "fsAsync"
path = require "path"
formidable = require "formidable"
later = require "later"
ResFile = require "./ResFile"
config = require "../config"

srvFactory = {}
exports.srvFactory = srvFactory
secLong = config.sessionTimeout
secLong = 1800 if !secLong
secLong *= 1000

sessionIdOp = config.sessionId

srvFactory._srvClz = (reqOpt,key,_sid,req,res)->
  reqOpt.req = req
  reqOpt.res = res
  clzs = key.split "||"
  reqOpt.srvPath = clzs[clzs.length-1]
  reqOpt.srvKey = clzs[0]
  srvPath = clzs[clzs.length-1].replace /\./gm,"/"
  reqOpt._sid = _sid
  if _sid and srvFactory[_sid] and srvFactory[_sid][clzs[0]]
    srv = srvFactory[_sid][clzs[0]]
    return srv
  throw new Error key if !clzs[0]
  srvName = path.basename srvPath
  try
    clazz = require("../srv/"+srvPath)[srvName]
  catch err
    console.error req.socket.remoteAddress if req
    throw err
  throw new Error srvPath+" The Class name is not correct! It may be "+path.basename srvPath if !clazz
  srv = new clazz()
  srv._srvFactory = srvFactory
  if _sid and srvFactory[_sid]
    srvFactory[_sid][clzs[0]] = srv
    srv.session = srvFactory[_sid].session
    srv._srvClz = (key)-> await srvFactory._srvClz reqOpt,key,_sid,req,res
  await srv.onDraw() if srv.onDraw
  srv

server = http.createServer((req,res)->
  #_sid sessionId,conn2 事务对应的连接,isTran是否开启事务,action执行完方法之后,向浏览器返回的命令
  #res_auto_end是否自动执行res.end(), _uid用于标识临时表,tmpTableArr已经创建的临时表的名字
  #reqOpt_ibmkx5s8为true则认为是reqOpt对象
  #rollbackTran方法执行完毕之后,是否回滚事务
  reqOpt = {_sid:undefined,tmpTableArr:[],req:req,res:res,res_auto_end:true,isTran:false,rollbackTran:false,conn2:undefined,action:undefined,error:"",info:"",_private:undefined,srvPath:undefined,srvKey:undefined,mdStr:undefined,pms:undefined,reqOpt_ibmkx5s8:true}
  tmpFn = ->
    headers = req.headers
    method = req.method
    urlParse = url.parse req.url,true
    hdv = undefined
    if method is "GET" or method is "get"
      parms = urlParse.query or {}
      if headers.hasOwnProperty "v"
        hdv = headers["v"]
      else
        hdv = parms._v if parms
    else if method is "POST" or method is "post"
      hdv = "v"
      parms = urlParse.query
      parms = parms or {}
      form = new formidable.IncomingForm()
      form.uploadDir = _PROJECT_PATH+"/tmp"
      form.on "field",(field, value)->
        if field is "pms"
          parms.pms = parms.pms or []
          value = JSON.decode value if typeOf(value) is "string"
          parms.pms.append value
        else
          parms[field] = value
        return
      fileObj = {}
      fileKey = []
      form.on "file",(field,file)->
        fileObj[field] = file
        fileKey.push field
        return
      form.on "buffer",(buffer)->
        parms.pms = [buffer]
        return
      await new Promise (resolve,reject)->
        form.on "error",(err)->
          reject err
          return
        form.on "end",->
          if fileKey.length > 0
            parms.pms = parms.pms or []
            for key in fileKey
              parms.pms[key] = fileObj[key]
          resolve()
          return
        form.parse req
        return
    else
      res.writeHead 404
      res.write method
      res.end()
      return
    ph = path.normalize(decodeURI(urlParse.pathname)).replace /\\/gm,"/"
    ph = config.mapping ph,req if config.mapping
    phs = ph.split "/"
    if hdv isnt "v" and !String(phs[1]).endsWith "Srv"
      await ResFile.resFile ph,req,res
      return
    res.setHeader "Cache-Control","no-cache"
    res.setHeader "Pragma","no-cache"
    res.setHeader "Content-Type","application/json;charset=utf-8"
    throw new Error ph if phs.length < 3
    mdStr = phs[2]
    pms = null
    if typeOf(parms.pms) is "string"
      try
        pms = JSON.decode parms.pms
      catch err
        console.error err
        throw err
    else
      pms = parms.pms
    srv = undefined
    #获得_sid
    _sid = undefined
    if sessionIdOp is undefined or sessionIdOp is "js"
      _sid = parms._sid
    else if sessionIdOp is "header"
      _sid = headers["_sid"]
    else if sessionIdOp is "cookie" and headers.cookie
      cookieArr = headers.cookie.split ";"
      for item in cookieArr
        itemArr = item.split "="
        key = String(itemArr[0]).trim()
        if key is "_sid"
          _sid = itemArr[1]
          break
    _sid = parms._sid if !_sid
    
    if _sid and srvFactory[_sid] and parms.ref_time isnt "false"
      session = srvFactory[_sid].session
      clearTimeout session._sess_time
      session._sess_time = undefined
      session._reqNum++
    
    srv = await srvFactory._srvClz reqOpt,phs[1],_sid,req,res
    
    #执行srv的方法
    err = undefined
    tk = undefined
    rollbackTran = reqOpt.rollbackTran
    try
      tk = await srv._applyMd reqOpt,mdStr,pms
      rollbackTran = reqOpt.rollbackTran
    catch er
      err = er
      rollbackTran = false
      #回滚事务
      if !err.fatal
        await srv.rollbackTran reqOpt
      else
        srv.endConn reqOpt
    if rollbackTran
      await srv.rollbackTran reqOpt
    if _sid and srvFactory[_sid] and parms.ref_time isnt "false"
      session = srvFactory[_sid].session
      session._reqNum--
      if session._reqNum is 0
        session._sess_time = setTimeout(->
          await srv._clearSession reqOpt
          return
        ,secLong)
    throw err if err
    if reqOpt.res_auto_end
      drJson = {d:tk}
      drJson.action = reqOpt.action if reqOpt.action
      drJson.error = reqOpt.error if reqOpt.error
      drJson.info = reqOpt.info if reqOpt.info
      if mdStr is "_sessionId"
        srvFactory[tk] = {}
        srvFactory[tk].session = {}
        srvFactory[tk].session._reqNum = 0
        srvFactory[tk].session._sess_time = setTimeout(->
          await srv._clearSession reqOpt
          return
        ,secLong)
      gf = await ResFile.gzipFn headers["accept-encoding"],"json",new Buffer JSON.encode drJson
      ResFile.md5Etag gf.zipBuf,gf.zipType,req,res
    return
  try
    await tmpFn()
  catch err
    if !err.is_out
      if err.stack
        console.error err.stack
      else
        console.error err
    err.is_out = true
    if reqOpt.res_auto_end
      error = err.toString()
      try
        error = JSON.encode err if error is "[object Object]"
      catch err
      res.write JSON.encode {error:error}
      res.end()
  return
)
server.on "connection",(socket)->
  socket.setNoDelay true
  return
process.on "uncaughtException",(err)->
  console.error err if err
  console.error err.stack if err and err.stack
  return
process.on 'exit',(code)->
  console.error "exit"
  console.error "exit: "+code
  return

fileTimeFn = (tmpDir,time)->
  date = new Date()
  dateTime2 = date.getTime()-time
  try
    fileArr = await fsAsync.readdirAsync tmpDir
    for file in fileArr
      continue if file is "readme.txt"
      stats = await fsAsync.statAsync "#{tmpDir}/#{file}"
      continue if !stats.isFile()
      if dateTime2 >= stats.atime.getTime()
        await fsAsync.unlinkAsync "#{tmpDir}/#{file}"
  catch err
    console.error err
  return
tmpFileTimeFn = ->
  await fileTimeFn "#{__dirname}/../tmp",172800000
  return
later.setInterval tmpFileTimeFn,later.parse.cron '0 4 * * *'

server.on "error",(e)->
  if e.code is "EADDRINUSE"
    console.error "端口 #{config.port or 80} 已被占用!"
    process.exit 1
    return
  console.error e.toString()
  return

server.listen config.port or 80
console.log "http://localhost:" + config.port or 80
exports.server = server
console.timeEnd "Start Server"
