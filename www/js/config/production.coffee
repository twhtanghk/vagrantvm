io.sails.url = 'https://mob.myvnc.com'
io.sails.path = "/im.app/socket.io"
io.sails.useCORSRouteToGetCookie = false
    
module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if @isNative() then 'mobile' else 'browser'
	authUrl:	'https://mob.myvnc.com'
	
	path: 'proxyvm'		
	oauth2:
		authUrl: "#{@authUrl}/org/oauth2/authorize/"
		opts:
			authUrl: "https://mob.myvnc.com/org/oauth2/authorize/"
			response_type:  "token"
			scope:          "https://mob.myvnc.com/org/users"
			client_id:      'proxyvmUAT'
			