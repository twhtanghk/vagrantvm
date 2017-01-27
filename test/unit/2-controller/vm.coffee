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

  it 'create vm', ->
    Promise.all vmname.map (name) ->
      req sails.hooks.http.app
        .post '/api/vm'
        .set 'Authorization', "Bearer #{token}"
        .send name: name
        .expect 201
        .then (res) ->
          vmlist.push res.body

  it 'up vm', ->
    Promise.all vmlist.map (vm) ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/up"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  it 'restart vm', ->
    Promise.all vmlist.map (vm) ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/restart"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  it 'down vm', ->
    Promise.all vmlist.map (vm) ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/suspend"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  it 'down vm', ->
    Promise.all vmlist.map (vm) ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/resume"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  it 'down vm', ->
    Promise.all vmlist.map (vm) ->
      req sails.hooks.http.app
        .put "/api/vm/#{vm.id}/down"
        .set 'Authorization', "Bearer #{token}"
        .expect 200

  it 'delete vm', ->
    Promise.all vmlist.map (vm) ->
      req sails.hooks.http.app
        .del "/api/vm/#{vm.id}"
        .set 'Authorization', "Bearer #{token}"
        .expect 200
