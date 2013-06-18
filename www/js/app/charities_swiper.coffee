class CharitiesSwiper
  constructor: (element) ->
    @element = document.getElementById(element)
    # @element = $("\##{element}")
    @charities = new Charities()
    @create_charities()
    @create_swiper()

  create_charities: ->
    for c in @charities.all()
      alert c.name

  create_swiper: ->
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

