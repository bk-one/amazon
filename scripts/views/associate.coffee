define (require) ->
  Backbone = require 'backbone'
  transformUtils = require 'cs!views/transformUtils'

  # Associate view
  # --------------

  class AssociateView extends Backbone.View

    tagName: "div"
    className: "associate"

    templ:  """
              <div class="bg-holder blurred"></div>
              <div class="bg-holder"></div>
                <div class="blackout"></div>
                <button class="btn-menu-button icon ion-navicon"></button>
                <h1><%= name %></h1>
                <form action="" id="amazon" class="amazon-form">
                  <input type="text" class="amazon-text" id="amazon-text">
                  <button type="submit" class="amazon-submit">
                    <i class="icon ion-search"></i>
                  </button>
                </form>
                <div class="description-holder">
                  <button class="btn-description-button icon ion-ios7-arrow-up"></button>
                  <img src="<%= logoURL %>"class="logo">
                  <div class="description">
                    <%= description %>
                    <!--iframe width="560" height="315" src="http://www.youtube.com/embed/RLYZWB-p7WY" frameborder="0" allowfullscreen></iframe-->
                  </div>
                </div>
              </div>
            """
    keyboardActive = false

    initialize: ->
      @template = _.template(@templ)

    render: ->
      @$el.html @template(@model.toJSON())

      # cache some important elements
      @descriptionHolder = @el.getElementsByClassName('description-holder')[0]
      @bgBlurred = @el.getElementsByClassName('blurred')[0]
      @logo = @el.getElementsByClassName('logo')[0]
      @menuButton = @el.getElementsByClassName('btn-menu-button')[0]
      @$searchField = @$el.find('.amazon-text')

      @$el.find('.bg-holder').css 'backgroundImage', 'url('+@model.get('backgroundURL')+')'

      @$searchField.on 'focus', =>
        @keyboardActive = true
        @trigger 'keyboardactive'

      @$searchField.on 'blur', =>
        @keyboardActive = false
        @trigger 'keyboardinactive'

      @$el.find('.amazon-form').on 'submit', =>
        @trigger('search', @model, @$searchField.val()) if @$searchField.val().length > 0
        false


      Hammer(@logo).on 'tap', =>
        @toggleDescription() unless @keyboardActive

      Hammer(@menuButton).on 'tap', =>
        @trigger 'showmenu'

      window.setTimeout @checkHeadingHeight, 100

      this

    checkHeadingHeight: =>
      hidden = @$el.hasClass 'hidden'
      @$el.removeClass 'hidden'

      # magic number!
      # just checking whether heading is over 2 lines
      if @$el.find('h1').height() > 50
        $(@descriptionHolder).addClass('two-line-heading')
      @$el.addClass('hidden') if hidden


    # deprecated
    showDescription: ->
      @bgBlurred.style.opacity = '1'
      @descriptionHolder.style.top = 0

    getDescriptionHolderHeight: () ->
      if not @descriptionHolderHeight?
        @descriptionHolderHeight = $(@descriptionHolder).height()
      @descriptionHolderHeight

    getDescriptionHolderTranslation: () ->
      if not @windowHeight?
        @windowHeight = $(window).height()
      if not @headingHeight?
        @headingHeight = @$el.find('h1').height()
      statusBarHeight = 20
      margin = 8
      arrowButtonheight = 32
      @windowHeight - statusBarHeight - @headingHeight - margin - arrowButtonheight

    showDescriptionIncremental: (direction, delta) ->
      if direction is 'up'
        if @descriptionVisible is true
          return
        normalised = -delta / @getDescriptionHolderHeight()
      else if direction is 'down'
        if @descriptionVisible isnt true or @descriptionHolder.scrollTop > 0
          return
        normalised = 1 - (delta / @getDescriptionHolderHeight())
        $(@descriptionHolder).removeClass('scrollable')

      normalised = if normalised > 1 then 1 else normalised
      normalised = if normalised < 0 then 0 else normalised

      # opacity: 0 -> 1
      opacity = normalised
      @bgBlurred.style.opacity = normalised

      # # top: 0 -> -10%
      # top = -normalised*10
      # @$el.find('.bg-holder').css 'top', top+'%'

      # # top: 90% -> 0
      # transform = Math.round((1-normalised) * @getDescriptionHolderTranslation())
      transform = Math.round((1-normalised) * 70)
      @descriptionHolder.style['-webkit-transform'] = 'translate3d(0, '+transform+'%, 0)'

      @descriptionMoving = true

    toggleDescription: () =>
      if @descriptionVisible
        @closeDescription()
      else
        @openDescription()

    openDescription: () =>
      unless @descriptionMoving is true or @descriptionVisible isnt true
        return
      $(@descriptionHolder).addClass('animating')
      $(@descriptionHolder).addClass('visible')
      $(@descriptionHolder).addClass('scrollable')
      $(@bgBlurred).addClass('animating')
      $(@bgBlurred).addClass('visible')
      $('.btn-description-button').removeClass('ion-ios7-arrow-up').addClass('ion-ios7-arrow-down')
      @descriptionVisible = true
      @descriptionMoving = false

      window.setTimeout(=>
        @descriptionHolder.style['-webkit-transform'] = ''
        @bgBlurred.style['opacity'] = ''
      , 0)

    closeDescription: () =>
      unless @descriptionMoving is true or (@descriptionVisible is true and @descriptionHolder.scrollTop <= 0)
        return
      $(@descriptionHolder).css('-webkit-transform', '')
      $(@bgBlurred).css('opacity', '')

      $(@descriptionHolder).bind "transitionend webkitTransitionEnd", @postDescriptionAnimation

      $(@descriptionHolder).removeClass('visible')
      $(@bgBlurred).removeClass('visible')
      $('.btn-description-button').removeClass('ion-ios7-arrow-down').addClass('ion-ios7-arrow-up')
      @descriptionVisible = false
      @descriptionMoving = false

    postDescriptionAnimation: () =>
      $(@descriptionHolder).removeClass('animating')
      $(@bgBlurred).removeClass('animating')
      $(@descriptionHolder).removeClass('scrollable')
      $(@descriptionHolder).unbind "transitionend webkitTransitionEnd", @postDescriptionAnimation

    hideDescription: ->
      @$el.find('.blurred').css 'opacity', '0'
      @$el.find('.bg-holder').css 'top', '0'
      @$el.find('.description-holder').removeClass('description-holder-visible')

    getSearchText: ->
      return @$el.find('.amazon-text').val()

    setSearchText: (text) ->
      @$el.find('.amazon-text').val(text)

  _.extend AssociateView.prototype, transformUtils

  AssociateView