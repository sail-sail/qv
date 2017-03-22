{SysSrv} = require "./SysSrv"

PrnClzz = SysSrv
exports.SysListSrv = new Class
  Extends: PrnClzz
  options:
    pgType: "list"
  initPg: (reqOpt,argObj)->
    t = this
    o = t.options
    await PrnClzz.prototype.initPg.apply t,arguments
    srchArr = await t.initSrch reqOpt
    sortArr = await t.initSortX reqOpt
    {srchArr:srchArr,sortArr:sortArr}
  #快捷搜索条件
  "@initSrch":{_private:true}
  initSrch: (reqOpt)->
    t = this
    o = t.options
    usr = t.session.usr
    sql = """
    select t.*
    from srch t
    left join page p
      on p.id=t.page_id
    where (t.usr_id=@usr_id or t.usr_id=0)
      and p.code=@page
    order by t.sort_num
    """
    rltSet = await t.callArr reqOpt,sql,{usr_id:usr.id,page:o.pg}
    rltSet
  #默认排序
  "@initSortX":{_private:true}
  initSortX: (reqOpt)->
    t = this
    o = t.options
    usr = t.session.usr
    sql = """
    select t.*
    from sort t
    left join page p
      on p.id=t.page_id
    where p.code=@page
    order by t.sort_num
    """
    rltSet = await t.callArr reqOpt,sql,{page:o.pg}
    rltSet
    