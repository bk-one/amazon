define (require) ->
  Backbone = require 'backbone'

  # Associate Model
  # ----------
  # Our basic **Associate** model has `name`, `backgroundURL`, `logoURL` and `description` attributes (for now).
  class Associate extends Backbone.Model

    defaults:
      name: "Associate name"
      backgroundURL: ""
      logoURL: ""
      shortDescription: "This is a short description"
      description: "Description goes here"
      tag: "amazon-tag"

    getLogoURL: ->
      @get('logoURL')