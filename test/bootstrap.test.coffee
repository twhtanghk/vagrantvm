Promise = require 'bluebird'
Sails = Promise.promisifyAll require 'sails'
fs = require 'fs'
co = require 'co'
config = JSON.parse fs.readFileSync './.sailsrc'

before ->
  Sails
    .liftAsync config
    .then -> co ->
      sails.config.oauth2
        .validToken sails.config.oauth2
    .then (token) ->
      global.uptime = 150000

after ->
  Sails.lowerAsync()
