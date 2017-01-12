 # AppsController
 #
 # @description :: Server-side logic for managing apps
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
Promise = require 'promise'
module.exports =

	create: (req, res) ->
		Model = actionUtil.parseModel(req)
		data = actionUtil.parseValues(req)
			
		Model.create(data)
			.then (newInstance) ->
				#ConfigServices.createConfig data
				#ConfigServices.restartServer data.path
				res.ok(newInstance)
			.catch res.serverError
			