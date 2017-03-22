require("m_");
require("ExpandUtil");
var fs = require('fs');
var path = require('path');
var gulp = require('gulp');
var coffee = require('gulp-coffee');
var newer = require('gulp-newer');
var esmangle = require('gulp-esmangle');
var less = require('gulp-less');
var LessPluginCleanCSS = require('less-plugin-clean-css');
var cleancss = new LessPluginCleanCSS({advanced: true});
var concat = require('gulp-concat');
var replace = require('gulp-replace');
var header = require('gulp-header');
var footer = require('gulp-footer');
var del = require('del');
var babel = require('gulp-babel');
var rename = require('gulp-rename');
var gulpif = require('gulp-if');
var minifycss = require('gulp-minify-css');

var date = new Date();

var root = "../_qv_/";
gulp.task('default', function() {
	gulp.start("srv","node_modules","config","web","version");
});

gulp.task('version', function() {
	var dateStr = date.Format("yyyyMMdd_hhmmss");
	var versionJs = "v"+dateStr;
	try {
		fs.mkdirSync(root);
	} catch(err) {}
	fs.writeFileSync(root+"/version.js","exports.version=\""+versionJs+"\";");
});

gulp.task('del', function() {
	return del([root],{force:true});
});

gulp.task('srv', function() {
	gulp.src("./dao/**/*.coffee")
	.pipe(newer({dest:root+'dao/',ext:".js"}))
	.pipe(coffee())
	.pipe(babel({"presets": ["stage-3"]}))
	.pipe(esmangle())
	.pipe(gulp.dest(root+'dao/'));
	
	gulp.src(["./dao/**/*.sql","!./dao/plv8-debug.sql"])
	.pipe(gulp.dest(root+'dao/'));
	
	gulp.src("./srv/**/*.coffee")
	.pipe(newer({dest:root+'srv/',ext:".js"}))
	.pipe(coffee())
	.pipe(babel({"presets": ["stage-3"]}))
	.pipe(esmangle())
	.pipe(gulp.dest(root+'srv/'));
	
	gulp.src("./tmp/**")
	.pipe(newer({dest:root+'tmp/'}))
	.pipe(gulp.dest(root+'tmp/'));
	
	gulp.src("./util/**/*.coffee")
	.pipe(newer({dest:root+'util/',ext:".js"}))
	.pipe(coffee())
	.pipe(babel({"presets": ["stage-3"]}))
	.pipe(esmangle())
	.pipe(gulp.dest(root+'util/'));
	
	gulp.src("./util/**/*.js")
	.pipe(newer({dest:root+'util/'}))
	.pipe(babel({"presets": ["stage-3"]}))
	.pipe(esmangle())
	.pipe(gulp.dest(root+'util/'));
});

gulp.task('node_modules', function() {
	var ingonArr = [ "!node_modules/gulp/**"
	              ,"!node_modules/gulp"
		          ,"!node_modules/gulp-*/**"
		          ,"!node_modules/gulp-*"
		          ,"!node_modules/less/**"
		          ,"!node_modules/less"
		          ,"!node_modules/less-*/**"
		          ,"!node_modules/less-*"
		          ,"!node_modules/coffee-script/**"
		          ,"!node_modules/coffee-script"
		          ,"!node_modules/**/examples/**"
		          ,"!node_modules/**/examples"
		          ,"!node_modules/**/example/**"
		          ,"!node_modules/**/example"
		          ,"!node_modules/**/test/**"
		          ,"!node_modules/**/test"
		          ,"!node_modules/**/test.js"
		          ,"!node_modules/**/benchmark/**"
		          ,"!node_modules/**/benchmark"
		          ,"!node_modules/**/*.markdown"
		          ,"!node_modules/**/*.md"
		          ,"!node_modules/**/Makefile"
		          ,"!node_modules/**/TODO"
		          ,"!node_modules/mysql/**"
		          ,"!node_modules/mysql"
		          ,"!node_modules/pg/**"
		          ,"!node_modules/pg"
		          ,"!node_modules/mqtt/**"
		          ,"!node_modules/mqtt"
		          ,"!node_modules/**/bin/**"
		          ,"!node_modules/**/bin"
		          ,"!node_modules/node-expat/lib/node-expat.js"
		          ];
	
	var srcArr = ["./node_modules/**/*.coffee"];
	srcArr.push.apply(srcArr,ingonArr);
	gulp.src(srcArr)
	.pipe(newer({dest:root+'node_modules/',ext:".js"}))
	.pipe(coffee())
	.pipe(babel({"presets": ["stage-3"]}))
	.pipe(esmangle())
	.pipe(gulp.dest(root+'node_modules/'));
	
	var srcArr = ["./node_modules/**/*.js","!node_modules/**/*.coffee"];
	srcArr.push.apply(srcArr,ingonArr);
	gulp.src(srcArr)
	.pipe(newer({dest:root+'node_modules/'}))
	.pipe(esmangle())
	.pipe(gulp.dest(root+'node_modules/'));
	
	var srcArr = ["./node_modules/**","!node_modules/**/*.coffee","!node_modules/**/*.js"];
	srcArr.push.apply(srcArr,ingonArr);
	gulp.src(srcArr)
	.pipe(newer({dest:root+'node_modules/'}))
	.pipe(gulp.dest(root+'node_modules/'));
	
	//pg
	var srcArr = ["./node_modules/pg/**/*"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'node_modules/pg/'}))
	.pipe(gulp.dest(root+"node_modules/pg/"));
	
	//mqtt
	var srcArr = ["./node_modules/mqtt/**/*"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'node_modules/mqtt/'}))
	.pipe(gulp.dest(root+"node_modules/mqtt/"));
	
	var srcArr = ["./node_modules/node-expat/lib/node-expat.js"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'node_modules/node-expat/lib/'}))
	.pipe(gulp.dest(root+"node_modules/node-expat/lib/"));
});

gulp.task('config', function() {
	var srcArr = ["./config.js","./jdbc.js"];
	gulp.src(srcArr)
	.pipe(newer({dest:root}))
	.pipe(gulp.dest(root));
	
	var srcArr = ["./debug.bat"];
	gulp.src(srcArr)
	.pipe(newer({dest:root}))
	.pipe(replace(" \"{debug:true}\"",""))
	.pipe(gulp.dest(root));
});

gulp.task('web', function() {
	gulp.src("./web/**/*.less")
	.pipe(newer({dest:root+'web/',ext:".css"}))
	.pipe(less({plugins: [cleancss]}))
	.pipe(gulp.dest(root+"web/"));
	
	gulp.src("./web/**/*.css")
	.pipe(newer({dest:root+'web/',ext:".css"}))
	.pipe(minifycss())
	.pipe(gulp.dest(root+"web/"));
	
	gulp.src("./web/**/*.ttf")
	.pipe(newer({dest:root+'web/',ext:".ttf"}))
	.pipe(gulp.dest(root+"web/"));
	
	var srcArr = ["./web/img/**"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'web/img/'}))
	.pipe(gulp.dest(root+"web/img/"));
	
	var srcArr = [
	              "./web/js/res/regeneratorRuntime.js"
	              ,"./web/js/res/mui.js"
	              ,"./web/js/res/avalon.modern.js"
	              ,"./web/js/res/mootools-core-yc.js"
	              ,"./web/js/res/sea.js"
	              ,"./web/js/res/seajs-css.js"
	              ,"./web/js/res/mootools-more-yc.js"
	              ,"./web/js/res/config.js"
	              ,"./web/js/res/DIY.js"
	              ,"./web/js/res/setImmediate.js"
	              ,"./web/js/res/date.js"
	              ,"./web/js/res/ExpandUtil.js"
	              ];
	var conditionStage_3 = function(file) {
		return ["config.js","DIY.js","setImmediate.js","date.js","ExpandUtil.js"].indexOf(file.relative) !== -1;
	};
	var conditionEsmangle = function(file) {
		return ["regeneratorRuntime.js","config.js","DIY.js","setImmediate.js","date.js","ExpandUtil.js"].indexOf(file.relative) !== -1;
	};
	gulp.src(srcArr)
	.pipe(newer({dest:root+'web/js/res/_resAll.js'}))
	.pipe(gulpif(conditionStage_3,babel({"presets": ["stage-3","es2015"]})))
	.pipe(gulpif(conditionEsmangle,esmangle()))
	.pipe(concat('_resAll.js'))
	.pipe(gulp.dest(root+'web/js/res/'));
	
	gulp.src("./web/js/res/license.txt").pipe(newer({dest:root+'web/js/res/'})).pipe(gulp.dest(root+'web/js/res/'));
	gulp.src("./web/js/res/browserMqtt.js").pipe(newer({dest:root+'web/js/res/'})).pipe(gulp.dest(root+'web/js/res/'));
	
	//echarts.min.js
	gulp.src("./web/js/echarts.min.js")
	.pipe(rename(function(path) {
		path.basename = path.basename.replace(".min","");
	}))
	.pipe(newer({dest:root+'web/js/'}))
	.pipe(gulp.dest(root+'web/js/'));
	
	var srcArr = ["./web/js/comp/**/*.js"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'web/js/comp'}))
	.pipe(babel({"presets": ["stage-3","es2015"]}))
	.pipe(esmangle())
	.pipe(header("sea_define(function(require,exports,module){"))
	.pipe(footer("});"))
	.pipe(gulp.dest(root+'web/js/comp/'));
	
	var srcArr = ["./web/js/comp/**/*.coffee"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'web/js/comp',ext:".js"}))
	.pipe(coffee())
	.pipe(babel({"presets": ["stage-3","es2015"]}))
	.pipe(esmangle())
	.pipe(header("sea_define(function(require,exports,module){"))
	.pipe(footer("});"))
	.pipe(gulp.dest(root+'web/js/comp/'));
	
	var srcArr = ["./web/**/*.coffee"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'web',ext:".js"}))
	.pipe(coffee())
	.pipe(babel({"presets": ["stage-3","es2015"]}))
	.pipe(esmangle())
	.pipe(header("sea_define(function(require,exports,module){"))
	.pipe(footer("});"))
	.pipe(gulp.dest(root+'web/'));
	
	var srcArr = ["./web/**/*.js"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'web',ext:".js"}))
	.pipe(coffee())
	.pipe(babel({"presets": ["stage-3","es2015"]}))
	.pipe(esmangle())
	.pipe(header("sea_define(function(require,exports,module){"))
	.pipe(footer("});"))
	.pipe(gulp.dest(root+'web/'));
	
	var srcArr = ["./web/**/*.html"];
	gulp.src(srcArr)
	.pipe(newer({dest:root+'web'}))
	.pipe(gulp.dest(root+'web/'));
});
gulp.task('babel', function() {
  return gulp.src('test.js')
    .pipe(babel({"presets": ["stage-3"]}))
    .pipe(gulp.dest('dist'));
});