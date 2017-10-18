env = require './config.json'
_ = require 'lodash'
require 'PageableAR'
require 'angular-file-saver'
require 'ng-file-upload'

angular
  .module 'starter.model', [
    'PageableAR'
    'ngFileSaver'
    'ngFileUpload'
  ]

  .factory 'resources', (pageableAR, $http, $log, FileSaver, Upload) ->

    class Vm extends pageableAR.Model
      $defaults:
        disk: parseInt env.DISK
        memory: parseInt env.MEMORY

      $idAttribute: 'id'
      
      $urlRoot: "api/vm"
      
      cmd: (op, files) ->
        switch op
          when 'console'
            window.open "../console/#{@name}/"
          when 'backup'
            $http
              .get "#{@$url()}/#{op}", responseType: 'blob'
              .then (res) ->
                filename = res.headers('Content-Disposition').match(/filename="(.+)"/)[1]
                FileSaver.saveAs res.data, filename
          when 'restore'
            if files.length != 0
              Upload
                .upload 
                  method: 'PUT'
                  url: "#{@$url()}/#{op}"
                  data: file: files[0]
                .then ->
                  $log.info "Restore completed"
                .catch (res) ->
                  $log.error res.data
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
