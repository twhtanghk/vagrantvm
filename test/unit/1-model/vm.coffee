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
    Promise.all vmlist.map (name) ->
      sails.models.vm
        .create
          name: name
          port:
            ssh: 2200
            http: 8000
          createdBy: createdBy

  it 'delete vm', ->
    Promise.all vmlist.map (name) ->
      sails.models.vm
        .destroy
          name: name

  it 'delete user', ->
    sails.models.user
      .destroy
        email: 'user@abc.com'
