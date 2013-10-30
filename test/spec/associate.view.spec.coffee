define (require) ->
  Associate = require('cs!models/associate')
  AssociateView = require('cs!views/associate')

  describe 'AssociateView', ->

    before ->
      @associate = new Associate()
      @associateView = new AssociateView({ model: @associate })

    it 'should exist', ->
      @associateView.should.be.defined

    it 'should have a model', ->
      @associateView.should.be.defined

    it 'should render a div.associate', ->
      @associateView.render().$el.should.have.class('associate')

    it 'should add a background image to the div', ->
      @associateView.render().$el.should.have.css 'background-image', @associate.get('backgroundURL')

    it 'should render an h1 with its name', ->
      console.log @associateView.render()
      @associateView.render().$el.find('h1').should.not.be.empty
      @associateView.render().$el.find('h1').should.have.text @associate.get('name')

