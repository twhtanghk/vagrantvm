describe 'model', ->
  createdBy = null

  it 'create user', ->
    sails.models.user
      .create
        email: 'user@abc.com'
      .then (user) ->
        createdBy = user
        
  it 'create vm', ->
    sails.models.vm
      .create
        name: 'test'
        port:
          ssh: 2200
          http: 8000
        createdBy: createdBy
