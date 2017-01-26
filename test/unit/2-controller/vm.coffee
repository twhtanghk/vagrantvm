req = require 'supertest-as-promised'
oauth2 = require 'oauth2_client'

describe 'controller', ->
  createdBy = null
  token = null
  vmname = ['test1', 'test2']
  vmlist = []

  before ->
    env = require '../../env.coffee'
    oauth2
      .token env.tokenUrl, env.client, env.user, env.scope
      .then (t) ->
        token = t

  vmname.map (name) ->
    it 'create vm', ->
      req sails.hooks.http.app
        .post '/api/vm'
        .set 'Authorization', "Bearer #{token}"
        .send name: name
        .expect 201
        .then (res) ->
          sails.log.debug res.statusCode
          sails.log.debug res.body
          vmlist.push res.body

  vmlist.map (vm) ->
    it 'up vm', ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/up"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  vmlist.map (vm) ->
    it 'restart vm', ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/restart"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  vmlist.map (vm) ->
    it 'down vm', ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/suspend"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  vmlist.map (vm) ->
    it 'down vm', ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/resume"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  vmlist.map (vm) ->
    it 'down vm', ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/down"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  vmlist.map (vm) ->
    it 'delete vm', ->
      req sails.hooks.http.app
        .del "/api/vm/#{vm.id}"
        .set 'Authorization', "Bearer #{token}"
        .expect 200
