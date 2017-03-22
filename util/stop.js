require('shelljs/global');
var fs = require("fs");
var path = require("path");
var _PROJECT_PATH = path.dirname(__dirname);

var exist = fs.existsSync(_PROJECT_PATH+"/Mother.pid");
if(exist) {
	var mother_pid = fs.readFileSync(_PROJECT_PATH+"/Mother.pid","utf8");
	mother_pid = mother_pid.trim();
	var excStr = "kill -9 "+mother_pid;
	exec(excStr);
	fs.unlinkSync(_PROJECT_PATH+"/Mother.pid");
	console.log(excStr);
}

var exist = fs.existsSync(_PROJECT_PATH+"/index.pid");
if(exist) {
	var index_pid = fs.readFileSync(_PROJECT_PATH+"/index.pid","utf8");
	index_pid = index_pid.trim();
	excStr = "kill -9 "+index_pid;
	exec(excStr);
	fs.unlinkSync(_PROJECT_PATH+"/index.pid");
	console.log(excStr);
}
