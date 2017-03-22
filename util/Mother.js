require("../config");
process.title = "Mother"+process.title;
var fs = require("fs");
var path = require("path");
if(process.platform === "linux") fs.writeFileSync(path.dirname(__dirname)+"/Mother.pid",process.pid);
start();
function start() {
	console.error('Mother process is running.');
	var ls = require('child_process').spawn('./node', ['util/index.js'],{cwd:__dirname+"/../",env: process.env});
	ls.stdout.on('data', function (data) {
		var data = data.toString();
		data = data.substring(0,data.length-1);
		console.log(data);
	});
	ls.stderr.on('data', function (data) {
		var data = data.toString();
		data = data.substring(0,data.length-1);
		console.error(data);
	});
	ls.on('exit', function (code) {
		console.error('child process exited with code ' + code);
		delete(ls);
		setTimeout(start,2000);
	});
}
