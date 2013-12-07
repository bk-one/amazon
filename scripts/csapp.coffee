define (require) ->
  AppView = require 'cs!views/app'
  Associates = require 'cs!collections/associates'
  AppData = require 'appdata'

  greencart =
    models: {}
    collections: {}
    views: {}

  StatusBar?.styleLightContent();

  associates = new Associates()
  AppData.associates = associates

  appView = greencart.views.app = new AppView()
  appView.render()

  # Pull the associates from the index.html for now
  assocs = window.assocs || []
  associates.add assocs

  # pull up the curtain...
  setTimeout(->
    navigator.splashscreen?.hide()
  , 200)

  # initialise Google Analytics
  # gaPlugin = window.plugins.gaPlugin;
  # gaPlugin.init(->
  #   AppData.ga = gaPlugin
  # , ->
  #   console.log 'fail'
  # , 'UA-45758341-1', 10);
  window.ga('create', 'UA-46256651-1', {
       'storage': 'none',
       'clientId': device.uuid
  })
  window.ga('send', 'pageview', {'page': 'index.html'})


  AppData.gaSuccess = ()->

  AppData.gaFailure = ()->

  greencart
