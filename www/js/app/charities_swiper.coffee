class CharitiesSwiper
  constructor: (element) ->
    @element = document.getElementById(element)
    # @element = $("\##{element}")
    @charities = new Charities()
    @createCharities()
    @createSwiper()

  createCharities: ->
    for c in @charities.all()
      @elementForCharity(c).appendTo($(".swipe-wrap"))

  createSwiper: ->
    @swiper = new Swipe(@element,
      startSlide: 0
      speed: 400
      auto: 3000
      continuous: false
      disableScroll: true
      stopPropagation: false
      # callback: -> (index, elem) ...
      # transitionEnd: -> (index, elem) ...
    )

  elementForCharity: (c) ->
    $("<div><img src='res/#{c.image}'></div>")

