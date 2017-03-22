{Srv} = require "../Srv"
fs = require "fs"
zlib = require "zlib"
path = require "path"
Hzip = require "hzip"
ejsexcel = require "ejsexcel"
fsAsync = require "fsAsync"
read_xlsx = require "read_xlsx"

PrnClzz = Srv
exports.SysSrv = new Class
  Extends: PrnClzz
  options:
    #表
    tab: undefined
    #页面名称
    pg: undefined
    menuId: undefined
    isMainFrame: undefined
    pgType: "add"
    #搜索条件
    seaArr: []
    #排序
    sortArr: []
    #h:include标签引入的页面的Clz
    hIncClzArr: []
    #不受登录超时影响的方法
    ssnArr: [
      ["sys.WechatSrv",undefined]
    ]
    #需要服务器端验证的字段,保存和修改时验证
    $vdts: []
    #默认排序字段
    sort_fld: "id asc"
    #是否启用字段
    enable_fld: undefined
  onDraw: ->
    t = this
    o = t.options
    await Srv.prototype.onDraw.apply t,arguments
    return
  initPg: (reqOpt,argObj)->
    t = this
    o = t.options
    o.pg = argObj.pg
    o.menuId = argObj.menuId
    o.isMainFrame = argObj.isMainFrame
    return
  #执行$vdts里面的所有验证
  runAllVdts: (reqOpt,eny,keyArr)->
    t = this
    o = t.options
    keyArr = o.$vdts if !keyArr
    for key in keyArr
      continue if !eny.hasOwnProperty key
      val = eny[key]
      isPass = await t[key+"Vdt"] reqOpt,key,val,eny.id,eny
      if isPass isnt true and isPass.err
        errObj = new String isPass.err
        errObj.is_out = true
        throw errObj
    true
  bufByOid: (reqOpt,oid)->
    t = this
    sql = "select lo_get($1) as buf"
    bufEny = await t.callOne reqOpt,sql,[oid]
    buf = bufEny.buf
    buf
  #大对象oid转换为提供文件下载的uid
  oid2uid: (reqOpt,oid,name)->
    t = this
    o = t.options
    return if !oid
    name2 = "lo_export"+String.uniqueID()
    tmpFile = _PROJECT_PATH+"/tmp/"+name2
    offset = 0
    while true
      sql = "select lo_get($1,$2,$3) as buf"
      bufEny = await t.callOne reqOpt,sql,[oid,offset*65536,65536]
      buf = bufEny.buf
      break if buf.length is 0
      offset++
      await fsAsync.appendFileAsync tmpFile,buf
    name = name or name2
    uid = await t.buf2uid reqOpt,tmpFile,name,(path2)-> await fsAsync.unlinkAsync path2
    uid
  #根据uid获得buffer上传到pg返回新oid
  "@uid2buf4pg":{_private: true}
  uid2buf4pg: (reqOpt,uid)->
    return uid if !uid
    t = this
    rvObj = t._state.download[uid]
    return uid if !rvObj
    prmTmp = new Promise (resolve,reject)->
      tmpFileStm = fs.createReadStream rvObj.buffer
      loid = undefined
      offset = 0
      tmpFileStm.on "data",(buf)->
        tmpFileStm.pause()
        try
          if loid is undefined
            loidEny = await t.callOne reqOpt,"select lo_from_bytea(0,$1) as loid",[buf]
            loid = loidEny.loid
            offset = buf.length
          else
            await t.callOne reqOpt,"select lo_put($1,$2,$3) as loid",[loid,offset,buf]
            offset += buf.length
          tmpFileStm.resume()
          return
        catch err
          await fsAsync.unlinkAsync rvObj.buffer
          reject err
        return
      tmpFileStm.on "error",(err)->
        await fsAsync.unlinkAsync rvObj.buffer
        reject err
        return
      tmpFileStm.on "end",->
        await fsAsync.unlinkAsync rvObj.buffer
        resolve loid
        return
      return
    prmTmp
  #增加排序,自动覆盖同名的排序
  sortAdd: (reqOpt,srtObj)->
    t = this
    o = t.options
    throw new Error srtObj if !srtObj.sort_fld
    srtObj.dirt = srtObj.dirt or "asc"
    throw new Error srtObj if srtObj.dirt isnt "asc" and srtObj.dirt isnt "desc"
    index = undefined
    for srtTmp,i in o.sortArr
      if srtObj.sort_fld is srtTmp.sort_fld
        o.sortArr[i] = srtObj
        index = i
        break
    if index is undefined
      index = o.sortArr.push(srtObj)-1
    index
  #删除排序
  sortDel: (reqOpt,sort_fld)->
    t = this
    o = t.options
    indexArr = []
    for srtObj,i in o.sortArr
      if srtObj.sort_fld is sort_fld
        indexArr.push i
    for index in indexArr
      o.sortArr.splice index,1
    return
  #增加搜索条件,返回条件所在位置
  srchAdd: (reqOpt,seaObj,replace)->
    t = this
    o = t.options
    throw new Error seaObj if seaObj.andOr isnt "and" and seaObj.andOr isnt "or"
    throw new Error seaObj if ["=",">=",">","<","<=","begin","end","like","!="].indexOf(seaObj.opt) is -1
    seaArr = o.seaArr
    if replace
      for seaTmp,i in seaArr
        continue if !seaTmp?
        if seaTmp.name is seaObj.name and seaTmp.andOr is seaObj.andOr and seaObj.opt is seaTmp.opt
          seaArr[i] = undefined
    for seaTmp,i in seaArr
      if seaTmp is undefined or seaTmp is null
        seaArr[i] = seaObj
        return i
    idx = seaArr.push(seaObj)-1
    idx
  #删除第几个搜索条件
  srchDel: (reqOpt,idx)->
    t = this
    o = t.options
    seaArr = o.seaArr
    seaArr[idx] = undefined
    return
  srchDelKey: (reqOpt,seaObj)->
    t = this
    o = t.options
    seaArr = o.seaArr
    throw new Error seaObj if seaObj.andOr isnt "and" and seaObj.andOr isnt "or"
    throw new Error seaObj if ["=",">=",">","<","<=","begin","end","like","!="].indexOf(seaObj.opt) is -1
    for seaTmp,i in seaArr
      continue if !seaTmp?
      if seaTmp.name is seaObj.name and seaTmp.andOr is seaObj.andOr and seaObj.opt is seaTmp.opt
        seaArr[i] = undefined
    return
  ###
    将搜索条件转换为where字符串
      argArr 之前的参数列表
      seaArr 搜索条件
      isWhr 是否加上 where 字样
  ###
  srch2Whr: (reqOpt,argArr,seaArr,isWhr,whr)->
    t = this
    o = t.options
    whr = whr or " "
    seaArr = seaArr or o.seaArr
    num = 0
    for seaObj in seaArr
      continue if !seaObj?
      continue if seaObj.andOr isnt "and" and seaObj.andOr isnt "or"
      continue if ["=",">=",">","<","<=","begin","end","like","!="].indexOf(seaObj.opt) is -1
      continue if String.isEmpty seaObj.name
      seaNameArr = seaObj.name.split " or "
      for seaName,k in seaNameArr
        opt = seaObj.opt
        value = seaObj.value
        seaName = seaName.trim()
        if opt is "begin"
          opt = "like"
          value = value+"%"
        else if opt is "end"
          opt = "like"
          value = "%"+value
        else if opt is "like"
          value = "%"+value+"%"
        index = argArr.push value
        if isWhr
          if num is 0
            whr += "\nwhere "
            whr += "(" if k is 0
          else
            if k is 0
              whr += "\n  #{seaObj.andOr} ("
            else
              whr += " or "
        else
          if k is 0
            whr += "\n  #{seaObj.andOr} ("
          else
            whr += " or "
        nameArr = seaName.split "\."
        if nameArr[0]
          whr += t.escapeId nameArr[0]
        if nameArr[1]
          whr += "."
          whr += t.escapeId nameArr[1]
        whr += " "+opt+" $"+index
        num++
      whr += ")"
    whr
  #拼装排序的字符串
  sort2Ody: (reqOpt,sortArr,isOrderBy)->
    t = this
    o = t.options
    str = ""
    str += "\norder by " if isOrderBy is true or o.sortArr.length > 0
    for srtObj,i in o.sortArr
      sort_fldArr = srtObj.sort_fld.split "\."
      if sort_fldArr[0]
        str += t.escapeId sort_fldArr[0]
      if sort_fldArr[1]
        str += "."
        str += t.escapeId sort_fldArr[1]
      str += " "+srtObj.dirt+","
    str
  dataGrid: (reqOpt,pgOffset,pgNum,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    argArr = []
    argArr.push pgNum,pgOffset if pgNum > 0
    sql = ""
    sql += await t.dgSelect reqOpt,tabEd,argArr
    sql += await t.dgJoin reqOpt,tabEd,argArr
    sql += await t.srch2Whr reqOpt,argArr,o.seaArr,true
    sql += await t.dgGroupBy reqOpt,tabEd,argArr
    sql += await t.sort2Ody reqOpt,o.sortArr,true
    sql += "\n  t.id asc"
    sql += "\nlimit $1 offset $2" if pgNum > 0
    rltSet = await t.callArr reqOpt,sql,argArr
    {rltSet:rltSet}
  "@dgSelect":{_private:true}
  dgSelect: (reqOpt,tabEd,argArr)-> "select t.* from #{tabEd} t"
  "@dgJoin":{_private:true}
  dgJoin: (reqOpt,tabEd,argArr)-> ""
  "@dcJoin":{_private:true}
  dcJoin: (reqOpt,tabEd,argArr)-> await this.dgJoin reqOpt,tabEd,argArr
  "@dgGroupBy":{_private:true}
  dgGroupBy: (reqOpt,tabEd,argArr)-> ""
  dataCount: (reqOpt,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    argArr = []
    sql = "select count(t.id) as count from #{tabEd} t"
    sql += await t.dcJoin reqOpt,tabEd,argArr
    sql += await t.srch2Whr reqOpt,argArr,o.seaArr,true
    eny = await t.callOne reqOpt,sql,argArr
    {count:eny.count}
  findById: (reqOpt,id,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    eny = await t.callOne reqOpt,"select t.* from #{tabEd} t where t.id=$1",[id]
    eny
  findByFld: (reqOpt,fld,val,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    fldEd = t.escapeId fld
    rltSet = await t.callArr reqOpt,"select t.* from "+tabEd+" t where \"t\"."+fldEd+"=$1",[val]
    rltSet
  #通过id删除一条记录
  "@delById":{isTran: true}
  delById: (reqOpt,id,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    rltSet = await t.callSql reqOpt,"delete from "+tabEd+" where id=$1",[id]
    rltSet
  #获得当前eny的所有祖宗id号的数组,从根节点往下排序
  treAllPrnId: (reqOpt,prn_id,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    oldIdArr = []
    tmpId = prn_id
    rvIdArr = []
    while true
      if oldIdArr.contains tmpId
        console.error "SysSrv.treAllPrnId: #{tab}.prn_id=#{tmpId} 死循环!"
        break
      eny = await t.callOne reqOpt,"select t.* from #{tabEd} t where t.id=$1",[tmpId]
      oldIdArr.push tmpId
      break if !eny
      tmpId = eny.prn_id
      rvIdArr.unshift eny
    rvIdArr
  #通过id号删除一颗树
  "@treDelNdById":{isTran:true}
  treDelNdById: (reqOpt,id,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEl = t.escapeId tab
    num = 0
    await t.delById reqOpt,id,tab
    num++
    {rowCount:num}
  befSavUpd: (reqOpt,eny,keyArr,returning,tab)->
  update: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    throw new Error "eny.id can not be empty!" if String.isEmpty eny.id
    await t.runAllVdts reqOpt,eny
    await t.befSavUpd reqOpt,eny,keyArr,returning,tab
    tab = tab or o.tab
    tabEl = t.escapeId tab
    sql = "update #{tabEl} set "
    argArr = []
    for key,i in keyArr
      val = eny[key]
      continue if val is undefined
      argArr.push val
      sql += t.escapeId(key)+"=$"+argArr.length+","
    return true if argArr.length is 0
    sql = sql.substring 0,sql.length-1 if sql.charAt(sql.length-1) is ","
    argArr.push eny.id
    sql += " where id=$"+argArr.length
    rltSet = await t.callSql reqOpt,sql,argArr
    rltSet
  #给saveAddClk调用
  "@sqlValStrFn":{_private:true}
  sqlValStrFn: (reqOpt,key,val,argArr)->
    sqlValStr = ""
    if val is undefined
      sqlValStr += "default"
    else
      argArr.push val
      sqlValStr += "$"+argArr.length
    sqlValStr += ","
    sqlValStr
  ###
  保存一条记录
    @eny 需要保存的实体类,例如:{name:"ab",username:"un"}
    @keyArr 需要保存的key,例如:["name","useranme"]
    @return 返回returning数组指定的列,特殊情况,如果returning是*则返回所有列,例如:returning为["id"]时,返回{id:2}
  ###
  "@saveAddClk":{isTran:true}
  saveAddClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    delete eny.id
    await t.runAllVdts reqOpt,eny
    await t.befSavUpd reqOpt,eny,keyArr,returning,tab
    tab = tab or o.tab
    tab = t.escapeId tab
    sql = "insert into "+tab+" ("
    sqlValStr = ""
    argArr = []
    for key in keyArr
      val = eny[key]
      sql += t.escapeId key
      sql += ","
      sqlValStr += t.sqlValStrFn reqOpt,key,val,argArr
    if keyArr.length isnt 0
      sql = sql.substring 0,sql.length-1
      sqlValStr = sqlValStr.substring 0,sqlValStr.length-1
    sql += ") values ("+sqlValStr+")"
    if returning is "*"
      sql += " returning *"
    else if returning
      typeTmp = typeOf returning
      returning = [returning] if typeTmp isnt "array"
      sql += " returning "
      for str,i in returning
        sql += t.escapeId str
        sql += "," if returning.length-1 isnt i
    rltSet = await t.callSql reqOpt,sql,argArr
    rltSet = rltSet.rows
    rltSet
  "@log":{_private:true}
  log: (reqOpt,eny)->
    t = this
    o = t.options
    usr = ""
    usr = t.session and t.session.usr and t.session.usr.code
    ip = ""
    ip = t.getClientIp reqOpt if reqOpt
    pg = eny.pg or ""
    rem = eny.rem or ""
    act = eny.act or ""
    keys = undefined
    keys = JSON.encode eny.keys if eny.keys
    bef = undefined
    bef = JSON.encode eny.bef if eny.bef
    aft = undefined
    aft = JSON.encode eny.aft if eny.aft
    head_obj = undefined
    head_obj = JSON.encode eny.head_obj if eny.head_obj
    eny2 = await t.callOne reqOpt,"insert into log(pg,usr,ip,bef,act,aft,rem,keys,head_obj) values($1,$2,$3,$4,$5,$6,$7,$8,$9) returning id",[pg,usr,ip,bef,act,aft,rem,keys,head_obj]
    {id:eny2.id}
  #点击确定按钮
  "@confirmButClk":{isTran:true}
  confirmButClk: (reqOpt,eny,keyArr,returning,tab)->
    t = this
    o = t.options
    rltSet = await t.saveAddClk reqOpt,eny,keyArr,returning,tab
    rltSet
  #获得树的根节点,可能有很多个
  treeRoot: (reqOpt,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    sql = """
    select t.*
    from #{tabEd} t 
    where 
      t.is_root=true
      and t.is_leaf=false
    """
    if o.enable_fld
      sql += " and t.#{o.enable_fld}=true"
    if o.sort_fld
      sql += " order by t.#{o.sort_fld}"
    rltSet = await t.callArr reqOpt,sql
    rltSet
  #获得树形结构的孩子们
  treeCld: (reqOpt,id,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    sql = """
    select t.*
    from #{tabEd} t 
    where 
      t.prn_id=$1
    """
    if o.enable_fld
      sql += " and t.#{o.enable_fld}=true"
    if o.sort_fld
      sql += " order by t.#{o.sort_fld}"
    rltSet = await t.callArr reqOpt,sql,[id]
    rltSet
  impxlx_lbl2val: (reqOpt,key,eny,type)-> if val is "-" then return else return eny[key]
  #导入Excel
  impxlx_fileChg: (reqOpt,file)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    if file.name.trim() is ""
      await fsAsync.unlinkAsync file.path
      throw "Sorry,You must select a file first!"
    extname = path.extname file.name
    if extname isnt ".xlsx"
      await fsAsync.unlinkAsync file.path
      throw new Error file.name+" must ends with .xlsx"
    buffer = await fsAsync.readFileAsync file.path
    await fsAsync.unlinkAsync file.path
    enyArr = await t.impxlx_enyArr reqOpt,buffer
    keyArr = enyArr.keyArr
    enyArr = enyArr.enyArr
    errStr = ""
    insertNum = 0
    updateNum = 0
    deleteNum = 0
    errorNum = 0
    for eny,k in enyArr
      try
        enyOld = undefined
        if eny.id
          enyOld = await t.callSql reqOpt,"select id from #{tabEd} where id=$1",[eny.id]
        if eny["I/D"] is "I" and enyOld
          sql = "update #{tabEd} set "
          argArr = []
          for key,i in keyArr
            val = await t.impxlx_lbl2val reqOpt,key,eny,"update"
            argArr.push val if val isnt undefined
            sql += "#{t.escapeId(key)}=$#{argArr.length}"
            sql += "," if i isnt keyArr.length-1
          argArr.push eny.id
          sql += " where id=$#{argArr.length}"
          if argArr.length > 1
            await t.callSql reqOpt,sql,argArr
            updateNum++
        else if eny["I/D"] is "I" and !enyOld
          sql = "insert into #{tabEd} ("
          vlStr = ""
          argArr = []
          for key,i in keyArr
            continue if key is "id"
            val = await t.impxlx_lbl2val reqOpt,key,eny,"insert"
            argArr.push val if val isnt undefined
            sql += t.escapeId key
            vlStr += "$#{argArr.length}"
            if i isnt keyArr.length-1
              sql += ","
              vlStr += ","
          sql += ") values (#{vlStr})"
          if argArr.length > 0
            await t.callSql reqOpt,sql,argArr
            insertNum++
        else if eny["I/D"] is "D" and enyOld
          await t.callSpl reqOpt,"delete from #{tabEd} where id=$1",[eny.id]
          deleteNum++
      catch err
        errStr += "第 #{(k+3)} 行导入失败: "+err.toString()+"\r\n"
        errorNum++
    console.error errStr if errStr
    reqOpt.info = ""
    if insertNum > 0
      reqOpt.info += "增加成功 #{insertNum} 行!</br>"
    if updateNum > 0
      reqOpt.info += "修改成功 #{updateNum} 行!</br>"
    if deleteNum > 0
      reqOpt.info += "删除成功 #{updateNum} 行!</br>"
    if errorNum > 0
      reqOpt.error = "导入失败 #{errorNum} 行!</br>"
    if insertNum is 0 and updateNum is 0 and deleteNum is 0 and errorNum is 0
      reqOpt.info = "导入 0 行!</br>"
    uid = undefined
    if !String.isEmpty errStr
      callback = (pathTmp)->
        try fsAsync.unlinkAsync pathTmp catch err
        return
      uid = await t.buf2uid reqOpt,new Buffer(errStr),path.basename(file.name,extname)+"-error.txt",callback
    {uid:uid}
  "@impxlx_enyArr":{_private:true}
  impxlx_enyArr: (reqOpt,buffer)->
    workbook = await read_xlsx.getWorkbook buffer
    sheet = await workbook.getSheet 0
    rowLen = sheet.getRows()
    if rowLen < 3
      reqOpt.info = "导入 0 行!"
      return
    enyArr = []
    keyArr = []
    cell2Arr = sheet.getRow 1
    for cell2 in cell2Arr
      keyArr[cell2.getColumn()] = cell2.getContents()
    for i in [2...rowLen]
      eny = {}
      enyArr.push eny
      cellArr = sheet.getRow i
      valArr = []
      for cell in cellArr
        valArr[cell.getColumn()] = cell.getContents()
      for key,k in keyArr
        continue if String.isEmpty key
        eny[key] = valArr[k] or ""
    keyArr2 = []
    for key in keyArr
      continue if String.isEmpty(key) or key.trim() is "I/D"
      keyArr2.push key.trim().toLowerCase()
    {enyArr:enyArr,keyArr:keyArr2}
  #导出Excel
  expxlxClk: (reqOpt,headArr,headObj)->
    t = this
    o = t.options
    headArr = headArr or []
    headObj = headObj or []
    headArr.unshift "id"
    headObj.id = "编码"
    headArr.push "I/D"
    headObj["I/D"] = "操作(I/D)"
    exlBuf = await fsAsync.readFileAsync __dirname+"/expxlxClk.xlsx"
    rltSet = await t.dataGrid reqOpt,-1,-1
    exlBuf2 = await ejsexcel.renderExcel exlBuf,{rltSet:rltSet,headArr:headArr,headObj:headObj}
    callback = (pathTmp)-> try fsAsync.unlinkAsync pathTmp catch err
    uid = await t.buf2uid reqOpt,exlBuf2,o.tab+".xlsx",callback
    {uid:uid}
  rgm: (reqOpt,id)->
    t = this
    o = t.options
    usr = t.session.usr
    sql = """
    select rg.* 
    from role_rig rg
    left join role_usr re
      on re.role_id=rg.role_id
    left join usr e
      on re.usr_id=e.id
    where rg.menu_id=$1
      and e.id=$2
    """
    argArr = [id,usr.id]
    rltSet = await t.callSql reqOpt,sql,argArr
    rltSet = rltSet.rows
    rltSet[0]
  "@getMsg":{notSid:true}
  getMsg: (reqOpt,code,sbt,lang)->
    t = this
    o = t.options
    if !lang
      lang = t.session.usr.lang if t.session.usr
    lang = lang or "en-US"
    sql = """
    select t.code,t.lbl,t.lang 
    from msg t
    where t.code=$1
      and t.lang=$2
    """
    argArr = [code,lang]
    rltSet = await t.callSql reqOpt,sql,argArr
    rltSet = rltSet.rows
    lbl = undefined
    lbl = rltSet[0].lbl if rltSet[0] and rltSet[0].lbl
    if lbl isnt undefined
      lbl = lbl.substitute sbt if sbt
    else
      lbl = code
      lbl += " (#{JSON.encode(sbt)})" if sbt
    lbl
  "@getMsgArr":{notSid:true}
  getMsgArr: (reqOpt,codeArr,lang)->
    t = this
    o = t.options
    if !lang
      lang = t.session.usr.lang if t.session.usr
    lang = lang or "en-US"
    argArr = [lang]
    sql = """
    select t.code,t.lbl,t.lang 
    from msg t
    where t.lang=$1
      and t.code in (
    """
    num = 0
    for code in codeArr
      continue if String.isEmpty code
      argArr.push code
      sql += "," if num isnt 0
      sql += "$"+argArr.length
      num++
    sql += ")"
    rltSet = await t.callSql reqOpt,sql,argArr
    rltSet = rltSet.rows
    rltSet
  hInclude: (reqOpt,hIncClzArr)->
    t = this
    o = t.options
    o.hIncClzArr = hIncClzArr
    return
  val2lbl: (reqOpt,key,val,tab)->
    t = this
    o = t.options
    tab = tab or o.tab
    tabEd = t.escapeId tab
    keyEd = t.escapeId key
    sql = """
    select t.*
    from #{tabEd} t
    where #{keyEd}=$1
    """
    eny = await t.callOne reqOpt,sql,[val]
    eny
  lblSetVal: (reqOpt,lbl,lblFld,fld,tab)->
    t = this
    o = t.options
    return if lbl is undefined
    return null if lbl is null
    tab = tab or o.tab
    tabEd = t.escapeId tab
    fld = fld or "id"
    lblFld = lblFld or "lbl"
    fldEd = t.escapeId fld
    lblFldEd = t.escapeId lblFld
    sql = "select t.#{fldEd} from #{tabEd} t where #{lblFldEd}=$1"
    eny = await t.callOne reqOpt,sql,[lbl]
    val = undefined
    val = eny[fld] if eny
    val
  _applyMd: (reqOpt,mdStr,pms)->
    t = this
    o = t.options
    srvPath = reqOpt.srvPath
    pass = true
    if !t.session.usr
      pass = false
      aMdObj = t["@"+mdStr]
      if aMdObj and aMdObj.notSid is true
        pass = true
      else
        for item in o.ssnArr
          if (!item[0] or item[0] is srvPath) and (!item[1] or item[1] is mdStr)
            pass = true
            break
    if !pass
      reqOpt.action = ["sttConfirm"]
      return
    rv = await PrnClzz.prototype._applyMd.apply t,arguments
    rv
  getOptionArr: (reqOpt,codeArr)->
    t = this
    o = t.options
    return [] if !codeArr.length
    usr = t.session.usr
    argArr = []
    sql = "select t.code,\"t\".\"value\" from \"option\" t where t.code in("
    num = 0
    for code in codeArr
      continue if String.isEmpty code
      argArr.push code
      sql += "," if num isnt 0
      sql += "$"+argArr.length
      num++
    sql += ")"
    rltSet = await t.callSql reqOpt,sql,argArr
    rltSet = rltSet.rows
    valObj = {}
    for eny in rltSet
      valObj[eny.code] = eny.value
    valObj
  getOption: (reqOpt,code)->
    t = this
    o = t.options
    throw new Error "SysSrv.getOption code can not be empty!" if String.isEmpty code
    codeArr = [code]
    valObj = await t.getOptionArr reqOpt,codeArr
    valObj[code]
  getSession: (reqOpt)-> reqOpt.session
  