define (require) ->
  Backbone = require 'backbone'
  Hammer = require 'hammer'

  transformUtils = require 'cs!views/transformUtils'

  # Wizard view
  # --------------

  class WizardView extends Backbone.View

    el: "#wizard",

    pages: [
      {
        text: 'Swipe links und rechts, um eine Organisation auszuwählen, die du unterstützen möchtest',
        image: 'images/wizard-0.png',
      },
      {
        text: 'Swipe nach oben, um mehr über die Organisation zu erfahren',
        image: 'images/wizard-1.png',
      }
      {
        text: 'Gib ein Suchbegriff für das Produkt ein, das du erwerben willst. Wir leiten dich weiter zu Amazon',
        image: '',
      }
      {
        text: 'Wenn du genau wissen willst, wie wir die Spenden erhalten, öffne das Menu',
        image: 'images/wizard-3.png',
      }
    ],

    num: 0,

    initialize: ->
      @textEl = $(@el).find('#instructions')[0]
      @imageEl = $(@el).find('#direction')[0]
      @buttonEl = $(@el).find('button')[0]

      # tap_max_touchtime setting fixes Trello Card #59
      Hammer(@buttonEl, { tap_max_touchtime : 2000 }).on 'tap', @tap

      @setWizard(@num)
      @show()

    tap: (e) =>
      if @num < 3
        @num++
        @setWizard()
      else
        @hide()

    setWizard: () ->
      @textEl.textContent = @pages[@num]['text']
      @imageEl.src = @pages[@num]['image']
      $(@el).removeClass('wizard-'+(@num-1)) if @num > 0
      $(@el).addClass('wizard-'+(@num))
      $('.current .amazon-form').appendTo($('.wizard')) if @num is 2
      $('.wizard .amazon-form').appendTo($('.current')) if @num is 3

    hide: ->
      @setOpacity 0, () =>
        @el.style['display'] = 'none'

    show: ->
      @el.style['display'] = 'block'

  _.extend WizardView.prototype, transformUtils

  WizardView