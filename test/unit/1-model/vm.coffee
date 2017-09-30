Promise = require 'bluebird'

describe 'model', ->
  createdBy = null
  vmlist = ['test1', 'test2']

  it 'create user', ->
    sails.models.user
      .create
        email: 'user@abc.com'
      .then (user) ->
        createdBy = user
        
  it 'create vm', ->
    Promise.mapSeries vmlist, (name) ->
      sails.models.vm
        .create
          name: name
          createdBy: createdBy

  it 'status vm', ->
    Promise.mapSeries vmlist, (name) ->
      sails.models.vm
        .findOne name: name
        .then (vm) ->
          vm?.status()

  it 'up vm', ->
    Promise
      .mapSeries vmlist, (name) ->
        sails.models.vm
          .findOne name: name
          .then (vm) ->
            vm?.up()
      .then ->
        Promise.delay uptime

  it 'restart vm', ->
    Promise.mapSeries vmlist, (name) ->
      sails.models.vm
        .findOne name: name
        .then (vm) ->
          vm?.restart()

  it 'delete vm', ->
    Promise.mapSeries vmlist, (name) ->
      sails.models.vm
        .destroy
          name: name

  it 'delete user', ->
    sails.models.user
      .destroy
        email: 'user@abc.com'
