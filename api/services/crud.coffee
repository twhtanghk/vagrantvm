Promise = require 'promise'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports = 
	create: (req) ->
		Model = actionUtil.parseModel(req)
		data = actionUtil.parseValues(req)
		
		new Promise (fulfill, reject) ->
			Model.create(data)
				.then (newInstance) ->
					if req._sails.hooks.pubsub
						if req.isSocket
							Model.subscribe(req, newInstance);
							Model.introduce(newInstance);
						Model.publishCreate(newInstance, !req.options.mirror && req)
					fulfill(newInstance)
				.catch reject
				
	find: (req) ->
		Model = actionUtil.parseModel req
		cond = actionUtil.parseCriteria req
		
		sails.log "cond: #{JSON.stringify cond}"
		
		sortBy = actionUtil.parseSort(req)
		if !_.isUndefined sortBy
			if sortBy.indexOf("project") > -1
				if sortBy.indexOf("asc") > -1
					sortBy = 
						"project":0
						"task":1
				else
					sortBy = 
						"project":1
						"task":1
			
		sails.log "sortBy: #{JSON.stringify sortBy}"
		
		count = Model.count()
			.where( cond )
			.toPromise()
		query = Model.find()
			.where( cond )
			.populateAll()
			.limit( actionUtil.parseLimit(req) )
			.skip( actionUtil.parseSkip(req) )
			.sort( sortBy )
			.toPromise()
		
		new Promise (fulfill, reject) ->
			Promise.all([count, query])
				.then (data) ->
					if req._sails.hooks.pubsub and req.isSocket
						Model.subscribe(req, data[1])
						if Model.autoWatch or req.options.autoWatch
							Model.watch(req)
						_.each data[1], (record) ->
							actionUtil.subscribeDeep(req, record)
					fulfill
						count:		data[0]
						results:	data[1]
				.catch reject
				
	_findOrCreate: (req, Model, cond, data) ->
		new Promise (fulfill, reject) ->
			Model.findOrCreate(cond, data)
				.then (newInstance) ->
					if req._sails.hooks.pubsub
						if req.isSocket
							Model.subscribe(req, newInstance)
							Model.introduce(newInstance)
						Model.publishCreate(newInstance, !req.options.mirror && req)
					fulfill(newInstance)
				.catch reject