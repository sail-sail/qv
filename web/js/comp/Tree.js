var Component = require("Component").Component;
exports.Tree = new Class({
	Extends : Component,
	options: {
		//是否开启选中节点的功能,默认启用
		openSelLi: true,
		//选中的节点
		selLi: undefined
	},
	selectLi: function(liEl){
		var t = this
		var o = t.options;
		if(o.selLi === liEl) return;
		if(o.selLi !== undefined && o.selLi !== null) o.selLi.removeClass("tree_div_seld");
		if(liEl !== undefined && liEl !== null) liEl.addClass("tree_div_seld");
		o.selLi = liEl;
	},
	getChildren: function (tree_li,hLvl) {
		return [];
	},
	getTitle: function(tree_li) {
		var t = this;
		return t.getLbl(tree_li);
	},
	getLbl: function(tree_li) {
		return "lbl";
	},
	isLeaf: function(tree_li) {
		return false;
	},
	enyEquals: function(eny0,eny1) {
		if(eny0 && eny1) return eny0.id === eny1.id;
		if((eny0 && !eny1) || (!eny0 && eny1)) return false;
		return true;
	},
	//获得当前eny的所有祖宗id号的数组,从根节点往下排序
	treAllPrnId: async function(eny) {
		return [];
	},
	//当前tree_li初始化完毕之后
	afInTl: function(tree_li) {
	},
	//叶子节点变为非叶子节点
	leaf2tree_closed: function(liEl){
		var t = this;
		var o = t.options;
		liEl.addClass("tree_closed");
		liEl.removeClass("tree_leaf");
	},
	//非叶子节点转换为叶子节点
	notLeaf2leaf: function(liEl) {
		var t = this;
		var o = t.options;
		var pul = liEl.getFirst(".tree_ul");
		pul.hide();
		liEl.removeClass("tree_opened");
		liEl.removeClass("tree_closed");
		liEl.addClass("tree_leaf");
	},
	//节点被点击了
	treeLiClick: async function(tree_hit,isSeld) {
		var t = this;
		var o = t.options;
		var tree_li = tree_hit.getParent(".tree_li");
		var isLeaf = await t.isLeaf(tree_li);
		if(!isLeaf) {
			await t.dataTree(tree_li);
			await t.nodeClick(tree_li);
		} else {
			await t.leafClick(tree_li);
		}
		
		if(isSeld !== false) {
			//选中节点
			if(!tree_hit.hasClass("tree_hit") && o.openSelLi === true) {
				await t.selectLi(tree_li);
			}
		}
	},
	//叶子节点被点击了
	leafClick: async function(tree_li) {
		
	},
	//非叶子节点被点击了
	nodeClick: async function(liEl) {
		var t = this;
		var o = t.options;
		if(t.isOpen(liEl)) {
			t.closeTreeLi(liEl);
		} else {
			t.openTreeLi(liEl);
		}
	},
	openTreeLi: function(liEl) {
		var t = this;
		var o = t.options;
		liEl.addClass("tree_opened");
		liEl.removeClass("tree_closed");
		var pul = liEl.getFirst(".tree_ul");
		pul.show();
	},
	closeTreeLi: function(liEl) {
		var t = this;
		var o = t.options;
		liEl.removeClass("tree_opened");
		liEl.addClass("tree_closed");
		var pul = liEl.getFirst(".tree_ul");
		pul.hide();
	},
	openTreeLi2show: function(liEl) {
		var t = this;
		while(true) {
			liEl = liEl.getParent(".tree_li");
			if(!liEl) break;
			t.openTreeLi(liEl);
		}
	},
	//当前节点是否处于打开状态
	isOpen: function(liEl){
		return liEl.hasClass("tree_opened");
	},
	empty: function() {
		var t = this;
		var o = t.options;
		var elt = o.ele;
		elt.empty();
	},
	hitAddEvt: function (liEl) {
		var t = this;
		var tree_hit = liEl.getFirst(".tree_div>.tree_pix_div>.tree_hit");
		tree_hit.addEvent("click",function(e){
			e.stop();
			t.treeLiClick(this);
		});
	},
	liAddEvt: function (liEl) {
		var t = this;
		var tree_div = liEl.getFirst(".tree_div");
		tree_div.addEvent("click",function(e){
			t.treeLiClick(this);
		});
	},
	getOldVal: function() {
		var elt, o, t, val;
		t = this;
		o = t.options;
		elt = o.ele;
		val = elt.retrieve("oldValue");
		return val;
	},
	setOldVal: function(val) {
		var elt, o, t;
		t = this;
		o = t.options;
		elt = o.ele;
		elt.eliminate("oldValue");
		elt.store("oldValue", val);
		return t;
	},
	getVal: function(opt) {
		var cb_tree, cb_treeWg, elt, eny, o, selLi, t;
		t = this;
		o = t.options;
		elt = o.ele;
		if (!o.selLi) return ;
		eny = o.selLi.retrieve("eny");
		if(!opt || opt.cmpOldVal !== false) {
			if(t.enyEquals(eny,t.getOldVal())) return;
		}
		return eny;
	},
	setVal: async function(eny) {
		var elt, o, t;
		t = this;
		o = t.options;
		elt = o.ele;
		var prnIdArr = await t.treAllPrnId(eny);
		for(var i=0; i<prnIdArr.length; i++) {
			var prnId = prnIdArr[i].id;
			var liEl = elt.getE("[h:id="+prnId+"]");
			if(!liEl) continue;
			var isLeaf = await t.isLeaf(liEl);
			await t.dataTree(liEl);
			if(!isLeaf) {
				t.openTreeLi(liEl);
			}
			var eny1 = liEl.retrieve("eny");
			if(t.enyEquals(eny,eny1)) {
				if(o.openSelLi === true) {
					await t.selectLi(liEl);
					return;
				}
			}
		}
		return;
	},
	dataTree: async function(tree_li,refresh) {
		var t = this;
		var o = t.options;
		var elt = o.ele;

		var pul = null;
		//层次
		var lvl = 0;
		
		//展开或者关闭
		if(tree_li) {
			//不是根节点
			pul = tree_li.getFirst(".tree_ul");
			lvl = pul.get("h:lvl").toInt();
			if(t.isOpen(tree_li)) return;
		} else {
			//根节点
			pul = elt;
			pul.set("h:lvl",lvl);
		}
		//已经有孩子了,就不用重新获得孩子了
		if(pul.getFirst(".tree_li") && refresh !== true) return;
		//刷新
		if(refresh === true && tree_li) {
			tree_li.empty();
		}
		var liEls = await t.getChildren(tree_li,lvl);
		if(typeOf(liEls) !== "array") {
			return ;
		}
		for (var i = 0; i < liEls.length; i++) {
			var liEl = liEls[i];
			liEl.inject(pul);
			liEl.set("h:lvl",lvl);
			var eny = liEl.retrieve("eny");
			if(eny && eny.id) liEl.set("h:id",eny.id);
			
			var isLeaf = await t.isLeaf(liEl);
			var lbl = t.getLbl(liEl);
			var title = t.getTitle(liEl);
			var is_empty_li = liEl.hasClass("tree_empty_li");

			liEl.addClass("tree_li");
			if(isLeaf === true) {
				liEl.addClass("tree_leaf");
			} else {
				if(!liEl.hasClass("tree_opened")){
					liEl.addClass("tree_closed");
				}
			}
			var tree_div = new Element("div",{"class":"tree_div"});
			for(var j=0; j<lvl; j++) {
				var tree_indent = new Element("div",{"class":"tree_indent"});
				tree_indent.inject(tree_div);
			}
			
			var tree_pix_div = new Element("div",{"class":"tree_pix_div"}).inject(tree_div);
			if(!is_empty_li) {
				var tree_hit = new Element("div",{"class":"tree_hit"});
				var tree_folder = new Element("div",{"class":"tree_folder"});
				tree_hit.inject(tree_pix_div);
				tree_folder.inject(tree_pix_div);
				if(typeOf(lbl) === "element") {
					lbl.inject(tree_div);
				} else {
					new Element("label",{"class":"tree_lbl",text:lbl}).inject(tree_div);
				}
				if(!String.isEmpty(title)) tree_div.set("title",title);
			}
			tree_div.inject(liEl);
			new Element("div",{"class":"tree_ul"}).inject(liEl).set("h:lvl",lvl+1);
			if(!is_empty_li) {
				//默认是否打开
				if(liEl.hasClass("default_opened")){
					await t.treeLiClick(tree_hit,false);
				}
				if(t.hitAddEvt) t.hitAddEvt(liEl);
			}
			if(t.liAddEvt) t.liAddEvt(liEl);
		}
		//当前tree_li初始化完毕之后
		if(t.afInTl) await t.afInTl(pul);
	}
});
