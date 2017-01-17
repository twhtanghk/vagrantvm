module.exports =
	hookTimeout:	400000
	
	port:			1337
		
	#scope:				["https://mob.myvnc.com/org/users"]

	oauth2:
		verifyURL:			"https://app.ogcio.gov.hk/auth/oauth2/verify/"
		tokenURL:			"https://app.ogcio.gov.hk/auth/oauth2/token/"
		scope: ['User']
		
	promise:
		timeout:	10000 # ms

	models:
		connection: 'mongo'
		migrate:	'alter'
	
	connections:
		mongo:
			adapter:	'sails-mongo'
			driver:		'mongodb'
			url1: 'mongodb://todoactiviti_mongo/proxyvmdev' #dev
			url: 'mongodb://todosailsrw:pass1234@localhost/vagrantvm'
					
	log:
		level: 'silly'