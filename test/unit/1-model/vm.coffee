describe 'model', ->
  createdBy = null
  vmlist = ['test1', 'test2']

  it 'create user', ->
    sails.models.user
      .create
        email: 'user@abc.com'
      .then (user) ->
        createdBy = user
        
  vmlist.map (name) ->
    it 'create vm', ->
      sails.models.vm
        .create
          name: name
          port:
            ssh: 2200
            http: 8000
          createdBy: createdBy

  vmlist.map (name) ->
    it 'delete vm', ->
      sails.models.vm
        .destroy
          name: name

  it 'delete user', ->
    sails.models.user
      .destroy
        email: 'user@abc.com'
