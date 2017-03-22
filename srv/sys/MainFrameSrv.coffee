{SysSrv} = require "./SysSrv"

exports.MainFrameSrv = new Class
  Extends: SysSrv
  findPageById: (reqOpt,id)->
    t = this
    usr = t.session.usr
    sql = """
    select t.*
      ,(case
          exists(select id from page_lang where lang=$2 and t.id=page_id)
        when true
          then (select lbl from page_lang where lang=$2 and t.id=page_id)
        else
          t.lbl
        end
      ) as lbl
    from page t
    where t.id=$1
    """
    eny = await t.callOne reqOpt,sql,[id,usr.lang]
    eny
  findPageByCode: (reqOpt,code)->
    t = this
    usr = t.session.usr
    sql = """
    select t.*
      ,(case
          exists(select id from page_lang where lang=$2 and t.id=page_id)
        when true
          then (select lbl from page_lang where lang=$2 and t.id=page_id)
        else
          t.lbl
        end
      ) as lbl
    from page t
    where t.code=$1
    """
    rltSet = await t.callArr reqOpt,sql,[code,usr.lang]
    rltSet
  #获得菜单对应的孩子
  menuCld: (reqOpt,menuId)->
    t = this
    usr = t.session.usr
    lang = usr.lang or 'en-US'
    sql = """
    select t.*
    ,(case exists(select id from menu_lang where lang=$2 and t.id=menu_id)
      when false 
        then t.lbl
      when true
        then (select lbl from menu_lang where lang=$2 and t.id=menu_id)
      else t.lbl end
    ) as lbl
    from menu t
    where 
      t.prn_id=$1
      and t.enable=true
    """
    argArr = [menuId,lang]
    sql += """
    
    order by t.sort_num asc
    """
    rltSet = await t.callArr reqOpt,sql,argArr
    rltSet
  menuPrn: (reqOpt,menuId)->
    t = this
    return if !menuId
    usr = t.session.usr
    lang = usr.lang or 'en-US'
    sql = """
    select t.*
    ,(case exists(select id from menu_lang where lang=$2 and t.id=menu_id)
      when false 
        then t.lbl
      when true
        then (select lbl from menu_lang where lang=$2 and t.id=menu_id)
      else t.lbl end
    ) as lbl
    from menu t
    where 
      t.id=$1
      and t.enable=true
    """
    sql += """
    
    order by t.sort_num asc
    """
    eny = await t.callOne reqOpt,sql,[menuId,lang]
    eny
  #获得菜单的根节点,可能有很多个
  menuRoot: (reqOpt)->
    t = this
    usr = t.session.usr
    lang = usr.lang or 'en-US'
    sql = """
    select t.*
    ,(case exists(select id from menu_lang where lang=$1 and t.id=menu_id)
      when false 
        then t.lbl
      when true
        then (select lbl from menu_lang where lang=$1 and t.id=menu_id)
      else t.lbl end
    ) as lbl
    from menu t
    where 
      t.is_root=true
      and t.enable=true
    """
    if usr.code isnt "admin"
      sql += """
      
        and t.id!=1
      """
    #发货员不能看到绩效
    if usr._role.id is 3
      sql += """
      
      and t.page_id not in(15)
      """
    #财务
    if usr._role.id is 4
      sql += """
      
      and t.page_id in (12,1)
      """
    sql += """
    
    order by t.sort_num asc
    """
    rltSet = await t.callArr reqOpt,sql,[lang]
    rltSet
