//作者: Sail QQ:151263555
exports.debug = false

//端口
exports.port = 88

//session失效时间
exports.sessionTimeout = 3600

exports.mapping = function (ph,req) {
	//var agent = req.headers["user-agent"] && req.headers["user-agent"].toLowerCase();
	if(ph === "" || ph === "/") {
		//if(agent.match(/(iphone|ipod|ipad|android)/)) return "/sys/MainApp.html"
		return "/sys/MainFrame.html";
	}
	if(ph === "/favicon.ico") return "/img/favicon.ico";
	return ph;
}

//缓存时间,默认10年
exports.cacheTimeUrl = function(ph) {return 0;}

//sessionId存储的方式,js,header,cookie
exports.sessionId = "header";

//日志配置 lever:日志等级info log error,path日志保存的路径
exports.log = {lever: "log",path: __dirname+"/../",separate:"yyyy-MM-dd",expire_day:31}

if (process.argv[2]) {
	var argv = eval('('+process.argv[2]+')');
	for(var key in argv) exports[key] = argv[key];
}
process.title = "lgf";
