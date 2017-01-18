module.exports =
	tableName:		'vm'

	schema:			true

	attributes:
		name:
			type:		'string'
			required:	true
			unique: 	true

		port:
			type:		'integer'
			required:	true
			  
		type:
			type:		'string'
			required:	true

		createdBy:
			type:		'string'
			required:	true
			      
		createdAt:
			type:		'datetime'
			defaultsTo:	new Date()
			
		updatedAt:
			type:		'datetime'
			defaultsTo:	new Date()   

	afterCreate: (values, cb) ->
		VMService.genFile(values)

		return cb null, values 	