define (require) ->
  Backbone = require 'backbone'
  transformUtils = require 'cs!views/transformUtils'

  # Associate view
  # --------------

  class AssociateView extends Backbone.View

    tagName: "div"
    className: "associate"

    templ:  """
              <h1><%= name %></h1>
              <form action="" id="amazon" class="amazon-form">
                <input type="text" class="amazon-text" id="amazon-text" placeholder="What are you looking for?">
                <input type="submit" class="amazon-submit" value="Go">
              </form>
              <img src="<%= logoURL %>" class="logo">
            """

    initialize: ->
      @template = _.template(@templ)

    render: ->
      @$el.html @template(@model.toJSON())
      @$el.css 'backgroundImage', 'url('+@model.get('backgroundURL')+')'
      this

  _.extend AssociateView.prototype, transformUtils

  AssociateView