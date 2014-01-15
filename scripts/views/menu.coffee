define (require) ->
  Backbone = require 'backbone'
  Hammer = require 'hammer'

  # Menu view
  # --------------

  class MenuView extends Backbone.View

    el: "#menu",

    initialize: ->
      Hammer(@el).on 'tap', @tap

    tap: (e) =>
      if e.target.className.indexOf('why') > -1
        window.open('http://blog.greencart.co/post/67258633679', '_system');
      else if e.target.className.indexOf('how') > -1
        window.open('http://greencart.co/wieviel', '_system');
      else if e.target.className.indexOf('share') > -1
        window.plugins.social.share('Shop consciously with Green Cart', 'http://greencart.co', 'www/images/icon@2X.png');
      else
        window.open('mailto:feedback@greencart.co');

    hide: ->
      @el.style['opacity'] = 0

    show: ->
      @el.style['opacity'] = 1

  MenuView