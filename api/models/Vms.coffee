 # Vms.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =

	tableName:		'vms'
  
	schema:			true
	
	attributes:

		vmIp:
			type:		'integer'
			required:	true

		port:
			type:		'integer'
			required:	true
			  
		contextPath:
			type:		'string'
			required:	true
			unique: 	true
      
		createdAt:
			type:		'datetime'
			defaultsTo:	new Date()
			
		createdBy:
			type:		'string'
			required:	true
			
		updatedAt:
			type:		'datetime'
			defaultsTo:	new Date()   