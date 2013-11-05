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
                <h1><%= name %></h1>
                <form action="" id="amazon" class="amazon-form">
                  <input type="text" class="amazon-text" id="amazon-text" placeholder="What are you looking for?">
                  <input type="submit" class="amazon-submit" value="Go">
                </form>
                <div class="description-holder">
                  <div class="description"><%= description %></div>
                </div>
              </div>
            """

    initialize: ->
      @template = _.template(@templ)

    render: ->
      @$el.html @template(@model.toJSON())
      @$el.find('.bg-holder').css 'backgroundImage', 'url('+@model.get('backgroundURL')+')'
      @$searchField = @$el.find('.amazon-text')
      @$el.find('.amazon-form').on('submit', =>
        @trigger('search', @model.get('tag'), @$searchField.val()) if @$searchField.val().length > 0
        false
      )
      this

    showDescription: ->
      @$el.find('.blurred').css 'opacity', '1'
      @$el.find('.bg-holder').css 'top', '-10%'
      @$el.find('.description-holder').addClass('description-holder-visible')

    hideDescription: ->
      @$el.find('.blurred').css 'opacity', '0'
      @$el.find('.bg-holder').css 'top', '0'
      @$el.find('.description-holder').removeClass('description-holder-visible')

  _.extend AssociateView.prototype, transformUtils

  AssociateView