define (require) ->
  Associate = require('cs!models/associate')

  describe 'Associate', ->

		before ->
		  @associate = new Associate()

		it 'should exist', ->
		  @associate.should.be.defined

	  it 'should be a Backbone model', ->
	    (_.isFunction(@associate.get)).should.be.true
	    (_.isFunction(@associate.set)).should.be.true

		it 'should be named "Associate"', ->
		  @associate.get('name').should.equal('Associate name')