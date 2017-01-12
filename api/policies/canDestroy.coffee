actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
 
module.exports = (req, res, next) ->
	
	Model = actionUtil.parseModel(req)
	pk = actionUtil.requirePk(req)
		
	cond = 
			id:			pk
			
	Model.findOne()
		.where( cond )
		.exec (err, data) ->
			if err
				return res.serverError err
			if data
				if req.user.isCreator(data) 
					return next()
				res.badRequest "Not authorized to delete with id #{pk}"
			res.notFound()