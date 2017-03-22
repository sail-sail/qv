delete from pg_largeobject;
--删除大对象函数
create or replace function qk_lo_unlink(loid1 oid) returns boolean as $qk$
declare
	loid2 oid;
begin
	select pl.loid into loid2 from pg_largeobject pl where pl.loid=loid1 limit 1 offset 0;
	if loid2 is null then
		raise notice '大对象%不存在',loid1;
		return false;
	end if;
	return lo_unlink(loid1);
end;
$qk$ language plpgsql;

--附件处理函数 col列名 tggObj ['NEW','OLD','TG_NAME','TG_WHEN','TG_LEVEL','TG_OP','TG_RELID','TG_TABLE_NAME','TG_TABLE_SCHEMA','TG_ARGV']
create or replace function qk_largeobject() returns boolean as $qk$
	var col = arguments[0];
	var tggObj = arguments[1];
	var TG_OP = tggObj.TG_OP;
	var OLD = tggObj.OLD;
	var NEW = tggObj.NEW;
	if(TG_OP === "UPDATE" || TG_OP === "DELETE") {
		if(!String.isEmpty(OLD[col]) && Number(OLD[col]) && (TG_OP === "UPDATE" && NEW[col] !== OLD[col] || TG_OP === "DELETE")) {
			plv8.execute("select qk_lo_unlink($1)",[OLD[col]]);
		}
		if(TG_OP === "DELETE") return OLD;
	}
	return true;
$qk$ language plv8;

--排序触发器函数sort_num
create or replace function qk_sort_num() returns boolean as $qk$
	var tab = arguments[0];
	var tggObj = arguments[1];
	tab = plv8.quote_ident(tab);
	var TG_OP = tggObj.TG_OP;
	var NEW = tggObj.NEW;
	if(TG_OP === "UPDATE" || TG_OP === "INSERT") {
		if(NEW.sort_num === 0) {
			var max_sort_num = plv8.execute("select max(sort_num) as max_sort_num from "+tab+"")[0].max_sort_num;
			plv8.execute("update "+tab+" set sort_num=$2 where id=$1",[NEW.id,max_sort_num+1]);
			return NEW;
		}
		var eny2 = plv8.execute("select * from "+tab+" where sort_num=$1 and id!=$2 limit 1 offset 0;",[NEW.sort_num,NEW.id])[0];
		if(eny2) {
			 plv8.execute("update "+tab+" set sort_num=sort_num+1 where id=$1",[eny2.id]);
		}
	}
	return true;
$qk$ language plv8;

--创建时间触发器函数
create or replace function func_4_create_time() returns trigger as $qk$
begin
	if tg_op = 'INSERT' then
		if new.create_time is NULL then
			new.create_time = now();
		end if;
	end if;
	return new;
end;
$qk$ language plpgsql;
--更新时间触发器函数
create or replace function func_4_update_time() returns trigger as $qk$
begin
	if tg_op = 'UPDATE' then
		if new.update_time is NULL then
			new.update_time = now();
		end if;
	end if;
	return new;
end;
$qk$ language plpgsql;

-------------------------------------------------------------------------------------------------------------------page
DROP TABLE IF EXISTS "page";
CREATE TABLE "page" (
  "id" 			serial 				PRIMARY KEY,
  "code" 		varchar(50) 		UNIQUE NOT NULL DEFAULT '',
  "lbl" 		varchar(50) 		NOT NULL DEFAULT '',
  "url" 		varchar(500) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE "page" IS '页面';
COMMENT ON COLUMN "page"."code" 		is '编码';
COMMENT ON COLUMN "page"."lbl" 			is '名称';
-------------------------------------------------------------------------------------------------------------------page_lang

DROP TABLE IF EXISTS "page_lang";
CREATE TABLE "page_lang" (
  "id" 			serial 				PRIMARY KEY,
  "page_id"		int					not null default 0,
  "lang"		varchar(50)		not null default '',
  "lbl"			varchar(50)		not null default ''
);
COMMENT ON TABLE  "page_lang" IS '页面语言';
COMMENT ON COLUMN "page_lang"."page_id" 		is '页面';
COMMENT ON COLUMN "page_lang"."lang" 			is '语言';
COMMENT ON COLUMN "page_lang"."lbl" 			is '名称';

-------------------------------------------------------------------------------------------------------------------menu
DROP TABLE IF EXISTS "menu";
CREATE TABLE "menu" (
  "id" 				serial 					PRIMARY KEY,
  "lbl" 			varchar(50) 			NOT NULL DEFAULT '',
  "prn_id"			int						NOT NULL DEFAULT 0,
  "open_op" 		varchar(50) 			NOT NULL DEFAULT '',
  "page_id" 		int 					NOT NULL DEFAULT 0,
  "is_root" 		boolean 				NOT NULL DEFAULT FALSE,
  "is_leaf" 		boolean 				NOT NULL DEFAULT FALSE,
  "is_log" 			boolean 				NOT NULL DEFAULT FALSE,
  "enable" 			boolean 				NOT NULL DEFAULT TRUE,
  "sort_num" 		int						NOT NULL DEFAULT 0
);
COMMENT ON TABLE "menu" IS '菜单';
COMMENT ON COLUMN "menu"."lbl" 		is '标签';
COMMENT ON COLUMN "menu"."prn_id" 		is '父菜单';
COMMENT ON COLUMN "menu"."open_op" 	is '打开方式';
COMMENT ON COLUMN "menu"."page_id" 	is '页面';
COMMENT ON COLUMN "menu"."is_root" 	is '根节点';
COMMENT ON COLUMN "menu"."is_leaf" 	is '叶子';
COMMENT ON COLUMN "menu"."is_log" 		is '日志';
COMMENT ON COLUMN "menu"."enable" 		is '启用';
COMMENT ON COLUMN "menu"."sort_num" 	is '排序';
create or replace function menu_sort_num() returns trigger as $qk$
	plv8.find_function("qk_sort_num")("menu",{TG_OP:TG_OP,NEW:NEW});
	return NEW;
$qk$ language plv8;
create trigger menu_sort_num_ui after insert or update on "menu" for each row execute procedure menu_sort_num();

-------------------------------------------------------------------------------------------------------------------menu_app
DROP TABLE IF EXISTS "menu_app";
CREATE TABLE "menu_app" (
  "id" 				serial 					PRIMARY KEY,
  "lbl" 			varchar(50) 			NOT NULL DEFAULT '',
  "prn_id"			int						NOT NULL DEFAULT 0,
  "open_op" 		varchar(50) 			NOT NULL DEFAULT '',
  "page_id" 		int 					NOT NULL DEFAULT 0,
  "is_root" 		boolean 				NOT NULL DEFAULT FALSE,
  "is_leaf" 		boolean 				NOT NULL DEFAULT FALSE,
  "is_log" 			boolean 				NOT NULL DEFAULT FALSE,
  "enable" 			boolean 				NOT NULL DEFAULT TRUE,
  "sort_num" 		int						NOT NULL DEFAULT 0
);
COMMENT ON TABLE  "menu_app" IS '菜单';
COMMENT ON COLUMN "menu_app"."lbl" 		is '标签';
COMMENT ON COLUMN "menu_app"."prn_id" 		is '父菜单';
COMMENT ON COLUMN "menu_app"."open_op" 	is '打开方式';
COMMENT ON COLUMN "menu_app"."page_id" 	is '页面';
COMMENT ON COLUMN "menu_app"."is_root" 	is '根节点';
COMMENT ON COLUMN "menu_app"."is_leaf" 	is '叶子';
COMMENT ON COLUMN "menu_app"."is_log" 		is '日志';
COMMENT ON COLUMN "menu_app"."enable" 		is '启用';
COMMENT ON COLUMN "menu_app"."sort_num" 	is '排序';
create or replace function menu_app_sort_num() returns trigger as $qk$
	plv8.find_function("qk_sort_num")("menu_app",{TG_OP:TG_OP,NEW:NEW});
	return NEW;
$qk$ language plv8;
create trigger menu_app_sort_num_ui after insert or update on "menu_app" for each row execute procedure menu_app_sort_num();

-------------------------------------------------------------------------------------------------------------------menu_lang
DROP TABLE IF EXISTS "menu_lang";
CREATE TABLE "menu_lang" (
  "id" 				serial 					PRIMARY KEY,
  "menu_id" 		int 					NOT NULL DEFAULT 0,
  "lang"			varchar(50)			NOT NULL DEFAULT '',
  "lbl"				varchar(50)			NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "menu_lang" IS '菜单语言';
COMMENT ON COLUMN "menu_lang"."menu_id" 		is '菜单';
COMMENT ON COLUMN "menu_lang"."lang" 			is '语言';
COMMENT ON COLUMN "menu_lang"."lbl" 			is '名称';


-------------------------------------------------------------------------------------------------------------------tab
DROP TABLE IF EXISTS "tab";
CREATE TABLE "tab" (
  "id" 					serial 					PRIMARY KEY,
  "code" 				varchar(50) 			not null default '',
  "lbl" 				varchar(50) 			not null default '',
  "is_log" 				boolean  				NOT NULL DEFAULT false,
  "create_time" 		timestamp 				default NULL,
  "rem" 				varchar(200) 			NOT NULL default ''
);
create trigger tab_func_4_create_time_i before insert on "tab" for each row execute procedure func_4_create_time();
COMMENT ON TABLE "tab" IS '表';
COMMENT ON COLUMN "tab"."code" 		is '编码';
COMMENT ON COLUMN "tab"."lbl" 			is '名称';
COMMENT ON COLUMN "tab"."is_log" 		is '记录日志';
COMMENT ON COLUMN "tab"."create_time" 	is '创建时间';
COMMENT ON COLUMN "tab"."rem" 			is '描述';

-------------------------------------------------------------------------------------------------------------------log 日志
DROP TABLE IF EXISTS "log";
CREATE TABLE "log" (
  "id" serial PRIMARY KEY,
  "pg" varchar(100) not null default '',
  "usr" varchar(100) not null default '',
  "ip" varchar(100) not null default '',
  "act" varchar(200) not null default '',
  "bef" json default null,
  "aft" json default null,
  "keys" json default null,
  "head_obj" json default null,
  "rem" text NOT NULL default '',
  "create_time" timestamp default NULL
);
COMMENT ON TABLE  "log" 				IS '日志';
COMMENT ON COLUMN "log"."pg" 			is '页面';
COMMENT ON COLUMN "log"."usr" 			is '用户';
COMMENT ON COLUMN "log"."ip" 			is 'IP地址';
COMMENT ON COLUMN "log"."act" 			is '操作';
COMMENT ON COLUMN "log"."bef" 			is '操作前';
COMMENT ON COLUMN "log"."aft" 			is '操作后';
COMMENT ON COLUMN "log"."keys"			is '简介';
COMMENT ON COLUMN "log"."head_obj"		is '头部描述';
COMMENT ON COLUMN "log"."rem" 			is '备注';
COMMENT ON COLUMN "log"."create_time" 	is '创建时间';
create trigger log_func_4_create_time_i before insert on "log" for each row execute procedure func_4_create_time();
select setval('log_id_seq',(select max(id) from log));

--------------------------------------------------------------------------------------------------lang
DROP TABLE IF EXISTS "lang";
CREATE TABLE "lang" (
  "id" 				serial PRIMARY KEY,
  "code" 			varchar(20) 		not null default '',
  "lbl" 			varchar(50) 		not null default ''
);
create unique index lang_code_openid_unique on "lang"("code");
COMMENT ON TABLE "lang" IS '语言';
COMMENT ON COLUMN "lang"."code" 				is '编码';
COMMENT ON COLUMN "lang"."lbl" 				is '名称';
insert into lang(code,lbl) values
 ('en-US','English')
,('zh-CN','简体中文')
;
--------------------------------------------------------------------------------------------------option
DROP TABLE IF EXISTS "option";
CREATE TABLE "option" (
  "id" 				serial PRIMARY KEY,
  "code" 			varchar(100) 		not null default '',
  "lbl" 			varchar(100) 		not null default '',
  "rem" 			varchar(250) 		not null default ''
);
create unique index option_code_openid_unique on "option"("code");
COMMENT ON TABLE "option" IS '系统选项';
COMMENT ON COLUMN "option"."code" 				is '关键字';
COMMENT ON COLUMN "option"."lbl" 				is '名称';
COMMENT ON COLUMN "option"."rem" 				is '描述';
--------------------------------------------------------------------------------------------------srch 搜索条件
DROP TABLE IF EXISTS "srch";
CREATE TABLE "srch" (
  "id" 				serial PRIMARY KEY,
  "usr_id" 			int 				NOT NULL DEFAULT 0,
  "page_id" 		int 				NOT NULL DEFAULT 0,
  "lbl" 			varchar(50) 		not null default '',
  "and_or" 			varchar(3) 		not null default 'and',
  "and_or_lbl" 		varchar(2) 		not null default '并且',
  "name" 			varchar(64) 		not null default '',
  "name_lbl" 		varchar(64) 		not null default '',
  "opt" 			varchar(4) 		not null default '=',
  "opt_lbl" 		varchar(4) 		not null default '等于',
  "value" 			varchar(500) 		not null default '',
  "dft"				boolean			NOT NULL DEFAULT FALSE,
  "sort_num" 		int					NOT NULL DEFAULT 0,
  "rem" 			varchar(100) 		not null default ''
);
COMMENT ON TABLE  "srch" 						is '搜索条件';
COMMENT ON COLUMN "srch"."usr_id" 				is '用户';
COMMENT ON COLUMN "srch"."page_id" 			is '页面';
COMMENT ON COLUMN "srch"."lbl" 				is '名称';
COMMENT ON COLUMN "srch"."and_or" 				is '连接';
COMMENT ON COLUMN "srch"."and_or_lbl"			is '连接名称';
COMMENT ON COLUMN "srch"."name" 				is '关键字';
COMMENT ON COLUMN "srch"."name_lbl"			is '关键字名称';
COMMENT ON COLUMN "srch"."opt" 				is '选项';
COMMENT ON COLUMN "srch"."opt_lbl"				is '选项名称';
COMMENT ON COLUMN "srch"."value" 				is '值';
COMMENT ON COLUMN "srch"."dft" 				is '默认';
COMMENT ON COLUMN "srch"."sort_num" 			is '排序';
COMMENT ON COLUMN "srch"."rem" 				is '备注';
create or replace function srch_sort_num() returns trigger as $qk$
	plv8.find_function("qk_sort_num")("srch",{TG_OP:TG_OP,NEW:NEW});
	return NEW;
$qk$ language plv8;
create trigger srch_sort_num_ui after insert or update on "srch" for each row execute procedure srch_sort_num();
--------------------------------------------------------------------------------------------------sort
DROP TABLE IF EXISTS "sort";
CREATE TABLE "sort" (
  "id" 				serial PRIMARY KEY,
  "page_id" 		int 				NOT NULL DEFAULT 0,
  "name"			varchar(64) 		not null default '',
  "opt" 			varchar(4) 		not null default 'desc',
  "sort_num" 		int					NOT NULL DEFAULT 0,
  "rem" 			varchar(100) 		not null default ''
);
COMMENT ON TABLE  "sort" 						is '排序';
COMMENT ON COLUMN "sort"."name" 				is '关键字';
COMMENT ON COLUMN "sort"."opt" 				is '选项';
COMMENT ON COLUMN "sort"."sort_num" 			is '排序';
COMMENT ON COLUMN "sort"."rem" 				is '备注';
create or replace function sort_sort_num() returns trigger as $qk$
	plv8.find_function("qk_sort_num")("sort",{TG_OP:TG_OP,NEW:NEW});
	return NEW;
$qk$ language plv8;
create trigger sort_sort_num_ui after insert or update on "sort" for each row execute procedure sort_sort_num();
--------------------------------------------------------------------------------------------------msg
DROP TABLE IF EXISTS "msg";
CREATE TABLE "msg" (
  "id" 				serial PRIMARY KEY,
  "code" 			varchar(200) 		not null default '',
  "lang" 			varchar(50) 		not null default '',
  "lbl" 			varchar(500) 		not null default '',
  "create_time" 	timestamp 			DEFAULT NULL,
  "update_time" 	timestamp 			DEFAULT NULL
);
create trigger msg_func_4_create_time_i before insert on "msg" for each row execute procedure func_4_create_time();
create trigger msg_func_4_update_time_i before update on "msg" for each row execute procedure func_4_update_time();
create unique index msg_code_lang_openid_unique on "msg"("code","lang");
COMMENT ON TABLE "msg" IS '国际化消息';
COMMENT ON COLUMN "msg"."code" 				is '编码';
COMMENT ON COLUMN "msg"."lang" 				is '语言';
COMMENT ON COLUMN "msg"."lbl" 					is '标签';
COMMENT ON COLUMN "msg"."create_time" 			is '创建时间';
COMMENT ON COLUMN "msg"."update_time" 			is '更新时间';
insert into msg(code,lang,lbl) values
 ('yes','en-US','Yes')
,('yes','zh-CN','是')
,('no','en-US','No')
,('no','zh-CN','否')
,('add','en-US','Add')
,('add','zh-CN','增加')
,('edit','en-US','Edit')
,('edit','zh-CN','修改')
,('delete','en-US','Delete')
,('delete','zh-CN','删除')
,('select','en-US','Select')
,('select','zh-CN','选择')
,('or','zh-CN','或者')
,('or','en-US','Or')
,('and','zh-CN','并且')
,('and','en-US','And')
,('tab','zh-CN','选项卡')
,('tab','en-US','Tab')

--SysList.coffee
,('equal','zh-CN','等于')
,('equal','en-US','Equal')
,('greater','zh-CN','大于')
,('greater','en-US','Greater')
,('greater_equal','zh-CN','大于等于')
,('greater_equal','en-US','GreaterEqual')
,('less','zh-CN','小于')
,('less','en-US','Less')
,('less_equal','zh-CN','小于等于')
,('less_equal','en-US','LessEqual')
,('begin_with','zh-CN','始于')
,('begin_with','en-US','BeginWith')
,('end_with','zh-CN','止于')
,('end_with','en-US','EndWith')
,('contain','zh-CN','包含')
,('contain','en-US','Contain')
,('increase_search_conditions','zh-CN','增加搜索条件')
,('increase_search_conditions','en-US','Increase the search conditions')
,('sure_to_delete','zh-CN','确定删除')
,('sure_to_delete','en-US','Sure to delete')
,('delete_num_records','zh-CN','删除 {0} 条记录!')
,('delete_num_records','en-US','Delete {0} records!')

--SysAdd.coffee
,('save_success','zh-CN','保存成功!')
,('save_success','en-US','Save success!')
,('data_has_not_been_saved','zh-CN','数据尚未保存! 是否继续退出?')
,('data_has_not_been_saved','en-US','Data has not been saved! Whether to continue to exit?')

--Et_psw.html
,('Et_psw.old_psw','zh-CN','旧密码')
,('Et_psw.old_psw','en-US','Old Password')
,('Et_psw.psw','zh-CN','新密码')
,('Et_psw.psw','en-US','New Password')
,('passwrod_edit_success','zh-CN','密码修改成功,请牢记新密码!')
,('passwrod_edit_success','en-US','Password edit success,please remember the new password!')
,('code_psw_not_correct','zh-CN','用户名或密码不正确!')
,('code_psw_not_correct','en-US','Username or password is not correct!')

--MainFrame.html
,('confirm','en-US','Confirm')
,('confirm','zh-CN','确定')
,('cancel','en-US','Cancel')
,('cancel','zh-CN','取消')
,('save','en-US','Save')
,('save','zh-CN','保存')
,('empty','en-US','Empty')
,('empty','zh-CN','清空')
,('current_user','en-US','Current user')
,('current_user','zh-CN','当前用户')
,('homepage','en-US','Homepage')
,('homepage','zh-CN','主页')
,('edit_password','en-US','Edit password')
,('edit_password','zh-CN','修改密码')
,('logout','en-US','Logout')
,('logout','zh-CN','退出登录')
,('system_menu','en-US','System menu')
,('system_menu','zh-CN','系统菜单')

--登录界面Login.coffee
,('usr.code','en-US','Username')
,('usr.code','zh-CN','用户名')
,('usr.password','en-US','Password')
,('usr.password','zh-CN','密码')
,('usr.old_psw','en-US','Old Password')
,('usr.old_psw','zh-CN','旧密码')
,('login','en-US','Login')
,('login','zh-CN','登录')
,('session_timeout_msg','en-US','Session timeout, please login again!')
,('session_timeout_msg','zh-CN','登录超时,请重新登录!')

--GameAddSrv.coffee
,('cannot_empty','en-US','Can not be empty!')
,('cannot_empty','zh-CN','不能为空!')
,('code_can_not_be_empty','en-US','Code can not be empty!')
,('code_can_not_be_empty','zh-CN','编码不能为空!')
,('val_exist','en-US','{val} already exist!')
,('val_exist','zh-CN','{val} 已经存在!')
,('code_val_exist','en-US','Code {val} already exist!')
,('code_val_exist','zh-CN','编码 {val} 已经存在!')

--UsrAddSrv.coffee
,('username_cannot_empty','zh-CN','用户名不能为空!')
,('username_cannot_empty','en-US','Username can not be empty!')
,('password_cannot_empty','zh-CN','密码不能为空!')
,('password_cannot_empty','en-US','Password can not be empty!')
,('password_must_6_12_length','en-US','Password length must between in 6 and 12!')
,('password_must_6_12_length','zh-CN','密码必须在6至12个字符之间!')
,('username_val_exist','en-US','Username {val} already exist!')
,('username_val_exist','zh-CN','用户名 {val} 已经存在!')

--LoginSrv.coffee
,('password_incorrect','en-US','Username or password is not correct!')
,('password_incorrect','zh-CN','用户名或密码不正确!')

--列表页面
,('optLbl','en-US','Operation')
,('optLbl','zh-CN','操作')

--page
,('page.code','zh-CN','编码')
,('page.code','en-US','Code')
,('page.lbl','zh-CN','标签')
,('page.lbl','en-US','Label')
--page_lang
,('page_lang._page_id','zh-CN','页面')
,('page_lang._page_id','en-US','Page')
,('page_lang.lang','zh-CN','语言')
,('page_lang.lang','en-US','Language')
,('page_lang.lbl','zh-CN','标签')
,('page_lang.lbl','en-US','Label')
--menu_lang
,('menu_lang._menu_id','zh-CN','菜单')
,('menu_lang._menu_id','en-US','Menu')
,('menu_lang.lang','zh-CN','语言')
,('menu_lang.lang','en-US','Language')
,('menu_lang.lbl','zh-CN','标签')
,('menu_lang.lbl','en-US','Label')
--菜单
,('menu.prn_id','zh-CN','父菜单')
,('menu.prn_id','en-US','Parent Menu')
,('menu.lbl','zh-CN','标签')
,('menu.lbl','en-US','Label')
,('menu._open_op','zh-CN','打开方式')
,('menu._open_op','en-US','Open Mode')
,('menu._page_id','zh-CN','页面')
,('menu._page_id','en-US','Page')
,('menu.is_root','zh-CN','根节点')
,('menu.is_root','en-US','Root')
,('menu.is_leaf','zh-CN','叶子')
,('menu.is_leaf','en-US','Leaf')
,('menu.is_log','zh-CN','日志')
,('menu.is_log','en-US','Log')
,('menu.enable','zh-CN','启用')
,('menu.enable','en-US','Enable')
,('menu.sort_num','zh-CN','排序')
,('menu.sort_num','en-US','Sort')
--表
,('tab.code','zh-CN','编码')
,('tab.code','en-US','Code')
,('tab.lbl','zh-CN','标签')
,('tab.lbl','en-US','Label')
,('tab.is_log','zh-CN','日志')
,('tab.is_log','en-US','Log')
,('tab.create_time','zh-CN','创建时间')
,('tab.create_time','en-US','Create Time')
,('tab.rem','zh-CN','备注')
,('tab.rem','en-US','Remark')
--日志
,('log.pg','zh-CN','页面')
,('log.pg','en-US','Page')
,('log.emp_lbl','zh-CN','用户名')
,('log.emp_lbl','en-US','Username')
,('log.tab','zh-CN','表')
,('log.tab','en-US','Table')
,('log.act','zh-CN','操作')
,('log.act','en-US','Action')
,('log.orcd','zh-CN','旧记录')
,('log.orcd','en-US','Old Recode')
,('log.nrcd','zh-CN','新记录')
,('log.nrcd','en-US','New Recode')
,('log.create_time','zh-CN','创建时间')
,('log.create_time','en-US','Create Time')
,('log.rem','zh-CN','备注')
,('log.rem','en-US','Remark')
--语言
,('lang.code','zh-CN','编码')
,('lang.code','en-US','Code')
,('lang.lbl','zh-CN','名称')
,('lang.lbl','en-US','Name')
--系统选项
,('option.code','zh-CN','编码')
,('option.code','en-US','Code')
,('option.lbl','zh-CN','标签')
,('option.lbl','en-US','Label')
,('option.rem','zh-CN','备注')
,('option.rem','en-US','Remark')
--国际化消息
,('msg.code','zh-CN','编码')
,('msg.code','en-US','Code')
,('msg.lang','zh-CN','语言')
,('msg.lang','en-US','Language')
,('msg.lbl','zh-CN','标签')
,('msg.lbl','en-US','Label')
,('msg.create_time','zh-CN','创建时间')
,('msg.create_time','en-US','Create Time')
,('msg.update_time','zh-CN','更新时间')
,('msg.update_time','en-US','Update Time')
;