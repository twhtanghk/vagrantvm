fs = require 'fs'
child_process = require('child_process')

module.exports = 
	genFile: (data) ->
		ConfigPath = sails.config.vmconfig.file.path
		ConfigFile = "#{sails.config.vmconfig.file.name}_#{data.type}" 
		ProjectPath = "#{sails.config.vmconfig.file.path}#{data.name}"
		FileName = sails.config.vmconfig.file.name
		
		sails.log.info "Create directory: #{ProjectPath} of vm: name: #{data.name} ,port: #{data.port}"
		sails.log.info "Copy template: #{ConfigPath}#{ConfigFile} #{ProjectPath}/#{FileName}"
		
		try
			fs.mkdirSync ProjectPath
			child_process.execSync "cp #{ConfigPath}#{ConfigFile} #{ProjectPath}/#{FileName}"
			child_process.execSync "sed -i 's/inputname/#{data.name}/g' #{ProjectPath}/#{FileName}" 
			child_process.execSync "sed -i 's/inputport/#{data.port}/g' #{ProjectPath}/#{FileName}"
			child_process.execSync "VAGRANT_CWD=#{ProjectPath} vagrant up --provider=docker"
		catch err
			sails.log.error "Create directory fail: #{ProjectPath} err: #{err}"
			return
		return