path = require 'path'
config = require './config.json'
window.io = require('sails.io.js')(require('socket.io-client'))

module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if module.exports.isNative() then 'mobile' else 'browser'

	oauth2:
		opts:
			authUrl: 		config.AUTHURL
			response_type:	"token"
			scope:			config.SCOPE
			client_id:		config.CLIENT_ID	
