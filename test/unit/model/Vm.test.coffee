request = require('supertest')
assert = require('assert')

describe 'Vm Model', ->

	describe 'create', ->
	    it 'add new record', (done) ->
	      Vm
	      	.create({name: 'testVM', port: '1337', type: 'mongo', createdBy:'doris'})
	        .then (record) ->
	        	console.log record.name
	        	assert.equal record.name, 'testVM'
	        	done()
	        .catch done
	          			