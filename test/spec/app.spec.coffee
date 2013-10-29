define (require) ->
  App = require(App)

  describe 'App', ->

    before ->
      @app = new App()

    it 'should exist', ->
      @app.should.be.defined
