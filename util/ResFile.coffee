config = require "../config"
url = require "url"
fsAsync = require "fsAsync"
path = require "path"
zlibAsync = require "zlibAsync"
crypto = require "crypto"

_PROJECT_PATH = global._PROJECT_PATH

mime = {
  "css": "text/css; charset=UTF-8"
  "gif": "image/gif"
  "html": "text/html; charset=UTF-8"
  "ico": "image/x-icon"
  "jpeg": "image/jpeg"
  "jpg": "image/jpeg"
  "png": "image/png"
  "js": "text/javascript; charset=UTF-8"
  "json": "application/json; charset=UTF-8"
  "pdf": "application/pdf"
  "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  "svg": "image/svg+xml; charset=UTF-8"
  "swf": "application/x-shockwave-flash"
  "tiff": "image/tiff"
  "txt": "text/plain; charset=UTF-8"
  "wav": "audio/x-wav"
  "wma": "audio/x-ms-wma"
  "wmv": "video/x-ms-wmv"
  "xml": "text/xml; charset=UTF-8"
  "mp4": "video/mp4"
  "mp3": "audio/x-mpeg"
  "3gp": "video/3gpp"
  "amr": "audio/amr"
  "mpg4": "video/mp4"
}
exports.mime = mime
gzip = {
  css: true
  txt: true
  json: true
  xml: true
  js: true
  html: true
  csv: true
  svg: true
}
exports.gzip = gzip

md5Etag = (buffer,ctEn,req,res)->
  res.setHeader "Content-Encoding",ctEn if ctEn isnt undefined and ctEn isnt null
  res.setHeader "Content-Length", buffer.length
  if buffer.length > 400
    inm = req.headers["if-none-match"]
    hashMd5 = crypto.createHash "md5"
    md5Str = hashMd5.update(buffer).digest "base64"
    md5Str = md5Str.substring 0,md5Str.length-2
    if md5Str is inm
      res.writeHead 304
    else
      res.setHeader "Etag",md5Str
      res.writeHead 200
      res.write buffer
  else
    res.writeHead 200
    res.write buffer
  res.end()
  return
exports.md5Etag = md5Etag

gzipFn = (aed,extname,buffer)->
  zipType = null
  zipBuf = null
  return {zipType:null,zipBuf:buffer} if buffer.length < 2048 or aed is undefined or aed is null
  if aed.match(/\bgzip\b/) and extname isnt null and extname.trim() isnt "" and gzip[extname] isnt undefined
    zipType = "gzip"
    zipBuf = await zlibAsync.gzipAsync buffer
  else if aed.match(/\bdeflate\b/) and extname isnt null and extname.trim() isnt "" and gzip[extname] isnt undefined
    zipType = "deflate"
    zipBuf = await zlibAsync.deflateAsync buffer
  else
    zipBuf = buffer
  {zipType:zipType,zipBuf:zipBuf}
exports.gzipFn = gzipFn

exports.resFile = (ph,req,res)->
  extname = path.extname ph
  extname = extname.substring 1,extname.length if extname
  res.setHeader "Content-Type",mime[extname] if extname and mime[extname]
  filename = path.basename ph
  disFilename = filename
  buffer = null
  src = null
  if config.debug
    #babelCore = require "babel-core"
    if extname is "js"
      if ph is "/js/res/_resAll.js"
        Buffers = require "buffers"
        buffers = new Buffers()
        for item in _resAll
          try buffer = await fsAsync.readFileAsync _PROJECT_PATH+"/web/"+item catch err
          if buffer
            #buffer = new Buffer babelCore.transform(buffer.toString(),{"presets": ["stage-3"]}).code if item is "/js/res/DIY.js"
            buffers.push buffer
        buffer = buffers.toBuffer()
      else
        src = undefined
        phCoffee = ph.substring(0,ph.lastIndexOf("."))+".coffee"
        try buffer = await fsAsync.readFileAsync _PROJECT_PATH+"/web/"+phCoffee catch err
        if buffer
          src = buffer.toString()
          debug_open = "###debug"
          debug_close = "###"
          src = src.replace new RegExp(debug_open+"([\\s\\S]*?)"+debug_close,"g"),(str)-> str.substring(debug_open.length,str.length-debug_close.length).trim()
          coffeeScript = require "coffee-script"
          #ref = coffeeScript.compile src,{sourceMap: true,inline: true,sourceFiles: [phCoffee]}
          #src = ref.js+"\n//# sourceMappingURL=data:application/json;base64,"+(new Buffer(unescape(encodeURIComponent(ref.v3SourceMap)))).toString("base64")
          src = coffeeScript.compile src
          #src = babelCore.transform(src,{"presets": ["stage-3"]}).code
        else
          try buffer = await fsAsync.readFileAsync _PROJECT_PATH+"/web/"+ph catch err
          if buffer
            babelArrNot = ["\\/js\\/res\\/mui\\.js","\\/js\\/echarts\\.js"]
            accept = true
            for filter in babelArrNot
              if new RegExp(filter,"gm").test ph
                accept = false
                break
            if accept
              src = buffer.toString()
              #src = babelCore.transform(src,{"presets": ["stage-3"]}).code
        if src
          defineFilterNot = ["\\/js\\/res\\/.*","\\/js\\/echarts\\.js"]
          accept = true
          for filter in defineFilterNot
            if new RegExp(filter,"gm").test ph
              accept = false
              break
          src = "sea_define(function(require,exports,module){"+src+"});" if accept and !src.startsWith "sea_define("
          buffer = new Buffer src
    else if extname is "css"
      phLess = ph.substring(0,ph.lastIndexOf("."))+".less"
      try buffer = await fsAsync.readFileAsync _PROJECT_PATH+"/web/"+phLess catch err
      if buffer
        src = buffer.toString()
        less = require "less"
        src = await less.render src
        buffer = new Buffer src.css
    res.setHeader "Cache-Control","no-cache"
    res.setHeader "Pragma","no-cache"
  else
    ctu = 0
    if config.cacheTimeUrl
      ctu = config.cacheTimeUrl ph
    if ctu
      res.setHeader "Cache-Control", "max-age="+ctu
    else
      res.setHeader "Cache-Control","no-cache"
      res.setHeader "Pragma","no-cache"
  if !buffer
    try buffer = await fsAsync.readFileAsync _PROJECT_PATH+"/web/"+ph catch err
  if !buffer
    try
      buffer = await fsAsync.readFileAsync _PROJECT_PATH+"/web/"+ph+"/index.html"
    catch err
  if !buffer
    try
      buffer = await fsAsync.readFileAsync _PROJECT_PATH+"/web/"+ph+"/index.htm"
    catch err
  res.setHeader "Content-Disposition","inline; filename="+disFilename
  if buffer is null or buffer is undefined
    res.writeHead 404
    res.end()
    return
  gf = await gzipFn req.headers["accept-encoding"],extname,buffer
  md5Etag gf.zipBuf,gf.zipType,req,res
  return
if config.debug
  _resAll = [
    "/js/res/avalon.modern-debug.js"
    "/js/res/mootools-core.js"
    "/js/res/sea-debug.js"
    "/js/res/seajs-css-debug.js"
    "/js/res/mootools-more.js"
    "/js/res/config.js"
    "/js/res/DIY.js"
    "/js/res/setImmediate.js"
    "/js/res/date.js"
    "/js/res/mui-debug.js"
    "/js/res/ExpandUtil.js"
  ]