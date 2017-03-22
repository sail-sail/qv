//全局配置信息
ops = {
	debug: true,
	//sessionId存储的方式,js,header,cookie
	sessionId: "header",
	//国际化缓存
	//,i18n:{}
	//sessionId
	//,_sid: ""
};
seajs.config({
	//模块映射
	alias: {
		Component: "/js/comp/Component",
		Srv: "/js/comp/Srv",
		//Bl_layout
		Bl_layout: "/js/comp/Bl_layout",
		//Tabbox
		Tabbox: "/js/comp/Bl_layout",
		Tabs: "/js/comp/Bl_layout",
		Tab: "/js/comp/Bl_layout",
		Tabpanels: "/js/comp/Bl_layout",
		Tabpanel: "/js/comp/Bl_layout",
		//Tree
		Tree: "/js/comp/Tree",
		ComboTree: "/js/comp/ComboTree",
		//MdLoading
		MdLoading: "/js/comp/OtherCom",
		//Notice
		Notice: "/js/comp/OtherCom",
		//Accordion
		Accordion: "/js/comp/Bl_layout",
		//上传控件
		UploadButton: "/js/comp/OtherCom",
		AutoComplete: "/js/comp/OtherCom",
		
		InputElement: "/js/comp/InputElement",
		TextInput: "/js/comp/InputElement",
		DateInput: "/js/comp/InputElement",
		DateTimeInput: "/js/comp/InputElement",
		Select: "/js/comp/InputElement",
		Checkbox: "/js/comp/InputElement",
		NumberInput: "/js/comp/InputElement",
		ImgInput: "/js/comp/InputElement",
		PopInput: "/js/comp/InputElement",
		
		//确认框
		ConFirm: "/sys/ConFirm",
		SysWin: "/sys/SysWin",
		//mainFrame
		MainFrame: "/sys/MainFrame"
	}
});
