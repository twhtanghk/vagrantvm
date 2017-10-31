req = require 'supertest-as-promised'
co = require 'co'
Promise = require 'bluebird'

describe 'controller', ->
  vmlist = ['test1', 'test2']
  vmCreated = null
  Model = null

  before ->
    Model = sails.config.vm.model()

  it 'create vm', ->
    Promise
      .all vmlist.map (name) -> co ->
        vm = Model name: name
        yield vm.save()
      .then (res) ->
        vmCreated = res

  it 'passwd vm', ->
    Promise
      .all vmCreated.map (vm) -> co ->
        yield vm.passwd 'passwd'

  it 'list all vm', -> co ->
    yield Model.fetchAll()

  it 'full list all vm by armodel', -> co ->
    gen = yield Model.fetchFull()
    for i from gen()
      console.log i

  it 'fetch vm', ->
    Promise
      .all vmCreated.map (vm) -> co ->
        yield vm.fetch()

  it 'up vm', ->
    Promise
      .all vmCreated.map (vm) -> co ->
        yield vm.up()
       
  it 'restart vm', ->
    Promise
      .all vmCreated.map (vm) -> co ->
        yield vm.restart()

  it 'delete vm', ->
    Promise
      .all vmCreated.map (vm) -> co ->
        yield vm.destroy()
      .catch ->
        Promise.resolve
