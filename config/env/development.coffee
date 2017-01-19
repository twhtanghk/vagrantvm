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
			url1: 'mongodb://todoactiviti_mongo/vagrantvm' #dev
			url: 'mongodb://vagrantvmrw:pass1234@localhost/vagrantvm'
					
	log:
		level: 'silly'
	
	vmconfig:
		file:
			path1:	'./vagrantvm/'
			path:	'/tmp/vagrantvm/'
			name:	'Vagrantfile'	