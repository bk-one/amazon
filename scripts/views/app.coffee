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

    addOne: (associate) ->
      view = new AssociateView(model: associate)
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

    clearPrevView: =>
      @getPrevView().addClass('hidden').removeClass('prev')

    clearNextView: =>
      @getNextView().addClass('hidden').removeClass('next')

    swipe: (isFwd = true) ->
      if isFwd and @getNextView()
        @currentView.removeClass('current').addClass('prev')
        @getNextView().removeClass('next').addClass('current', @clearPrevView, this)
        @currentView = @getNextView()
      else if not isFwd and @getPrevView()
        @currentView.removeClass('current').addClass('next')
        @getPrevView().removeClass('prev').addClass('current', @clearNextView, this)
        @currentView = @getPrevView()

    swipeFwd: =>
      @swipe(true)

    swipeBack: =>
      @swipe(false)

  _.extend AppView.prototype, transformUtils
  AppView

