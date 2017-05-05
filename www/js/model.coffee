env = require './config.json'
require 'PageableAR'
require 'angular-file-saver'

angular.module 'starter.model', ['PageableAR', 'ngFileSaver']

  .factory 'resources', (pageableAR, $http, FileSaver) ->

    class Vm extends pageableAR.Model
      $defaults:
        disk: parseInt env.DISK
        memory: parseInt env.MEMORY

      $idAttribute: 'id'
      
      $urlRoot: "api/vm"
      
      cmd: (op) ->
        switch op
          when 'ssh'
            window.open "#{env.SSHURL}?port=#{@port.ssh}"
          when 'backup'
            $http
              .get "#{@$url()}/#{op}", responseType: 'blob'
              .then (res) ->
                filename = res.headers('Content-Disposition').match(/filename="(.+)"/)[1]
                FileSaver.saveAs res.data, filename
          when 'restore'
            @$save {}, url: "#{@$url()}/#{op}"
          else
            @$save {}, url: "#{@$url()}/#{op}"

      cfg: ->
        JSON.stringify _.extend _.pick(@, 'status', 'memory', 'disk'), @port

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
