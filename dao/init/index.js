require.extensions['.node_v' + process.versions.modules + "_" + process.platform + "_" + process.arch] = function(module, filename) {
  return require.extensions['.node'](module, filename);
};

var fs = require("fs");
var path = require("path");
require("m_");
require("date");
require("ExpandUtil");
var coffeeScript = require("coffee-script");
var babelCore = require("babel-core");
require.extensions['.coffee'] = function(module, filename) {
	var content = coffeeScript.compile(fs.readFileSync(filename, 'utf8'), {
		filename : filename
	});
	content = babelCore.transform(content,{"presets": ["stage-3"]}).code;
	return module._compile(content, filename);
};
require.extensions['.js'] = function(module, filename) {
	var content = fs.readFileSync(filename, 'utf8');
	if(filename.indexOf("node_modules") === -1) {
		content = babelCore.transform(content,{"presets": ["stage-3"]}).code;
	}
	return module._compile(content, filename);
};

require("./init");