fsAsync = require "fsAsync"
path = require "path"
uuid = require "uuid"

#遍历文件夹ph
traverseDir = (ph,filter)->
  names = await readdirAsync ph
  for i in [0...names.length]
    name = names[i]
    ph2 = path.join ph,name
    if filter
      stats = await fsAsync.statAsync ph2
      tk = await filter ph2,stats
      continue if tk is false
    if stats.isDirectory()
      await traverseDir ph2,filter
  return
exports.traverseDir = traverseDir

#遍历删除文件夹dir
rmdirs = (ph)->
  stats = await fsAsync.statAsync ph
  if not stats.isDirectory()
    await fsAsync.unlinkAsync ph
    return
  names = await fsAsync.readdirAsync ph
  for i in [0...names.length]
    name = names[i]
    ph2 = path.join ph,name
    stats = await fsAsync.statAsync ph2
    if stats.isDirectory()
      await rmdirs ph2
    else
      await fsAsync.unlinkAsync ph2
  await fsAsync.rmdirAsync ph
  return
exports.rmdirs = rmdirs

#递归创建文件夹
mkdirp = (dir,callback,mode)->
  dir = dir.replace /\\/gm,"/"
  arrDir = dir.split "/"
  tmpDir = ""
  for str,i in arrDir
    tmpDir += str
    tmpDir += "/" if i isnt arrDir.length-1
    try
      stats = await fsAsync.statAsync tmpDir
    catch err
      await fsAsync.mkdirAsync tmpDir,mode
      if callback
        await callback tmpDir,mode
  return
exports.mkdirp = mkdirp

#查看文件后缀名,来决定文件是否合法
isLegalFileName = (fileName)->
  rigs = [".exe",".com",".pif",".bat",".scr"]
  for rig in rigs
    extname = path.extname fileName
    return false if rigs.indexOf(extname) isnt -1
  true
#将buf写到临时文件里面去,通常用来提供下载
writeTmpFile = (buf)->
  uid = uuid.v4()
  tmpFileName = "#{_PROJECT_PATH}/tmp/"+uid+".tmp"
  await fsAsync.writeFileAsync tmpFileName,buf
  tmpFileName
#判断是否是属于图片的后缀
isImgSfx = (sfx)-> 
  return false if typeOf(sfx) isnt "string"
  sfx = sfx.toLowerCase()
  sfx is "png" or sfx is "gif" or sfx is "bmp" or sfx is "jpg" or sfx is "tiff"
exports.isLegalFileName = isLegalFileName
exports.writeTmpFile = writeTmpFile
exports.isImgSfx = isImgSfx
