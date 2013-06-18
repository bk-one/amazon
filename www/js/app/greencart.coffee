class Greencart
  constructor: ->
    @swiper = new Swipe(document.getElementById('slider'),
      startSlide: 0
      speed: 400
      auto: 3000
      continuous: false
      disableScroll: true
      stopPropagation: false
      # callback: -> (index, elem) ...
      # transitionEnd: -> (index, elem) ...
    )
