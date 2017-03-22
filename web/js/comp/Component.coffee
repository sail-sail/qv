exports.Component = new Class
  Implements: [Events,Options]
  options:
    #对应的控件
    ele: null
  initialize: (options) ->
    t = this
    t
  onDraw: ->
  #这个特殊的方法,有了这个方法之后,就可以这样获得对象中的元素$(obj)
  toElement: ->
    t = this
    ele = t.options.ele
    alert "ele must be element!" if typeOf(ele) isnt "element"
    ele
  alert: -> window.alert.apply window,arguments
  