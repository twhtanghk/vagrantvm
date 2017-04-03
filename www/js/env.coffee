path = require 'path'
config = require './config.json'
root = require('url').parse config.ROOTURL
url = "#{root.protocol}//#{root.host}"

io.sails.url = url
io.sails.path = path.join root.path, 'socket.io'
io.sails.useCORSRouteToGetCookie = false

module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if module.exports.isNative() then 'mobile' else 'browser'

	oauth2:
		opts:
			authUrl: 		"#{config.AUTHURL}/oauth2/authorize/"
			response_type:	"token"
			scope:			config.OAUTH2_SCOPE
			client_id:		config.CLIENT_ID	
