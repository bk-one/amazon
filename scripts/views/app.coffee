define (require) ->
  Backbone = require 'backbone'
  $.hammer = require 'jquery.hammer'

  AppData = require 'appdata'
  AssociateView = require 'cs!views/associate'
  transformUtils = require 'cs!views/transformUtils'

  class AppView extends Backbone.View
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#app"

    disableGestures: false

    initialize: ->
      @listenTo AppData.associates, "add", @addOne
      @associateViews = []

      # @$el.hammer().on 'swipeleft', @swipeFwd
      # @$el.hammer().on 'swiperight', @swipeBack
      @$el.hammer().on 'swipeup', @swipeUp
      @$el.hammer().on 'swipedown', @swipeDown

      @$el.hammer().on 'dragstart', @dragStart
      @$el.hammer().on 'dragleft dragright', @drag
      @$el.hammer().on 'dragend', @dragEnd

    addOne: (associate) ->
      view = new AssociateView(model: associate)

      @listenTo view, 'search', @openBrowser
      @listenTo view, 'keyboardactive', @disableDrag
      @listenTo view, 'keyboardinactive', =>
        @synchroniseSearchFields()
        @enableDrag()

      view.render()

      @associateViews.push view

      if @isCurrentView(view)
        view.addClass 'current'
      else if @isNextView(view)
        view.addClass 'next'
      else if @isPrevView(view)
        view.addClass 'prev'
      else
        view.addClass 'hidden'

      @$el.append view.el

    #
    # Browser opening stuff
    #

    openBrowser: (associateTag, searchTerm) ->
      url = 'http://www.amazon.de/gp/aw/s/?k='+searchTerm+'&tag='+associateTag
      @browser = window.open(url, '_blank', 'location=no,transitionstyle=fliphorizontal,closebuttoncaption=< Back to Greencart')
      @browser.addEventListener('loadstop', @insertGreencartGraphic)
      @browser.addEventListener('exit', @removeBrowserListeners)

    insertGreencartGraphic: =>
      @browser.insertCSS(
        code: """
        i.a-icon.a-nav-cart {
          -webkit-background-size: cover !important;
          background-image:url("http://www.adam-butler.com/images/amazon-greencart.png") !important;
          background-position: 0 0 !important;
        }
        """
      )

    removeBrowserListeners: =>
      @browser.removeEventListener('loadstop', @insertGreencartGraphic)
      @browser.removeEventListener('exit', @removeBrowserListeners)
      @browser = null

    synchroniseSearchFields: =>
      text = @getCurrentView().getSearchText()
      view.setSearchText(text) for view in @associateViews

    #
    # Associate view manipulation
    #

    getCurrentView: ->
      @currentView ?= @associateViews[0]

    getNextView: ->
      index = @associateViews.indexOf(@getCurrentView())
      if index < @associateViews.length-1 then @associateViews[index+1] else null

    getPrevView: ->
      index = @associateViews.indexOf(@getCurrentView())
      if index > 0 then @associateViews[index-1] else null

    isCurrentView: (view) ->
      view == @getCurrentView()

    isNextView: (view) ->
      @associateViews.indexOf(view) == @associateViews.indexOf(@getCurrentView()) + 1

    isPrevView: (view) ->
      @associateViews.indexOf(view) == @associateViews.indexOf(@getCurrentView()) - 1

    clearPrevView: =>
      @getPrevView()?.addClass('hidden').removeClass('prev')

    clearNextView: =>
      @getNextView()?.addClass('hidden').removeClass('next')

    setPrevView: (prevView) =>
      prevView = prevView ? @getPrevView()
      prevView?.removeClass('hidden').addClass('prev')

    setNextView: (nextView) =>
      nextView = nextView ? @getNextView()
      nextView?.removeClass('hidden').addClass('next')

    swipe: (fwd = true) ->
      return if @isDragging
      if fwd and @getNextView()
        @currentView.removeClass('current').addClass('prev')
        @getNextView()?.removeClass('next').addClass(
          'current'
          ->
            @clearPrevView()
            @currentView = @getNextView()
            @setNextView()
          this
        )

      else if not fwd and @getPrevView()
        @currentView.removeClass('current').addClass('next')
        @getPrevView()?.removeClass('prev').addClass(
          'current'
          ->
            @clearNextView()
            @currentView = @getPrevView()
            @setPrevView()
          this
        )
      this

    swipeFwd: =>
      @swipe(true)

    swipeBack: =>
      @swipe(false)

    swipeUp: =>
      unless @disableGestures
        @currentView.showDescription()

    swipeDown: =>
      unless @disableGestures
        @currentView.hideDescription()

    # dragging...

    disableDrag: () =>
      @disableGestures = true

    enableDrag: () =>
      @disableGestures = false

    dragStart: (e) =>
      if @disableGestures?
        return
      @isDragging = true

    drag: (e) =>
      unless @disableGestures
        delta = @getDelta(e)
        @translateViews(delta)

    dragEnd: (e) =>
      unless @disableGestures
        delta = @getDelta(e)
        if delta < -@getWidth() / 2
          @translateViews(-@getWidth(), true, @concludeFwdDrag)
        else if delta > @getWidth() / 2
          @translateViews(@getWidth(), true, @concludeDrag)
        else
          @translateViews(0, true)
        @isDragging = false


    concludeFwdDrag: =>
      @concludeDrag(true)

    concludeDrag: (fwd) =>
      if fwd
        @currentView.setTransition('none').removeClass('current').addClass('prev').clearTransform().clearTransition(true)
        @clearPrevView()?.setTransition('none').clearTransform().clearTransition(true)
        @currentView = @getNextView().setTransition('none').removeClass('next').addClass('current').clearTransform().clearTransition(true)
        @setNextView()
      else
        @currentView.setTransition('none').removeClass('current').addClass('next').clearTransform().clearTransition(true)
        @clearNextView()?.setTransition('none').clearTransform().clearTransition(true)
        @currentView = @getPrevView().setTransition('none').removeClass('prev').addClass('current').clearTransform().clearTransition(true)
        @setPrevView()

    getDelta: (event) ->
      delta = event.gesture.deltaX

      # can't go beyond first and last pages
      if (delta > 0 and @isFirst()) or (delta < 0 and @isLast())
        delta = delta / 3

      delta

    getWidth: () ->
        if not @width?
          @width = @$el.width()
        @width

    isFirst: ->
      return @getPrevView() is null

    isLast: ->
      return @getNextView() is null

    translateViews: (x, withTransition = false, callback = false) ->
      # transform = 'translate3d('+x+'px, 0, 0)'
      transform = 'translateX('+x+'px)'
      @getPrevView()?.setTransform(transform, withTransition)
      @getCurrentView().setTransform(transform, callback or withTransition)
      @getNextView()?.setTransform(transform, withTransition)

    clearTranslations: () ->
      @getPrevView()?.resetTransition()
      @getCurrentView().resetTransition()
      @getNextView()?.resetTransition()
      _.defer(->
        @getPrevView()?.clearCSS()
        @getCurrentView().clearCSS()
        @getNextView()?.clearCSS()
      )


  _.extend AppView.prototype, transformUtils
  AppView

