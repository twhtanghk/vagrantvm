fs = require 'fs'
child_process = require('child_process')

module.exports = 
	genFile: (data) ->
		FilePath = sails.config.vmconfig.file.path + data.name
		FileName = sails.config.vmconfig.file.name
		sails.log.info "Create directory: #{FilePath} of vm: name: #{data.name} ,port: #{data.port}"
		
		try
			fs.mkdirSync FilePath
			child_process.execSync "cp #{sails.config.vmconfig.file.path}#{sails.config.vmconfig.file.name} #{FilePath}"
			child_process.execSync "sed -ie 's/inputname/#{data.name}/g' #{FilePath}/#{FileName}" 
			child_process.execSync "sed -ie 's/inputport/#{data.port}/g' #{FilePath}/#{FileName}"
		catch err
			sails.log.error "Create directory fail: #{FilePath} err: #{err}"
			return
		return