(function(){
// 对Date的扩展，将 Date 转化为指定格式的String   
// 月(M)、日(d)、小时(h)、分(m)、秒(s)、季度(q) 可以用 1-2 个占位符，   
// 年(y)可以用 1-4 个占位符，毫秒(S)只能用 1 个占位符(是 1-3 位的数字)   
// 例子：   
// (new Date()).Format("yyyy-MM-dd hh:mm:ss.S") ==> 2006-07-02 08:09:04.423   
// (new Date()).Format("yyyy-M-d h:m:s.S")      ==> 2006-7-2 8:9:4.18
if(!Date.prototype.Format) {
	Date.prototype.Format = function(fmt) {
		var o = {
			"M+" : this.getMonth()+1,                 //月份
			"d+" : this.getDate(),                    //日
			"h+" : this.getHours(),                   //小时
			"m+" : this.getMinutes(),                 //分
			"s+" : this.getSeconds(),                 //秒
			"q+" : Math.floor((this.getMonth()+3)/3), //季度
			"S"  : this.getMilliseconds()             //毫秒
		};
		if(/(y+)/.test(fmt))
			fmt=fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length));
		for(var k in o)
			if(new RegExp("("+ k +")").test(fmt))
		fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));
		return fmt;
	};
}
Date.fromISO = function(s){
	if(typeOf(s) !== "string") return s;
	if(s.indexOf(":") === -1) s += " 00:00:00";
	var date = new Date(s);
	if(!isNaN(date)) return date;
	var day, tz;
	var rxs= [/^(\d{4}\-\d\d\-\d\d([tT ][\d:\.]*)?)([zZ]|([+\-])(\d\d):(\d\d))?$/,/^\s*(\d{4})-(\d\d)-(\d\d)\s*$/];
	for(var i=0; i<rxs.length; i++) {
		var rx = rxs[i];
		var p= rx.exec(s);
		if(p && p[1]){
			day= p[1].split(/\D/).map(function(itm){
				return parseInt(itm, 10) || 0;
			});
			day[1]-= 1;
			day= new Date(Date.UTC.apply(Date, day));
			if(!day.getDate()) return s;
			if(p[5]){
				tz= parseInt(p[5], 10)*60;
				if(p[6]) tz += parseInt(p[6], 10);
				if(p[4]== "+") tz*= -1;
				if(tz) day.setUTCMinutes(day.getUTCMinutes()+ tz);
			}
			return day;
		}
	}
	if(date === undefined || date === null || isNaN(date)) return null;
	return date;
}
//"aaabbb{0}ccc{1}ddd".format0(["g","h"]);
//输出"aaabbbgccchddd"
String.prototype.format0 = function(args,begin,end){
	var t = this;
	if(args === undefined || args === null) args = "";
	if(!Array.isArray(args)) args = [args];
	begin = begin || "{";
	end = end || "}"
	begin = begin.escapeRegExp();
	end = end.escapeRegExp();
    return t.replace(new RegExp(begin+"(\\d+)"+end,"g"), function(m, i){
    	if(args[i] === undefined || args[i] === null) args[i] = "";
        return args[i];
    });
};
String.isEmpty = function(str,isTrim) {
	if(str === undefined || str === null) return true
	if(isTrim !== false) {
		str = String(str).trim();
	} else {
		str = String(str);
	}
	return str === "";
};
if(String.prototype.startsWith === undefined) {
	String.prototype.startsWith = function(s) {
		return this.indexOf(s) === 0;
	};
}
if(String.prototype.endsWith === undefined) {
	String.prototype.endsWith = function(s) {
		var t = this;
    	var ltIn = t.lastIndexOf(s);
    	if(ltIn === -1) return false;
    	return t.length-s.length === ltIn;
	};
}
if(String.prototype.reverse === undefined) {
	String.prototype.reverse = function () {
		return this.split('').reverse().join('');
	};
}
if(RegExp.prototype.clone === undefined) {
	RegExp.prototype.clone = function() {
		var gm = "";
		if(this.global === true) {
			gm += "g";
		}
		if(this.ignoreCase === true) {
			gm += "i";
		}
		if(this.multiline === true) {
			gm += "m";
		}
		return new RegExp(this.source,gm);
	};
}
if(String.prototype.replaceLast === undefined) {
	String.prototype.replaceLast = function (what, replacement) {
		var t = this;
		var mthArr = t.match(what);
		var num = 0;
		return t.replace(what,function(s){
			num++;
			if(num === mthArr.length) {
				return replacement;
			}
			return s;
		});
	};
}
String.implement({
    windowsEncodePath: function(){
    	var str = this
    	.replace(/\&#(?!\d+;)/gm,"&#38;&#35;")
    	
    	.replace(/\//gm,"&#47;")
    	.replace(/\\/gm,"&#92;")
    	.replace(/:/gm, "&#58;")
    	.replace(/\*/gm,"&#42;")
    	.replace(/\?/gm,"&#63;")
    	.replace(/"/gm, "&#34;")
    	.replace(/</gm, "&#60;")
    	.replace(/>/gm, "&#62;")
    	.replace(/\|/gm,"&#124;")
    	.replace(/ /gm,"€");
    	return str;
    },
    windowsDecodePath: function(){
    	var str = this
    	.replace(/\&#47;/gm,"/")
    	.replace(/\&#92;/gm,"\\")
    	.replace(/\&#58;/gm,":")
    	.replace(/\&#42;/gm,"*")
    	.replace(/\&#63;/gm,"?")
    	.replace(/\&#34;/gm,"\"")
    	.replace(/\&#60;/gm,"<")
    	.replace(/\&#62;/gm,">")
    	.replace(/\&#124;/gm,"|")
    	
    	.replace(/\&#38;\&#35;/gm,"&#")
    	.replace(/€/gm," ");
    	return str;
    },
    //如果字符串以s结尾,删除
    subSufix: function(s) {
    	var t = this;
    	if(t.endsWith(s)) return t.substring(0,t.length-s.length);
    	return t;
    },
    extname: function(s) {
    	var t = this;
    	if(!s) s = ".";
    	var index = t.lastIndexOf(s);
    	if(index === -1) return "";
    	var s2 = t.substring(index);
    	return s2;
    },
    basename: function(s) {
    	var t = this;
    	var extname = t.extname(s);
    	if(extname === "") return t;
    	return t.subSufix(extname);
    }
});
Events.implement({
	fireEvent: function(type, args, delay){
		type = type.replace(/^on([A-Z])/, function(full, first){
			return first.toLowerCase();
		});
		var events = this.$events[type];
		if (!events) return this;
		args = Array.from(args);
		for(var i=0; i<events.length; i++) {
			var fn = events[i];
			if(!fn) continue;
			if (delay) {
				fn.delay(delay, this, args);
			} else {
				var rvEv = fn.apply(this, args);
				if(rvEv === "stopImmediatePropagation") break;
			}
		}
		return this;
	}
});
if(global.Promise) {
	Promise.fromCallback = function(cb,t){
		return function(){
			var args = Array.from(arguments);
			if(!t) t = this;
			return new Promise(function(resolve,reject){
				args.push(function(data){
					resolve(data);
				});
				if(cb) cb.apply(t,args);
				else resolve();
			});
		};
	};
	Promise.fromStandard = function(cb,t){
		return function(){
			var args = Array.from(arguments);
			if(!t) t = this;
			return new Promise(function(resolve,reject){
				args.push(function(err,data){
					if(err) {
						reject(err);
						return;
					}
					resolve(data);
				});
				if(cb) cb.apply(t,args);
				else resolve();
			});
		};
	};
	Promise.sleep = function(time){
		return new Promise(function(resolve,reject){
			if(time > 0) {
				setTimeout(function(){
					resolve();
				},time);
			} else {
				setImmediate(function(){
					resolve();
				});
			}
		});
	};
}
}).call(this);
