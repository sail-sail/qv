nodejs应用系统

https://github.com/sail-sail/qv

```
1, 安装数据库 PostgreSQL 9.6.x
    https://www.postgresql.org/download/
    (windows x64,centos x64等均可)

2, 停止PostgreSQL服务, 安装PostgreSQL的plv8插件
    centos:
    http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/
    (plv8_94-1.4.4-1.rhel6.x86_64.rpm),(plv8_94-debuginfo-1.4.4-1.rhel6.x86_64.rpm)
    windows:
    http://www.postgresonline.com/journal/archives/367-PLV8-binaries-for-PostgreSQL-9.6-windows-both-32-bit-and-64-bit.html
    32位(PostgreSQL 9.6beta1 plv8 32-bit download - PL/V8 1.4.8)
    64位(PostgreSQL 9.6beta1 plv8 64-bit download - PL/V8 1.4.8)

3, 配置plv8
    PostgreSQL/9.6/data/postgresql.conf
    最后一行加入: plv8.start_proc = 'init_plv8'

4, 启动PostgreSQL服务, 打开pgAdmin客户端创建数据库 qv

5, 执行sql文件
    qv/dao/init/plv8.sql
    qv/dao/init/sys.sql
    qv/dao/init/lgf.sql
    qv/dao/init/city.sql

6, 安装开发时node_modules
    解压 qv/node_modules.7z 到 qv 的上一层目录

6, 启动--调试方式启动nodejs的版本需大于7.6.*
    cd qv
    node "util/index.js" "{debug:true}"

7, chrome浏览器访问
    http//localhost:8280

8, 发布
    npm install -g gulp
    cd qv
    gulp
    会生成文件夹 _qv_
    发布后,nodejs版本需大于4.0, IE浏览器版本大于等于IE8
```
```
体验: http://119.29.236.97:7777/ 用户名 admin 密码 111111
```
```
联系作者: QQ:151263555  Email:151263555@qq.com
源码免费,时间宝贵,问答收费
```