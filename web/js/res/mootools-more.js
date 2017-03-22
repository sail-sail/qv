/* MooTools: the javascript framework. license: MIT-style license. copyright: Copyright (c) 2006-2016 [Valerio Proietti](http://mad4milk.net/).*/ 
/*!
Web Build: http://mootools.net/more/builder/0e5e9802d8dc3d68c394454eb7415f6c
*/
/*
---

script: More.js

name: More

description: MooTools More

license: MIT-style license

authors:
  - Guillermo Rauch
  - Thomas Aylott
  - Scott Kyle
  - Arian Stolwijk
  - Tim Wienk
  - Christoph Pojer
  - Aaron Newton
  - Jacob Thornton

requires:
  - Core/MooTools

provides: [MooTools.More]

...
*/

MooTools.More = {
	version: '1.6.0'
};

/*
---

script: Drag.js

name: Drag

description: The base Drag Class. Can be used to drag and resize Elements using mouse events.

license: MIT-style license

authors:
  - Valerio Proietti
  - Tom Occhinno
  - Jan Kassens

requires:
  - Core/Events
  - Core/Options
  - Core/Element.Event
  - Core/Element.Style
  - Core/Element.Dimensions
  - MooTools.More

provides: [Drag]
...

*/
(function(){

var Drag = this.Drag = new Class({

	Implements: [Events, Options],

	options: {/*
		onBeforeStart: function(thisElement){},
		onStart: function(thisElement, event){},
		onSnap: function(thisElement){},
		onDrag: function(thisElement, event){},
		onCancel: function(thisElement){},
		onComplete: function(thisElement, event){},*/
		snap: 6,
		unit: 'px',
		grid: false,
		style: true,
		limit: false,
		handle: false,
		invert: false,
		unDraggableTags: ['button', 'input', 'a', 'textarea', 'select', 'option'],
		preventDefault: false,
		stopPropagation: false,
		compensateScroll: false,
		modifiers: {x: 'left', y: 'top'}
	},

	initialize: function(){
		var params = Array.link(arguments, {
			'options': Type.isObject,
			'element': function(obj){
				return obj != null;
			}
		});

		this.element = document.id(params.element);
		this.document = this.element.getDocument();
		this.setOptions(params.options || {});
		var htype = typeOf(this.options.handle);
		this.handles = ((htype == 'array' || htype == 'collection') ? $$(this.options.handle) : document.id(this.options.handle)) || this.element;
		this.mouse = {'now': {}, 'pos': {}};
		this.value = {'start': {}, 'now': {}};
		this.offsetParent = (function(el){
			var offsetParent = el.getOffsetParent();
			var isBody = !offsetParent || (/^(?:body|html)$/i).test(offsetParent.tagName);
			return isBody ? window : document.id(offsetParent);
		})(this.element);
		this.selection = 'selectstart' in document ? 'selectstart' : 'mousedown';

		this.compensateScroll = {start: {}, diff: {}, last: {}};

		if ('ondragstart' in document && !('FileReader' in window) && !Drag.ondragstartFixed){
			document.ondragstart = Function.convert(false);
			Drag.ondragstartFixed = true;
		}

		this.bound = {
			start: this.start.bind(this),
			check: this.check.bind(this),
			drag: this.drag.bind(this),
			stop: this.stop.bind(this),
			cancel: this.cancel.bind(this),
			eventStop: Function.convert(false),
			scrollListener: this.scrollListener.bind(this)
		};
		this.attach();
	},

	attach: function(){
		this.handles.addEvent('mousedown', this.bound.start);
		this.handles.addEvent('touchstart', this.bound.start);
		if (this.options.compensateScroll) this.offsetParent.addEvent('scroll', this.bound.scrollListener);
		return this;
	},

	detach: function(){
		this.handles.removeEvent('mousedown', this.bound.start);
		this.handles.removeEvent('touchstart', this.bound.start);
		if (this.options.compensateScroll) this.offsetParent.removeEvent('scroll', this.bound.scrollListener);
		return this;
	},

	scrollListener: function(){

		if (!this.mouse.start) return;
		var newScrollValue = this.offsetParent.getScroll();

		if (this.element.getStyle('position') == 'absolute'){
			var scrollDiff = this.sumValues(newScrollValue, this.compensateScroll.last, -1);
			this.mouse.now = this.sumValues(this.mouse.now, scrollDiff, 1);
		} else {
			this.compensateScroll.diff = this.sumValues(newScrollValue, this.compensateScroll.start, -1);
		}
		if (this.offsetParent != window) this.compensateScroll.diff = this.sumValues(this.compensateScroll.start, newScrollValue, -1);
		this.compensateScroll.last = newScrollValue;
		this.render(this.options);
	},

	sumValues: function(alpha, beta, op){
		var sum = {}, options = this.options;
		for (var z in options.modifiers){
			if (!options.modifiers[z]) continue;
			sum[z] = alpha[z] + beta[z] * op;
		}
		return sum;
	},

	start: function(event){
		if (this.options.unDraggableTags.contains(event.target.get('tag'))) return;

		var options = this.options;

		if (event.rightClick) return;

		if (options.preventDefault) event.preventDefault();
		if (options.stopPropagation) event.stopPropagation();
		this.compensateScroll.start = this.compensateScroll.last = this.offsetParent.getScroll();
		this.compensateScroll.diff = {x: 0, y: 0};
		this.mouse.start = event.page;
		this.fireEvent('beforeStart', this.element);

		var limit = options.limit;
		this.limit = {x: [], y: []};

		var z, coordinates, offsetParent = this.offsetParent == window ? null : this.offsetParent;
		for (z in options.modifiers){
			if (!options.modifiers[z]) continue;

			var style = this.element.getStyle(options.modifiers[z]);

			// Some browsers (IE and Opera) don't always return pixels.
			if (style && !style.match(/px$/)){
				if (!coordinates) coordinates = this.element.getCoordinates(offsetParent);
				style = coordinates[options.modifiers[z]];
			}

			if (options.style) this.value.now[z] = (style || 0).toInt();
			else this.value.now[z] = this.element[options.modifiers[z]];

			if (options.invert) this.value.now[z] *= -1;

			this.mouse.pos[z] = event.page[z] - this.value.now[z];

			if (limit && limit[z]){
				var i = 2;
				while (i--){
					var limitZI = limit[z][i];
					if (limitZI || limitZI === 0) this.limit[z][i] = (typeof limitZI == 'function') ? limitZI() : limitZI;
				}
			}
		}

		if (typeOf(this.options.grid) == 'number') this.options.grid = {
			x: this.options.grid,
			y: this.options.grid
		};

		var events = {
			mousemove: this.bound.check,
			mouseup: this.bound.cancel,
			touchmove: this.bound.check,
			touchend: this.bound.cancel
		};
		events[this.selection] = this.bound.eventStop;
		this.document.addEvents(events);
	},

	check: function(event){
		if (this.options.preventDefault) event.preventDefault();
		var distance = Math.round(Math.sqrt(Math.pow(event.page.x - this.mouse.start.x, 2) + Math.pow(event.page.y - this.mouse.start.y, 2)));
		if (distance > this.options.snap){
			this.cancel();
			this.document.addEvents({
				mousemove: this.bound.drag,
				mouseup: this.bound.stop,
				touchmove: this.bound.drag,
				touchend: this.bound.stop
			});
			this.fireEvent('start', [this.element, event]).fireEvent('snap', this.element);
		}
	},

	drag: function(event){
		var options = this.options;
		if (options.preventDefault) event.preventDefault();
		this.mouse.now = this.sumValues(event.page, this.compensateScroll.diff, -1);

		this.render(options);
		this.fireEvent('drag', [this.element, event]);
	},

	render: function(options){
		for (var z in options.modifiers){
			if (!options.modifiers[z]) continue;
			this.value.now[z] = this.mouse.now[z] - this.mouse.pos[z];

			if (options.invert) this.value.now[z] *= -1;
			if (options.limit && this.limit[z]){
				if ((this.limit[z][1] || this.limit[z][1] === 0) && (this.value.now[z] > this.limit[z][1])){
					this.value.now[z] = this.limit[z][1];
				} else if ((this.limit[z][0] || this.limit[z][0] === 0) && (this.value.now[z] < this.limit[z][0])){
					this.value.now[z] = this.limit[z][0];
				}
			}
			if (options.grid[z]) this.value.now[z] -= ((this.value.now[z] - (this.limit[z][0]||0)) % options.grid[z]);
			if (options.style) this.element.setStyle(options.modifiers[z], this.value.now[z] + options.unit);
			else this.element[options.modifiers[z]] = this.value.now[z];
		}
	},

	cancel: function(event){
		this.document.removeEvents({
			mousemove: this.bound.check,
			mouseup: this.bound.cancel,
			touchmove: this.bound.check,
			touchend: this.bound.cancel
		});
		if (event){
			this.document.removeEvent(this.selection, this.bound.eventStop);
			this.fireEvent('cancel', this.element);
		}
	},

	stop: function(event){
		var events = {
			mousemove: this.bound.drag,
			mouseup: this.bound.stop,
			touchmove: this.bound.drag,
			touchend: this.bound.stop
		};
		events[this.selection] = this.bound.eventStop;
		this.document.removeEvents(events);
		this.mouse.start = null;
		if (event) this.fireEvent('complete', [this.element, event]);
	}

});

})();


Element.implement({

	makeResizable: function(options){
		var drag = new Drag(this, Object.merge({
			modifiers: {
				x: 'width',
				y: 'height'
			}
		}, options));

		this.store('resizer', drag);
		return drag.addEvent('drag', function(){
			this.fireEvent('resize', drag);
		}.bind(this));
	}

});

/*
---

script: Drag.Move.js

name: Drag.Move

description: A Drag extension that provides support for the constraining of draggables to containers and droppables.

license: MIT-style license

authors:
  - Valerio Proietti
  - Tom Occhinno
  - Jan Kassens
  - Aaron Newton
  - Scott Kyle

requires:
  - Core/Element.Dimensions
  - Drag

provides: [Drag.Move]

...
*/

Drag.Move = new Class({

	Extends: Drag,

	options: {/*
		onEnter: function(thisElement, overed){},
		onLeave: function(thisElement, overed){},
		onDrop: function(thisElement, overed, event){},*/
		droppables: [],
		container: false,
		precalculate: false,
		includeMargins: true,
		checkDroppables: true
	},

	initialize: function(element, options){
		//this.parent(element, options);
		Drag.prototype.initialize.apply(this,[element, options]);
		element = this.element;

		this.droppables = $$(this.options.droppables);
		this.setContainer(this.options.container);

		if (this.options.style){
			if (this.options.modifiers.x == 'left' && this.options.modifiers.y == 'top'){
				var parent = element.getOffsetParent(),
					styles = element.getStyles('left', 'top');
				if (parent && (styles.left == 'auto' || styles.top == 'auto')){
					element.setPosition(element.getPosition(parent));
				}
			}

			if (element.getStyle('position') == 'static') element.setStyle('position', 'absolute');
		}

		this.addEvent('start', this.checkDroppables, true);
		this.overed = null;
	},

	setContainer: function(container){
		this.container = document.id(container);
		if (this.container && typeOf(this.container) != 'element'){
			this.container = document.id(this.container.getDocument().body);
		}
	},

	start: function(event){
		if (this.container) this.options.limit = this.calculateLimit();

		if (this.options.precalculate){
			this.positions = this.droppables.map(function(el){
				return el.getCoordinates();
			});
		}

		//this.parent(event);
		Drag.prototype.start.apply(this,[event]);
	},

	calculateLimit: function(){
		var element = this.element,
			container = this.container,

			offsetParent = document.id(element.getOffsetParent()) || document.body,
			containerCoordinates = container.getCoordinates(offsetParent),
			elementMargin = {},
			elementBorder = {},
			containerMargin = {},
			containerBorder = {},
			offsetParentPadding = {},
			offsetScroll = offsetParent.getScroll();

		['top', 'right', 'bottom', 'left'].each(function(pad){
			elementMargin[pad] = element.getStyle('margin-' + pad).toInt();
			elementBorder[pad] = element.getStyle('border-' + pad).toInt();
			containerMargin[pad] = container.getStyle('margin-' + pad).toInt();
			containerBorder[pad] = container.getStyle('border-' + pad).toInt();
			offsetParentPadding[pad] = offsetParent.getStyle('padding-' + pad).toInt();
		}, this);

		var width = element.offsetWidth + elementMargin.left + elementMargin.right,
			height = element.offsetHeight + elementMargin.top + elementMargin.bottom,
			left = 0 + offsetScroll.x,
			top = 0 + offsetScroll.y,
			right = containerCoordinates.right - containerBorder.right - width + offsetScroll.x,
			bottom = containerCoordinates.bottom - containerBorder.bottom - height + offsetScroll.y;

		if (this.options.includeMargins){
			left += elementMargin.left;
			top += elementMargin.top;
		} else {
			right += elementMargin.right;
			bottom += elementMargin.bottom;
		}

		if (element.getStyle('position') == 'relative'){
			var coords = element.getCoordinates(offsetParent);
			coords.left -= element.getStyle('left').toInt();
			coords.top -= element.getStyle('top').toInt();

			left -= coords.left;
			top -= coords.top;
			if (container.getStyle('position') != 'relative'){
				left += containerBorder.left;
				top += containerBorder.top;
			}
			right += elementMargin.left - coords.left;
			bottom += elementMargin.top - coords.top;

			if (container != offsetParent){
				left += containerMargin.left + offsetParentPadding.left;
				if (!offsetParentPadding.left && left < 0) left = 0;
				top += offsetParent == document.body ? 0 : containerMargin.top + offsetParentPadding.top;
				if (!offsetParentPadding.top && top < 0) top = 0;
			}
		} else {
			left -= elementMargin.left;
			top -= elementMargin.top;
			if (container != offsetParent){
				left += containerCoordinates.left + containerBorder.left;
				top += containerCoordinates.top + containerBorder.top;
			}
		}

		return {
			x: [left, right],
			y: [top, bottom]
		};
	},

	getDroppableCoordinates: function(element){
		var position = element.getCoordinates();
		if (element.getStyle('position') == 'fixed'){
			var scroll = window.getScroll();
			position.left += scroll.x;
			position.right += scroll.x;
			position.top += scroll.y;
			position.bottom += scroll.y;
		}
		return position;
	},

	checkDroppables: function(){
		var overed = this.droppables.filter(function(el, i){
			el = this.positions ? this.positions[i] : this.getDroppableCoordinates(el);
			var now = this.mouse.now;
			return (now.x > el.left && now.x < el.right && now.y < el.bottom && now.y > el.top);
		}, this).getLast();

		if (this.overed != overed){
			if (this.overed) this.fireEvent('leave', [this.element, this.overed]);
			if (overed) this.fireEvent('enter', [this.element, overed]);
			this.overed = overed;
		}
	},

	drag: function(event){
		//this.parent(event);
		Drag.prototype.drag.apply(this,[event]);
		if (this.options.checkDroppables && this.droppables.length) this.checkDroppables();
	},

	stop: function(event){
		this.checkDroppables();
		this.fireEvent('drop', [this.element, this.overed, event]);
		this.overed = null;
		//return this.parent(event);
		return Drag.prototype.stop.apply(this,[event]);
	}

});

Element.implement({

	makeDraggable: function(options){
		var drag = new Drag.Move(this, options);
		this.store('dragger', drag);
		return drag;
	}

});

/*
---

script: Element.Measure.js

name: Element.Measure

description: Extends the Element native object to include methods useful in measuring dimensions.

credits: "Element.measure / .expose methods by Daniel Steigerwald License: MIT-style license. Copyright: Copyright (c) 2008 Daniel Steigerwald, daniel.steigerwald.cz"

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/Element.Style
  - Core/Element.Dimensions
  - MooTools.More

provides: [Element.Measure]

...
*/

(function(){

var getStylesList = function(styles, planes){
	var list = [];
	Object.each(planes, function(directions){
		Object.each(directions, function(edge){
			styles.each(function(style){
				list.push(style + '-' + edge + (style == 'border' ? '-width' : ''));
			});
		});
	});
	return list;
};

var calculateEdgeSize = function(edge, styles){
	var total = 0;
	Object.each(styles, function(value, style){
		if (style.test(edge)) total = total + value.toInt();
	});
	return total;
};

var isVisible = function(el){
	return !!(!el || el.offsetHeight || el.offsetWidth);
};


Element.implement({

	measure: function(fn){
		if (isVisible(this)) return fn.call(this);
		var parent = this.getParent(),
			toMeasure = [];
		while (!isVisible(parent) && parent != document.body){
			toMeasure.push(parent.expose());
			parent = parent.getParent();
		}
		var restore = this.expose(),
			result = fn.call(this);
		restore();
		toMeasure.each(function(restore){
			restore();
		});
		return result;
	},

	expose: function(){
		if (this.getStyle('display') != 'none') return function(){};
		var before = this.style.cssText;
		this.setStyles({
			display: 'block',
			position: 'absolute',
			visibility: 'hidden'
		});
		return function(){
			this.style.cssText = before;
		}.bind(this);
	},

	getDimensions: function(options){
		options = Object.merge({computeSize: false}, options);
		var dim = {x: 0, y: 0};

		var getSize = function(el, options){
			return (options.computeSize) ? el.getComputedSize(options) : el.getSize();
		};

		var parent = this.getParent('body');

		if (parent && this.getStyle('display') == 'none'){
			dim = this.measure(function(){
				return getSize(this, options);
			});
		} else if (parent){
			try { //safari sometimes crashes here, so catch it
				dim = getSize(this, options);
			} catch (e){}
		}

		return Object.append(dim, (dim.x || dim.x === 0) ? {
			width: dim.x,
			height: dim.y
		} : {
			x: dim.width,
			y: dim.height
		});
	},

	getComputedSize: function(options){
		

		options = Object.merge({
			styles: ['padding','border'],
			planes: {
				height: ['top','bottom'],
				width: ['left','right']
			},
			mode: 'both'
		}, options);

		var styles = {},
			size = {width: 0, height: 0},
			dimensions;

		if (options.mode == 'vertical'){
			delete size.width;
			delete options.planes.width;
		} else if (options.mode == 'horizontal'){
			delete size.height;
			delete options.planes.height;
		}

		getStylesList(options.styles, options.planes).each(function(style){
			styles[style] = this.getStyle(style).toInt();
		}, this);

		Object.each(options.planes, function(edges, plane){

			var capitalized = plane.capitalize(),
				style = this.getStyle(plane);

			if (style == 'auto' && !dimensions) dimensions = this.getDimensions();

			style = styles[plane] = (style == 'auto') ? dimensions[plane] : style.toInt();
			size['total' + capitalized] = style;

			edges.each(function(edge){
				var edgesize = calculateEdgeSize(edge, styles);
				size['computed' + edge.capitalize()] = edgesize;
				size['total' + capitalized] += edgesize;
			});

		}, this);

		return Object.append(size, styles);
	}

});

})();

/*
---

script: Class.Binds.js

name: Class.Binds

description: Automagically binds specified methods in a class to the instance of the class.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/Class
  - MooTools.More

provides: [Class.Binds]

...
*/

Class.Mutators.Binds = function(binds){
	if (!this.prototype.initialize) this.implement('initialize', function(){});
	return Array.convert(binds).concat(this.prototype.Binds || []);
};

Class.Mutators.initialize = function(initialize){
	return function(){
		Array.convert(this.Binds).each(function(name){
			var original = this[name];
			if (original) this[name] = original.bind(this);
		}, this);
		return initialize.apply(this, arguments);
	};
};

/*
---

script: Slider.js

name: Slider

description: Class for creating horizontal and vertical slider controls.

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Element.Dimensions
  - Core/Number
  - Class.Binds
  - Drag
  - Element.Measure

provides: [Slider]

...
*/
(function(){

var Slider = this.Slider = new Class({

	Implements: [Events, Options],

	Binds: ['clickedElement', 'draggedKnob', 'scrolledElement'],

	options: {/*
		onTick: function(intPosition){},
		onMove: function(){},
		onChange: function(intStep){},
		onComplete: function(strStep){},*/
		onTick: function(position){
			this.setKnobPosition(position);
		},
		initialStep: 0,
		snap: false,
		offset: 0,
		range: false,
		wheel: false,
		steps: 100,
		mode: 'horizontal'
	},

	initialize: function(element, knob, options){
		this.setOptions(options);
		options = this.options;
		this.element = document.id(element);
		knob = this.knob = document.id(knob);
		this.previousChange = this.previousEnd = this.step = options.initialStep ? options.initialStep : options.range ? options.range[0] : 0;

		var limit = {},
			modifiers = {x: false, y: false};

		switch (options.mode){
			case 'vertical':
				this.axis = 'y';
				this.property = 'top';
				this.offset = 'offsetHeight';
				break;
			case 'horizontal':
				this.axis = 'x';
				this.property = 'left';
				this.offset = 'offsetWidth';
		}

		this.setSliderDimensions();
		this.setRange(options.range, null, true);

		if (knob.getStyle('position') == 'static') knob.setStyle('position', 'relative');
		knob.setStyle(this.property, -options.offset);
		modifiers[this.axis] = this.property;
		limit[this.axis] = [-options.offset, this.full - options.offset];

		var dragOptions = {
			snap: 0,
			limit: limit,
			modifiers: modifiers,
			onDrag: this.draggedKnob,
			onStart: this.draggedKnob,
			onBeforeStart: (function(){
				this.isDragging = true;
			}).bind(this),
			onCancel: function(){
				this.isDragging = false;
			}.bind(this),
			onComplete: function(){
				this.isDragging = false;
				this.draggedKnob();
				this.end();
			}.bind(this)
		};
		if (options.snap) this.setSnap(dragOptions);

		this.drag = new Drag(knob, dragOptions);
		if (options.initialStep != null) this.set(options.initialStep, true);
		this.attach();
	},

	attach: function(){
		this.element.addEvent('mousedown', this.clickedElement);
		if (this.options.wheel) this.element.addEvent('mousewheel', this.scrolledElement);
		this.drag.attach();
		return this;
	},

	detach: function(){
		this.element.removeEvent('mousedown', this.clickedElement)
			.removeEvent('mousewheel', this.scrolledElement);
		this.drag.detach();
		return this;
	},

	autosize: function(){
		this.setSliderDimensions()
			.setKnobPosition(this.toPosition(this.step));
		this.drag.options.limit[this.axis] = [-this.options.offset, this.full - this.options.offset];
		if (this.options.snap) this.setSnap();
		return this;
	},

	setSnap: function(options){
		if (!options) options = this.drag.options;
		options.grid = Math.ceil(this.stepWidth);
		options.limit[this.axis][1] = this.element[this.offset];
		return this;
	},

	setKnobPosition: function(position){
		if (this.options.snap) position = this.toPosition(this.step);
		this.knob.setStyle(this.property, position);
		return this;
	},

	setSliderDimensions: function(){
		this.full = this.element.measure(function(){
			this.half = this.knob[this.offset] / 2;
			return this.element[this.offset] - this.knob[this.offset] + (this.options.offset * 2);
		}.bind(this));
		return this;
	},

	set: function(step, silently){
		if (!((this.range > 0) ^ (step < this.min))) step = this.min;
		if (!((this.range > 0) ^ (step > this.max))) step = this.max;

		this.step = (step).round(this.modulus.decimalLength);
		if (silently) this.checkStep().setKnobPosition(this.toPosition(this.step));
		else this.checkStep().fireEvent('tick', this.toPosition(this.step)).fireEvent('move').end();
		return this;
	},

	setRange: function(range, pos, silently){
		this.min = Array.pick([range[0], 0]);
		this.max = Array.pick([range[1], this.options.steps]);
		this.range = this.max - this.min;
		this.steps = this.options.steps || this.full;
		var stepSize = this.stepSize = Math.abs(this.range) / this.steps;
		this.stepWidth = this.stepSize * this.full / Math.abs(this.range);
		this.setModulus();

		if (range) this.set(Array.pick([pos, this.step]).limit(this.min,this.max), silently);
		return this;
	},

	setModulus: function(){
		var decimals = ((this.stepSize + '').split('.')[1] || []).length,
			modulus = 1 + '';
		while (decimals--) modulus += '0';
		this.modulus = {multiplier: (modulus).toInt(10), decimalLength: modulus.length - 1};
	},

	clickedElement: function(event){
		if (this.isDragging || event.target == this.knob) return;

		var dir = this.range < 0 ? -1 : 1,
			position = event.page[this.axis] - this.element.getPosition()[this.axis] - this.half;

		position = position.limit(-this.options.offset, this.full - this.options.offset);

		this.step = (this.min + dir * this.toStep(position)).round(this.modulus.decimalLength);

		this.checkStep()
			.fireEvent('tick', position)
			.fireEvent('move')
			.end();
	},

	scrolledElement: function(event){
		var mode = (this.options.mode == 'horizontal') ? (event.wheel < 0) : (event.wheel > 0);
		this.set(this.step + (mode ? -1 : 1) * this.stepSize);
		event.stop();
	},

	draggedKnob: function(){
		var dir = this.range < 0 ? -1 : 1,
			position = this.drag.value.now[this.axis];

		position = position.limit(-this.options.offset, this.full -this.options.offset);

		this.step = (this.min + dir * this.toStep(position)).round(this.modulus.decimalLength);
		this.checkStep();
		this.fireEvent('move');
	},

	checkStep: function(){
		var step = this.step;
		if (this.previousChange != step){
			this.previousChange = step;
			this.fireEvent('change', step);
		}
		return this;
	},

	end: function(){
		var step = this.step;
		if (this.previousEnd !== step){
			this.previousEnd = step;
			this.fireEvent('complete', step + '');
		}
		return this;
	},

	toStep: function(position){
		var step = (position + this.options.offset) * this.stepSize / this.full * this.steps;
		return this.options.steps ? (step - (step * this.modulus.multiplier) % (this.stepSize * this.modulus.multiplier) / this.modulus.multiplier).round(this.modulus.decimalLength) : step;
	},

	toPosition: function(step){
		return (this.full * Math.abs(this.min - step)) / (this.steps * this.stepSize) - this.options.offset || 0;
	}

});

})();


/*
---

script: String.Extras.js

name: String.Extras

description: Extends the String native object to include methods useful in managing various kinds of strings (query strings, urls, html, etc).

license: MIT-style license

authors:
  - Aaron Newton
  - Guillermo Rauch
  - Christopher Pitt

requires:
  - Core/String
  - Core/Array
  - MooTools.More

provides: [String.Extras]

...
*/

(function(){

var special = {
		'a': /[àáâãäåăą]/g,
		'A': /[ÀÁÂÃÄÅĂĄ]/g,
		'c': /[ćčç]/g,
		'C': /[ĆČÇ]/g,
		'd': /[ďđ]/g,
		'D': /[ĎÐ]/g,
		'e': /[èéêëěę]/g,
		'E': /[ÈÉÊËĚĘ]/g,
		'g': /[ğ]/g,
		'G': /[Ğ]/g,
		'i': /[ìíîï]/g,
		'I': /[ÌÍÎÏ]/g,
		'l': /[ĺľł]/g,
		'L': /[ĹĽŁ]/g,
		'n': /[ñňń]/g,
		'N': /[ÑŇŃ]/g,
		'o': /[òóôõöøő]/g,
		'O': /[ÒÓÔÕÖØ]/g,
		'r': /[řŕ]/g,
		'R': /[ŘŔ]/g,
		's': /[ššş]/g,
		'S': /[ŠŞŚ]/g,
		't': /[ťţ]/g,
		'T': /[ŤŢ]/g,
		'u': /[ùúûůüµ]/g,
		'U': /[ÙÚÛŮÜ]/g,
		'y': /[ÿý]/g,
		'Y': /[ŸÝ]/g,
		'z': /[žźż]/g,
		'Z': /[ŽŹŻ]/g,
		'th': /[þ]/g,
		'TH': /[Þ]/g,
		'dh': /[ð]/g,
		'DH': /[Ð]/g,
		'ss': /[ß]/g,
		'oe': /[œ]/g,
		'OE': /[Œ]/g,
		'ae': /[æ]/g,
		'AE': /[Æ]/g
	},

	tidy = {
		' ': /[\xa0\u2002\u2003\u2009]/g,
		'*': /[\xb7]/g,
		'\'': /[\u2018\u2019]/g,
		'"': /[\u201c\u201d]/g,
		'...': /[\u2026]/g,
		'-': /[\u2013]/g,
	//	'--': /[\u2014]/g,
		'&raquo;': /[\uFFFD]/g
	},

	conversions = {
		ms: 1,
		s: 1000,
		m: 6e4,
		h: 36e5
	},

	findUnits = /(\d*.?\d+)([msh]+)/;

var walk = function(string, replacements){
	var result = string, key;
	for (key in replacements) result = result.replace(replacements[key], key);
	return result;
};

var getRegexForTag = function(tag, contents){
	tag = tag || (contents ? '' : '\\w+');
	var regstr = contents ? '<' + tag + '(?!\\w)[^>]*>([\\s\\S]*?)<\/' + tag + '(?!\\w)>' : '<\/?' + tag + '\/?>|<' + tag + '[\\s|\/][^>]*>';
	return new RegExp(regstr, 'gi');
};

String.implement({

	standardize: function(){
		return walk(this, special);
	},

	repeat: function(times){
		return new Array(times + 1).join(this);
	},

	pad: function(length, str, direction){
		if (this.length >= length) return this;

		var pad = (str == null ? ' ' : '' + str)
			.repeat(length - this.length)
			.substr(0, length - this.length);

		if (!direction || direction == 'right') return this + pad;
		if (direction == 'left') return pad + this;

		return pad.substr(0, (pad.length / 2).floor()) + this + pad.substr(0, (pad.length / 2).ceil());
	},

	getTags: function(tag, contents){
		return this.match(getRegexForTag(tag, contents)) || [];
	},

	stripTags: function(tag, contents){
		return this.replace(getRegexForTag(tag, contents), '');
	},

	tidy: function(){
		return walk(this, tidy);
	},

	truncate: function(max, trail, atChar){
		var string = this;
		if (trail == null && arguments.length == 1) trail = '…';
		if (string.length > max){
			string = string.substring(0, max);
			if (atChar){
				var index = string.lastIndexOf(atChar);
				if (index != -1) string = string.substr(0, index);
			}
			if (trail) string += trail;
		}
		return string;
	},

	ms: function(){
		// "Borrowed" from https://gist.github.com/1503944
		var units = findUnits.exec(this);
		if (units == null) return Number(this);
		return Number(units[1]) * conversions[units[2]];
	}

});

})();

/*
---

script: Element.Forms.js

name: Element.Forms

description: Extends the Element native object to include methods useful in managing inputs.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/Element
  - String.Extras
  - MooTools.More

provides: [Element.Forms]

...
*/

Element.implement({

	tidy: function(){
		this.set('value', this.get('value').tidy());
	},

	getTextInRange: function(start, end){
		return this.get('value').substring(start, end);
	},

	getSelectedText: function(){
		if (this.setSelectionRange) return this.getTextInRange(this.getSelectionStart(), this.getSelectionEnd());
		return document.selection.createRange().text;
	},

	getSelectedRange: function(){
		if (this.selectionStart != null){
			return {
				start: this.selectionStart,
				end: this.selectionEnd
			};
		}

		var pos = {
			start: 0,
			end: 0
		};
		var range = this.getDocument().selection.createRange();
		if (!range || range.parentElement() != this) return pos;
		var duplicate = range.duplicate();

		if (this.type == 'text'){
			pos.start = 0 - duplicate.moveStart('character', -100000);
			pos.end = pos.start + range.text.length;
		} else {
			var value = this.get('value');
			var offset = value.length;
			duplicate.moveToElementText(this);
			duplicate.setEndPoint('StartToEnd', range);
			if (duplicate.text.length) offset -= value.match(/[\n\r]*$/)[0].length;
			pos.end = offset - duplicate.text.length;
			duplicate.setEndPoint('StartToStart', range);
			pos.start = offset - duplicate.text.length;
		}
		return pos;
	},

	getSelectionStart: function(){
		return this.getSelectedRange().start;
	},

	getSelectionEnd: function(){
		return this.getSelectedRange().end;
	},

	setCaretPosition: function(pos){
		if (pos == 'end') pos = this.get('value').length;
		this.selectRange(pos, pos);
		return this;
	},

	getCaretPosition: function(){
		return this.getSelectedRange().start;
	},

	selectRange: function(start, end){
		if (this.setSelectionRange){
			this.focus();
			this.setSelectionRange(start, end);
		} else {
			var value = this.get('value');
			var diff = value.substr(start, end - start).replace(/\r/g, '').length;
			start = value.substr(0, start).replace(/\r/g, '').length;
			var range = this.createTextRange();
			range.collapse(true);
			range.moveEnd('character', start + diff);
			range.moveStart('character', start);
			range.select();
		}
		return this;
	},

	insertAtCursor: function(value, select){
		var pos = this.getSelectedRange();
		var text = this.get('value');
		this.set('value', text.substring(0, pos.start) + value + text.substring(pos.end, text.length));
		if (select !== false) this.selectRange(pos.start, pos.start + value.length);
		else this.setCaretPosition(pos.start + value.length);
		return this;
	},

	insertAroundCursor: function(options, select){
		options = Object.append({
			before: '',
			defaultMiddle: '',
			after: ''
		}, options);

		var value = this.getSelectedText() || options.defaultMiddle;
		var pos = this.getSelectedRange();
		var text = this.get('value');

		if (pos.start == pos.end){
			this.set('value', text.substring(0, pos.start) + options.before + value + options.after + text.substring(pos.end, text.length));
			this.selectRange(pos.start + options.before.length, pos.end + options.before.length + value.length);
		} else {
			var current = text.substring(pos.start, pos.end);
			this.set('value', text.substring(0, pos.start) + options.before + current + options.after + text.substring(pos.end, text.length));
			var selStart = pos.start + options.before.length;
			if (select !== false) this.selectRange(selStart, selStart + current.length);
			else this.setCaretPosition(selStart + text.length);
		}
		return this;
	}

});

/*
---

script: Element.Pin.js

name: Element.Pin

description: Extends the Element native object to include the pin method useful for fixed positioning for elements.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/Element.Event
  - Core/Element.Dimensions
  - Core/Element.Style
  - MooTools.More

provides: [Element.Pin]

...
*/

(function(){
var supportsPositionFixed = false,
	supportTested = false;

var testPositionFixed = function(){
	var test = new Element('div').setStyles({
		position: 'fixed',
		top: 0,
		right: 0
	}).inject(document.body);
	supportsPositionFixed = (test.offsetTop === 0);
	test.dispose();
	supportTested = true;
};

Element.implement({

	pin: function(enable, forceScroll){
		if (!supportTested) testPositionFixed();
		if (this.getStyle('display') == 'none') return this;

		var pinnedPosition,
			scroll = window.getScroll(),
			parent,
			scrollFixer;

		if (enable !== false){
			pinnedPosition = this.getPosition();
			if (!this.retrieve('pin:_pinned')){
				var currentPosition = {
					top: pinnedPosition.y - scroll.y,
					left: pinnedPosition.x - scroll.x,
					margin: '0px',
					padding: '0px'
				};

				if (supportsPositionFixed && !forceScroll){
					this.setStyle('position', 'fixed').setStyles(currentPosition);
				} else {

					parent = this.getOffsetParent();
					var position = this.getPosition(parent),
						styles = this.getStyles('left', 'top');

					if (parent && styles.left == 'auto' || styles.top == 'auto') this.setPosition(position);
					if (this.getStyle('position') == 'static') this.setStyle('position', 'absolute');

					position = {
						x: styles.left.toInt() - scroll.x,
						y: styles.top.toInt() - scroll.y
					};

					scrollFixer = function(){
						if (!this.retrieve('pin:_pinned')) return;
						var scroll = window.getScroll();
						this.setStyles({
							left: position.x + scroll.x,
							top: position.y + scroll.y
						});
					}.bind(this);

					this.store('pin:_scrollFixer', scrollFixer);
					window.addEvent('scroll', scrollFixer);
				}
				this.store('pin:_pinned', true);
			}

		} else {
			if (!this.retrieve('pin:_pinned')) return this;

			parent = this.getParent();
			var offsetParent = (parent.getComputedStyle('position') != 'static' ? parent : parent.getOffsetParent());

			pinnedPosition = this.getPosition();

			this.store('pin:_pinned', false);
			scrollFixer = this.retrieve('pin:_scrollFixer');
			if (!scrollFixer){
				this.setStyles({
					position: 'absolute',
					top: pinnedPosition.y + scroll.y,
					left: pinnedPosition.x + scroll.x
				});
			} else {
				this.store('pin:_scrollFixer', null);
				window.removeEvent('scroll', scrollFixer);
			}
			this.removeClass('isPinned');
		}
		return this;
	},

	unpin: function(){
		return this.pin(false);
	},

	togglePin: function(){
		return this.pin(!this.retrieve('pin:_pinned'));
	}

});



})();

/*
---

script: Element.Position.js

name: Element.Position

description: Extends the Element native object to include methods useful positioning elements relative to others.

license: MIT-style license

authors:
  - Aaron Newton
  - Jacob Thornton

requires:
  - Core/Options
  - Core/Element.Dimensions
  - Element.Measure

provides: [Element.Position]

...
*/

(function(original){

var local = Element.Position = {

	options: {/*
		edge: false,
		returnPos: false,
		minimum: {x: 0, y: 0},
		maximum: {x: 0, y: 0},
		relFixedPosition: false,
		ignoreMargins: false,
		ignoreScroll: false,
		allowNegative: false,*/
		relativeTo: document.body,
		position: {
			x: 'center', //left, center, right
			y: 'center' //top, center, bottom
		},
		offset: {x: 0, y: 0}
	},

	getOptions: function(element, options){
		options = Object.merge({}, local.options, options);
		local.setPositionOption(options);
		local.setEdgeOption(options);
		local.setOffsetOption(element, options);
		local.setDimensionsOption(element, options);
		return options;
	},

	setPositionOption: function(options){
		options.position = local.getCoordinateFromValue(options.position);
	},

	setEdgeOption: function(options){
		var edgeOption = local.getCoordinateFromValue(options.edge);
		options.edge = edgeOption ? edgeOption :
			(options.position.x == 'center' && options.position.y == 'center') ? {x: 'center', y: 'center'} :
			{x: 'left', y: 'top'};
	},

	setOffsetOption: function(element, options){
		var parentOffset = {x: 0, y: 0};
		var parentScroll = {x: 0, y: 0};
		var offsetParent = element.measure(function(){
			return document.id(this.getOffsetParent());
		});

		if (!offsetParent || offsetParent == element.getDocument().body) return;

		parentScroll = offsetParent.getScroll();
		parentOffset = offsetParent.measure(function(){
			var position = this.getPosition();
			if (this.getStyle('position') == 'fixed'){
				var scroll = window.getScroll();
				position.x += scroll.x;
				position.y += scroll.y;
			}
			return position;
		});

		options.offset = {
			parentPositioned: offsetParent != document.id(options.relativeTo),
			x: options.offset.x - parentOffset.x + parentScroll.x,
			y: options.offset.y - parentOffset.y + parentScroll.y
		};
	},

	setDimensionsOption: function(element, options){
		options.dimensions = element.getDimensions({
			computeSize: true,
			styles: ['padding', 'border', 'margin']
		});
	},

	getPosition: function(element, options){
		var position = {};
		options = local.getOptions(element, options);
		var relativeTo = document.id(options.relativeTo) || document.body;

		local.setPositionCoordinates(options, position, relativeTo);
		if (options.edge) local.toEdge(position, options);

		var offset = options.offset;
		position.left = ((position.x >= 0 || offset.parentPositioned || options.allowNegative) ? position.x : 0).toInt();
		position.top = ((position.y >= 0 || offset.parentPositioned || options.allowNegative) ? position.y : 0).toInt();

		local.toMinMax(position, options);

		if (options.relFixedPosition || relativeTo.getStyle('position') == 'fixed') local.toRelFixedPosition(relativeTo, position);
		if (options.ignoreScroll) local.toIgnoreScroll(relativeTo, position);
		if (options.ignoreMargins) local.toIgnoreMargins(position, options);

		position.left = Math.ceil(position.left);
		position.top = Math.ceil(position.top);
		delete position.x;
		delete position.y;

		return position;
	},

	setPositionCoordinates: function(options, position, relativeTo){
		var offsetY = options.offset.y,
			offsetX = options.offset.x,
			calc = (relativeTo == document.body) ? window.getScroll() : relativeTo.getPosition(),
			top = calc.y,
			left = calc.x,
			winSize = window.getSize();

		switch (options.position.x){
			case 'left': position.x = left + offsetX; break;
			case 'right': position.x = left + offsetX + relativeTo.offsetWidth; break;
			default: position.x = left + ((relativeTo == document.body ? winSize.x : relativeTo.offsetWidth) / 2) + offsetX; break;
		}

		switch (options.position.y){
			case 'top': position.y = top + offsetY; break;
			case 'bottom': position.y = top + offsetY + relativeTo.offsetHeight; break;
			default: position.y = top + ((relativeTo == document.body ? winSize.y : relativeTo.offsetHeight) / 2) + offsetY; break;
		}
	},

	toMinMax: function(position, options){
		var xy = {left: 'x', top: 'y'}, value;
		['minimum', 'maximum'].each(function(minmax){
			['left', 'top'].each(function(lr){
				value = options[minmax] ? options[minmax][xy[lr]] : null;
				if (value != null && ((minmax == 'minimum') ? position[lr] < value : position[lr] > value)) position[lr] = value;
			});
		});
	},

	toRelFixedPosition: function(relativeTo, position){
		var winScroll = window.getScroll();
		position.top += winScroll.y;
		position.left += winScroll.x;
	},

	toIgnoreScroll: function(relativeTo, position){
		var relScroll = relativeTo.getScroll();
		position.top -= relScroll.y;
		position.left -= relScroll.x;
	},

	toIgnoreMargins: function(position, options){
		position.left += options.edge.x == 'right'
			? options.dimensions['margin-right']
			: (options.edge.x != 'center'
				? -options.dimensions['margin-left']
				: -options.dimensions['margin-left'] + ((options.dimensions['margin-right'] + options.dimensions['margin-left']) / 2));

		position.top += options.edge.y == 'bottom'
			? options.dimensions['margin-bottom']
			: (options.edge.y != 'center'
				? -options.dimensions['margin-top']
				: -options.dimensions['margin-top'] + ((options.dimensions['margin-bottom'] + options.dimensions['margin-top']) / 2));
	},

	toEdge: function(position, options){
		var edgeOffset = {},
			dimensions = options.dimensions,
			edge = options.edge;

		switch (edge.x){
			case 'left': edgeOffset.x = 0; break;
			case 'right': edgeOffset.x = -dimensions.x - dimensions.computedRight - dimensions.computedLeft; break;
			// center
			default: edgeOffset.x = -(Math.round(dimensions.totalWidth / 2)); break;
		}

		switch (edge.y){
			case 'top': edgeOffset.y = 0; break;
			case 'bottom': edgeOffset.y = -dimensions.y - dimensions.computedTop - dimensions.computedBottom; break;
			// center
			default: edgeOffset.y = -(Math.round(dimensions.totalHeight / 2)); break;
		}

		position.x += edgeOffset.x;
		position.y += edgeOffset.y;
	},

	getCoordinateFromValue: function(option){
		if (typeOf(option) != 'string') return option;
		option = option.toLowerCase();

		return {
			x: option.test('left') ? 'left'
				: (option.test('right') ? 'right' : 'center'),
			y: option.test(/upper|top/) ? 'top'
				: (option.test('bottom') ? 'bottom' : 'center')
		};
	}

};

Element.implement({

	position: function(options){
		if (options && (options.x != null || options.y != null)){
			return (original ? original.apply(this, arguments) : this);
		}
		var position = this.setStyle('position', 'absolute').calculatePosition(options);
		return (options && options.returnPos) ? position : this.setStyles(position);
	},

	calculatePosition: function(options){
		return local.getPosition(this, options);
	}

});

})(Element.prototype.position);

/*
---

script: Element.Shortcuts.js

name: Element.Shortcuts

description: Extends the Element native object to include some shortcut methods.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/Element.Style
  - MooTools.More

provides: [Element.Shortcuts]

...
*/

Element.implement({

	isDisplayed: function(){
		return this.getStyle('display') != 'none';
	},

	isVisible: function(){
		var w = this.offsetWidth,
			h = this.offsetHeight;
		return (w == 0 && h == 0) ? false : (w > 0 && h > 0) ? true : this.style.display != 'none';
	},

	toggle: function(){
		return this[this.isDisplayed() ? 'hide' : 'show']();
	},

	hide: function(){
		var d;
		try {
			//IE fails here if the element is not in the dom
			d = this.getStyle('display');
		} catch (e){}
		if (d == 'none') return this;
		return this.store('element:_originalDisplay', d || '').setStyle('display', 'none');
	},

	show: function(display){
		if (!display && this.isDisplayed()) return this;
		display = display || this.retrieve('element:_originalDisplay') || 'block';
		return this.setStyle('display', (display == 'none') ? 'block' : display);
	},

	swapClass: function(remove, add){
		return this.removeClass(remove).addClass(add);
	}

});

Document.implement({

	clearSelection: function(){
		if (window.getSelection){
			var selection = window.getSelection();
			if (selection && selection.removeAllRanges) selection.removeAllRanges();
		} else if (document.selection && document.selection.empty){
			try {
				//IE fails here if selected element is not in dom
				document.selection.empty();
			} catch (e){}
		}
	}

});

/*
---

script: Elements.From.js

name: Elements.From

description: Returns a collection of elements from a string of html.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/String
  - Core/Element
  - MooTools.More

provides: [Elements.from, Elements.From]

...
*/

Elements.from = function(text, excludeScripts){
	if (excludeScripts || excludeScripts == null) text = text.stripScripts();

	var container, match = text.match(/^\s*(?:<!--.*?-->\s*)*<(t[dhr]|tbody|tfoot|thead)/i);

	if (match){
		container = new Element('table');
		var tag = match[1].toLowerCase();
		if (['td', 'th', 'tr'].contains(tag)){
			container = new Element('tbody').inject(container);
			if (tag != 'tr') container = new Element('tr').inject(container);
		}
	}

	return (container || new Element('div')).set('html', text).getChildren();
};

/*
---

script: String.QueryString.js

name: String.QueryString

description: Methods for dealing with URI query strings.

license: MIT-style license

authors:
  - Sebastian Markbåge
  - Aaron Newton
  - Lennart Pilon
  - Valerio Proietti

requires:
  - Core/Array
  - Core/String
  - MooTools.More

provides: [String.QueryString]

...
*/

(function(){

/**
 * decodeURIComponent doesn't do the correct thing with query parameter keys or
 * values. Specifically, it leaves '+' as '+' when it should be converting them
 * to spaces as that's the specification. When browsers submit HTML forms via
 * GET, the values are encoded using 'application/x-www-form-urlencoded'
 * which converts spaces to '+'.
 *
 * See: http://unixpapa.com/js/querystring.html for a description of the
 * problem.
 */
var decodeComponent = function(str){
	return decodeURIComponent(str.replace(/\+/g, ' '));
};

String.implement({

	parseQueryString: function(decodeKeys, decodeValues){
		if (decodeKeys == null) decodeKeys = true;
		if (decodeValues == null) decodeValues = true;

		var vars = this.split(/[&;]/),
			object = {};
		if (!vars.length) return object;

		vars.each(function(val){
			var index = val.indexOf('=') + 1,
				value = index ? val.substr(index) : '',
				keys = index ? val.substr(0, index - 1).match(/([^\]\[]+|(\B)(?=\]))/g) : [val],
				obj = object;
			if (!keys) return;
			if (decodeValues) value = decodeComponent(value);
			keys.each(function(key, i){
				if (decodeKeys) key = decodeComponent(key);
				var current = obj[key];

				if (i < keys.length - 1) obj = obj[key] = current || {};
				else if (typeOf(current) == 'array') current.push(value);
				else obj[key] = current != null ? [current, value] : value;
			});
		});

		return object;
	},

	cleanQueryString: function(method){
		return this.split('&').filter(function(val){
			var index = val.indexOf('='),
				key = index < 0 ? '' : val.substr(0, index),
				value = val.substr(index + 1);

			return method ? method.call(null, key, value) : (value || value === 0);
		}).join('&');
	}

});

})();

/*
---

script: Object.Extras.js

name: Object.Extras

description: Extra Object generics, like getFromPath which allows a path notation to child elements.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/Object
  - MooTools.More

provides: [Object.Extras]

...
*/

(function(){

var defined = function(value){
	return value != null;
};

var hasOwnProperty = Object.prototype.hasOwnProperty;

Object.extend({

	getFromPath: function(source, parts){
		if (typeof parts == 'string') parts = parts.split('.');
		for (var i = 0, l = parts.length; i < l; i++){
			if (hasOwnProperty.call(source, parts[i])) source = source[parts[i]];
			else return null;
		}
		return source;
	},

	cleanValues: function(object, method){
		method = method || defined;
		for (var key in object) if (!method(object[key])){
			delete object[key];
		}
		return object;
	},

	erase: function(object, key){
		if (hasOwnProperty.call(object, key)) delete object[key];
		return object;
	},

	run: function(object){
		var args = Array.slice(arguments, 1);
		for (var key in object) if (object[key].apply){
			object[key].apply(object, args);
		}
		return object;
	}

});

})();

/*
---

script: Fx.Scroll.js

name: Fx.Scroll

description: Effect to smoothly scroll any element, including the window.

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Fx
  - Core/Element.Event
  - Core/Element.Dimensions
  - MooTools.More

provides: [Fx.Scroll]

...
*/

(function(){

Fx.Scroll = new Class({

	Extends: Fx,

	options: {
		offset: {x: 0, y: 0},
		wheelStops: true
	},

	initialize: function(element, options){
		this.element = this.subject = document.id(element);
		//this.parent(options);
		Fx.prototype.initialize.apply(this,[options]);

		if (typeOf(this.element) != 'element') this.element = document.id(this.element.getDocument().body);

		if (this.options.wheelStops){
			var stopper = this.element,
				cancel = this.cancel.pass(false, this);
			this.addEvent('start', function(){
				stopper.addEvent('mousewheel', cancel);
			}, true);
			this.addEvent('complete', function(){
				stopper.removeEvent('mousewheel', cancel);
			}, true);
		}
	},

	set: function(){
		var now = Array.flatten(arguments);
		this.element.scrollTo(now[0], now[1]);
		return this;
	},

	compute: function(from, to, delta){
		return [0, 1].map(function(i){
			return Fx.compute(from[i], to[i], delta);
		});
	},

	start: function(x, y){
		if (!this.check(x, y)) return this;
		var scroll = this.element.getScroll();
		//return this.parent([scroll.x, scroll.y], [x, y]);
		return Fx.prototype.start.apply(this,[scroll.x, scroll.y], [x, y]);
	},

	calculateScroll: function(x, y){
		var element = this.element,
			scrollSize = element.getScrollSize(),
			scroll = element.getScroll(),
			size = element.getSize(),
			offset = this.options.offset,
			values = {x: x, y: y};

		for (var z in values){
			if (!values[z] && values[z] !== 0) values[z] = scroll[z];
			if (typeOf(values[z]) != 'number') values[z] = scrollSize[z] - size[z];
			values[z] += offset[z];
		}

		return [values.x, values.y];
	},

	toTop: function(){
		return this.start.apply(this, this.calculateScroll(false, 0));
	},

	toLeft: function(){
		return this.start.apply(this, this.calculateScroll(0, false));
	},

	toRight: function(){
		return this.start.apply(this, this.calculateScroll('right', false));
	},

	toBottom: function(){
		return this.start.apply(this, this.calculateScroll(false, 'bottom'));
	},

	toElement: function(el, axes){
		axes = axes ? Array.convert(axes) : ['x', 'y'];
		var scroll = isBody(this.element) ? {x: 0, y: 0} : this.element.getScroll();
		var position = Object.map(document.id(el).getPosition(this.element), function(value, axis){
			return axes.contains(axis) ? value + scroll[axis] : false;
		});
		return this.start.apply(this, this.calculateScroll(position.x, position.y));
	},

	toElementEdge: function(el, axes, offset){
		axes = axes ? Array.convert(axes) : ['x', 'y'];
		el = document.id(el);
		var to = {},
			position = el.getPosition(this.element),
			size = el.getSize(),
			scroll = this.element.getScroll(),
			containerSize = this.element.getSize(),
			edge = {
				x: position.x + size.x,
				y: position.y + size.y
			};

		['x', 'y'].each(function(axis){
			if (axes.contains(axis)){
				if (edge[axis] > scroll[axis] + containerSize[axis]) to[axis] = edge[axis] - containerSize[axis];
				if (position[axis] < scroll[axis]) to[axis] = position[axis];
			}
			if (to[axis] == null) to[axis] = scroll[axis];
			if (offset && offset[axis]) to[axis] = to[axis] + offset[axis];
		}, this);

		if (to.x != scroll.x || to.y != scroll.y) this.start(to.x, to.y);
		return this;
	},

	toElementCenter: function(el, axes, offset){
		axes = axes ? Array.convert(axes) : ['x', 'y'];
		el = document.id(el);
		var to = {},
			position = el.getPosition(this.element),
			size = el.getSize(),
			scroll = this.element.getScroll(),
			containerSize = this.element.getSize();

		['x', 'y'].each(function(axis){
			if (axes.contains(axis)){
				to[axis] = position[axis] - (containerSize[axis] - size[axis]) / 2;
			}
			if (to[axis] == null) to[axis] = scroll[axis];
			if (offset && offset[axis]) to[axis] = to[axis] + offset[axis];
		}, this);

		if (to.x != scroll.x || to.y != scroll.y) this.start(to.x, to.y);
		return this;
	}

});



function isBody(element){
	return (/^(?:body|html)$/i).test(element.tagName);
}

})();

/*
---

name: Events.Pseudos

description: Adds the functionality to add pseudo events

license: MIT-style license

authors:
  - Arian Stolwijk

requires: [Core/Class.Extras, Core/Slick.Parser, MooTools.More]

provides: [Events.Pseudos]

...
*/

(function(){

Events.Pseudos = function(pseudos, addEvent, removeEvent){

	var storeKey = '_monitorEvents:';

	var storageOf = function(object){
		return {
			store: object.store ? function(key, value){
				object.store(storeKey + key, value);
			} : function(key, value){
				(object._monitorEvents || (object._monitorEvents = {}))[key] = value;
			},
			retrieve: object.retrieve ? function(key, dflt){
				return object.retrieve(storeKey + key, dflt);
			} : function(key, dflt){
				if (!object._monitorEvents) return dflt;
				return object._monitorEvents[key] || dflt;
			}
		};
	};

	var splitType = function(type){
		if (type.indexOf(':') == -1 || !pseudos) return null;

		var parsed = Slick.parse(type).expressions[0][0],
			parsedPseudos = parsed.pseudos,
			l = parsedPseudos.length,
			splits = [];

		while (l--){
			var pseudo = parsedPseudos[l].key,
				listener = pseudos[pseudo];
			if (listener != null) splits.push({
				event: parsed.tag,
				value: parsedPseudos[l].value,
				pseudo: pseudo,
				original: type,
				listener: listener
			});
		}
		return splits.length ? splits : null;
	};

	return {

		addEvent: function(type, fn, internal){
			var split = splitType(type);
			if (!split) return addEvent.call(this, type, fn, internal);

			var storage = storageOf(this),
				events = storage.retrieve(type, []),
				eventType = split[0].event,
				args = Array.slice(arguments, 2),
				stack = fn,
				self = this;

			split.each(function(item){
				var listener = item.listener,
					stackFn = stack;
				if (listener == false) eventType += ':' + item.pseudo + '(' + item.value + ')';
				else stack = function(){
					listener.call(self, item, stackFn, arguments, stack);
				};
			});

			events.include({type: eventType, event: fn, monitor: stack});
			storage.store(type, events);

			if (type != eventType) addEvent.apply(this, [type, fn].concat(args));
			return addEvent.apply(this, [eventType, stack].concat(args));
		},

		removeEvent: function(type, fn){
			var split = splitType(type);
			if (!split) return removeEvent.call(this, type, fn);

			var storage = storageOf(this),
				events = storage.retrieve(type);
			if (!events) return this;

			var args = Array.slice(arguments, 2);

			removeEvent.apply(this, [type, fn].concat(args));
			events.each(function(monitor, i){
				if (!fn || monitor.event == fn) removeEvent.apply(this, [monitor.type, monitor.monitor].concat(args));
				delete events[i];
			}, this);

			storage.store(type, events);
			return this;
		}

	};

};

var pseudos = {

	once: function(split, fn, args, monitor){
		fn.apply(this, args);
		this.removeEvent(split.event, monitor)
			.removeEvent(split.original, fn);
	},

	throttle: function(split, fn, args){
		if (!fn._throttled){
			fn.apply(this, args);
			fn._throttled = setTimeout(function(){
				fn._throttled = false;
			}, split.value || 250);
		}
	},

	pause: function(split, fn, args){
		clearTimeout(fn._pause);
		fn._pause = fn.delay(split.value || 250, this, args);
	}

};

Events.definePseudo = function(key, listener){
	pseudos[key] = listener;
	return this;
};

Events.lookupPseudo = function(key){
	return pseudos[key];
};

var proto = Events.prototype;
Events.implement(Events.Pseudos(pseudos, proto.addEvent, proto.removeEvent));

['Request', 'Fx'].each(function(klass){
	if (this[klass]) this[klass].implement(Events.prototype);
});

})();

/*
---

name: Element.Event.Pseudos

description: Adds the functionality to add pseudo events for Elements

license: MIT-style license

authors:
  - Arian Stolwijk

requires: [Core/Element.Event, Core/Element.Delegation, Events.Pseudos]

provides: [Element.Event.Pseudos, Element.Delegation.Pseudo]

...
*/

(function(){

var pseudos = {relay: false},
	copyFromEvents = ['once', 'throttle', 'pause'],
	count = copyFromEvents.length;

while (count--) pseudos[copyFromEvents[count]] = Events.lookupPseudo(copyFromEvents[count]);

DOMEvent.definePseudo = function(key, listener){
	pseudos[key] = listener;
	return this;
};

var proto = Element.prototype;
[Element, Window, Document].invoke('implement', Events.Pseudos(pseudos, proto.addEvent, proto.removeEvent));

})();

/*
---

name: Element.Event.Pseudos.Keys

description: Adds functionality fire events if certain keycombinations are pressed

license: MIT-style license

authors:
  - Arian Stolwijk

requires: [Element.Event.Pseudos]

provides: [Element.Event.Pseudos.Keys]

...
*/

(function(){

var keysStoreKey = '$moo:keys-pressed',
	keysKeyupStoreKey = '$moo:keys-keyup';


DOMEvent.definePseudo('keys', function(split, fn, args){

	var event = args[0],
		keys = [],
		pressed = this.retrieve(keysStoreKey, []),
		value = split.value;

	if (value != '+') keys.append(value.replace('++', function(){
		keys.push('+'); // shift++ and shift+++a
		return '';
	}).split('+'));
	else keys = ['+'];

	pressed.include(event.key);

	if (keys.every(function(key){
		return pressed.contains(key);
	})) fn.apply(this, args);

	this.store(keysStoreKey, pressed);

	if (!this.retrieve(keysKeyupStoreKey)){
		var keyup = function(event){
			(function(){
				pressed = this.retrieve(keysStoreKey, []).erase(event.key);
				this.store(keysStoreKey, pressed);
			}).delay(0, this); // Fix for IE
		};
		this.store(keysKeyupStoreKey, keyup).addEvent('keyup', keyup);
	}

});

DOMEvent.defineKeys({
	'16': 'shift',
	'17': 'control',
	'18': 'alt',
	'20': 'capslock',
	'33': 'pageup',
	'34': 'pagedown',
	'35': 'end',
	'36': 'home',
	'144': 'numlock',
	'145': 'scrolllock',
	'186': ';',
	'187': '=',
	'188': ',',
	'190': '.',
	'191': '/',
	'192': '`',
	'219': '[',
	'220': '\\',
	'221': ']',
	'222': "'",
	'107': '+',
	'109': '-', // subtract
	'189': '-'  // dash
});

})();

/*
---

script: Keyboard.js

name: Keyboard

description: KeyboardEvents used to intercept events on a class for keyboard and format modifiers in a specific order so as to make alt+shift+c the same as shift+alt+c.

license: MIT-style license

authors:
  - Perrin Westrich
  - Aaron Newton
  - Scott Kyle

requires:
  - Core/Events
  - Core/Options
  - Core/Element.Event
  - Element.Event.Pseudos.Keys

provides: [Keyboard]

...
*/

(function(){

var Keyboard = this.Keyboard = new Class({

	Extends: Events,

	Implements: [Options],

	options: {/*
		onActivate: function(){},
		onDeactivate: function(){},*/
		defaultEventType: 'keydown',
		active: false,
		manager: null,
		events: {},
		nonParsedEvents: ['activate', 'deactivate', 'onactivate', 'ondeactivate', 'changed', 'onchanged']
	},

	initialize: function(options){
		if (options && options.manager){
			this._manager = options.manager;
			delete options.manager;
		}
		this.setOptions(options);
		this._setup();
	},

	addEvent: function(type, fn, internal){
		//return this.parent(Keyboard.parse(type, this.options.defaultEventType, this.options.nonParsedEvents), fn, internal);
		return Events.prototype.addEvent.apply(this,[Keyboard.parse(type, this.options.defaultEventType, this.options.nonParsedEvents), fn, internal]);
	},

	removeEvent: function(type, fn){
		//return this.parent(Keyboard.parse(type, this.options.defaultEventType, this.options.nonParsedEvents), fn);
		return Events.prototype.removeEvent.apply(this,[Keyboard.parse(type, this.options.defaultEventType, this.options.nonParsedEvents), fn]);
	},

	toggleActive: function(){
		return this[this.isActive() ? 'deactivate' : 'activate']();
	},

	activate: function(instance){
		if (instance){
			if (instance.isActive()) return this;
			//if we're stealing focus, store the last keyboard to have it so the relinquish command works
			if (this._activeKB && instance != this._activeKB){
				this.previous = this._activeKB;
				this.previous.fireEvent('deactivate');
			}
			//if we're enabling a child, assign it so that events are now passed to it
			this._activeKB = instance.fireEvent('activate');
			Keyboard.manager.fireEvent('changed');
		} else if (this._manager){
			//else we're enabling ourselves, we must ask our parent to do it for us
			this._manager.activate(this);
		}
		return this;
	},

	isActive: function(){
		return this._manager ? (this._manager._activeKB == this) : (Keyboard.manager == this);
	},

	deactivate: function(instance){
		if (instance){
			if (instance === this._activeKB){
				this._activeKB = null;
				instance.fireEvent('deactivate');
				Keyboard.manager.fireEvent('changed');
			}
		} else if (this._manager){
			this._manager.deactivate(this);
		}
		return this;
	},

	relinquish: function(){
		if (this.isActive() && this._manager && this._manager.previous) this._manager.activate(this._manager.previous);
		else this.deactivate();
		return this;
	},

	//management logic
	manage: function(instance){
		if (instance._manager) instance._manager.drop(instance);
		this._instances.push(instance);
		instance._manager = this;
		if (!this._activeKB) this.activate(instance);
		return this;
	},

	drop: function(instance){
		instance.relinquish();
		this._instances.erase(instance);
		if (this._activeKB == instance){
			if (this.previous && this._instances.contains(this.previous)) this.activate(this.previous);
			else this._activeKB = this._instances[0];
		}
		return this;
	},

	trace: function(){
		Keyboard.trace(this);
	},

	each: function(fn){
		Keyboard.each(this, fn);
	},

	/*
		PRIVATE METHODS
	*/

	_instances: [],

	_disable: function(instance){
		if (this._activeKB == instance) this._activeKB = null;
	},

	_setup: function(){
		this.addEvents(this.options.events);
		//if this is the root manager, nothing manages it
		if (Keyboard.manager && !this._manager) Keyboard.manager.manage(this);
		if (this.options.active) this.activate();
		else this.relinquish();
	},

	_handle: function(event, type){
		//Keyboard.stop(event) prevents key propagation
		if (event.preventKeyboardPropagation) return;

		var bubbles = !!this._manager;
		if (bubbles && this._activeKB){
			this._activeKB._handle(event, type);
			if (event.preventKeyboardPropagation) return;
		}
		this.fireEvent(type, event);

		if (!bubbles && this._activeKB) this._activeKB._handle(event, type);
	}

});

var parsed = {};
var modifiers = ['shift', 'control', 'alt', 'meta'];
var regex = /^(?:shift|control|ctrl|alt|meta)$/;

Keyboard.parse = function(type, eventType, ignore){
	if (ignore && ignore.contains(type.toLowerCase())) return type;

	type = type.toLowerCase().replace(/^(keyup|keydown):/, function($0, $1){
		eventType = $1;
		return '';
	});

	if (!parsed[type]){
		if (type != '+'){
			var key, mods = {};
			type.split('+').each(function(part){
				if (regex.test(part)) mods[part] = true;
				else key = part;
			});

			mods.control = mods.control || mods.ctrl; // allow both control and ctrl

			var keys = [];
			modifiers.each(function(mod){
				if (mods[mod]) keys.push(mod);
			});

			if (key) keys.push(key);
			parsed[type] = keys.join('+');
		} else {
			parsed[type] = type;
		}
	}

	return eventType + ':keys(' + parsed[type] + ')';
};

Keyboard.each = function(keyboard, fn){
	var current = keyboard || Keyboard.manager;
	while (current){
		fn(current);
		current = current._activeKB;
	}
};

Keyboard.stop = function(event){
	event.preventKeyboardPropagation = true;
};

Keyboard.manager = new Keyboard({
	active: true
});

Keyboard.trace = function(keyboard){
	keyboard = keyboard || Keyboard.manager;
	var hasConsole = window.console && console.log;
	if (hasConsole) console.log('the following items have focus: ');
	Keyboard.each(keyboard, function(current){
		if (hasConsole) console.log(document.id(current.widget) || current.wiget || current);
	});
};

var handler = function(event){
	var keys = [];
	modifiers.each(function(mod){
		if (event[mod]) keys.push(mod);
	});

	if (!regex.test(event.key)) keys.push(event.key);
	Keyboard.manager._handle(event, event.type + ':keys(' + keys.join('+') + ')');
};

document.addEvents({
	'keyup': handler,
	'keydown': handler
});

})();

/*
---

script: Keyboard.Extras.js

name: Keyboard.Extras

description: Enhances Keyboard by adding the ability to name and describe keyboard shortcuts, and the ability to grab shortcuts by name and bind the shortcut to different keys.

license: MIT-style license

authors:
  - Perrin Westrich

requires:
  - Keyboard
  - MooTools.More

provides: [Keyboard.Extras]

...
*/
Keyboard.prototype.options.nonParsedEvents.combine(['rebound', 'onrebound']);

Keyboard.implement({

	/*
		shortcut should be in the format of:
		{
			'keys': 'shift+s', // the default to add as an event.
			'description': 'blah blah blah', // a brief description of the functionality.
			'handler': function(){} // the event handler to run when keys are pressed.
		}
	*/
	addShortcut: function(name, shortcut){
		this._shortcuts = this._shortcuts || [];
		this._shortcutIndex = this._shortcutIndex || {};

		shortcut.getKeyboard = Function.convert(this);
		shortcut.name = name;
		this._shortcutIndex[name] = shortcut;
		this._shortcuts.push(shortcut);
		if (shortcut.keys) this.addEvent(shortcut.keys, shortcut.handler);
		return this;
	},

	addShortcuts: function(obj){
		for (var name in obj) this.addShortcut(name, obj[name]);
		return this;
	},

	removeShortcut: function(name){
		var shortcut = this.getShortcut(name);
		if (shortcut && shortcut.keys){
			this.removeEvent(shortcut.keys, shortcut.handler);
			delete this._shortcutIndex[name];
			this._shortcuts.erase(shortcut);
		}
		return this;
	},

	removeShortcuts: function(names){
		names.each(this.removeShortcut, this);
		return this;
	},

	getShortcuts: function(){
		return this._shortcuts || [];
	},

	getShortcut: function(name){
		return (this._shortcutIndex || {})[name];
	}

});

Keyboard.rebind = function(newKeys, shortcuts){
	Array.convert(shortcuts).each(function(shortcut){
		shortcut.getKeyboard().removeEvent(shortcut.keys, shortcut.handler);
		shortcut.getKeyboard().addEvent(newKeys, shortcut.handler);
		shortcut.keys = newKeys;
		shortcut.getKeyboard().fireEvent('rebound');
	});
};


Keyboard.getActiveShortcuts = function(keyboard){
	var activeKBS = [], activeSCS = [];
	Keyboard.each(keyboard, [].push.bind(activeKBS));
	activeKBS.each(function(kb){ activeSCS.extend(kb.getShortcuts()); });
	return activeSCS;
};

Keyboard.getShortcut = function(name, keyboard, opts){
	opts = opts || {};
	var shortcuts = opts.many ? [] : null,
		set = opts.many ? function(kb){
			var shortcut = kb.getShortcut(name);
			if (shortcut) shortcuts.push(shortcut);
		} : function(kb){
			if (!shortcuts) shortcuts = kb.getShortcut(name);
		};
	Keyboard.each(keyboard, set);
	return shortcuts;
};

Keyboard.getShortcuts = function(name, keyboard){
	return Keyboard.getShortcut(name, keyboard, { many: true });
};

/*
---

script: Scroller.js

name: Scroller

description: Class which scrolls the contents of any Element (including the window) when the mouse reaches the Element's boundaries.

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Events
  - Core/Options
  - Core/Element.Event
  - Core/Element.Dimensions
  - MooTools.More

provides: [Scroller]

...
*/
(function(){

var Scroller = this.Scroller = new Class({

	Implements: [Events, Options],

	options: {
		area: 20,
		velocity: 1,
		onChange: function(x, y){
			this.element.scrollTo(x, y);
		},
		fps: 50
	},

	initialize: function(element, options){
		this.setOptions(options);
		this.element = document.id(element);
		this.docBody = document.id(this.element.getDocument().body);
		this.listener = (typeOf(this.element) != 'element') ? this.docBody : this.element;
		this.timer = null;
		this.bound = {
			attach: this.attach.bind(this),
			detach: this.detach.bind(this),
			getCoords: this.getCoords.bind(this)
		};
	},

	start: function(){
		this.listener.addEvents({
			mouseover: this.bound.attach,
			mouseleave: this.bound.detach
		});
		return this;
	},

	stop: function(){
		this.listener.removeEvents({
			mouseover: this.bound.attach,
			mouseleave: this.bound.detach
		});
		this.detach();
		this.timer = clearInterval(this.timer);
		return this;
	},

	attach: function(){
		this.listener.addEvent('mousemove', this.bound.getCoords);
	},

	detach: function(){
		this.listener.removeEvent('mousemove', this.bound.getCoords);
		this.timer = clearInterval(this.timer);
	},

	getCoords: function(event){
		this.page = (this.listener.get('tag') == 'body') ? event.client : event.page;
		if (!this.timer) this.timer = this.scroll.periodical(Math.round(1000 / this.options.fps), this);
	},

	scroll: function(){
		var size = this.element.getSize(),
			scroll = this.element.getScroll(),
			pos = ((this.element != this.docBody) && (this.element != window)) ? this.element.getOffsets() : {x: 0, y: 0},
			scrollSize = this.element.getScrollSize(),
			change = {x: 0, y: 0},
			top = this.options.area.top || this.options.area,
			bottom = this.options.area.bottom || this.options.area;
		for (var z in this.page){
			if (this.page[z] < (top + pos[z]) && scroll[z] != 0){
				change[z] = (this.page[z] - top - pos[z]) * this.options.velocity;
			} else if (this.page[z] + bottom > (size[z] + pos[z]) && scroll[z] + size[z] != scrollSize[z]){
				change[z] = (this.page[z] - size[z] + bottom - pos[z]) * this.options.velocity;
			}
			change[z] = change[z].round();
		}
		if (change.y || change.x) this.fireEvent('change', [scroll.x + change.x, scroll.y + change.y]);
	}

});

})();


/*
---

script: Tips.js

name: Tips

description: Class for creating nice tips that follow the mouse cursor when hovering an element.

license: MIT-style license

authors:
  - Valerio Proietti
  - Christoph Pojer
  - Luis Merino

requires:
  - Core/Options
  - Core/Events
  - Core/Element.Event
  - Core/Element.Style
  - Core/Element.Dimensions
  - MooTools.More

provides: [Tips]

...
*/

(function(){

var read = function(option, element){
	return (option) ? (typeOf(option) == 'function' ? option(element) : element.get(option)) : '';
};

var Tips = this.Tips = new Class({

	Implements: [Events, Options],

	options: {/*
		id: null,
		onAttach: function(element){},
		onDetach: function(element){},
		onBound: function(coords){},*/
		onShow: function(){
			this.tip.setStyle('display', 'block');
		},
		onHide: function(){
			this.tip.setStyle('display', 'none');
		},
		title: 'title',
		text: function(element){
			return element.get('rel') || element.get('href');
		},
		showDelay: 100,
		hideDelay: 100,
		className: 'tip-wrap',
		offset: {x: 16, y: 16},
		windowPadding: {x:0, y:0},
		fixed: false,
		waiAria: true,
		hideEmpty: false
	},

	initialize: function(){
		var params = Array.link(arguments, {
			options: Type.isObject,
			elements: function(obj){
				return obj != null;
			}
		});
		this.setOptions(params.options);
		if (params.elements) this.attach(params.elements);
		this.container = new Element('div', {'class': 'tip'});

		if (this.options.id){
			this.container.set('id', this.options.id);
			if (this.options.waiAria) this.attachWaiAria();
		}
	},

	toElement: function(){
		if (this.tip) return this.tip;

		this.tip = new Element('div', {
			'class': this.options.className,
			styles: {
				position: 'absolute',
				top: 0,
				left: 0,
				display: 'none'
			}
		}).adopt(
			new Element('div', {'class': 'tip-top'}),
			this.container,
			new Element('div', {'class': 'tip-bottom'})
		);

		return this.tip;
	},

	attachWaiAria: function(){
		var id = this.options.id;
		this.container.set('role', 'tooltip');

		if (!this.waiAria){
			this.waiAria = {
				show: function(element){
					if (id) element.set('aria-describedby', id);
					this.container.set('aria-hidden', 'false');
				},
				hide: function(element){
					if (id) element.erase('aria-describedby');
					this.container.set('aria-hidden', 'true');
				}
			};
		}
		this.addEvents(this.waiAria);
	},

	detachWaiAria: function(){
		if (this.waiAria){
			this.container.erase('role');
			this.container.erase('aria-hidden');
			this.removeEvents(this.waiAria);
		}
	},

	attach: function(elements){
		$$(elements).each(function(element){
			var title = read(this.options.title, element),
				text = read(this.options.text, element);

			element.set('title', '').store('tip:native', title).retrieve('tip:title', title);
			element.retrieve('tip:text', text);
			this.fireEvent('attach', [element]);

			var events = ['enter', 'leave'];
			if (!this.options.fixed) events.push('move');

			events.each(function(value){
				var event = element.retrieve('tip:' + value);
				if (!event) event = function(event){
					this['element' + value.capitalize()].apply(this, [event, element]);
				}.bind(this);

				element.store('tip:' + value, event).addEvent('mouse' + value, event);
			}, this);
		}, this);

		return this;
	},

	detach: function(elements){
		$$(elements).each(function(element){
			['enter', 'leave', 'move'].each(function(value){
				element.removeEvent('mouse' + value, element.retrieve('tip:' + value)).eliminate('tip:' + value);
			});

			this.fireEvent('detach', [element]);

			if (this.options.title == 'title'){ // This is necessary to check if we can revert the title
				var original = element.retrieve('tip:native');
				if (original) element.set('title', original);
			}
		}, this);

		return this;
	},

	elementEnter: function(event, element){
		clearTimeout(this.timer);
		this.timer = (function(){
			this.container.empty();
			var showTip = !this.options.hideEmpty;
			['title', 'text'].each(function(value){
				var content = element.retrieve('tip:' + value);
				var div = this['_' + value + 'Element'] = new Element('div', {
					'class': 'tip-' + value
				}).inject(this.container);
				if (content){
					this.fill(div, content);
					showTip = true;
				}
			}, this);
			if (showTip){
				this.show(element);
			} else {
				this.hide(element);
			}
			this.position((this.options.fixed) ? {page: element.getPosition()} : event);
		}).delay(this.options.showDelay, this);
	},

	elementLeave: function(event, element){
		clearTimeout(this.timer);
		this.timer = this.hide.delay(this.options.hideDelay, this, element);
		this.fireForParent(event, element);
	},

	setTitle: function(title){
		if (this._titleElement){
			this._titleElement.empty();
			this.fill(this._titleElement, title);
		}
		return this;
	},

	setText: function(text){
		if (this._textElement){
			this._textElement.empty();
			this.fill(this._textElement, text);
		}
		return this;
	},

	fireForParent: function(event, element){
		element = element.getParent();
		if (!element || element == document.body) return;
		if (element.retrieve('tip:enter')) element.fireEvent('mouseenter', event);
		else this.fireForParent(event, element);
	},

	elementMove: function(event, element){
		this.position(event);
	},

	position: function(event){
		if (!this.tip) document.id(this);

		var size = window.getSize(), scroll = window.getScroll(),
			tip = {x: this.tip.offsetWidth, y: this.tip.offsetHeight},
			props = {x: 'left', y: 'top'},
			bounds = {y: false, x2: false, y2: false, x: false},
			obj = {};

		for (var z in props){
			obj[props[z]] = event.page[z] + this.options.offset[z];
			if (obj[props[z]] < 0) bounds[z] = true;
			if ((obj[props[z]] + tip[z] - scroll[z]) > size[z] - this.options.windowPadding[z]){
				obj[props[z]] = event.page[z] - this.options.offset[z] - tip[z];
				bounds[z+'2'] = true;
			}
		}

		this.fireEvent('bound', bounds);
		this.tip.setStyles(obj);
	},

	fill: function(element, contents){
		if (typeof contents == 'string') element.set('html', contents);
		else element.adopt(contents);
	},

	show: function(element){
		if (!this.tip) document.id(this);
		if (!this.tip.getParent()) this.tip.inject(document.body);
		this.fireEvent('show', [this.tip, element]);
	},

	hide: function(element){
		if (!this.tip) document.id(this);
		this.fireEvent('hide', [this.tip, element]);
	}

});

})();

/*
---

script: Request.JSONP.js

name: Request.JSONP

description: Defines Request.JSONP, a class for cross domain javascript via script injection.

license: MIT-style license

authors:
  - Aaron Newton
  - Guillermo Rauch
  - Arian Stolwijk

requires:
  - Core/Element
  - Core/Request
  - MooTools.More

provides: [Request.JSONP]

...
*/

Request.JSONP = new Class({

	Implements: [Chain, Events, Options],

	options: {/*
		onRequest: function(src, scriptElement){},
		onComplete: function(data){},
		onSuccess: function(data){},
		onCancel: function(){},
		onTimeout: function(){},
		onError: function(){}, */
		onRequest: function(src){
			if (this.options.log && window.console && console.log){
				console.log('JSONP retrieving script with url:' + src);
			}
		},
		onError: function(src){
			if (this.options.log && window.console && console.warn){
				console.warn('JSONP '+ src +' will fail in Internet Explorer, which enforces a 2083 bytes length limit on URIs');
			}
		},
		url: '',
		callbackKey: 'callback',
		injectScript: document.head,
		data: '',
		link: 'ignore',
		timeout: 0,
		log: false
	},

	initialize: function(options){
		this.setOptions(options);
	},

	send: function(options){
		if (!Request.prototype.check.call(this, options)) return this;
		this.running = true;

		var type = typeOf(options);
		if (type == 'string' || type == 'element') options = {data: options};
		options = Object.merge(this.options, options || {});

		var data = options.data;
		switch (typeOf(data)){
			case 'element': data = document.id(data).toQueryString(); break;
			case 'object': case 'hash': data = Object.toQueryString(data);
		}

		var index = this.index = Request.JSONP.counter++,
			key = 'request_' + index;

		var src = options.url +
			(options.url.test('\\?') ? '&' :'?') +
			(options.callbackKey) +
			'=Request.JSONP.request_map.request_'+ index +
			(data ? '&' + data : '');

		if (src.length > 2083) this.fireEvent('error', src);

		Request.JSONP.request_map[key] = function(){
			delete Request.JSONP.request_map[key];
			this.success(arguments, index);
		}.bind(this);

		var script = this.getScript(src).inject(options.injectScript);
		this.fireEvent('request', [src, script]);

		if (options.timeout) this.timeout.delay(options.timeout, this);

		return this;
	},

	getScript: function(src){
		if (!this.script) this.script = new Element('script', {
			type: 'text/javascript',
			async: true,
			src: src
		});
		return this.script;
	},

	success: function(args){
		if (!this.running) return;
		this.clear()
			.fireEvent('complete', args).fireEvent('success', args)
			.callChain();
	},

	cancel: function(){
		if (this.running) this.clear().fireEvent('cancel');
		return this;
	},

	isRunning: function(){
		return !!this.running;
	},

	clear: function(){
		this.running = false;
		if (this.script){
			this.script.destroy();
			this.script = null;
		}
		return this;
	},

	timeout: function(){
		if (this.running){
			this.running = false;
			this.fireEvent('timeout', [this.script.get('src'), this.script]).fireEvent('failure').cancel();
		}
		return this;
	}

});

Request.JSONP.counter = 0;
Request.JSONP.request_map = {};

/*
---

script: Array.Extras.js

name: Array.Extras

description: Extends the Array native object to include useful methods to work with arrays.

license: MIT-style license

authors:
  - Christoph Pojer
  - Sebastian Markbåge

requires:
  - Core/Array
  - MooTools.More

provides: [Array.Extras]

...
*/

(function(nil){

Array.implement({

	min: function(){
		return Math.min.apply(null, this);
	},

	max: function(){
		return Math.max.apply(null, this);
	},

	average: function(){
		return this.length ? this.sum() / this.length : 0;
	},

	sum: function(){
		var result = 0, l = this.length;
		if (l){
			while (l--){
				if (this[l] != null) result += parseFloat(this[l]);
			}
		}
		return result;
	},

	unique: function(){
		return [].combine(this);
	},

	shuffle: function(){
		for (var i = this.length; i && --i;){
			var temp = this[i], r = Math.floor(Math.random() * ( i + 1 ));
			this[i] = this[r];
			this[r] = temp;
		}
		return this;
	},

	reduce: function(fn, value){
		for (var i = 0, l = this.length; i < l; i++){
			if (i in this) value = value === nil ? this[i] : fn.call(null, value, this[i], i, this);
		}
		return value;
	},

	reduceRight: function(fn, value){
		var i = this.length;
		while (i--){
			if (i in this) value = value === nil ? this[i] : fn.call(null, value, this[i], i, this);
		}
		return value;
	},

	pluck: function(prop){
		return this.map(function(item){
			return item[prop];
		});
	}

});

})();

/*
---

script: Locale.js

name: Locale

description: Provides methods for localization.

license: MIT-style license

authors:
  - Aaron Newton
  - Arian Stolwijk

requires:
  - Core/Events
  - Object.Extras
  - MooTools.More

provides: [Locale, Lang]

...
*/

(function(){

var current = null,
	locales = {},
	inherits = {};

var getSet = function(set){
	if (instanceOf(set, Locale.Set)) return set;
	else return locales[set];
};

var Locale = this.Locale = {

	define: function(locale, set, key, value){
		var name;
		if (instanceOf(locale, Locale.Set)){
			name = locale.name;
			if (name) locales[name] = locale;
		} else {
			name = locale;
			if (!locales[name]) locales[name] = new Locale.Set(name);
			locale = locales[name];
		}

		if (set) locale.define(set, key, value);

		

		if (!current) current = locale;

		return locale;
	},

	use: function(locale){
		locale = getSet(locale);

		if (locale){
			current = locale;

			this.fireEvent('change', locale);

			
		}

		return this;
	},

	getCurrent: function(){
		return current;
	},

	get: function(key, args){
		return (current) ? current.get(key, args) : '';
	},

	inherit: function(locale, inherits, set){
		locale = getSet(locale);

		if (locale) locale.inherit(inherits, set);
		return this;
	},

	list: function(){
		return Object.keys(locales);
	}

};

Object.append(Locale, new Events);

Locale.Set = new Class({

	sets: {},

	inherits: {
		locales: [],
		sets: {}
	},

	initialize: function(name){
		this.name = name || '';
	},

	define: function(set, key, value){
		var defineData = this.sets[set];
		if (!defineData) defineData = {};

		if (key){
			if (typeOf(key) == 'object') defineData = Object.merge(defineData, key);
			else defineData[key] = value;
		}
		this.sets[set] = defineData;

		return this;
	},

	get: function(key, args, _base){
		var value = Object.getFromPath(this.sets, key);
		if (value != null){
			var type = typeOf(value);
			if (type == 'function') value = value.apply(null, Array.convert(args));
			else if (type == 'object') value = Object.clone(value);
			return value;
		}

		// get value of inherited locales
		var index = key.indexOf('.'),
			set = index < 0 ? key : key.substr(0, index),
			names = (this.inherits.sets[set] || []).combine(this.inherits.locales).include('en-US');
		if (!_base) _base = [];

		for (var i = 0, l = names.length; i < l; i++){
			if (_base.contains(names[i])) continue;
			_base.include(names[i]);

			var locale = locales[names[i]];
			if (!locale) continue;

			value = locale.get(key, args, _base);
			if (value != null) return value;
		}

		return '';
	},

	inherit: function(names, set){
		names = Array.convert(names);

		if (set && !this.inherits.sets[set]) this.inherits.sets[set] = [];

		var l = names.length;
		while (l--) (set ? this.inherits.sets[set] : this.inherits.locales).unshift(names[l]);

		return this;
	}

});



})();

/*
---

name: Locale.en-US.Date

description: Date messages for US English.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Locale

provides: [Locale.en-US.Date]

...
*/

Locale.define('en-US', 'Date', {

	months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
	months_abbr: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
	days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
	days_abbr: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],

	// Culture's date order: MM/DD/YYYY
	dateOrder: ['month', 'date', 'year'],
	shortDate: '%m/%d/%Y',
	shortTime: '%I:%M%p',
	AM: 'AM',
	PM: 'PM',
	firstDayOfWeek: 0,

	// Date.Extras
	ordinal: function(dayOfMonth){
		// 1st, 2nd, 3rd, etc.
		return (dayOfMonth > 3 && dayOfMonth < 21) ? 'th' : ['th', 'st', 'nd', 'rd', 'th'][Math.min(dayOfMonth % 10, 4)];
	},

	lessThanMinuteAgo: 'less than a minute ago',
	minuteAgo: 'about a minute ago',
	minutesAgo: '{delta} minutes ago',
	hourAgo: 'about an hour ago',
	hoursAgo: 'about {delta} hours ago',
	dayAgo: '1 day ago',
	daysAgo: '{delta} days ago',
	weekAgo: '1 week ago',
	weeksAgo: '{delta} weeks ago',
	monthAgo: '1 month ago',
	monthsAgo: '{delta} months ago',
	yearAgo: '1 year ago',
	yearsAgo: '{delta} years ago',

	lessThanMinuteUntil: 'less than a minute from now',
	minuteUntil: 'about a minute from now',
	minutesUntil: '{delta} minutes from now',
	hourUntil: 'about an hour from now',
	hoursUntil: 'about {delta} hours from now',
	dayUntil: '1 day from now',
	daysUntil: '{delta} days from now',
	weekUntil: '1 week from now',
	weeksUntil: '{delta} weeks from now',
	monthUntil: '1 month from now',
	monthsUntil: '{delta} months from now',
	yearUntil: '1 year from now',
	yearsUntil: '{delta} years from now'

});

/*
---

script: Date.js

name: Date

description: Extends the Date native object to include methods useful in managing dates.

license: MIT-style license

authors:
  - Aaron Newton
  - Nicholas Barthelemy - https://svn.nbarthelemy.com/date-js/
  - Harald Kirshner - mail [at] digitarald.de; http://digitarald.de
  - Scott Kyle - scott [at] appden.com; http://appden.com

requires:
  - Core/Array
  - Core/String
  - Core/Number
  - MooTools.More
  - Locale
  - Locale.en-US.Date

provides: [Date]

...
*/

(function(){

var Date = this.Date;

var DateMethods = Date.Methods = {
	ms: 'Milliseconds',
	year: 'FullYear',
	min: 'Minutes',
	mo: 'Month',
	sec: 'Seconds',
	hr: 'Hours'
};

[
	'Date', 'Day', 'FullYear', 'Hours', 'Milliseconds', 'Minutes', 'Month', 'Seconds', 'Time', 'TimezoneOffset',
	'Week', 'Timezone', 'GMTOffset', 'DayOfYear', 'LastMonth', 'LastDayOfMonth', 'UTCDate', 'UTCDay', 'UTCFullYear',
	'AMPM', 'Ordinal', 'UTCHours', 'UTCMilliseconds', 'UTCMinutes', 'UTCMonth', 'UTCSeconds', 'UTCMilliseconds'
].each(function(method){
	Date.Methods[method.toLowerCase()] = method;
});

var pad = function(n, digits, string){
	if (digits == 1) return n;
	return n < Math.pow(10, digits - 1) ? (string || '0') + pad(n, digits - 1, string) : n;
};

Date.implement({

	set: function(prop, value){
		prop = prop.toLowerCase();
		var method = DateMethods[prop] && 'set' + DateMethods[prop];
		if (method && this[method]) this[method](value);
		return this;
	}.overloadSetter(),

	get: function(prop){
		prop = prop.toLowerCase();
		var method = DateMethods[prop] && 'get' + DateMethods[prop];
		if (method && this[method]) return this[method]();
		return null;
	}.overloadGetter(),

	clone: function(){
		return new Date(this.get('time'));
	},

	increment: function(interval, times){
		interval = interval || 'day';
		times = times != null ? times : 1;

		switch (interval){
			case 'year':
				return this.increment('month', times * 12);
			case 'month':
				var d = this.get('date');
				this.set('date', 1).set('mo', this.get('mo') + times);
				return this.set('date', d.min(this.get('lastdayofmonth')));
			case 'week':
				return this.increment('day', times * 7);
			case 'day':
				return this.set('date', this.get('date') + times);
		}

		if (!Date.units[interval]) throw new Error(interval + ' is not a supported interval');

		return this.set('time', this.get('time') + times * Date.units[interval]());
	},

	decrement: function(interval, times){
		return this.increment(interval, -1 * (times != null ? times : 1));
	},

	isLeapYear: function(){
		return Date.isLeapYear(this.get('year'));
	},

	clearTime: function(){
		return this.set({hr: 0, min: 0, sec: 0, ms: 0});
	},

	diff: function(date, resolution){
		if (typeOf(date) == 'string') date = Date.parse(date);

		return ((date - this) / Date.units[resolution || 'day'](3, 3)).round(); // non-leap year, 30-day month
	},

	getLastDayOfMonth: function(){
		return Date.daysInMonth(this.get('mo'), this.get('year'));
	},

	getDayOfYear: function(){
		return (Date.UTC(this.get('year'), this.get('mo'), this.get('date') + 1)
			- Date.UTC(this.get('year'), 0, 1)) / Date.units.day();
	},

	setDay: function(day, firstDayOfWeek){
		if (firstDayOfWeek == null){
			firstDayOfWeek = Date.getMsg('firstDayOfWeek');
			if (firstDayOfWeek === '') firstDayOfWeek = 1;
		}

		day = (7 + Date.parseDay(day, true) - firstDayOfWeek) % 7;
		var currentDay = (7 + this.get('day') - firstDayOfWeek) % 7;

		return this.increment('day', day - currentDay);
	},

	getWeek: function(firstDayOfWeek){
		if (firstDayOfWeek == null){
			firstDayOfWeek = Date.getMsg('firstDayOfWeek');
			if (firstDayOfWeek === '') firstDayOfWeek = 1;
		}

		var date = this,
			dayOfWeek = (7 + date.get('day') - firstDayOfWeek) % 7,
			dividend = 0,
			firstDayOfYear;

		if (firstDayOfWeek == 1){
			// ISO-8601, week belongs to year that has the most days of the week (i.e. has the thursday of the week)
			var month = date.get('month'),
				startOfWeek = date.get('date') - dayOfWeek;

			if (month == 11 && startOfWeek > 28) return 1; // Week 1 of next year

			if (month == 0 && startOfWeek < -2){
				// Use a date from last year to determine the week
				date = new Date(date).decrement('day', dayOfWeek);
				dayOfWeek = 0;
			}

			firstDayOfYear = new Date(date.get('year'), 0, 1).get('day') || 7;
			if (firstDayOfYear > 4) dividend = -7; // First week of the year is not week 1
		} else {
			// In other cultures the first week of the year is always week 1 and the last week always 53 or 54.
			// Days in the same week can have a different weeknumber if the week spreads across two years.
			firstDayOfYear = new Date(date.get('year'), 0, 1).get('day');
		}

		dividend += date.get('dayofyear');
		dividend += 6 - dayOfWeek; // Add days so we calculate the current date's week as a full week
		dividend += (7 + firstDayOfYear - firstDayOfWeek) % 7; // Make up for first week of the year not being a full week

		return (dividend / 7);
	},

	getOrdinal: function(day){
		return Date.getMsg('ordinal', day || this.get('date'));
	},

	getTimezone: function(){
		return this.toString()
			.replace(/^.*? ([A-Z]{3}).[0-9]{4}.*$/, '$1')
			.replace(/^.*?\(([A-Z])[a-z]+ ([A-Z])[a-z]+ ([A-Z])[a-z]+\)$/, '$1$2$3');
	},

	getGMTOffset: function(){
		var off = this.get('timezoneOffset');
		return ((off > 0) ? '-' : '+') + pad((off.abs() / 60).floor(), 2) + pad(off % 60, 2);
	},

	setAMPM: function(ampm){
		ampm = ampm.toUpperCase();
		var hr = this.get('hr');
		if (hr > 11 && ampm == 'AM') return this.decrement('hour', 12);
		else if (hr < 12 && ampm == 'PM') return this.increment('hour', 12);
		return this;
	},

	getAMPM: function(){
		return (this.get('hr') < 12) ? 'AM' : 'PM';
	},

	parse: function(str){
		this.set('time', Date.parse(str));
		return this;
	},

	isValid: function(date){
		if (!date) date = this;
		return typeOf(date) == 'date' && !isNaN(date.valueOf());
	},

	format: function(format){
		if (!this.isValid()) return 'invalid date';

		if (!format) format = '%x %X';
		if (typeof format == 'string') format = formats[format.toLowerCase()] || format;
		if (typeof format == 'function') return format(this);

		var d = this;
		return format.replace(/%([a-z%])/gi,
			function($0, $1){
				switch ($1){
					case 'a': return Date.getMsg('days_abbr')[d.get('day')];
					case 'A': return Date.getMsg('days')[d.get('day')];
					case 'b': return Date.getMsg('months_abbr')[d.get('month')];
					case 'B': return Date.getMsg('months')[d.get('month')];
					case 'c': return d.format('%a %b %d %H:%M:%S %Y');
					case 'd': return pad(d.get('date'), 2);
					case 'e': return pad(d.get('date'), 2, ' ');
					case 'H': return pad(d.get('hr'), 2);
					case 'I': return pad((d.get('hr') % 12) || 12, 2);
					case 'j': return pad(d.get('dayofyear'), 3);
					case 'k': return pad(d.get('hr'), 2, ' ');
					case 'l': return pad((d.get('hr') % 12) || 12, 2, ' ');
					case 'L': return pad(d.get('ms'), 3);
					case 'm': return pad((d.get('mo') + 1), 2);
					case 'M': return pad(d.get('min'), 2);
					case 'o': return d.get('ordinal');
					case 'p': return Date.getMsg(d.get('ampm'));
					case 's': return Math.round(d / 1000);
					case 'S': return pad(d.get('seconds'), 2);
					case 'T': return d.format('%H:%M:%S');
					case 'U': return pad(d.get('week'), 2);
					case 'w': return d.get('day');
					case 'x': return d.format(Date.getMsg('shortDate'));
					case 'X': return d.format(Date.getMsg('shortTime'));
					case 'y': return d.get('year').toString().substr(2);
					case 'Y': return d.get('year');
					case 'z': return d.get('GMTOffset');
					case 'Z': return d.get('Timezone');
				}
				return $1;
			}
		);
	},

	toISOString: function(){
		return this.format('iso8601');
	}

}).alias({
	toJSON: 'toISOString',
	compare: 'diff',
	strftime: 'format'
});

// The day and month abbreviations are standardized, so we cannot use simply %a and %b because they will get localized
var rfcDayAbbr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
	rfcMonthAbbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

var formats = {
	db: '%Y-%m-%d %H:%M:%S',
	compact: '%Y%m%dT%H%M%S',
	'short': '%d %b %H:%M',
	'long': '%B %d, %Y %H:%M',
	rfc822: function(date){
		return rfcDayAbbr[date.get('day')] + date.format(', %d ') + rfcMonthAbbr[date.get('month')] + date.format(' %Y %H:%M:%S %Z');
	},
	rfc2822: function(date){
		return rfcDayAbbr[date.get('day')] + date.format(', %d ') + rfcMonthAbbr[date.get('month')] + date.format(' %Y %H:%M:%S %z');
	},
	iso8601: function(date){
		return (
			date.getUTCFullYear() + '-' +
			pad(date.getUTCMonth() + 1, 2) + '-' +
			pad(date.getUTCDate(), 2) + 'T' +
			pad(date.getUTCHours(), 2) + ':' +
			pad(date.getUTCMinutes(), 2) + ':' +
			pad(date.getUTCSeconds(), 2) + '.' +
			pad(date.getUTCMilliseconds(), 3) + 'Z'
		);
	}
};

var parsePatterns = [],
	nativeParse = Date.parse;

var parseWord = function(type, word, num){
	var ret = -1,
		translated = Date.getMsg(type + 's');
	switch (typeOf(word)){
		case 'object':
			ret = translated[word.get(type)];
			break;
		case 'number':
			ret = translated[word];
			if (!ret) throw new Error('Invalid ' + type + ' index: ' + word);
			break;
		case 'string':
			var match = translated.filter(function(name){
				return this.test(name);
			}, new RegExp('^' + word, 'i'));
			if (!match.length) throw new Error('Invalid ' + type + ' string');
			if (match.length > 1) throw new Error('Ambiguous ' + type);
			ret = match[0];
	}

	return (num) ? translated.indexOf(ret) : ret;
};

var startCentury = 1900,
	startYear = 70;

Date.extend({

	getMsg: function(key, args){
		return Locale.get('Date.' + key, args);
	},

	units: {
		ms: Function.convert(1),
		second: Function.convert(1000),
		minute: Function.convert(60000),
		hour: Function.convert(3600000),
		day: Function.convert(86400000),
		week: Function.convert(608400000),
		month: function(month, year){
			var d = new Date;
			return Date.daysInMonth(month != null ? month : d.get('mo'), year != null ? year : d.get('year')) * 86400000;
		},
		year: function(year){
			year = year || new Date().get('year');
			return Date.isLeapYear(year) ? 31622400000 : 31536000000;
		}
	},

	daysInMonth: function(month, year){
		return [31, Date.isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
	},

	isLeapYear: function(year){
		return ((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0);
	},

	parse: function(from){
		var t = typeOf(from);
		if (t == 'number') return new Date(from);
		if (t != 'string') return from;
		from = from.clean();
		if (!from.length) return null;

		var parsed;
		parsePatterns.some(function(pattern){
			var bits = pattern.re.exec(from);
			return (bits) ? (parsed = pattern.handler(bits)) : false;
		});

		if (!(parsed && parsed.isValid())){
			parsed = new Date(nativeParse(from));
			if (!(parsed && parsed.isValid())) parsed = new Date(from.toInt());
		}
		return parsed;
	},

	parseDay: function(day, num){
		return parseWord('day', day, num);
	},

	parseMonth: function(month, num){
		return parseWord('month', month, num);
	},

	parseUTC: function(value){
		var localDate = new Date(value);
		var utcSeconds = Date.UTC(
			localDate.get('year'),
			localDate.get('mo'),
			localDate.get('date'),
			localDate.get('hr'),
			localDate.get('min'),
			localDate.get('sec'),
			localDate.get('ms')
		);
		return new Date(utcSeconds);
	},

	orderIndex: function(unit){
		return Date.getMsg('dateOrder').indexOf(unit) + 1;
	},

	defineFormat: function(name, format){
		formats[name] = format;
		return this;
	},

	

	defineParser: function(pattern){
		parsePatterns.push((pattern.re && pattern.handler) ? pattern : build(pattern));
		return this;
	},

	defineParsers: function(){
		Array.flatten(arguments).each(Date.defineParser);
		return this;
	},

	define2DigitYearStart: function(year){
		startYear = year % 100;
		startCentury = year - startYear;
		return this;
	}

}).extend({
	defineFormats: Date.defineFormat.overloadSetter()
});

var regexOf = function(type){
	return new RegExp('(?:' + Date.getMsg(type).map(function(name){
		return name.substr(0, 3);
	}).join('|') + ')[a-z]*');
};

var replacers = function(key){
	switch (key){
		case 'T':
			return '%H:%M:%S';
		case 'x': // iso8601 covers yyyy-mm-dd, so just check if month is first
			return ((Date.orderIndex('month') == 1) ? '%m[-./]%d' : '%d[-./]%m') + '([-./]%y)?';
		case 'X':
			return '%H([.:]%M)?([.:]%S([.:]%s)?)? ?%p? ?%z?';
	}
	return null;
};

var keys = {
	d: /[0-2]?[0-9]|3[01]/,
	H: /[01]?[0-9]|2[0-3]/,
	I: /0?[1-9]|1[0-2]/,
	M: /[0-5]?\d/,
	s: /\d+/,
	o: /[a-z]*/,
	p: /[ap]\.?m\.?/,
	y: /\d{2}|\d{4}/,
	Y: /\d{4}/,
	z: /Z|[+-]\d{2}(?::?\d{2})?/
};

keys.m = keys.I;
keys.S = keys.M;

var currentLanguage;

var recompile = function(language){
	currentLanguage = language;

	keys.a = keys.A = regexOf('days');
	keys.b = keys.B = regexOf('months');

	parsePatterns.each(function(pattern, i){
		if (pattern.format) parsePatterns[i] = build(pattern.format);
	});
};

var build = function(format){
	if (!currentLanguage) return {format: format};

	var parsed = [];
	var re = (format.source || format) // allow format to be regex
	.replace(/%([a-z])/gi,
		function($0, $1){
			return replacers($1) || $0;
		}
	).replace(/\((?!\?)/g, '(?:') // make all groups non-capturing
	.replace(/ (?!\?|\*)/g, ',? ') // be forgiving with spaces and commas
	.replace(/%([a-z%])/gi,
		function($0, $1){
			var p = keys[$1];
			if (!p) return $1;
			parsed.push($1);
			return '(' + p.source + ')';
		}
	).replace(/\[a-z\]/gi, '[a-z\\u00c0-\\uffff;\&]'); // handle unicode words

	return {
		format: format,
		re: new RegExp('^' + re + '$', 'i'),
		handler: function(bits){
			bits = bits.slice(1).associate(parsed);
			var date = new Date().clearTime(),
				year = bits.y || bits.Y;

			if (year != null) handle.call(date, 'y', year); // need to start in the right year
			if ('d' in bits) handle.call(date, 'd', 1);
			if ('m' in bits || bits.b || bits.B) handle.call(date, 'm', 1);

			for (var key in bits) handle.call(date, key, bits[key]);
			return date;
		}
	};
};

var handle = function(key, value){
	if (!value) return this;

	switch (key){
		case 'a': case 'A': return this.set('day', Date.parseDay(value, true));
		case 'b': case 'B': return this.set('mo', Date.parseMonth(value, true));
		case 'd': return this.set('date', value);
		case 'H': case 'I': return this.set('hr', value);
		case 'm': return this.set('mo', value - 1);
		case 'M': return this.set('min', value);
		case 'p': return this.set('ampm', value.replace(/\./g, ''));
		case 'S': return this.set('sec', value);
		case 's': return this.set('ms', ('0.' + value) * 1000);
		case 'w': return this.set('day', value);
		case 'Y': return this.set('year', value);
		case 'y':
			value = +value;
			if (value < 100) value += startCentury + (value < startYear ? 100 : 0);
			return this.set('year', value);
		case 'z':
			if (value == 'Z') value = '+00';
			var offset = value.match(/([+-])(\d{2}):?(\d{2})?/);
			offset = (offset[1] + '1') * (offset[2] * 60 + (+offset[3] || 0)) + this.getTimezoneOffset();
			return this.set('time', this - offset * 60000);
	}

	return this;
};

Date.defineParsers(
	'%Y([-./]%m([-./]%d((T| )%X)?)?)?', // "1999-12-31", "1999-12-31 11:59pm", "1999-12-31 23:59:59", ISO8601
	'%Y%m%d(T%H(%M%S?)?)?', // "19991231", "19991231T1159", compact
	'%x( %X)?', // "12/31", "12.31.99", "12-31-1999", "12/31/2008 11:59 PM"
	'%d%o( %b( %Y)?)?( %X)?', // "31st", "31st December", "31 Dec 1999", "31 Dec 1999 11:59pm"
	'%b( %d%o)?( %Y)?( %X)?', // Same as above with month and day switched
	'%Y %b( %d%o( %X)?)?', // Same as above with year coming first
	'%o %b %d %X %z %Y', // "Thu Oct 22 08:11:23 +0000 2009"
	'%T', // %H:%M:%S
	'%H:%M( ?%p)?' // "11:05pm", "11:05 am" and "11:05"
);

Locale.addEvent('change', function(language){
	if (Locale.get('Date')) recompile(language);
}).fireEvent('change', Locale.getCurrent());

})();

/*
---

script: Date.Extras.js

name: Date.Extras

description: Extends the Date native object to include extra methods (on top of those in Date.js).

license: MIT-style license

authors:
  - Aaron Newton
  - Scott Kyle

requires:
  - Date

provides: [Date.Extras]

...
*/

Date.implement({

	timeDiffInWords: function(to){
		return Date.distanceOfTimeInWords(this, to || new Date);
	},

	timeDiff: function(to, separator){
		if (to == null) to = new Date;
		var delta = ((to - this) / 1000).floor().abs();

		var vals = [],
			durations = [60, 60, 24, 365, 0],
			names = ['s', 'm', 'h', 'd', 'y'],
			value, duration;

		for (var item = 0; item < durations.length; item++){
			if (item && !delta) break;
			value = delta;
			if ((duration = durations[item])){
				value = (delta % duration);
				delta = (delta / duration).floor();
			}
			vals.unshift(value + (names[item] || ''));
		}

		return vals.join(separator || ':');
	}

}).extend({

	distanceOfTimeInWords: function(from, to){
		return Date.getTimePhrase(((to - from) / 1000).toInt());
	},

	getTimePhrase: function(delta){
		var suffix = (delta < 0) ? 'Until' : 'Ago';
		if (delta < 0) delta *= -1;

		var units = {
			minute: 60,
			hour: 60,
			day: 24,
			week: 7,
			month: 52 / 12,
			year: 12,
			eon: Infinity
		};

		var msg = 'lessThanMinute';

		for (var unit in units){
			var interval = units[unit];
			if (delta < 1.5 * interval){
				if (delta > 0.75 * interval) msg = unit;
				break;
			}
			delta /= interval;
			msg = unit + 's';
		}

		delta = delta.round();
		return Date.getMsg(msg + suffix, delta).substitute({delta: delta});
	}

}).defineParsers(

	{
		// "today", "tomorrow", "yesterday"
		re: /^(?:tod|tom|yes)/i,
		handler: function(bits){
			var d = new Date().clearTime();
			switch (bits[0]){
				case 'tom': return d.increment();
				case 'yes': return d.decrement();
				default: return d;
			}
		}
	},

	{
		// "next Wednesday", "last Thursday"
		re: /^(next|last) ([a-z]+)$/i,
		handler: function(bits){
			var d = new Date().clearTime();
			var day = d.getDay();
			var newDay = Date.parseDay(bits[2], true);
			var addDays = newDay - day;
			if (newDay <= day) addDays += 7;
			if (bits[1] == 'last') addDays -= 7;
			return d.set('date', d.getDate() + addDays);
		}
	}

).alias('timeAgoInWords', 'timeDiffInWords');

/*
---

name: Hash

description: Contains Hash Prototypes. Provides a means for overcoming the JavaScript practical impossibility of extending native Objects.

license: MIT-style license.

requires:
  - Core/Object
  - MooTools.More

provides: [Hash]

...
*/

(function(){

if (this.Hash) return;

var Hash = this.Hash = new Type('Hash', function(object){
	if (typeOf(object) == 'hash') object = Object.clone(object.getClean());
	for (var key in object) this[key] = object[key];
	return this;
});

this.$H = function(object){
	return new Hash(object);
};

Hash.implement({

	forEach: function(fn, bind){
		Object.forEach(this, fn, bind);
	},

	getClean: function(){
		var clean = {};
		for (var key in this){
			if (this.hasOwnProperty(key)) clean[key] = this[key];
		}
		return clean;
	},

	getLength: function(){
		var length = 0;
		for (var key in this){
			if (this.hasOwnProperty(key)) length++;
		}
		return length;
	}

});

Hash.alias('each', 'forEach');

Hash.implement({

	has: Object.prototype.hasOwnProperty,

	keyOf: function(value){
		return Object.keyOf(this, value);
	},

	hasValue: function(value){
		return Object.contains(this, value);
	},

	extend: function(properties){
		Hash.each(properties || {}, function(value, key){
			Hash.set(this, key, value);
		}, this);
		return this;
	},

	combine: function(properties){
		Hash.each(properties || {}, function(value, key){
			Hash.include(this, key, value);
		}, this);
		return this;
	},

	erase: function(key){
		if (this.hasOwnProperty(key)) delete this[key];
		return this;
	},

	get: function(key){
		return (this.hasOwnProperty(key)) ? this[key] : null;
	},

	set: function(key, value){
		if (!this[key] || this.hasOwnProperty(key)) this[key] = value;
		return this;
	},

	empty: function(){
		Hash.each(this, function(value, key){
			delete this[key];
		}, this);
		return this;
	},

	include: function(key, value){
		if (this[key] == undefined) this[key] = value;
		return this;
	},

	map: function(fn, bind){
		return new Hash(Object.map(this, fn, bind));
	},

	filter: function(fn, bind){
		return new Hash(Object.filter(this, fn, bind));
	},

	every: function(fn, bind){
		return Object.every(this, fn, bind);
	},

	some: function(fn, bind){
		return Object.some(this, fn, bind);
	},

	getKeys: function(){
		return Object.keys(this);
	},

	getValues: function(){
		return Object.values(this);
	},

	toQueryString: function(base){
		return Object.toQueryString(this, base);
	}

});

Hash.alias({indexOf: 'keyOf', contains: 'hasValue'});


})();


/*
---

script: Hash.Extras.js

name: Hash.Extras

description: Extends the Hash Type to include getFromPath which allows a path notation to child elements.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Hash
  - Object.Extras

provides: [Hash.Extras]

...
*/

Hash.implement({

	getFromPath: function(notation){
		return Object.getFromPath(this, notation);
	},

	cleanValues: function(method){
		return new Hash(Object.cleanValues(this, method));
	},

	run: function(){
		Object.run(arguments);
	}

});

/*
---

name: Locale.en-US.Number

description: Number messages for US English.

license: MIT-style license

authors:
  - Arian Stolwijk

requires:
  - Locale

provides: [Locale.en-US.Number]

...
*/

Locale.define('en-US', 'Number', {

	decimal: '.',
	group: ',',

/* 	Commented properties are the defaults for Number.format
	decimals: 0,
	precision: 0,
	scientific: null,

	prefix: null,
	suffic: null,

	// Negative/Currency/percentage will mixin Number
	negative: {
		prefix: '-'
	},*/

	currency: {
//		decimals: 2,
		prefix: '$ '
	}/*,

	percentage: {
		decimals: 2,
		suffix: '%'
	}*/

});



/*
---
name: Number.Format
description: Extends the Number Type object to include a number formatting method.
license: MIT-style license
authors: [Arian Stolwijk]
requires: [Core/Number, Locale.en-US.Number]
# Number.Extras is for compatibility
provides: [Number.Format, Number.Extras]
...
*/


Number.implement({

	format: function(options){
		// Thanks dojo and YUI for some inspiration
		var value = this;
		options = options ? Object.clone(options) : {};
		var getOption = function(key){
			if (options[key] != null) return options[key];
			return Locale.get('Number.' + key);
		};

		var negative = value < 0,
			decimal = getOption('decimal'),
			precision = getOption('precision'),
			group = getOption('group'),
			decimals = getOption('decimals');

		if (negative){
			var negativeLocale = getOption('negative') || {};
			if (negativeLocale.prefix == null && negativeLocale.suffix == null) negativeLocale.prefix = '-';
			['prefix', 'suffix'].each(function(key){
				if (negativeLocale[key]) options[key] = getOption(key) + negativeLocale[key];
			});

			value = -value;
		}

		var prefix = getOption('prefix'),
			suffix = getOption('suffix');

		if (decimals !== '' && decimals >= 0 && decimals <= 20) value = value.toFixed(decimals);
		if (precision >= 1 && precision <= 21) value = (+value).toPrecision(precision);

		value += '';
		var index;
		if (getOption('scientific') === false && value.indexOf('e') > -1){
			var match = value.split('e'),
				zeros = +match[1];
			value = match[0].replace('.', '');

			if (zeros < 0){
				zeros = -zeros - 1;
				index = match[0].indexOf('.');
				if (index > -1) zeros -= index - 1;
				while (zeros--) value = '0' + value;
				value = '0.' + value;
			} else {
				index = match[0].lastIndexOf('.');
				if (index > -1) zeros -= match[0].length - index - 1;
				while (zeros--) value += '0';
			}
		}

		if (decimal != '.') value = value.replace('.', decimal);

		if (group){
			index = value.lastIndexOf(decimal);
			index = (index > -1) ? index : value.length;
			var newOutput = value.substring(index),
				i = index;

			while (i--){
				if ((index - i - 1) % 3 == 0 && i != (index - 1)) newOutput = group + newOutput;
				newOutput = value.charAt(i) + newOutput;
			}

			value = newOutput;
		}

		if (prefix) value = prefix + value;
		if (suffix) value += suffix;

		return value;
	},

	formatCurrency: function(decimals){
		var locale = Locale.get('Number.currency') || {};
		if (locale.scientific == null) locale.scientific = false;
		locale.decimals = decimals != null ? decimals
			: (locale.decimals == null ? 2 : locale.decimals);

		return this.format(locale);
	},

	formatPercentage: function(decimals){
		var locale = Locale.get('Number.percentage') || {};
		if (locale.suffix == null) locale.suffix = '%';
		locale.decimals = decimals != null ? decimals
			: (locale.decimals == null ? 2 : locale.decimals);

		return this.format(locale);
	}

});

/*
---

script: URI.js

name: URI

description: Provides methods useful in managing the window location and uris.

license: MIT-style license

authors:
  - Sebastian Markbåge
  - Aaron Newton

requires:
  - Core/Object
  - Core/Class
  - Core/Class.Extras
  - Core/Element
  - String.QueryString

provides: [URI]

...
*/

(function(){

var toString = function(){
	return this.get('value');
};

var URI = this.URI = new Class({

	Implements: Options,

	options: {
		/*base: false*/
	},

	regex: /^(?:(\w+):)?(?:\/\/(?:(?:([^:@\/]*):?([^:@\/]*))?@)?(\[[A-Fa-f0-9:]+\]|[^:\/?#]*)(?::(\d*))?)?(\.\.?$|(?:[^?#\/]*\/)*)([^?#]*)(?:\?([^#]*))?(?:#(.*))?/,
	parts: ['scheme', 'user', 'password', 'host', 'port', 'directory', 'file', 'query', 'fragment'],
	schemes: {http: 80, https: 443, ftp: 21, rtsp: 554, mms: 1755, file: 0},

	initialize: function(uri, options){
		this.setOptions(options);
		var base = this.options.base || URI.base;
		if (!uri) uri = base;

		if (uri && uri.parsed) this.parsed = Object.clone(uri.parsed);
		else this.set('value', uri.href || uri.toString(), base ? new URI(base) : false);
	},

	parse: function(value, base){
		var bits = value.match(this.regex);
		if (!bits) return false;
		bits.shift();
		return this.merge(bits.associate(this.parts), base);
	},

	merge: function(bits, base){
		if ((!bits || !bits.scheme) && (!base || !base.scheme)) return false;
		if (base){
			this.parts.every(function(part){
				if (bits[part]) return false;
				bits[part] = base[part] || '';
				return true;
			});
		}
		bits.port = bits.port || this.schemes[bits.scheme.toLowerCase()];
		bits.directory = bits.directory ? this.parseDirectory(bits.directory, base ? base.directory : '') : '/';
		return bits;
	},

	parseDirectory: function(directory, baseDirectory){
		directory = (directory.substr(0, 1) == '/' ? '' : (baseDirectory || '/')) + directory;
		if (!directory.test(URI.regs.directoryDot)) return directory;
		var result = [];
		directory.replace(URI.regs.endSlash, '').split('/').each(function(dir){
			if (dir == '..' && result.length > 0) result.pop();
			else if (dir != '.') result.push(dir);
		});
		return result.join('/') + '/';
	},

	combine: function(bits){
		return bits.value || bits.scheme + '://' +
			(bits.user ? bits.user + (bits.password ? ':' + bits.password : '') + '@' : '') +
			(bits.host || '') + (bits.port && bits.port != this.schemes[bits.scheme] ? ':' + bits.port : '') +
			(bits.directory || '/') + (bits.file || '') +
			(bits.query ? '?' + bits.query : '') +
			(bits.fragment ? '#' + bits.fragment : '');
	},

	set: function(part, value, base){
		if (part == 'value'){
			var scheme = value.match(URI.regs.scheme);
			if (scheme) scheme = scheme[1];
			if (scheme && this.schemes[scheme.toLowerCase()] == null) this.parsed = { scheme: scheme, value: value };
			else this.parsed = this.parse(value, (base || this).parsed) || (scheme ? { scheme: scheme, value: value } : { value: value });
		} else if (part == 'data'){
			this.setData(value);
		} else {
			this.parsed[part] = value;
		}
		return this;
	},

	get: function(part, base){
		switch (part){
			case 'value': return this.combine(this.parsed, base ? base.parsed : false);
			case 'data' : return this.getData();
		}
		return this.parsed[part] || '';
	},

	go: function(){
		document.location.href = this.toString();
	},

	toURI: function(){
		return this;
	},

	getData: function(key, part){
		var qs = this.get(part || 'query');
		if (!(qs || qs === 0)) return key ? null : {};
		var obj = qs.parseQueryString();
		return key ? obj[key] : obj;
	},

	setData: function(values, merge, part){
		if (typeof values == 'string'){
			var data = this.getData();
			data[arguments[0]] = arguments[1];
			values = data;
		} else if (merge){
			values = Object.merge(this.getData(null, part), values);
		}
		return this.set(part || 'query', Object.toQueryString(values));
	},

	clearData: function(part){
		return this.set(part || 'query', '');
	},

	toString: toString,
	valueOf: toString

});

URI.regs = {
	endSlash: /\/$/,
	scheme: /^(\w+):/,
	directoryDot: /\.\/|\.$/
};

URI.base = new URI(Array.convert(document.getElements('base[href]', true)).getLast(), {base: document.location});

String.implement({

	toURI: function(options){
		return new URI(this, options);
	}

});

})();

/*
---

script: Class.Refactor.js

name: Class.Refactor

description: Extends a class onto itself with new property, preserving any items attached to the class's namespace.

license: MIT-style license

authors:
  - Aaron Newton

requires:
  - Core/Class
  - MooTools.More

# Some modules declare themselves dependent on Class.Refactor
provides: [Class.refactor, Class.Refactor]

...
*/

Class.refactor = function(original, refactors){

	Object.each(refactors, function(item, name){
		var origin = original.prototype[name];
		origin = (origin && origin.$origin) || origin || function(){};
		original.implement(name, (typeof item == 'function') ? function(){
			var old = this.previous;
			this.previous = origin;
			var value = item.apply(this, arguments);
			this.previous = old;
			return value;
		} : item);
	});

	return original;

};

/*
---

script: URI.Relative.js

name: URI.Relative

description: Extends the URI class to add methods for computing relative and absolute urls.

license: MIT-style license

authors:
  - Sebastian Markbåge


requires:
  - Class.refactor
  - URI

provides: [URI.Relative]

...
*/

URI = Class.refactor(URI, {

	combine: function(bits, base){
		if (!base || bits.scheme != base.scheme || bits.host != base.host || bits.port != base.port)
			return this.previous.apply(this, arguments);
		var end = bits.file + (bits.query ? '?' + bits.query : '') + (bits.fragment ? '#' + bits.fragment : '');

		if (!base.directory) return (bits.directory || (bits.file ? '' : './')) + end;

		var baseDir = base.directory.split('/'),
			relDir = bits.directory.split('/'),
			path = '',
			offset;

		var i = 0;
		for (offset = 0; offset < baseDir.length && offset < relDir.length && baseDir[offset] == relDir[offset]; offset++);
		for (i = 0; i < baseDir.length - offset - 1; i++) path += '../';
		for (i = offset; i < relDir.length - 1; i++) path += relDir[i] + '/';

		return (path || (bits.file ? '' : './')) + end;
	},

	toAbsolute: function(base){
		base = new URI(base);
		if (base) base.set('directory', '').set('file', '');
		return this.toRelative(base);
	},

	toRelative: function(base){
		return this.get('value', new URI(base));
	}

});

/*
---

script: Assets.js

name: Assets

description: Provides methods to dynamically load JavaScript, CSS, and Image files into the document.

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Element.Event
  - MooTools.More

provides: [Assets, Asset.javascript, Asset.css, Asset.image, Asset.images]

...
*/
;(function(){

var Asset = this.Asset = {

	javascript: function(source, properties){
		if (!properties) properties = {};

		var script = new Element('script', {src: source, type: 'text/javascript'}),
			doc = properties.document || document,
			load = properties.onload || properties.onLoad;

		delete properties.onload;
		delete properties.onLoad;
		delete properties.document;

		if (load){
			if (!script.addEventListener){
				script.addEvent('readystatechange', function(){
					if (['loaded', 'complete'].contains(this.readyState)) load.call(this);
				});
			} else {
				script.addEvent('load', load);
			}
		}

		return script.set(properties).inject(doc.head);
	},

	css: function(source, properties){
		if (!properties) properties = {};

		var load = properties.onload || properties.onLoad,
			doc = properties.document || document,
			timeout = properties.timeout || 3000;

		['onload', 'onLoad', 'document'].each(function(prop){
			delete properties[prop];
		});

		var link = new Element('link', {
			type: 'text/css',
			rel: 'stylesheet',
			media: 'screen',
			href: source
		}).setProperties(properties).inject(doc.head);

		if (load){
			// based on article at http://www.yearofmoo.com/2011/03/cross-browser-stylesheet-preloading.html
			var loaded = false, retries = 0;
			var check = function(){
				var stylesheets = document.styleSheets;
				for (var i = 0; i < stylesheets.length; i++){
					var file = stylesheets[i];
					var owner = file.ownerNode ? file.ownerNode : file.owningElement;
					if (owner && owner == link){
						loaded = true;
						return load.call(link);
					}
				}
				retries++;
				if (!loaded && retries < timeout / 50) return setTimeout(check, 50);
			};
			setTimeout(check, 0);
		}
		return link;
	},

	image: function(source, properties){
		if (!properties) properties = {};

		var image = new Image(),
			element = document.id(image) || new Element('img');

		['load', 'abort', 'error'].each(function(name){
			var type = 'on' + name,
				cap = 'on' + name.capitalize(),
				event = properties[type] || properties[cap] || function(){};

			delete properties[cap];
			delete properties[type];

			image[type] = function(){
				if (!image) return;
				if (!element.parentNode){
					element.width = image.width;
					element.height = image.height;
				}
				image = image.onload = image.onabort = image.onerror = null;
				event.delay(1, element, element);
				element.fireEvent(name, element, 1);
			};
		});

		image.src = element.src = source;
		if (image && image.complete) image.onload.delay(1);
		return element.set(properties);
	},

	images: function(sources, options){
		sources = Array.convert(sources);

		var fn = function(){},
			counter = 0;

		options = Object.merge({
			onComplete: fn,
			onProgress: fn,
			onError: fn,
			properties: {}
		}, options);

		return new Elements(sources.map(function(source, index){
			return Asset.image(source, Object.append(options.properties, {
				onload: function(){
					counter++;
					options.onProgress.call(this, counter, index, source);
					if (counter == sources.length) options.onComplete();
				},
				onerror: function(){
					counter++;
					options.onError.call(this, counter, index, source);
					if (counter == sources.length) options.onComplete();
				}
			}));
		}));
	}

};

})();

/*
---

script: Color.js

name: Color

description: Class for creating and manipulating colors in JavaScript. Supports HSB -> RGB Conversions and vice versa.

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Array
  - Core/String
  - Core/Number
  - Core/Hash
  - Core/Function
  - MooTools.More

provides: [Color]

...
*/

(function(){

var Color = this.Color = new Type('Color', function(color, type){
	if (arguments.length >= 3){
		type = 'rgb'; color = Array.slice(arguments, 0, 3);
	} else if (typeof color == 'string'){
		if (color.match(/rgb/)) color = color.rgbToHex().hexToRgb(true);
		else if (color.match(/hsb/)) color = color.hsbToRgb();
		else color = color.hexToRgb(true);
	}
	type = type || 'rgb';
	switch (type){
		case 'hsb':
			var old = color;
			color = color.hsbToRgb();
			color.hsb = old;
			break;
		case 'hex': color = color.hexToRgb(true); break;
	}
	color.rgb = color.slice(0, 3);
	color.hsb = color.hsb || color.rgbToHsb();
	color.hex = color.rgbToHex();
	return Object.append(color, this);
});

Color.implement({

	mix: function(){
		var colors = Array.slice(arguments);
		var alpha = (typeOf(colors.getLast()) == 'number') ? colors.pop() : 50;
		var rgb = this.slice();
		colors.each(function(color){
			color = new Color(color);
			for (var i = 0; i < 3; i++) rgb[i] = Math.round((rgb[i] / 100 * (100 - alpha)) + (color[i] / 100 * alpha));
		});
		return new Color(rgb, 'rgb');
	},

	invert: function(){
		return new Color(this.map(function(value){
			return 255 - value;
		}));
	},

	setHue: function(value){
		return new Color([value, this.hsb[1], this.hsb[2]], 'hsb');
	},

	setSaturation: function(percent){
		return new Color([this.hsb[0], percent, this.hsb[2]], 'hsb');
	},

	setBrightness: function(percent){
		return new Color([this.hsb[0], this.hsb[1], percent], 'hsb');
	}

});

this.$RGB = function(r, g, b){
	return new Color([r, g, b], 'rgb');
};

this.$HSB = function(h, s, b){
	return new Color([h, s, b], 'hsb');
};

this.$HEX = function(hex){
	return new Color(hex, 'hex');
};

Array.implement({

	rgbToHsb: function(){
		var red = this[0],
			green = this[1],
			blue = this[2],
			hue = 0,
			max = Math.max(red, green, blue),
			min = Math.min(red, green, blue),
			delta = max - min,
			brightness = max / 255,
			saturation = (max != 0) ? delta / max : 0;

		if (saturation != 0){
			var rr = (max - red) / delta;
			var gr = (max - green) / delta;
			var br = (max - blue) / delta;
			if (red == max) hue = br - gr;
			else if (green == max) hue = 2 + rr - br;
			else hue = 4 + gr - rr;
			hue /= 6;
			if (hue < 0) hue++;
		}
		return [Math.round(hue * 360), Math.round(saturation * 100), Math.round(brightness * 100)];
	},

	hsbToRgb: function(){
		var br = Math.round(this[2] / 100 * 255);
		if (this[1] == 0){
			return [br, br, br];
		} else {
			var hue = this[0] % 360;
			var f = hue % 60;
			var p = Math.round((this[2] * (100 - this[1])) / 10000 * 255);
			var q = Math.round((this[2] * (6000 - this[1] * f)) / 600000 * 255);
			var t = Math.round((this[2] * (6000 - this[1] * (60 - f))) / 600000 * 255);
			switch (Math.floor(hue / 60)){
				case 0: return [br, t, p];
				case 1: return [q, br, p];
				case 2: return [p, br, t];
				case 3: return [p, q, br];
				case 4: return [t, p, br];
				case 5: return [br, p, q];
			}
		}
		return false;
	}

});

String.implement({

	rgbToHsb: function(){
		var rgb = this.match(/\d{1,3}/g);
		return (rgb) ? rgb.rgbToHsb() : null;
	},

	hsbToRgb: function(){
		var hsb = this.match(/\d{1,3}/g);
		return (hsb) ? hsb.hsbToRgb() : null;
	}

});

})();


/*
---

script: Group.js

name: Group

description: Class for monitoring collections of events

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Events
  - MooTools.More

provides: [Group]

...
*/

(function(){

var Group = this.Group = new Class({

	initialize: function(){
		this.instances = Array.flatten(arguments);
	},

	addEvent: function(type, fn){
		var instances = this.instances,
			len = instances.length,
			togo = len,
			args = new Array(len),
			self = this;

		instances.each(function(instance, i){
			instance.addEvent(type, function(){
				if (!args[i]) togo--;
				args[i] = arguments;
				if (!togo){
					fn.call(self, instances, instance, args);
					togo = len;
					args = new Array(len);
				}
			});
		});
	}

});

})();

/*
---

script: Hash.Cookie.js

name: Hash.Cookie

description: Class for creating, reading, and deleting Cookies in JSON format.

license: MIT-style license

authors:
  - Valerio Proietti
  - Aaron Newton

requires:
  - Core/Cookie
  - Core/JSON
  - MooTools.More
  - Hash

provides: [Hash.Cookie]

...
*/

Hash.Cookie = new Class({

	Extends: Cookie,

	options: {
		autoSave: true
	},

	initialize: function(name, options){
		//this.parent(name, options);
		Cookie.prototype.initialize.apply(this,[name, options]);
		this.load();
	},

	save: function(){
		var value = JSON.encode(this.hash);
		if (!value || value.length > 4096) return false; //cookie would be truncated!
		if (value == '{}') this.dispose();
		else this.write(value);
		return true;
	},

	load: function(){
		this.hash = new Hash(JSON.decode(this.read(), true));
		return this;
	}

});

Hash.each(Hash.prototype, function(method, name){
	if (typeof method == 'function') Hash.Cookie.implement(name, function(){
		var value = method.apply(this.hash, arguments);
		if (this.options.autoSave) this.save();
		return value;
	});
});

/*
---

name: Swiff

description: Wrapper for embedding SWF movies. Supports External Interface Communication.

license: MIT-style license.

credits:
  - Flash detection & Internet Explorer + Flash Player 9 fix inspired by SWFObject.

requires: [Core/Options, Core/Object, Core/Element]

provides: Swiff

...
*/

(function(){

var Swiff = this.Swiff = new Class({

	Implements: Options,

	options: {
		id: null,
		height: 1,
		width: 1,
		container: null,
		properties: {},
		params: {
			quality: 'high',
			allowScriptAccess: 'always',
			wMode: 'window',
			swLiveConnect: true
		},
		callBacks: {},
		vars: {}
	},

	toElement: function(){
		return this.object;
	},

	initialize: function(path, options){
		this.instance = 'Swiff_' + String.uniqueID();

		this.setOptions(options);
		options = this.options;
		var id = this.id = options.id || this.instance;
		var container = document.id(options.container);

		Swiff.CallBacks[this.instance] = {};

		var params = options.params, vars = options.vars, callBacks = options.callBacks;
		var properties = Object.append({height: options.height, width: options.width}, options.properties);

		var self = this;

		for (var callBack in callBacks){
			Swiff.CallBacks[this.instance][callBack] = (function(option){
				return function(){
					return option.apply(self.object, arguments);
				};
			})(callBacks[callBack]);
			vars[callBack] = 'Swiff.CallBacks.' + this.instance + '.' + callBack;
		}

		params.flashVars = Object.toQueryString(vars);
		if ('ActiveXObject' in window){
			properties.classid = 'clsid:D27CDB6E-AE6D-11cf-96B8-444553540000';
			params.movie = path;
		} else {
			properties.type = 'application/x-shockwave-flash';
		}
		properties.data = path;

		var build = '<object id="' + id + '"';
		for (var property in properties) build += ' ' + property + '="' + properties[property] + '"';
		build += '>';
		for (var param in params){
			if (params[param]) build += '<param name="' + param + '" value="' + params[param] + '" />';
		}
		build += '</object>';
		this.object = ((container) ? container.empty() : new Element('div')).set('html', build).firstChild;
	},

	replaces: function(element){
		element = document.id(element, true);
		element.parentNode.replaceChild(this.toElement(), element);
		return this;
	},

	inject: function(element){
		document.id(element, true).appendChild(this.toElement());
		return this;
	},

	remote: function(){
		return Swiff.remote.apply(Swiff, [this.toElement()].append(arguments));
	}

});

Swiff.CallBacks = {};

Swiff.remote = function(obj, fn){
	var rs = obj.CallFunction('<invoke name="' + fn + '" returntype="javascript">' + __flash__argumentsToXML(arguments, 2) + '</invoke>');
	return eval(rs);
};

/*
---

script: Fx.Elements.js

name: Fx.Elements

description: Effect to change any number of CSS properties of any number of Elements.

license: MIT-style license

authors:
  - Valerio Proietti

requires:
  - Core/Fx.CSS
  - MooTools.More

provides: [Fx.Elements]

...
*/

Fx.Elements = new Class({

	Extends: Fx.CSS,

	initialize: function(elements, options){
		this.elements = this.subject = $$(elements);
		//this.parent(options);
		Fx.CSS.prototype.initialize.apply(this,[options]);
	},

	compute: function(from, to, delta){
		var now = {};

		for (var i in from){
			var iFrom = from[i], iTo = to[i], iNow = now[i] = {};
			//for (var p in iFrom) iNow[p] = this.parent(iFrom[p], iTo[p], delta);
			for (var p in iFrom) iNow[p] = Fx.CSS.prototype.compute.apply(this,[iFrom[p], iTo[p], delta]);
		}

		return now;
	},

	set: function(now){
		for (var i in now){
			if (!this.elements[i]) continue;

			var iNow = now[i];
			for (var p in iNow) this.render(this.elements[i], p, iNow[p], this.options.unit);
		}

		return this;
	},

	start: function(obj){
		if (!this.check(obj)) return this;
		var from = {}, to = {};

		for (var i in obj){
			if (!this.elements[i]) continue;

			var iProps = obj[i], iFrom = from[i] = {}, iTo = to[i] = {};

			for (var p in iProps){
				var parsed = this.prepare(this.elements[i], p, iProps[p]);
				iFrom[p] = parsed.from;
				iTo[p] = parsed.to;
			}
		}

		//return this.parent(from, to);
		return Fx.CSS.prototype.start.apply(this,[from, to]);
	}

});

})();
