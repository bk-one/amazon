define (require) ->
  AppView = require 'cs!views/app'
  Associates = require 'cs!collections/associates'
  AppData = require 'appdata'

  greencart =
    models: {}
    collections: {}
    views: {}

  StatusBar.styleLightContent();

  associates = new Associates()
  AppData.associates = associates

  appView = greencart.views.app = new AppView()
  appView.render()

  # Pull the associates from the index.html for now
  assocs = window.assocs || []
  associates.add assocs

  # pull up the curtain...
  navigator.splashscreen.hide()

  greencart
