define (require) ->
  Backbone = require 'backbone'

  Associate = require 'cs!models/associate'


  # Associates Collection
  # ---------------
  class Associates extends Backbone.Collection
    # Reference to this collection's model.
    model: Associate
