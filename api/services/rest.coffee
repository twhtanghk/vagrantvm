http = require 'needle'
Promise = require 'bluebird'

options = 
	timeout:	sails.config.promise.timeout

tokenOptions = _.clone options	
		
module.exports =
				
	get: (token, url, opts) ->
		new Promise (fulfill, reject) ->
			if _.isUndefined opts
				opts = _.extend options, sails.config.http.opts,
					headers:
						Authorization:	"Bearer #{token}"
				opts = _.omit opts, 'Content-Type', 'username', 'password'
			
			http.get url, opts, (err, res) ->
				if err
					return reject err
				fulfill res
				
	post: (token, url, opts, data) ->
		new Promise (fulfill, reject) ->
			if _.isUndefined opts
				opts = _.extend options, sails.config.http.opts,
					headers:
						Authorization:	"Bearer #{token}"
						
			http.post url, data, opts, (err, res) ->
				if err
					return reject err
				fulfill res

	delete: (token, url, opts) ->
		new Promise (fulfill, reject) ->
			if _.isUndefined opts
				opts = _.extend options, sails.config.http.opts,
					headers:
						Authorization:	"Bearer #{token}"
						
			http.delete url, {}, opts, (err, res) ->
				if err
					return reject err
				fulfill res
									
	push: (token, roster, msg) ->
		param =
			roster: roster
			msg:	msg
		data = _.mapValues sails.config.push.data, (value) ->
			_.template value, param
		@post token, sails.config.push.url, 
			users:	[roster.createdBy.email]
			data:	data
			
	gcmPush: (users, data) ->
		new Promise (fulfill, reject) ->
			opts = _.extend options,
				headers:
					Authorization: 	"key=#{sails.config.push.gcm.apikey}"
					'Content-Type': 'application/json'
				json:		true
			devices = []
			_.each users, (user) ->
				_.each user.devices, (device) ->
					devices.push device.regid 
			defaultMsg =
				title:		'Instant Messaging'
				message:	' '
			data =
				registration_ids:	_.uniq(devices)
				data:				_.extend defaultMsg, data
			http.post sails.config.push.gcm.url, data, opts, (err, res) =>
				if err
					return reject(err)
				fulfill(res.body)
				
	# get token for Resource Owner Password Credentials Grant
	# url: 	authorization server url to get token 
	# client:
	#	id: 	registered client id
	#	secret:	client secret
	# user:
	#	id:		registered user id
	#	secret:	user password
	# scope:	[ "https://mob.myvnc.com/org/users", "https://mob.myvnc.com/mobile"]
	token: (url, client, user, scope) ->
		opts = _.extend tokenOptions, sails.config.http.opts,
			headers =
				'Content-Type':	'application/x-www-form-urlencoded'
				username:		client.id
				password:		client.secret
		
		data =
			grant_type: 	'password'
			username:		user.id
			password:		user.secret 
			scope:			scope.join(' ')
		
		new Promise (fulfill, reject) ->
			http.post url, data, opts, (err, res) ->
				#sails.log "post get token : " + JSON.stringify res.body 
				if err
					return reject err
				fulfill res