req = require 'supertest-as-promised'
Promise = require 'bluebird'

describe 'controller', ->
  vmlist = ['test1', 'test2']

  it 'create vm', ->
    Promise.all vmlist.map (name) ->
      req sails.hooks.http.app
        .post '/api/vm'
        .set 'Authorization', "Bearer #{token}"
        .send name: name
        .expect 201

  it 'status vm', ->
    Promise
      .all vmlist.map (name) ->
        sails.models.vm
          .findOne name: name
          .then (vm) ->
            req sails.hooks.http.app
              .get "/api/vm/#{vm.id}"
              .set 'Authorization', "Bearer #{token}"
              .expect 200

  it 'up vm', ->
    Promise
      .all vmlist.map (name) ->
        sails.models.vm
          .findOne name: name
          .then (vm) ->
            req sails.hooks.http.app
              .put "/api/vm/#{vm.id}/up"
              .set 'Authorization', "Bearer #{token}"
              .expect 200
          .then ->
            Promise.delay uptime
       
  it 'restart vm', ->
    Promise
      .all vmlist.map (name) ->
        sails.models.vm
          .findOne name: name
          .then (vm) ->
            req sails.hooks.http.app
              .put "/api/vm/#{vm.id}/restart"
              .set 'Authorization', "Bearer #{token}"
              .expect 200

  it 'delete vm', ->
    Promise
      .all vmlist.map (name) ->
        sails.models.vm
          .findOne name: name
          .then (vm) ->
            req sails.hooks.http.app
              .del "/api/vm/#{vm.id}"
              .set 'Authorization', "Bearer #{token}"
              .expect 200
