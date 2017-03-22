insert into "srch"("usr_id","page_id","lbl","and_or","and_or_lbl","name","name_lbl","opt","opt_lbl","value","dft","rem") values
 (0,	10,		'未发货订单',		'and',		'并且',		't.state',				'状态',			'=',		'等于',			'未发货',		false,		'未发货订单')
,(0,	10,		'当天订单',			'and',		'并且',		't.create_time',		'创建时间',		'>=',		'大于等于',		'javascript:r=(new Date()).Format("yyyy-MM-dd")',		false,		'')
,(0,	10,		'当天订单',			'and',		'并且',		't.create_time',		'创建时间',		'<',		'小于',			'javascript:var date=new Date();date.setDate(date.getDate()+1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	10,		'昨天订单',			'and',		'并且',		't.create_time',		'创建时间',		'>=',		'大于等于',		'javascript:var date=new Date();date.setDate(date.getDate()-1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	10,		'昨天订单',			'and',		'并且',		't.create_time',		'创建时间',		'<',		'小于',			'javascript:r=(new Date()).Format("yyyy-MM-dd")',		false,		'')
,(0,	15,		'当天业绩',			'and',		'并且',		't.create_time',		'创建时间',		'>=',		'大于等于',		'javascript:r=(new Date()).Format("yyyy-MM-dd")',		true,		'')
,(0,	15,		'当天业绩',			'and',		'并且',		't.create_time',		'创建时间',		'<',		'小于',			'javascript:var date=new Date();date.setDate(date.getDate()+1);r=date.Format("yyyy-MM-dd")',		true,		'')
,(0,	15,		'昨天业绩',			'and',		'并且',		't.create_time',		'创建时间',		'>=',		'大于等于',		'javascript:var date=new Date();date.setDate(date.getDate()-1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	15,		'昨天业绩',			'and',		'并且',		't.create_time',		'创建时间',		'<',		'小于',			'javascript:r=(new Date()).Format("yyyy-MM-dd")',		false,		'')
,(0,	15,		'当月业绩',			'and',		'并且',		't.create_time',		'创建时间',		'>=',		'大于等于',		'javascript:var date=new Date();date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	15,		'当月业绩',			'and',		'并且',		't.create_time',		'创建时间',		'<',		'小于',			'javascript:var date=new Date();date.setMonth(date.getMonth()+1);date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	15,		'上月业绩',			'and',		'并且',		't.create_time',		'创建时间',		'>=',		'大于等于',		'javascript:var date=new Date();date.setMonth(date.getMonth()-1);date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	15,		'上月业绩',			'and',		'并且',		't.create_time',		'创建时间',		'<',		'小于',			'javascript:var date=new Date();date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	17,		'当月',				'and',		'并且',		't.tme',				'日期',			'>=',		'大于等于',		'javascript:var date=new Date();date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	17,		'当月',				'and',		'并且',		't.tme',				'日期',			'<',		'小于',			'javascript:var date=new Date();date.setMonth(date.getMonth()+1);date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	21,		'当天统计',			'and',		'并且',		't.dt',					'日期',			'>=',		'大于等于',		'javascript:r=(new Date()).Format("yyyy-MM-dd")',		true,		'')
,(0,	21,		'当天统计',			'and',		'并且',		't.dt',					'日期',			'<',		'小于',			'javascript:var date=new Date();date.setDate(date.getDate()+1);r=date.Format("yyyy-MM-dd")',		true,		'')
,(0,	21,		'昨天统计',			'and',		'并且',		't.dt',					'日期',			'>=',		'大于等于',		'javascript:var date=new Date();date.setDate(date.getDate()-1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	21,		'昨天统计',			'and',		'并且',		't.dt',					'日期',			'<',		'小于',			'javascript:r=(new Date()).Format("yyyy-MM-dd")',		false,		'')
,(0,	21,		'当月统计',			'and',		'并且',		't.dt',					'日期',			'>=',		'大于等于',		'javascript:var date=new Date();date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	21,		'当月统计',			'and',		'并且',		't.dt',					'日期',			'<',		'小于',			'javascript:var date=new Date();date.setMonth(date.getMonth()+1);date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	21,		'上月统计',			'and',		'并且',		't.dt',					'日期',			'>=',		'大于等于',		'javascript:var date=new Date();date.setMonth(date.getMonth()-1);date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
,(0,	21,		'上月统计',			'and',		'并且',		't.dt',					'日期',			'<',		'小于',			'javascript:var date=new Date();date.setDate(1);r=date.Format("yyyy-MM-dd")',		false,		'')
;
insert into "sort"("page_id","name","opt") values
 (10,'t.create_time','desc')
,(15,'amt','desc')
,(21,'t.dt','desc')
,(22,'t.dt','desc')
;
INSERT INTO "page"("id","code","lbl","url") VALUES
 (1,	'UsrList',				'用户列表',					'/usr/UsrList.html')
,(2,	'Et_psw',				'修改密码',					'/usr/Et_psw.html')
,(3,	'RoleList',				'角色列表',					'/role/RoleList.html')
,(4,	'MenuList',				'菜单列表',					'/menu/MenuList.html')
,(5,	'PageList',				'页面列表',					'/page/PageList.html')
,(6,	'OptionList',			'系统选项列表',				'/option/OptionList.html')
,(7,	'CourierList',			'快递列表',					'/courier/CourierList.html')
,(8,	'Pay_typeList',			'付款方式列表',				'/pay_type/Pay_typeList.html')
,(9,	'PtList',				'产品列表',					'/pt/PtList.html')
,(10,	'SoList',				'订单列表',					'/so/SoList.html')
,(11,	'SodList',				'订单明细列表',				'/sod/SodList.html')
,(12,	'SoT2',					'订单标签页',				'/so/SoT2.html')
,(13,	'PtT2',					'产品标签页',				'/pt/PtT2.html')
,(14,	'Rn_gdList',			'退货列表',					'/rn_gd/Rn_gdList.html')
,(15,	'AchtList',				'绩效列表',					'/acht/AchtList.html')
,(16,	'Mth_tgList',			'绩效目标列表',				'/mth_tg/Mth_tgList.html')
,(17,	'Mnl_ahtList',			'手工业绩列表',				'/mnl_aht/Mnl_ahtList.html')
,(18,	'ProvinList',			'省份列表',					'/provin/ProvinList.html')
,(19,	'CityList',				'城市列表',					'/city/CityList.html')
,(20,	'Qk_rmList',			'快捷备注列表',				'/qk_rm/Qk_rmList.html')
,(21,	'Cus_sttList',			'客户统计',					'/cus_stt/Cus_sttList.html')
,(22,	'LogList',				'日志列表',					'/log/LogList.html')
;
select setval('page_id_seq',(select max(id) from page));
INSERT INTO "menu" ("id","lbl","prn_id","open_op","page_id","is_root","is_leaf","enable") VALUES 
 (1,	'基础数据',			0,		'tab',0, 	true,	false,	true)
,(2,	'角色',				1,		'tab',3, 	false,	true,	true)
,(3,	'菜单',				1,		'tab',4, 	false,	true,	true)
,(4,	'页面',				1,		'tab',5, 	false,	true,	true)
,(5,	'系统选项',			1,		'tab',6, 	false,	true,	true)
,(6,	'快递',				1,		'tab',7, 	false,	true,	true)
,(7,	'省份',				1,		'tab',18, 	false,	true,	true)
,(8,	'城市',				1,		'tab',19, 	false,	true,	true)
,(9,	'付款方式',			1,		'tab',8, 	false,	true,	true)
,(10,	'绩效目标',			1,		'tab',16, 	false,	true,	true)
,(11,	'产品',				1,		'tab',13, 	false,	true,	true)
,(12,	'手工绩效',			1,		'tab',17, 	false,	true,	true)
,(13,	'快捷备注',			1,		'tab',20, 	false,	true,	true)
,(14,	'日志',				1,		'tab',22, 	false,	true,	true)
,(15,	'退货',				0,		'tab',14, 	true,	true,	true)
,(16,	'用户',				0,		'tab',1, 	true,	true,	true)
,(17,	'订单',				0,		'tab',12, 	true,	true,	true)
,(18,	'绩效',				0,		'tab',15, 	true,	true,	true)
,(19,	'客户统计',			0,		'tab',21, 	true,	true,	true)
;
select setval('menu_id_seq',(select max(id) from menu));

insert into "option"(code,lbl,rem) values
 ('host','http://localhost:8480','服务器域名')
,('ip','127.0.0.1','服务器IP地址')
;
--------------------------------------------------------------------------------------------------usr 用户
DROP TABLE IF EXISTS "usr";
CREATE TABLE "usr" (
  "id" 				serial				PRIMARY KEY,
  "code" 			varchar(50) 		NOT NULL,
  "password" 		varchar(50) 		NOT NULL,
  "lbl" 			varchar(50) 		NOT NULL DEFAULT '',
  "role_id" 		int					default 0,
  "prn_id"			int					default 0,
  "email"			varchar(25) 		NOT NULL DEFAULT '',
  "mph"				varchar(25) 		NOT NULL DEFAULT '',
  "wechat"			varchar(50) 		NOT NULL DEFAULT '',
  "tph"				varchar(25) 		NOT NULL DEFAULT '',
  "lgn_tm"			timestamp			DEFAULT NULL,
  "ip"				varchar(35) 		NOT NULL DEFAULT '',
  "img"				oid 				DEFAULT NULL,
  "create_time"		timestamp			DEFAULT NULL,
  "lgn_num"			int					default 0,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "usr"					is '用户';
COMMENT ON COLUMN "usr"."code" 			is '用户名';
COMMENT ON COLUMN "usr"."password"			is '密码';
COMMENT ON COLUMN "usr"."lbl" 				is '姓名';
COMMENT ON COLUMN "usr"."role_id" 			is '角色';
COMMENT ON COLUMN "usr"."prn_id" 			is '父用户';
COMMENT ON COLUMN "usr"."email" 			is '邮箱';
COMMENT ON COLUMN "usr"."mph" 				is '手机';
COMMENT ON COLUMN "usr"."wechat" 			is '微信';
COMMENT ON COLUMN "usr"."tph" 				is '固定电话';
COMMENT ON COLUMN "usr"."ip" 				is 'IP地址';
COMMENT ON COLUMN "usr"."img" 				is '头像';
COMMENT ON COLUMN "usr"."create_time" 		is '注册时间';
COMMENT ON COLUMN "usr"."lgn_num" 			is '密码错误';
COMMENT ON COLUMN "usr"."rem" 				is '备注';
create trigger usr_func_4_create_time_i before insert on "usr" for each row execute procedure func_4_create_time();
INSERT INTO "usr" ("id","role_id","lbl","code","password") VALUES 
 (1,0,'管理员','admin','admin123')
,(2,2,'客服1','kefu','123456')
,(3,1,'组长1','zuzhang','123456')
,(4,3,'发货员1','fahuo','123456')
;
create unique index usr_code_unique on "usr"("code");
select setval('usr_id_seq',(select max(id) from usr));
create or replace function usr__largeobject() returns trigger as $qk$
	["img"].forEach(function(item){
		plv8.find_function("qk_largeobject")(item,{TG_OP:TG_OP,NEW:NEW,OLD:OLD});
	});
	return NEW;
$qk$ language plv8;
create trigger usr__largeobject_ud before update or delete on "usr" for each row execute procedure usr__largeobject();
--------------------------------------------------------------------------------------------------role 角色
DROP TABLE IF EXISTS "role";
CREATE TABLE "role" (
  "id" 				serial				PRIMARY KEY,
  "lbl" 			varchar(50) 		NOT NULL,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "role"						is '角色';
COMMENT ON COLUMN "role"."lbl" 				is '名称';
COMMENT ON COLUMN "role"."rem" 				is '备注';
insert into "role"("id","lbl","rem") values
 (1,'组长','')
,(2,'客服','')
,(3,'发货员','')
,(4,'财务','')
;
select setval('role_id_seq',(select max(id) from "role"));
--------------------------------------------------------------------------------------------------courier 快递
DROP TABLE IF EXISTS "courier";
CREATE TABLE "courier" (
  "id" 				serial				PRIMARY KEY,
  "lbl" 			varchar(50) 		NOT NULL,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "courier"					is '快递';
COMMENT ON COLUMN "courier"."lbl" 				is '名称';
COMMENT ON COLUMN "courier"."rem" 				is '备注';
insert into "courier"("id","lbl","rem") values
 (1,'顺丰','')
,(2,'圆通','')
,(3,'申通','')
;
select setval('courier_id_seq',(select max(id) from "courier"));
--------------------------------------------------------------------------------------------------pt 产品
--名称lbl, 单价pr, 库存数量qty, 单位um, 最低库存min_qty, 最高库存max_qty, 创建时间create_time, 修改时间update_time, 备注rem
DROP TABLE IF EXISTS "pt";
CREATE TABLE "pt" (
  "id" 				serial				PRIMARY KEY,
  "lbl" 			varchar(50) 		DEFAULT '',
  "pr"				numeric(20,10)		NOT NULL default 0,
  "create_time"		timestamp			DEFAULT NULL,
  "update_time"		timestamp			DEFAULT NULL,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "pt"						is '产品';
COMMENT ON COLUMN "pt"."lbl" 				is '名称';
COMMENT ON COLUMN "pt"."pr" 				is '单价';
COMMENT ON COLUMN "pt"."create_time" 		is '创建时间';
COMMENT ON COLUMN "pt"."update_time" 		is '修改时间';
COMMENT ON COLUMN "pt"."rem" 				is '备注';
create trigger pt_func_4_create_time_i before insert on "pt" for each row execute procedure func_4_create_time();
create trigger pt_func_4_update_time_i before update on "pt" for each row execute procedure func_4_update_time();
select setval('pt_id_seq',(select max(id) from "pt"));
--------------------------------------------------------------------------------------------------pt_sc 产品规格
DROP TABLE IF EXISTS "pt_sc";
CREATE TABLE "pt_sc" (
  "id" 				serial				PRIMARY KEY,
  "pt_id"			int					NOT NULL DEFAULT 0,
  "lbl" 			varchar(50) 		NOT NULL,
  "qty"				numeric(20,10)		NOT NULL default 0,
  "min_qty"			numeric(20,10)		NOT NULL default 0,
  "max_qty"			numeric(20,10)		NOT NULL default 0,
  "sort_num" 		int					NOT NULL DEFAULT 0,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "pt_sc"						is '产品规格';
COMMENT ON COLUMN "pt_sc"."pt_id" 				is '产品';
COMMENT ON COLUMN "pt_sc"."lbl" 				is '规格';
COMMENT ON COLUMN "pt_sc"."qty" 				is '库存数量';
COMMENT ON COLUMN "pt_sc"."min_qty" 			is '最低库存';
COMMENT ON COLUMN "pt_sc"."max_qty" 			is '最高库存';
COMMENT ON COLUMN "pt_sc"."sort_num" 			is '排序';
COMMENT ON COLUMN "pt_sc"."rem" 				is '备注';
select setval('pt_sc_id_seq',(select max(id) from "pt_sc"));
create or replace function pt_sc_sort_num() returns trigger as $qk$
	plv8.find_function("qk_sort_num")("pt_sc",{TG_OP:TG_OP,NEW:NEW});
	return NEW;
$qk$ language plv8;
create trigger pt_sc_sort_num_ui after insert or update on "pt_sc" for each row execute procedure pt_sc_sort_num();
--------------------------------------------------------------------------------------------------pay_type 付款方式
DROP TABLE IF EXISTS "pay_type";
CREATE TABLE "pay_type" (
  "id" 				serial				PRIMARY KEY,
  "lbl" 			varchar(50) 		DEFAULT '',
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "pay_type"						is '付款方式';
COMMENT ON COLUMN "pay_type"."lbl" 				is '名称';
COMMENT ON COLUMN "pay_type"."rem" 				is '备注';
insert into "pay_type"("id","lbl","rem") values
 (1,'微信','')
,(2,'建行','')
,(3,'支付宝','')
,(4,'邮政','')
,(5,'欠款','')
;
select setval('pay_type_id_seq',(select max(id) from "pay_type"));
--------------------------------------------------------------------------------------------------mth_tg 月绩效目标
DROP TABLE IF EXISTS "mth_tg";
CREATE TABLE "mth_tg" (
  "id" 				serial				PRIMARY KEY,
  "usr_id"			int					NOT NULL DEFAULT 0,
  "pn_tg"			numeric(20,10)		NOT NULL default 0,
  "tm_tg"			numeric(20,10)		NOT NULL default 0
);
COMMENT ON TABLE  "mth_tg"							is '绩效目标';
COMMENT ON COLUMN "mth_tg"."usr_id" 				is '客服';
COMMENT ON COLUMN "mth_tg"."pn_tg"					is '个人目标';
COMMENT ON COLUMN "mth_tg"."tm_tg"					is '团队目标';
insert into "mth_tg"("usr_id","pn_tg","tm_tg") values
 (0,3000,80000)
;
select setval('mth_tg_id_seq',(select max(id) from "mth_tg"));
--------------------------------------------------------------------------------------------------so 订单
--客服usr_id, 客户cm_nm, 快递courier_id, 代收clt, 全款fpy, 手机mph, 地址addr, 创建时间create_time, 修改时间update_time, 创建人create_usr, 修改人update_usr, 备注rem
DROP TABLE IF EXISTS "so";
CREATE TABLE "so" (
  "id" 				serial				PRIMARY KEY,
  "acc_state"		varchar(20)		not null default '未核',
  "crr_state"		varchar(20)		not null default '未付',
  "cr_no" 			varchar(50) 		NOT NULL DEFAULT '',
  "state" 			varchar(50) 		NOT NULL DEFAULT '',
  "usr_id"			int					NOT NULL DEFAULT 0,
  "cm_nm" 			varchar(50) 		NOT NULL,
  "courier_id"		int					NOT NULL DEFAULT 0,
  "pay_type_id"		int					NOT NULL DEFAULT 0,
  "amt"				numeric(20,10)		NOT NULL default 0,
  "trust_amt"		numeric(20,10)		NOT NULL default 0,
  "mbp" 			varchar(50) 		NOT NULL,
  "cy_thg" 			varchar(70) 		NOT NULL DEFAULT '',
  "qk" 				boolean	 		NOT NULL DEFAULT false,
  "addr" 			varchar(500) 		NOT NULL,
  "xudan" 			boolean	 		DEFAULT NULL,
  "create_time"		timestamp			DEFAULT NULL,
  "update_time"		timestamp			DEFAULT NULL,
  "create_usr"		varchar(50) 		NOT NULL DEFAULT '',
  "update_usr"		varchar(50) 		NOT NULL DEFAULT '',
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "so"						is '产品';
COMMENT ON COLUMN "so"."acc_state" 		is '财务(已核,未核)';
COMMENT ON COLUMN "so"."crr_state" 		is '快递(到付,未付)';
COMMENT ON COLUMN "so"."cr_no" 			is '快递单号';
COMMENT ON COLUMN "so"."state" 			is '状态';
COMMENT ON COLUMN "so"."usr_id" 			is '用户';
COMMENT ON COLUMN "so"."cm_nm" 			is '客户';
COMMENT ON COLUMN "so"."courier_id" 		is '快递';
COMMENT ON COLUMN "so"."pay_type_id"		is '付款方式';
COMMENT ON COLUMN "so"."amt"				is '金额';
COMMENT ON COLUMN "so"."trust_amt"			is '代收金额';
COMMENT ON COLUMN "so"."mbp" 				is '手机';
COMMENT ON COLUMN "so"."cy_thg" 			is '托寄物内容';
COMMENT ON COLUMN "so"."qk"				is '欠款';
COMMENT ON COLUMN "so"."addr"				is '地址';
COMMENT ON COLUMN "so"."xudan"				is '续单';
COMMENT ON COLUMN "so"."create_time" 		is '创建时间';
COMMENT ON COLUMN "so"."update_time" 		is '修改时间';
COMMENT ON COLUMN "so"."create_usr" 		is '创建人';
COMMENT ON COLUMN "so"."update_usr" 		is '修改人';
COMMENT ON COLUMN "so"."rem" 				is '备注';
create trigger so_func_4_create_time_i before insert on "so" for each row execute procedure func_4_create_time();
create trigger so_func_4_update_time_i before update on "so" for each row execute procedure func_4_update_time();
select setval('so_id_seq',(select max(id) from "so"));
--------------------------------------------------------------------------------------------------sod 订单
--订单 so_id, 数量 qty, 金额 amt, 产品 pt_id, 创建时间 create_time, 备注 rem
DROP TABLE IF EXISTS "sod";
CREATE TABLE "sod" (
  "id" 				serial				PRIMARY KEY,
  "so_id"			int					NOT NULL DEFAULT 0,
  "pt_id"			int					NOT NULL DEFAULT 0,
  "pt_sc_id"		int					NOT NULL DEFAULT 0,
  "qty"				numeric(20,10)		NOT NULL DEFAULT 0,
  "create_time"		timestamp			DEFAULT NULL
);
COMMENT ON TABLE  "sod"					is '订单明细';
COMMENT ON COLUMN "sod"."so_id" 			is '订单编号';
COMMENT ON COLUMN "sod"."pt_id" 			is '产品';
COMMENT ON COLUMN "sod"."pt_sc_id" 		is '规格';
COMMENT ON COLUMN "sod"."qty" 				is '数量';
COMMENT ON COLUMN "sod"."create_time" 		is '创建时间';
create trigger sod_func_4_create_time_i before insert on "sod" for each row execute procedure func_4_create_time();
select setval('sod_id_seq',(select max(id) from "sod"));
-------------------------------------------------------------------------------------------------退货 rn_gd
--客服 usr_id,  快递单号 so_id,  退货金额 amt, 创建时间 create_time, 创建人 create_usr,  备注 rem
DROP TABLE IF EXISTS "rn_gd";
CREATE TABLE "rn_gd" (
  "id" 				serial				PRIMARY KEY,
  "so_id"			int					NOT NULL DEFAULT 0,
  "amt"				numeric(20,10)		NOT NULL default 0,
  "create_time"		timestamp			DEFAULT NULL,
  "create_usr"		varchar(50) 		NOT NULL DEFAULT '',
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "rn_gd"						is '退货';
COMMENT ON COLUMN "rn_gd"."so_id" 				is '快递单号';
COMMENT ON COLUMN "rn_gd"."amt" 				is '金额';
COMMENT ON COLUMN "rn_gd"."create_time" 		is '创建时间';
COMMENT ON COLUMN "rn_gd"."create_usr" 		is '创建人';
COMMENT ON COLUMN "rn_gd"."rem" 				is '备注';
create trigger rn_gd_func_4_create_time_i before insert on "rn_gd" for each row execute procedure func_4_create_time();
select setval('rn_gd_id_seq',(select max(id) from "rn_gd"));
--------------------------------------------------------------------------------------------------mnl_aht 手工业绩
DROP TABLE IF EXISTS "mnl_aht";
CREATE TABLE "mnl_aht" (
  "id" 				serial				PRIMARY KEY,
  "tme" 			timestamp			DEFAULT NULL,
  "amt"				numeric(20,10)		NOT NULL default 0,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "mnl_aht"					is '快递';
COMMENT ON COLUMN "mnl_aht"."tme" 				is '时间';
COMMENT ON COLUMN "mnl_aht"."amt" 				is '金额';
COMMENT ON COLUMN "mnl_aht"."rem" 				is '备注';
select setval('mnl_aht_id_seq',(select max(id) from "mnl_aht"));

--------------------------------------------------------------------------------------------------provin 省份
DROP TABLE IF EXISTS "provin";
CREATE TABLE "provin" (
  "id" 				serial				PRIMARY KEY,
  "lbl" 			varchar(50) 		NOT NULL,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "provin"						is '省份';
COMMENT ON COLUMN "provin"."lbl" 				is '名称';
COMMENT ON COLUMN "provin"."rem" 				is '备注';
select setval('provin_id_seq',(select max(id) from "provin"));
--------------------------------------------------------------------------------------------------city 城市
DROP TABLE IF EXISTS "city";
CREATE TABLE "city" (
  "id" 				serial				PRIMARY KEY,
  "provin_id"		int					NOT NULL DEFAULT 0,
  "lbl" 			varchar(50) 		NOT NULL,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "city"						is '城市';
COMMENT ON COLUMN "city"."provin_id" 			is '省份';
COMMENT ON COLUMN "city"."lbl" 				is '城市';
COMMENT ON COLUMN "city"."rem" 				is '备注';
select setval('city_id_seq',(select max(id) from "city"));
--------------------------------------------------------------------------------------------------qk_rm 快捷备注
DROP TABLE IF EXISTS "qk_rm";
CREATE TABLE "qk_rm" (
  "id" 				serial				PRIMARY KEY,
  "lbl" 			varchar(50) 		NOT NULL,
  "sort_num" 		int					NOT NULL DEFAULT 0,
  "rem"				varchar(100) 		NOT NULL DEFAULT ''
);
COMMENT ON TABLE  "qk_rm"						is '快捷备注';
COMMENT ON COLUMN "qk_rm"."lbl" 				is '名称';
COMMENT ON COLUMN "qk_rm"."sort_num" 			is '排序';
COMMENT ON COLUMN "qk_rm"."rem" 				is '备注';
select setval('qk_rm_id_seq',(select max(id) from "qk_rm"));
create or replace function qk_rm_sort_num() returns trigger as $$
	plv8.find_function("qk_sort_num")("qk_rm",{TG_OP:TG_OP,NEW:NEW});
	return NEW;
$$ language plv8;
create trigger qk_rm_sort_num_ui after insert or update on "qk_rm" for each row execute procedure qk_rm_sort_num();
--------------------------------------------------------------------------------------------------cus_stt 客户统计
DROP TABLE IF EXISTS "cus_stt";
CREATE TABLE "cus_stt" (
  "id" 				serial				PRIMARY KEY,
  "dt"	 			timestamp		 	NOT NULL,
  "usr_id"			int					NOT NULL DEFAULT 0,
  "mrn"				int 				NOT NULL DEFAULT 0,
  "aft"				int 				NOT NULL DEFAULT 0,
  "ngt"				int 				NOT NULL DEFAULT 0,
  "no_rpy"			int 				NOT NULL DEFAULT 0,
  "black"			int 				NOT NULL DEFAULT 0,
  "efft"			int 				NOT NULL DEFAULT 0,
  "intt"			int 				NOT NULL DEFAULT 0,
  "bill"			int 				NOT NULL DEFAULT 0,
  "tt_nm"			int 				NOT NULL DEFAULT 0,
  "cnv_rt"			numeric(20,10)		NOT NULL default 0
);
COMMENT ON TABLE  "cus_stt"						is '客户统计';
COMMENT ON COLUMN "cus_stt"."dt" 					is '日期';
COMMENT ON COLUMN "cus_stt"."usr_id" 				is '客服';
COMMENT ON COLUMN "cus_stt"."mrn" 					is '早上';
COMMENT ON COLUMN "cus_stt"."aft" 					is '中午';
COMMENT ON COLUMN "cus_stt"."ngt" 					is '晚上';
COMMENT ON COLUMN "cus_stt"."no_rpy" 				is '不回复';
COMMENT ON COLUMN "cus_stt"."black" 				is '拉黑';
COMMENT ON COLUMN "cus_stt"."efft" 				is '有效';
COMMENT ON COLUMN "cus_stt"."intt" 				is '意向';
COMMENT ON COLUMN "cus_stt"."bill" 				is '开单';
COMMENT ON COLUMN "cus_stt"."tt_nm" 				is '总人数';
COMMENT ON COLUMN "cus_stt"."cnv_rt" 				is '转化率';