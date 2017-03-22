var Component = require("Component").Component;
var Srv = require("Srv").Srv;
exports.MdLoading = new Class({
	Extends: Component,
	options:{
		num: 0,
		requestArr: []
	},
	onDraw: function () {
		var t = this;
		var o = t.options;
		$(t).addEvents({
			click:function () {
				if(window.confirm("Are you sure?")) {
					t.tpMlAll();
					if(t.skCls !== undefined) t.skCls();
				}
			}
		});
		//请求等待图标
	    window.loadWg = t;
	},
	//动画开始
	stMl: function(request) {
		var t = this;
		var o = t.options;
		if(request !== undefined) o.requestArr.push(request);
		//动画已经开始了
		if($(t).isDisplayed()) {
			o.num++;
			return;
		}
		o.num = 1;
		$(t).show();
	},
	//取消所有请求
	tpMlAll: function() {
		var t = this;
		var o = t.options;
		for(var i=0; i<o.requestArr.length; i++) {
			if(o.requestArr[i].cancel) o.requestArr[i].cancel();
		}
		o.requestArr = [];
		if(o._ws !== undefined) {
			try{o._ws.close()} catch(err) {}
		}
		o.num = 0;
		$(t).hide();
	},
	//取消单个请求
	tpMl: function(request) {
		var t = this;
		var o = t.options;
		if(request !== undefined) {
			var tmpArr = [];
			for(var i=0; i<o.requestArr.length; i++) {
				if(o.requestArr[i] !== request) tmpArr.push(o.requestArr[i]);
			}
			o.requestArr = tmpArr;
		}
		o.num--;
		if(o.num <= 0) {
			$(t).hide();
			o.num = 0;
		}
	}
});
exports.Notice = new Class({
	Extends: Component,
	onDraw: function () {
		var t = this;
		var o = t.options;
		var info = $(t).getFirst(".notice_info");
		info.hide();
		window.ncWg = t;
	},
	//关闭此info
	close: function (info) {
		info.setStyles({position:"relative"});
		info.destroy();
	},
	//type类型:error,warn,info;str内容;time延迟多少秒关闭
	addNotice: function(type,str,time,callback) {
		var t = this;
		var o = t.options;
		var elt = o.ele;
		var notice_infoArr = elt.getChildren(".notice_info");
		for(var i=0; i<notice_infoArr.length; i++) {
			var notice_info = notice_infoArr[i];
			var notice_content_error = notice_info.getE(".notice_content_error");
			if(!notice_content_error) continue;
			if(str === notice_content_error.get("html")) return;
		}
		var ifo = $(t).getFirst(".notice_info");
		var info = ifo.clone();
		var nn = info.getE(".notice_num");
		//过几秒自动消失
		var itvl = null;
		if(time && time >= 1 && nn) {
			nn.set("text",time+" ");
			itvl = setInterval(function(){
				time--;
				if(time <= 0) {
					clearInterval(itvl);
					t.close(info);
				}
				nn.set("text",time+" ");
			},1000);
		}
		//可以移动的
		var notice_title = info.getElement(".notice_title");
		new Drag($(t),{
			handle:notice_title,
			modifiers:{x:'left',y:'top'},
			onCancel: function(){
				clearInterval(itvl);
				t.close(info);
			}
		});
		var msv = function() {
			clearInterval(itvl);
			nn && nn.set("text","");
			info.removeEvent("mouseover",msv);
		};
		info.addEvents({
			mouseover: msv
		});
		info.getE(".notice_content_info")
		.set("html",str)
		.removeClass("notice_content_info")
		.addClass("notice_content_"+type);
		info.inject(elt);
		info.setStyles({opacity:0,position:"relative"});
		info.setStyles({display:null});
		info.erase("style");
		if(callback) callback();
	}
});
//自动补全控件
exports.AutoComplete = new Class({
	Extends: Component,
	onDraw: function() {
		var t = this;
		t.addEvent("refresh:pause(80)",function(){
			t.refresh().start();
		});
	},
	itemClick: function(li) {
	},
	//每80毫秒通过ajax获得筛选之后的列表
	ajaxItems: function(val) {
	},
	getLbl: function(item) {
		return item.lbl;
	},
	//选中
	select: function(li) {
		var t = this;
		var o = t.options;
		var div = $(t).getFirst(".auto_complete_div");
		if(!div) {
			return;
		}
		div.getChildren(".auto_complete_selected").removeClass("auto_complete_selected");
		li && li.addClass("auto_complete_selected");
	},
	//根据input的value刷新显示的li
	refresh: async function() {
		var t = this;
		var div = $(t).getFirst(".auto_complete_div");
		var input = $(t).getFirst(".auto_complete_input");
		if(!div || !input) {
			return;
		}
		//div的位置x,y坐标
		var pst = $(t).measure(function(){
			return this.getPosition();
		});
		var size = $(t).measure(function(){
			return this.getSize();
		});
		div.setStyles({
			top:pst.y+size.y,
			left:pst.x,
			width:303,
			"max-height":304
		});
		var val = input.get("value").trim();
		var items = await t.ajaxItems(val);
		if(items) {
			div.empty();
			for(var i=0; i<items.length; i++) {
				var item = items[i];
				var lbl = t.getLbl(item);
				var li = new Element("div",{"class":"auto_complete_li",text:lbl});
				li.inject(div);
				if(i === 0) {
					li.addClass("auto_complete_selected");
				}
				if(i%2 === 0) {
					li.addClass("auto_complete_odd");
				}
				li.store("item",item);
				li.addEvent("click",function() {
					t.itemClick(this);
					div.hide();
				});
			}
			div.setStyle("display","block");
		}
	},
	initSecWg: function() {
		var t = this;
		var div = $(t).getFirst(".auto_complete_div");
		div.empty();
		var input = $(t).getFirst(".auto_complete_input");
		if(!div || !input) return;
		input.addEvents({
			keydown:function(e) {
				var code = e.code;
				if(code === 13) {
					e.stop();
				}
			},
			keyup:function(e) {
				var code = e.code;
				if(!div.isDisplayed()){
					t.fireEvent("refresh");
					return;
				}
				var seled = div.getFirst(".auto_complete_selected");
				//向上箭头
				if(code === 38) {
					var li = null;
					if(seled) {
						li = seled.getPrevious("div");
					}
					if(li === null) {
						li = div.getLast();
					}
					t.select(li);
					e.preventDefault();
				//向下箭头
				} else if(code === 40) {
					var li = null;
					if(seled) {
						li = seled.getNext("div");
					}
					if(li === null) {
						li = div.getFirst();
					}
					t.select(li);
					e.preventDefault();
				//回车
				} else if(code === 13) {
					if(!seled){
						t.fireEvent("refresh");
						return;
					}
					t.itemClick(seled);
					div.empty();
					div.hide();
				//Esc
				} else if(code === 27) {
					div.empty();
					div.hide();
				} else {
					t.fireEvent("refresh");
				}
			},
			dblclick: function() {
				if(!div.isDisplayed()){
					t.fireEvent("refresh");
					return;
				}
				div.empty();
				div.hide();
			},
			blur: function() {
				setTimeout(function(){
					div.empty();
					div.hide();
				},250)
			}
		});
	}
});
//下拉按钮
exports.Butsel = new Class({
	Extends: Component,
	onDraw: function() {
		var t = this;
		var o = t.options;
		$(t).addEvents({
			keydown: function(e) {
				var code = e.code;
				if(code === 13 || code === 38 || code === 40) {
					e.stopPropagation();
				}
			},
			keyup: function(e) {
				var code = e.code;
				if(code === 13 || code === 38 || code === 40) {
					e.stopPropagation();
				}
			}
		});
	}
});
