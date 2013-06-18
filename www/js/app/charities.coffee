class Charities
  constructor: ->
    @charities = []

    @charities.push key: 'dsoaijd', image: 'frog1.jpg', name: 'first'
    @charities.push key: 'dooaijd', image: 'frog2.jpg', name: 'second'
    @charities.push key: 'dooaijd', image: 'frog1.jpg', name: 'third'
    @charities.push key: 'dooaiji', image: 'frog2.jpg', name: 'fourth'
    @charities.push key: 'dooaiwi', image: 'frog2.jpg', name: 'fives'


  all: ->
    @charities
