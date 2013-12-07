define (require) ->
  Backbone = require 'backbone'
  Hammer = require 'hammer'

  AppData = require 'appdata'
  AssociateView = require 'cs!views/associate'
  MenuView = require 'cs!views/menu'
  WizardView = require 'cs!views/wizard'
  transformUtils = require 'cs!views/transformUtils'

  class AppView extends Backbone.View
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#app"

    disableGestures: false

    initialize: ->
      @listenTo AppData.associates, "add", @addOne
      @associateViews = []

      @screenWidth = @el.getBoundingClientRect().width
      @menuView = new MenuView

      experienced = window.localStorage.getItem('green')
      unless experienced?
        @wizardView = new WizardView()
        window.localStorage.setItem('green', 'cart')

      @hammer = Hammer(@el, {drag_lock_to_axis: true})
      @hammer.on 'dragstart', @dragStart
      @hammer.on 'dragleft dragright', @drag
      @hammer.on 'dragup dragdown', @drag
      @hammer.on 'dragend', @dragEnd
      @hammer.on 'tap', @defocusInput

    addOne: (associate) ->
      view = new AssociateView(model: associate)

      @listenTo view, 'search', @openBrowser
      @listenTo view, 'keyboardactive', @disableDrag
      @listenTo view, 'keyboardinactive', =>
        @synchroniseSearchFields()
        @enableDrag()
      @listenTo view, 'showmenu', @toggleMenu

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

    openBrowser: (associate, searchTerm) ->
      # send to google analytics
      # AppData.ga.trackEvent(AppData.gaSuccess, AppData.gaFailure, 'Search', associate.get('name'), searchTerm, 1)
      window.ga('send', 'event', 'Search', associate.get('name'), searchTerm);
      url = 'http://www.amazon.de/gp/aw/s/?k='+searchTerm+'&tag='+associate.get('tag')
      @browser = window.open(url, '_blank', 'location=no,transitionstyle=fliphorizontal,closebuttoncaption=< '+associate.get('name'))

    synchroniseSearchFields: =>
      text = @getCurrentView().getSearchText()
      view.setSearchText(text) for view in @associateViews

    defocusInput: (e) ->

      if document.activeElement? and document.activeElement.type == 'text'
        unless e.target.tagName is 'BUTTON' or e.target.tagName is 'INPUT'
          $(document.activeElement).blur()
        return false
      else return true


    toggleMenu: =>
      if @menuVisible
        @closeMenu()
      else
        @openMenu()

    openMenu: ->
      unless @disableGestures
        @menuView.show()
        @setTransform('translate3d(60%,0,0)')
        # @el.addClass 'pointer-passthrough'
        @menuVisible = true
        @disableDrag()

    closeMenu: ->
      @setTransform('translate3d(0,0,0)', =>
        @menuView.hide()
      )
      # @el.removeClass 'pointer-passthrough'
      @menuVisible = false
      @enableDrag()

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
      return if @isXDragging
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
      if not @disableGestures
        if e.gesture.direction is 'up' or e.gesture.direction is 'down'
            @isYDragging = true
        else if @getCurrentView().descriptionVisible isnt true
          @isXDragging = true
          requestAnimationFrame @moveCarousel
      # else if @menuVisible
      #   if e.gesture.direction is 'left'
      #     @isXDragging = true

    drag: (e) =>
      if not @disableGestures
        if @isYDragging
          delta = e.gesture.deltaY
          @getCurrentView().showDescriptionIncremental(e.gesture.direction, delta)
          # @showDescription(delta)
        else if @isXDragging
          @xDelta = @getDelta(e)
          # @translateViews(delta)
      # else if @menuVisible and @isXDragging
      #   # 60 is the % a menu displaces the view
      #   delta = 60 + (event.gesture.deltaX / @getWidth() * 60)
      #   @setTransform('translate3d('+delta+'%,0,0)')

    moveCarousel: =>
      if @isXDragging
        @translateViews @xDelta
        requestAnimationFrame @moveCarousel

    dragEnd: (e) =>
      unless @disableGestures
        if @isYDragging
          direction = e.gesture.interimDirection
          if direction is 'up'
            @getCurrentView().openDescription()
          else
            @getCurrentView().closeDescription()
        else if @isXDragging
          delta = @getDelta(e)
          velocity = e.gesture.velocityX
          direction = e.gesture.interimDirection
          if (delta > 0 and @isFirst()) or (delta < 0 and @isLast())
            @translateViews(0, true)

          # if it was a swipe-like gesture, act on it
          else if velocity > 0.5
            if direction is 'left'
              @translateViews(-@getWidth(), true, @concludeFwdDrag)
            else
              @translateViews(@getWidth(), true, @concludeDrag)

          else if delta < -(@screenWidth / 2) and direction is 'left'
            @translateViews(-@getWidth(), true, @concludeFwdDrag)
          else if delta > (@screenWidth / 2) and direction is 'right'
            @translateViews(@getWidth(), true, @concludeDrag)
          else
            @translateViews(0, true)
        @isXDragging = false
        @isYDragging = false


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
      return @associateViews.indexOf(@currentView) == 0
      # return @getPrevView() is null

    isLast: ->
      return @associateViews.indexOf(@currentView) == @associateViews.length - 1
      # return @getNextView() is null

    translateViews: (x, withTransition = false, callback = false) ->
      transform = 'translate3d('+x+'px, 0, 0)'
      # transform = 'translateX('+x+'px)'
      @getPrevView()?.setTransform(transform, withTransition)
      @getCurrentView().setTransform(transform, callback or withTransition)
      @getNextView()?.setTransform(transform, withTransition)

    # showDescription: (delta) ->
    #   normalised = -delta / 300
    #   normalised = if normalised > 1 then 1 else normalised
    #   @getCurrentView().showDescriptionIncremental(normalised)

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

