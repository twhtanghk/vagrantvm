
module.exports = 

	bootstrap:	(cb) ->
		if process.env.OAUTH2_CA
			require 'ssl-root-cas'
				.inject()
				.addFile process.env.OAUTH2_CA
		cb()		