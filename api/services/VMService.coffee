fs = require 'fs'

genFileName = (appsName) ->
	#filename =	"#{appsName}#{sails.config.proxy.file.extension}"
	name = 	sails.config.vmconfig.file.name
	path = 	sails.config.vmconfig.file.path
	return path + name
	
module.exports = 
	genFile: (data) ->
		FilePath = sails.config.vmconfig.file.path + data.name
		FileName = sails.config.vmconfig.file.name
		
		sails.log.info "Create directory: #{FilePath} of vm: name: #{data.name} ,port: #{data.port}"
		 
		filedata = "test text"
		try
			fs.mkdirSync FilePath
			fs.writeFileSync FilePath+ FileName, filedata
		catch err
			sails.log.error "Create directory fail: #{FilePath} err: #{err}"
			return
		return