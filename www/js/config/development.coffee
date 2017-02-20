io.sails.url = 'https://app.ogcio.gov.hk'
io.sails.path = "/im.app/socket.io"
io.sails.useCORSRouteToGetCookie = false
    
module.exports =
	isMobile: ->
		/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
	isNative: ->
		/^file/i.test(document.URL)
	platform: ->
		if @isNative() then 'mobile' else 'browser'
	authUrl:	'https://app.ogcio.gov.hk'
	
	path: 'vm'		
	oauth2:
		authUrl: "#{@authUrl}/auth/oauth2/authorize/"
		opts:
			authUrl: "https://app.ogcio.gov.hk/auth/oauth2/authorize/"
			response_type:  "token"
			scope: 'User'
			client_id: 'vagrantvmDEV'
	vmStatus:
		up: 'UP'
		down: 'DOWN'			