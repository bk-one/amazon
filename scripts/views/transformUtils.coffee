define [], ->
  transformUtils =
    scale: 1
    transition: `undefined`
    isTransitionDisabled: false
    setScale: (scale, callback, context, args) ->
      @scale = scale
      @setTransform "scale3D(" + scale + "," + scale + ",1)", callback, context, args
      this

    setOpacity: (opacity, callback, context, args) ->
      if callback
        @doPostTransitionCallback callback, context, args
      @$el.css "opacity", opacity
      this

    getTransition: ->
      @transition = @$el.css("transition")  unless @transition
      @transition

    setTransition: (transition = '') ->
      unless @transition is transition
        @transition = transition
        @$el.css "transition", transition
      this

    resetTransition: ->
      @setTransition ""
      this

    clearTransition: (delay = false) ->
      that = this
      if delay
        # magic number, boo
        _.delay((-> that.setTransition ""), 10)
      else
        @setTransition ""

      this

    clearCSS: ->
      @$el.removeAttr "style"
      this

    reset: ->
      @clearTransition()
      @clearTransform()
      @clearCSS()

    getTransform: ->
      @$el.css "-webkit-transform"


    # either callback is a post-transition callback function
    # or it's nothing
    # or it's a boolean false, meaning disable the transition
    setTransform: (transform, callback, context, args) ->
      transition = undefined
      if callback is false
        if @isTransitionDisabled is false
          @isTransitionDisabled = true
          @setTransition "none"
      else if callback is true
        if @isTransitionDisabled
          @isTransitionDisabled = false
          @resetTransition()
      else
        if @isTransitionDisabled
          @resetTransition()
          @isTransitionDisabled = false
        @doPostTransitionCallback callback, context, args
      @$el[0].style['-webkit-transform'] = transform
      this

    clearTransform: (callback, context, args) ->
      @setTransform "", callback, context, args

    addClass: (klass, callback, context, args) ->
      @doPostTransitionCallback callback, context, args
      @$el.addClass klass
      this

    removeClass: (klass, callback, context, args) ->
      @doPostTransitionCallback callback, context, args
      @$el.removeClass klass
      this

    toggleClass: (klass, callback, context, args) ->
      @doPostTransitionCallback callback, context, args
      @$el.toggleClass klass
      this

    doPostTransitionCallback: (callback, context, args) ->
      that = this
      if callback
        @$el.bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", ->
          that.$el.unbind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd"
          callback and callback.call(context, args)


  transformUtils
