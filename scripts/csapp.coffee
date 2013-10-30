define (require) ->
  AppView = require 'cs!views/app'
  Associates = require 'cs!collections/associates'
  AppData = require 'appdata'

  greencart =
    models: {}
    collections: {}
    views: {}

  associates = new Associates()
  AppData.associates = associates

  appView = greencart.views.app = new AppView()
  appView.render()

  # Pull the associates from the index.html for now
  assocs = window.assocs || []
  associates.add assocs

  greencart