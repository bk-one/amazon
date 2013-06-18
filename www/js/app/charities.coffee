class Charities
  constructor: ->
    @charities = []

    @charities.push key: 'dsoaijd', image: 'frog1.jpg', name: 'first'
    @charities.push key: 'dooaijd', image: 'frog2.jpg', name: 'second'


  all: ->
    @charities
