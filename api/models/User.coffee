module.exports =
	tableName:	'users'
	schema:		true
	autoPK:		false
	attributes:
		url:
			type: 		'string'
			required: 	true
			
		username:
			type: 		'string'
			required: 	true
			primaryKey: true
			
		email:
			type:		'string' 
			required:	true

		#check if user is authorized to remove the specified data
		isCreator: (data) ->
			sails.services.user.isCreator(@, data)

			
