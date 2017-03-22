{SysSrv} = require "./SysSrv"
qr_image = require "qr-image"
fsAsync = require "fsAsync"

qrcodeSrv = undefined

PrnClzz = SysSrv
exports.QrcodeSrv = new Class
  Extends: PrnClzz
  initialize: (options) ->
    t = this
    return qrcodeSrv if qrcodeSrv
    PrnClzz.prototype.initialize.apply t,arguments
    qrcodeSrv = t
    t
  "@qrcode":{notSid:false}
  qrcode: (reqOpt,qrStr,qrOpt)->
    t = this
    req = reqOpt.req
    res = reqOpt.res
    reqOpt.res_auto_end = false
    qrOpt2 = {type:'png',parse_url:false}
    Object.merge qrOpt2,qrOpt
    try
      qrImg = qr_image.image qrStr,qrOpt2
      res.writeHead 200, {'Content-Type': 'image/png'}
      qrImg.pipe res
    catch err
      res.writeHead 414, {'Content-Type': 'text/html'}
      res.end '<h1>414 Request-URI Too Large</h1>'
      console.error err
    return