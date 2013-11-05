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

    initialize: ->
      @listenTo AppData.associates, "add", @addOne
      @associateViews = []

      @$el.hammer().on 'swipeleft', @swipeFwd
      @$el.hammer().on 'swiperight', @swipeBack
      @$el.hammer().on 'swipeup', @swipeUp
      @$el.hammer().on 'swipedown', @swipeDown

    addOne: (associate) ->
      view = new AssociateView(model: associate)
      @listenTo view, 'search', @openBrowser
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

    #
    # Associate view manipulation
    #

    getCurrentView: ->
      @currentView ?= @associateViews[0]

    getNextView: ->
      index = @associateViews.indexOf(@getCurrentView())
      if index < @associateViews.length then @associateViews[index+1] else null

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
      @currentView.showDescription()

    swipeDown: =>
      @currentView.hideDescription()

  _.extend AppView.prototype, transformUtils
  AppView

