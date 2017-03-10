require 'PageableAR'

angular.module 'starter.model', ['PageableAR']

  .factory 'resources', (pageableAR) ->

    class Vm extends pageableAR.Model
      $idAttribute: 'id'
      
      $urlRoot: "api/vm"
      
      cmd: (op) ->
        @$save {}, url: "#{@$url()}/#{op}"

      cfg: ->
        JSON.stringify _.extend _.pick(@, 'status'), @port

    # VmList
    class VmList extends pageableAR.PageableCollection

      model: Vm
      
      $urlRoot: "api/vm"

    class User extends pageableAR.Model
      $idAttribute: 'username'
      
      $urlRoot: "api/user"
      
      _me = null
      
      @me: ->
        _me ?= new User username: 'me'
    
    # UserList
    class UserList extends pageableAR.PageableCollection

      model: User
      
      $urlRoot: "api/user"

    Vm:    Vm
    VmList:  VmList
    User:    User
    UserList:  UserList
