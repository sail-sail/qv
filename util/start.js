require('shelljs/global');
var fs = require("fs");
var path = require("path");
var _PROJECT_PATH = path.dirname(__dirname);

if(!String.prototype.endsWith) {
	String.prototype.endsWith = function(s) {
		var t = this;
    	var ltIn = t.lastIndexOf(s);
    	if(ltIn === -1) return false;
    	return t.length-s.length === ltIn;
	};
}

var date = new Date();
//expire_day删除7天前的日志
var conf = require("../config").ops;
var expire_day = Number(conf.expire_day);
if(expire_day !== -1) {
	expire_day = expire_day || 7;
	var expire_time = expire_day * 86400000;
	var files = fs.readdirSync(_PROJECT_PATH+"/../");
	for(var i=0; i<files.length; i++) {
		var file = files[i];
		if(file.indexOf("node_") !== 0) continue;
		if(file.lastIndexOf(".log") !== file.length-".log".length) continue;
		var stats = fs.statSync(_PROJECT_PATH+"/../"+file);
		if(date.getTime() - stats.mtime.getTime() > expire_time) {
			fs.unlinkSync(_PROJECT_PATH+"/../"+file);
		}
	}
}

var exist = fs.existsSync(_PROJECT_PATH+"/Mother.pid");
if(exist) {
	var mother_pid = fs.readFileSync(_PROJECT_PATH+"/Mother.pid","utf8");
	mother_pid = mother_pid.trim();
	var excStr = "kill -9 "+mother_pid;
	exec(excStr);
	console.log(excStr);
}

var exist = fs.existsSync(_PROJECT_PATH+"/index.pid");
if(exist) {
	var index_pid = fs.readFileSync(_PROJECT_PATH+"/index.pid","utf8");
	index_pid = index_pid.trim();
	excStr = "kill -9 "+index_pid;
	exec(excStr);
	console.log(excStr);
}

excStr = 'nohup ./node "./util/Mother.js" >/dev/null 2>../node_`date +"%Y-%m-%d_%H-%M-%S"`.log &';
exec(excStr);
console.log(excStr);