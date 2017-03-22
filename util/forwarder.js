var net = require('net');
// parse "80" and "localhost:80" or even "42mEANINg-life.com:80"
var addrRegex = /^(([a-zA-Z\-\.0-9]+):)?(\d+)$/;
var addr = {
    from: addrRegex.exec(process.argv[2]),
    to: addrRegex.exec(process.argv[3])
};
if (!addr.from || !addr.to) throw new Error('Usage: <from> <to>');
net.createServer(function(from) {
	var to = net.createConnection({host: addr.to[2],port: addr.to[3]});
	from.pipe(to);
	to.pipe(from);
}).listen(addr.from[3], addr.from[2]);
process.title = "node_forwarder";

process.on("exit",function(code) {
	console.error("exit: "+code);
});
process.on("beforeExit",function() {
	console.error("---beforeExit---");
	console.error(arguments);
});
process.on("uncaughtException",function(err) {
	console.error(err);
	console.error(err.stack);
});
process.on('unhandledRejection',function() {
	console.error("unhandledRejection");
	console.error(arguments);
});
process.on('rejectionHandled',function() {
	console.error("rejectionHandled");
	console.error(arguments);
});