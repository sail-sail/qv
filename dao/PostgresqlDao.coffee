pg = require "pg"

exports.PostgresqlDao = new Class
  Implements: [Events, Options]
  options:
    dbName: undefined
    jdbcDb: undefined
  initialize: (options) ->
    t = this
    t.setOptions options
    return
  connectAsync: ->
    args = Array.from arguments
    new Promise (resolve,reject)->
      callback = (err,client,done)->
        if err
          reject err
          return
        resolve {client:client,done:done}
        return
      args.push callback
      pg.connect.apply pg,args
      return
  queryAsync: (client)->
    args = Array.from arguments
    args.shift()
    new Promise (resolve,reject)->
      callback = (err,result)->
        if err
          reject err
          return
        resolve result
        return
      args.push callback
      client.query.apply client,args
      return
  plv8Block: (sql,argArr)->
    t = this
    sql = sql.replace(/"/gm,"\\\"").replace(/\n/gm," ")
    sql = sql.replace /\$\d+/gm,(a0)->
      if a0.startsWith "$"
        a0 = Number a0.replace "$",""
        a0--
      t.literalId argArr[a0]
    sql = sql.replace /\@\w+/gm,(a0)-> t.literalId argArr[a0.substring(1)]
    sql
  escapeId: (str)-> pg.Client.prototype.escapeIdentifier str
  literalId: (str)->
    if typeOf(str) is "string"
      return pg.Client.prototype.escapeLiteral str
    str
  getDb_type: (reqOpt)->
    t = this
    o = t.options
    jdbcDb = o.jdbcDb
    db_type = jdbcDb[o.dbName].db_type
    db_type
  callSp: (reqOpt,sp,spArg,rsNum,fetch)->
    t = this
    o = t.options
    conn2 = reqOpt.conn2
    jdbcDb = o.jdbcDb
    #是否内部事务,如果是内部事务,则在这个方法内部提交或者回滚
    isInnerTran = !conn2
    #{client:client,done:done}
    if isInnerTran
      conn2 = await t.connectAsync jdbcDb[o.dbName]
      console.log "begin;"
      await t.queryAsync conn2.client,"begin"
    spIde = ""
    spArr = sp.split "\."
    if spArr.length > 1
      spIde = conn2.client.escapeIdentifier(spArr[0])+"."+conn2.client.escapeIdentifier(spArr[1])
    sql = "select * from "+spIde+"("
    spArg2 = []
    isFirst = true
    if rsNum
      for i in [0...rsNum]
        if !isFirst
          sql += ","
        else
          isFirst = false
        tmpNum = spArg2.push "f"+(i+1)
        sql += "$"+tmpNum
    if spArg
      for arg,i in spArg
        if !isFirst
          sql += ","
        else
          isFirst = false
        tmpNum = spArg2.push arg
        sql += "$"+tmpNum
    sql += ")"
    rltSet = []
    console.time "sql"
    if isInnerTran
      try
        rltSetTmp = await t.callSql reqOpt,sql,spArg2,rsNum
        if rsNum isnt 0
          if fetch isnt false
            for i in [0...rsNum]
              rltFth = await t.queryAsync conn2.client,"FETCH ALL IN f"+(i+1)
              rltSet.push rltFth.rows
        else
          rltSet = rltSetTmp
      catch err
        console.log "rollback;"
        try
          await t.queryAsync conn2.client,"rollback"
        catch err
          console.error err
        conn2.done()
        throw err
      console.log "commit;"
      try
        await t.queryAsync conn2.client,"commit"
      catch err
        console.error err
      conn2.done()
    else
      rltSetTmp = await t.callSql reqOpt,sql,spArg2,rsNum
      if rsNum isnt 0
        if fetch isnt false
          for i in [0...rsNum]
            rltFth = await t.queryAsync conn2.client,"FETCH ALL IN f"+(i+1)
            rltSet.push rltFth.rows
      else
        rltSet = rltSetTmp
    console.timeEnd "sql"
    rltSet
  callSql: (reqOpt,sql,spArg,rsNum)->
    rltSet = null
    t = this
    o = t.options
    if spArg
      spArgTyp = typeOf spArg
      if spArgTyp is "object"
        spArg2 = []
        sql = sql.replace /@\w+/gm,(strTmp)->
          strTmp = strTmp.substring 1
          spArg2.push spArg[strTmp]
          "$#{spArg2.length}"
        spArg = spArg2
      else if spArgTyp isnt "array"
        console.error sql
        throw new Error "Type of spArg is #{spArgTyp} must be array or object!"
    conn2 = reqOpt and reqOpt.conn2
    jdbcDb = o.jdbcDb
    sql_debug = undefined
    if spArg
      sql_debug = sql.replace /\$\d+/gm,(strTmp)->
        numTmp = Number strTmp.substring 1
        numTmp--
        return 'NULL' if !spArg[numTmp]?
        return spArg[numTmp] if Number.isFinite spArg[numTmp]
        return "?buffer?" if Buffer.isBuffer spArg[numTmp]
        "'#{spArg[numTmp]}'"
    else
      sql_debug = sql
    console.log sql_debug+";" if !reqOpt or reqOpt.sqlNotLog isnt true
    isInnerTran = !conn2
    conn2 = await t.connectAsync jdbcDb[o.dbName] if isInnerTran
    try
      rltSet = await t.queryAsync conn2.client,sql,spArg
    catch err
      conn2.done() if isInnerTran
      console.error sql_debug+";" if sql_debug
      throw err
    conn2.done() if isInnerTran
    rltSet
  getConn: (reqOpt)->
    t = this
    o = t.options
    jdbcDb = o.jdbcDb
    conn2 = await t.connectAsync jdbcDb[o.dbName]
    reqOpt.conn2 = conn2
    conn2
  endConn: (reqOpt)->
    t = this
    o = t.options
    conn2 = reqOpt.conn2
    return if !conn2
    conn2.done();
    return
  beginTran: (reqOpt)->
    t = this
    console.log "begin;"
    conn2 = reqOpt.conn2
    await t.queryAsync conn2.client,"begin"
  commitTran: (reqOpt)->
    t = this
    conn2 = reqOpt.conn2
    return if !conn2
    console.log "commit;"
    rv = await t.queryAsync conn2.client,"commit"
    conn2.done()
    reqOpt.conn2 = undefined
    rv
  rollbackTran: (reqOpt)->
    t = this
    conn2 = reqOpt.conn2
    return if !conn2
    console.log "rollback;"
    rv = await t.queryAsync conn2.client,"rollback"
    conn2.done()
    reqOpt.conn2 = undefined
    rv
  setAutoCommit: (reqOpt,atc)->
    t = this
    conn2 = reqOpt.conn2
    autocommit = "on"
    if atc is false
      autocommit = "off"
    await t.queryAsync conn2.client,"set autocommit "+autocommit
  