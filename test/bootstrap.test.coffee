Promise = require 'bluebird'
Sails = Promise.promisifyAll require 'sails'
oauth2 = require 'oauth2_client'
fs = require 'fs'
config = JSON.parse fs.readFileSync './.sailsrc'

before ->
  Sails
    .liftAsync config
    .then ->
      {url, client, user, scope} = sails.config.oauth2
      oauth2
        .token url.token, client, user, scope
    .then (token) ->
      global.token = token
		
after ->
  Sails.lowerAsync()
