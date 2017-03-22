jdbc = require "../jdbc"
generic_pool = undefined
mysql = undefined

exports.Dao = new Class(
  Implements: [Events, Options]
  options:
    db: undefined
    dbConf: undefined
    pool: undefined
  initialize: (options) ->
    t = this
    t.setOptions options
    o = t.options
    o.db = "db" if !o.db
    o.dbConf = jdbc[o.db]
    throw new Error "/jdbc.js "+o.db+" does not defined!" if !o.dbConf
    dbConf = o.dbConf
    #同时执行多条sql语句
    dbConf.multipleStatements = true if dbConf.multipleStatements is undefined
    o.pool = generic_pool.Pool({
      name: o.db+dbConf.db_type
      create: (callback)->
        console.log "_pool_:"+o.pool.getPoolSize()
        connTmp = mysql.createConnection dbConf
        connTmp.on "error",(err)->
          if err
            try o.pool.destroy connTmp catch er2
            throw err
          return
        callback null,connTmp
        return
      destroy: (connTmp)->
        connTmp.destroy()
        return
      max: dbConf.idleMax or 20
      min: dbConf.idleMin or 1
      idleTimeoutMillis: dbConf.idleTimeoutMillis or 18000000
    })
    t
  escapeId: (str)-> mysql.escapeId str
  getDb_type: ->
    t = this
    o = t.options
    o.dbConf.db_type
  getConn: (reqOpt)->
    return if !reqOpt.isTran
    t = this
    o = t.options
    conn2Pm = new Promise((resolve,reject)->
      o.pool.acquire((err,conn2)->
        if err
          reject err
          o.pool.destroy conn2 if err.fatal or ["PROTOCOL_CONNECTION_LOST","PROTOCOL_ENQUEUE_AFTER_DESTROY","ECONNRESET","ETIMEDOUT","ECONNREFUSED"].indexOf(err.code) isnt -1
          return
        reqOpt.conn2 = conn2
        resolve()
        return
      )
      return
    )
    conn2Pm
  endConn: (reqOpt)->
    t = this
    o = t.options
    conn2 = reqOpt.conn2
    return if !conn2
    o.pool.release conn2
    reqOpt.conn2 = undefined
    return
  destroyConn: (reqOpt)->
    t = this
    o = t.options
    conn2 = reqOpt.conn2
    o.pool.destroy conn2 if conn2
    return
  beginTran: (reqOpt)->
    t = this
    o = t.options
    conn2 = reqOpt.conn2
    return if !conn2
    console.log "begin;"
    beginTransactionAsync = Promise.fromStandard conn2.beginTransaction,conn2
    beginTransactionAsync()
  commitTran: (reqOpt)->
    t = this
    o = t.options
    conn2 = reqOpt.conn2
    return if !conn2
    console.log "commit;"
    commitAsync = Promise.fromStandard conn2.commit,conn2
    await commitAsync()
    t.endConn reqOpt
    return
  rollbackTran: (reqOpt)->
    t = this
    o = t.options
    conn2 = reqOpt.conn2
    return if !conn2
    console.log "rollback;"
    rollbackAsync = Promise.fromStandard conn2.rollback,conn2
    await rollbackAsync()
    t.endConn reqOpt
    return
  callSp: (reqOpt,sp,spArg,rsNum)->
    t = this
    o = t.options
    dbConf = o.dbConf
    sql = undefined
    sp = mysql.escapeId sp
    sql = "call "+sp+"("
    spArgLen = 0
    spArgLen = spArg.length if spArg
    spArgLen = 0 if spArgLen is undefined
    for i in [0...spArgLen]
      sql += "," if i isnt 0
      sql += "?"
    sql += ")"
    rltSet = await t.callSql reqOpt,sql,spArg,rsNum
    rltSet
  callSql: (reqOpt,sql,spArg)->
    t = this
    o = t.options
    throw new Error "Dao.callSql sql can not be empty!" if !sql
    dbConf = o.dbConf
    #如果开启了事务,一定使用已经开启事务的连接
    conn3 = undefined
    isInCon = false
    if reqOpt.isTran
      throw new Error "The conn2 has been commit or rollback!" if !reqOpt.conn2
      conn3 = reqOpt.conn2
    else
      conn3 = await t.getConn()
      isInCon = true
    qyObj = {
      sql:sql
      typeCast: (field, next)->
        return field.string() if ["TIMESTAMP","DATE","DATETIME","NEWDATE"].indexOf(field.type) isnt -1
        next()
    }
    rltSetPm = new Promise (resolve,reject)->
      qyCblFn = (err,rltSet,fields)->
        if err
          if err.fatal or ["PROTOCOL_CONNECTION_LOST","PROTOCOL_ENQUEUE_AFTER_DESTROY","ECONNRESET","ETIMEDOUT","ECONNREFUSED"].indexOf(err.code) isnt -1
            o.pool.destroy conn3 if isInCon
          else
            o.pool.release conn3 if isInCon
          reject err
          return
        resolve rltSet
        return
      query = conn3.query qyObj,spArg,qyCblFn
      console.log query.sql.replace(/`/gm,"")+";"
      return
    await rltSetPm
)
Dao = exports.Dao
instnAll = {}
Dao.instnAll = instnAll
Dao.getInstance = (dbName,jdbcDb)->
  dbName = "db" if !dbName
  dao = instnAll[dbName]
  return dao if dao
  jdbcDb = jdbcDb or jdbc
  dbConf = jdbcDb[dbName]
  throw new Error "dbName:"+dbName+" is not correct!" if !dbConf
  dbConf.db_type = dbConf.db_type or "mysql"
  db_type = dbConf.db_type
  if db_type is "mysql"
    mysql = require "mysql" if !mysql
    generic_pool = require "generic-pool" if !generic_pool
    dao = new Dao {dbName:dbName,jdbcDb:jdbcDb}
  else
    db_typeDaoStr = db_type.charAt(0).toUpperCase()+db_type.substring(1)+"Dao"
    Db_typeDao = undefined
    Db_typeDao = require("./"+db_typeDaoStr)[db_typeDaoStr]
    throw new Error "db_type #{db_typeDaoStr} can not be found!" if !Db_typeDao
    dao = new Db_typeDao {dbName:dbName,jdbcDb:jdbcDb}
  instnAll[dbName] = dao
  dao
