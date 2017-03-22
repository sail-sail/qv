var Component = require("Component").Component;
exports.Bl_layout = new Class({
	Extends: Component,
	//绘图
	onDraw: function() {
		var t = this;
		t.bl_noth_split();
		t.bl_west_split();
		t.bl_west_split_img();
		t.bl_noth_split_img();
		t.bl_east_split_img();
		return t;
	},
	bl_noth_split: function(){
		var t = this;
		var handle = $(t).getFirst(".bl_noth_split");
		if(handle === null || handle.hasClass("splt_not_mv") === true) return;
		var bl_noth_cont = $(t).getFirst(".bl_noth_cont");
		var centers = $(t).getChildren(".bl_west_split,.bl_west_cont,.bl_center,.bl_east_split,.bl_east_cont");
		new Drag(handle,{handle: handle,modifiers: {y:"top",x:null},preventDefault:true,stopPropagation:true}).addEvents({
			drag:function() {
				var top = handle.getStyle("top").toInt();
				bl_noth_cont.setStyle("height",top);
				centers.setStyle("top",top+6);
			}
		});
	},
	bl_west_split: function(){
		var t = this;
		var handle = $(t).getFirst(".bl_west_split");
		if(handle === null || handle.hasClass("splt_not_mv") === true) return;
		var bl_center = $(t).getFirst(".bl_center");
		var bl_west_cont = $(t).getFirst(".bl_west_cont");
		new Drag(handle,{handle:handle,modifiers:{y:null,x:"left"},preventDefault:true,stopPropagation:true}).addEvents({
			drag:function(){
				var left = handle.getStyle("left").toInt();
				bl_center.setStyle("left",left+6);
				bl_west_cont.setStyle("width",left);
			}
		});
	},
	bl_west_split_img: function() {
		var t = this;
		var bl_west_split = $(t).getFirst(".bl_west_split");
		if(bl_west_split === null) return;
		var bl_west_split_img = bl_west_split.getFirst(".bl_west_split_img");
		if(!bl_west_split_img) return;
		var bl_west_colpsd = $(t).getFirst(".bl_west_colpsd");
		bl_west_split_img.addEvents({
			click: function(){
				t.west_close();
			}
		});
		bl_west_colpsd.addEvents({
			click: function(){
				t.west_open();
			}
		});
	},
	bl_east_split_img: function() {
		var t = this;
		var bl_east_split = $(t).getFirst(".bl_east_split");
		if(bl_east_split === null) return;
		var bl_east_colpsd = $(t).getFirst(".bl_east_colpsd");
		if(bl_east_colpsd === null) return;
		var bl_east_split_img = bl_east_split.getFirst(".bl_east_split_img");
		if(bl_east_split_img === null) return;
		bl_east_split_img.addEvents({
			click: function(){
				t.east_close();
			}
		});
		bl_east_colpsd.addEvents({
			click: function(){
				t.east_open();
			}
		});
	},
	//西边关闭
	west_close: function() {
		var t = this;
		var bl_west_split = $(t).getFirst(".bl_west_split");
		if(bl_west_split === null) return;
		var bl_west_cont = $(t).getFirst(".bl_west_cont");
		var bl_center = $(t).getFirst(".bl_center");
		var bl_west_colpsd = $(t).getFirst(".bl_west_colpsd");
		bl_west_cont.hide();
		bl_west_split.hide();
		bl_center.setStyle("left",16);
		bl_west_colpsd.setStyles({
			top:bl_west_split.getStyle("top"),
			left:0,
			bottom:bl_west_split.getStyle("bottom")
		});
		bl_west_colpsd.show("block");
	},
	//西边打卡
	west_open: function(){
		var t = this;
		var bl_west_split = $(t).getFirst(".bl_west_split");
		if(bl_west_split === null) return;
		var bl_center = $(t).getFirst(".bl_center");
		var bl_west_colpsd = $(t).getFirst(".bl_west_colpsd");
		var bl_west_cont = $(t).getFirst(".bl_west_cont");
		bl_west_colpsd.hide();
		bl_west_cont.show();
		bl_west_split.show();
		bl_center.setStyle("left",bl_west_split.getStyle("left").toInt()+6);
	},
	//东边关闭
	east_close: function(){
		var t = this;
		var bl_east_split = $(t).getFirst(".bl_east_split");
		if(bl_east_split === null) return;
		var bl_east_colpsd = $(t).getFirst(".bl_east_colpsd");
		if(bl_east_colpsd === null) return;
		var bl_east_cont = $(t).getFirst(".bl_east_cont");
		var bl_center = $(t).getFirst(".bl_center");
		
		bl_east_cont.hide();
		bl_east_split.hide();
		bl_center.setStyle("right",16);
		bl_east_colpsd.setStyles({
			top:bl_east_split.getStyle("top"),
			right:0,
			bottom:bl_east_split.getStyle("bottom")
		});
		bl_east_colpsd.show("block");
		t.fireEvent("after_east_close");
	},
	//东边打开
	east_open: function(){
		var t = this;
		var bl_east_split = $(t).getFirst(".bl_east_split");
		if(bl_east_split === null) return;
		var bl_east_colpsd = $(t).getFirst(".bl_east_colpsd");
		if(bl_east_colpsd === null) return;
		var bl_east_cont = $(t).getFirst(".bl_east_cont");
		var bl_center = $(t).getFirst(".bl_center");
		
		bl_east_colpsd.hide();
		bl_east_cont.show();
		bl_east_split.show();
		bl_center.setStyle("right",bl_east_split.getStyle("right").toInt()+6);
		t.fireEvent("after_east_open");
	},
	bl_noth_split_img: function() {
		var t = this;
		var bl_noth_split = $(t).getFirst(".bl_noth_split");
		if(!bl_noth_split) return;
		var bl_noth_split_img = bl_noth_split.getFirst(".bl_noth_split_img");
		if(!bl_noth_split_img) return;
		var bl_noth_cont = $(t).getFirst(".bl_noth_cont");
		var bl_noth_colpsd = $(t).getFirst(".bl_noth_colpsd");
		var bl_center = $(t).getFirst(".bl_center");
		var centers = $(t).getChildren(".bl_center," +
				".bl_west_split,.bl_west_colpsd,.bl_west_cont," +
				".bl_east_split,.bl_east_colpsd,.bl_east_cont");
		bl_noth_split_img.addEvents({
			click: function(){
				bl_noth_cont.hide();
				bl_noth_split.hide();
				centers.setStyle("top",16);
				var left = bl_noth_split.getStyle("left");
				var right = bl_noth_split.getStyle("right");
				bl_noth_colpsd.setStyles({left:left,top:0,right:right});
				bl_noth_colpsd.show("block");
			}
		});
		bl_noth_colpsd.addEvents({
			click: function(){
				bl_noth_colpsd.hide();
				bl_noth_cont.show();
				bl_noth_split.show();
				var top = bl_noth_split.getStyle("top").toInt()+6;
				centers.setStyle("top",top);
			}
		});
	}
});
// Tabbox
exports.Tabbox = new Class({
	Extends : Component,
	options: {
		//记住上N次选中的选项卡
		seledTab: []
	},
	getTabs: function() {
		var t = this;
		return $(t).getFirst("[h:apply=Tabs]");
	},
	getTabpanels: function() {
		var t = this;
		return $(t).getFirst("[h:apply=Tabpanels]");
	},
	// 获得所有Panel
	getTbps: function() {
		var t = this;
		var tabpanels = t.getTabpanels();
		if (tabpanels) {
			return tabpanels.getChildren("[h:apply=Tabpanel]");
		}
		return [];
	},
	// 获得所有的Tab
	getTbs: function() {
		var t = this;
		var tabs = t.getTabs();
		if(tabs !== null) {
			return tabs.getChildren("[h:apply=Tab]");
		}
		return [];
	},
	getFirst: function() {
		var t = this;
		var tabs = t.getTabs();
		if(tabs === null) return null;
		return tabs.getFirst("[h:apply=Tab]");
	},
	//清除所有的选项卡
	emptyAllTbs: function(){
		var t = this;
		$(t).getEs("[h:pg]").fireEvent("close");
		t.getTbps().destroy();
		t.getTbs().destroy();
		return t;
	},
	// 获得当前选中的选项卡
	getSelTab : function() {
		var t = this;
		var tbs = t.getTbs();
		return tbs[t.getSelIndex()];
	},
	//初始化选项卡的关闭按钮
	initTabCloseBut: function() {
		var t = this;
		var tcb = $(t).getE(".tab_close_but");
		tcb && tcb.addEvent("click",function() {
			var selTab = t.getSelTab();
			selTab && selTab.retrieve("widget").fireEvent("close");
		});
	},
	// 绘图
	onDraw : function() {
		var t = this;
		var selIndex = t.getSelIndex();
		var tbs = t.getTbs();
		var tb = tbs[selIndex];
		t.selectTab(tb);
		t.initTabCloseBut();
		
		return t;
	},
	selectTab : function(tb) {
		if(tb !== undefined) tb.retrieve("widget").select();
	},
	// 获得选中状态第几个
	getSelIndex : function() {
		var t = this;
		var tbs = t.getTbs();
		var len = tbs.length;
		for ( var i = 0; i < len; i++) {
			var tb = tbs[i];
			var isSel = tb.hasClass("tab-selected");
			if (isSel && tb.isDisplayed()) {
				return i;
			}
		}
		return;
	},
	//deleteTab删除一个选项卡之后,tabbox下面已经没有Tab的话
	hasNotTab: function(){
		var t = this
		$(t).destroy();
	},
	//增加一个选项卡
	addTabAsync: async function(text,closeAble) {
		var t = this;
		text = text || "";
		var tabs = t.getTabs();
		
		var tab = new Element("div",{"h:apply":"Tab","class":"tab"});
		//2012-05-23
		await tab.onDrawAsync();
		
		var tabLbl = new Element("span",{"class":"tab-label","text":text});
		tabLbl.inject(tab);
		if(closeAble === true) {
			tab.addClass("tab-close");
		}
		
		var tabpanels = t.getTabpanels();
		var tabpanel = new Element("div",{"h:apply":"Tabpanel","class":"tabpanel"});
		//2012-05-23
		await tabpanel.onDrawAsync();
		
		tabpanel.inject(tabpanels);
		tab.inject(tabs);
		
		return {tab:tab,tabpanel:tabpanel};
	}
});
// Tabs
exports.Tabs = new Class({
	Extends : Component,
	getTabbox : function() {
		var t = this;
		var o = t.options;
		return $(t).getParent();
	}
});
// Tab
exports.Tab = new Class({
	Extends: Component,
	onDraw: function() {
		var t = this;
		var o = t.options;

		//键盘按下事件
		$(t).addEvents({
			click: function() {
				t.fireEvent("select");
			},
			close: function() {
				t.fireEvent("close");
			},
			select: function() {
				t.fireEvent("select");
			}
		});
		//关闭选项卡事件
		t.addEvents({
			close:function() {
				//t.deleteTab();
			},
			select: function() {
				t.select();
			}
		});
	},
	setLbl: function(lbl) {
		var t = this;
		if(lbl !== null && lbl !== undefined) $(t).set("html",lbl);
	},
	getTabbox: function() {
		var t = this;
		var o = t.options;
		var tabs = $(t).getParent();
		return tabs && tabs.retrieve("widget").getTabbox();
	},
	getIndex: function() {
		var t = this;
		var o = t.options;
		var tabbox = t.getTabbox();
		var tbs = tabbox.retrieve("widget").getTbs();
		for ( var i = 0; i < tbs.length; i++) {
			var tb = tbs[i];
			if ($(t) === tb) {
				return i;
			}
		}
	},
	getLinkPanel: function() {
		var t = this;
		var tabbox = t.getTabbox();
		var tbps = tabbox.retrieve("widget").getTbps();
		return tbps[t.getIndex()];
	},
	//当前选项卡是否处于被选中状态中
	isSelected: function(){
		var t = this;
		var o = t.options;
		var isSeled = $(t).hasClass("tab-selected");
		return isSeled;
	},
	select: function() {
		var t = this;
		if(t.isSelected()) return;
		var tabbox = t.getTabbox();
		var tbbWg = tabbox.retrieve("widget");
		var tcb = tabbox.getE(".tab_close_but");
		//选中这个选项卡前,看看是否能被关闭
		if(tcb !== null) {
			if(t.canClose()) {
				tcb.show();
			} else {
				tcb.hide();
			}
		}
		
		var tabsDiv = tbbWg.getTabs();
		var tpsDiv = tbbWg.getTabpanels();
		var ts = "tab-selected";
		var tps = "tabpanel-selected";
		//去除已经选中的
		var selTab = tabsDiv.getChildren("."+ts);
		selTab.removeClass(ts);
		var selTp = tpsDiv.getChildren("."+tps);
		selTp.removeClass(tps);
		selTp.hide();
		
		var seledTab = tbbWg.options.seledTab;
		if(seledTab[seledTab.length-1] !== $(t)) {
			if(seledTab.length > 20) seledTab.shift();
			seledTab.push($(t));
		}
		//选中当前的
		$(t).addClass(ts);
		var tp = t.getLinkPanel();
		tp.addClass(tps);
		if($(t).isDisplayed() === true) tp.show("block");
		return t;
	},
	//获得下一个兄弟选项卡
	getNext: function(){
		var t = this;
		var o = t.options;
		
		var tabboxObj = t.getTabbox().retrieve("widget");
		var tbs = tabboxObj.getTbs();
		var len = tbs.length;
		var index = t.getIndex();
		return tbs[index+1];
	},
	//获得上一个兄弟选项卡
	getPrevious: function(){
		var t = this;
		var o = t.options;
		
		var tabboxObj = t.getTabbox().retrieve("widget");
		var tbs = tabboxObj.getTbs();
		var len = tbs.length;
		var index = t.getIndex();
		return tbs[index-1];
	},
	// 是否可以关闭
	canClose: function() {
		var t = this;
		return $(t).hasClass("tab-close");
	},
	getNextDisplayed: function(){
		var t = this;
		var next = null;
		var nextTmp = $(t);
		while(true) {
			nextTmp = nextTmp.getNext(".tab");
			if(nextTmp === null) break;
			else if(nextTmp.isDisplayed()) {
				next = nextTmp;
				break;
			}
		}
		if(next === null) {
			nextTmp = $(t);
			while(true) {
				nextTmp = nextTmp.getPrevious(".tab");
				if(nextTmp === null) break;
				else if(nextTmp.isDisplayed()) {
					next = nextTmp;
					break;
				}
			}
		}
		return next;
	},
	//删除此选项卡
	deleteTab: function () {
		var t = this;
		var close = t.canClose();
		if(!close) return;
		var tabbox = t.getTabbox();
		if(!tabbox) return;
		var tabboxWg = tabbox.retrieve("widget");
		var tbp = t.getLinkPanel();
		//sail 2012-07-29 记住上N次选中的选项卡,seledTab先进后出算法
		var seledTab = tabboxWg.options.seledTab;
		seledTab.pop();
		var next = null;
		while(true) {
			if(seledTab.length === 0) {
				next = t.getNextDisplayed();
				break;
			}
			next = seledTab.pop();
			if(!next || !next.retrieve("widget")) {
				if(!next.retrieve("widget")) seledTab.erase($(t));
				continue;
			} else {
				break;
			}
		}
		seledTab.erase($(t));
		tbp.destroy();
		$(t).destroy();
		if(!tabboxWg.getTabs().getFirst(".tab")) {
			tabboxWg.hasNotTab();
			return t;
		}
		//没有任何选中的选项卡
		if(tabboxWg.getSelIndex() === undefined && next !== null) {
			if($(next).retrieve("widget") === null) {
				next = tabboxWg.getFirst();
			}
			if(next !== null) $(next).retrieve("widget").fireEvent("select");
		}
		tbp = undefined;
		t = undefined;
	},
	show: function() {
		var t = this;
		$(t).show("block");
		var tbp = t.getLinkPanel();
		tbp.show("block");
		t.select();
		return t;
	},
	isShow: function(){
		var t = this;
		return $(t).isDisaplay();
	},
	//隐藏选项卡
	hide: function() {
		var t = this;
		$(t).hide();
		var tbp = t.getLinkPanel();
		tbp.hide();
		var tabbox = t.getTabbox();
		if(!tabbox) return t;
		var tabboxWg = tabbox.retrieve("widget");
		var next = null;
		var nextTmp = $(t);
		while(true) {
			nextTmp = nextTmp.getNext(".tab");
			if(nextTmp === null) break;
			else if(nextTmp.isDisplayed()) {
				next = nextTmp;
				break;
			}
		}
		if(next === null) {
			nextTmp = $(t);
			while(true) {
				nextTmp = nextTmp.getPrevious(".tab");
				if(nextTmp === null) break;
				else if(nextTmp.isDisplayed()) {
					next = nextTmp;
					break;
				}
			}
		}
		if(tabboxWg.getSelIndex() === undefined && next !== null) {
			next.retrieve("widget").fireEvent("select");
		}
		return t;
	}
});
// Tabpanels
exports.Tabpanels = new Class({
	Extends: Component,
	getTabbox: function() {
		var t = this;
		return $(t).getParent();
	}
});
// Tabpanel
exports.Tabpanel = new Class({
	Extends : Component,
//	onDraw: function(){
//		var t = this;
//		window.addEvent("resize:throttle(200)",function(){
//			if(t.isSelected()) {
//				var clientHeight = $(t).measure(function(){
//					return this.clientHeight;
//				});
//				console.log(clientHeight);
//				$(t).setStyle("max-height",clientHeight);
//			}
//		});
//	},
	getTabbox : function() {
		var t = this;
		return $(t).getParent().retrieve("widget").getTabbox();
	},
	getIndex : function() {
		var t = this;
		var tabbox = t.getTabbox();
		var tbps = tabbox.retrieve("widget").getTbps();
		for ( var i = 0; i < tbps.length; i++) {
			var tbp = tbps[i];
			if ($(t) === tbp) {
				return i;
			}
		}
	},
	getLinkTab : function() {
		var t = this;
		var tabbox = t.getTabbox();
		var tbs = tabbox.retrieve("widget").getTbs();
		return tbs[t.getIndex()];
	},
	//当前选项卡是否处于被选中状态中
	isSelected: function(){
		var t = this;
		var o = t.options;
		var isSeled = $(t).hasClass("tabpanel-selected");
		return isSeled;
	},
	select : function() {
		var t = this;
		var tabWg = t.getLinkTab().retrieve("widget");
		tabWg.select();
		return t;
	}
});
//Accordion手风琴控件
exports.Accordion = new Class({
	Extends : Component,
	onDraw: function () {
		var t = this;
		var o = t.options;
		var acds = $(t).getChildren(".acdin");
		acds.addEvent("click",function (e) {
			var tg = e.target;
			t.acdnSelect(tg);
		});
	},
	//点击了节点tg后
	acdnSelect: function (tg) {
		var t = this;
		if(tg.hasClass("acdin-selected")) return;
		
		var ac = "acdin";
		var acc = ac+"-content";
		var as = ac+"-selected";
		var acs = acc+"-selected";

		//已经选中的收起
		var asEle = $(t).getChildren("."+as);
		var acsEle = $(t).getChildren("."+acs);
		asEle.removeClass(as);
		acsEle.removeClass(acs);

		//选中自己
		tg.addClass(as);
		var tgn = tg.getNext("."+acc);
		tgn.addClass(acs);
		
		//刷新位置
		t.refPosition(tg);
	},
	//刷新位置
	refPosition: function(tg) {
		var t = this;
		var gap = 26;
		var seled = $(t).getFirst(".acdin-selected");
		var prevs = seled.getAllPrevious(".acdin");
		prevs.unshift(seled);
		for(var i=0; i<prevs.length; i++) {
			var prev = prevs[prevs.length-1-i];
			prev.setStyles({top:gap*i,bottom:null});
		}
		var sibs = seled.getAllNext(".acdin");
		for(var i=0; i<sibs.length; i++) {
			var sib = sibs[sibs.length-1-i];
			sib.setStyles({bottom:gap*i,top:null});
		}
	}
});
