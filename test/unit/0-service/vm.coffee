describe 'service', ->
  it 'create vm', ->
    sails.services.vm
      .create
        name: 'test'
        memory: 1024
        disk: 20
        port:
          ssh: 2200
          http: 8000

  it 'destroy vm', ->
    sails.services.vm
      .destroy
        name: 'test'
