var fromCallback = function(cb,t){
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
var fromStandard = function(cb,t){
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
var isType = function(type) {
  return function(obj) {
    return Object.prototype.toString.call(obj) === "[object " + type + "]";
  };
};

var isObject = isType("Object");

var isString = isType("String");

var isArray = Array.isArray || isType("Array");

var isFunction = isType("Function");

var str2Xml = function(str) {
  var charTmp, i, l, ref2, s, str2;
  if (!isString(str)) {
    return str;
  }
  str2 = "";
  for (i = l = 0, ref2 = str.length; 0 <= ref2 ? l < ref2 : l > ref2; i = 0 <= ref2 ? ++l : --l) {
    charTmp = str.charCodeAt(i);
    s = str.charAt(i);
    if (charTmp <= 31 && charTmp !== 9 && charTmp !== 10 || charTmp === 127) {
      s = JSON.stringify(s);
      s = s.substring(1, s.length - 1);
      s = s.replace("\\u", "_x") + "_";
      str2 += s;
      continue;
    }
    if (s === "&") {
      s = "&amp;";
    } else if (s === "<") {
      s = "&lt;";
    } else if (s === ">") {
      s = "&gt;";
    } else if (s === "\"") {
      s = "&quot;";
    } else if (s === "'") {
      s = "&apos;";
    }
    str2 += s;
  }
  return str2;
};
var charToNum = function(str) {
  var i, j, l, len, ref2, temp, val;
  str = new String(str);
  val = 0;
  len = str.length;
  for (j = l = 0, ref2 = len; 0 <= ref2 ? l < ref2 : l > ref2; j = 0 <= ref2 ? ++l : --l) {
    i = len - 1 - j;
    temp = str.charCodeAt(i) - 65 + 1;
    val += temp * Math.pow(26, j);
  }
  return val;
};
var charPlus = function(str, num) {
  var ch, i, strNum, temp;
  strNum = charToNum(str);
  strNum += num;
  if (strNum <= 0) return "A";
  temp = "";
  ch = "";
  while (strNum >= 1) {
    i = strNum % 26;
    if (i !== 0) {
      ch = String.fromCharCode(65 + i - 1);
      temp = ch + temp;
    } else {
      ch = "Z";
      temp = ch + temp;
      strNum--;
    }
    strNum = Math.floor(strNum / 26);
  }
  return temp;
};
exports.isType = isType;
exports.isObject = isObject;
exports.isString = isString;
exports.isArray = isArray;
exports.isFunction = isFunction;
exports.str2Xml = str2Xml;
exports.charToNum = charToNum;
exports.charPlus = charPlus;
exports.fromCallback = fromCallback;
exports.fromStandard = fromStandard;
