env = require './env.coffee'

require './model.coffee'

angular.module 'starter.controller', [ 'ionic', 'http-auth-interceptor', 'ngCordova',  'starter.model', 'platform']

  .controller 'MenuCtrl', ($scope) ->
    $scope.env = env
    $scope.navigator = navigator

  .controller 'ItemCtrl', ($scope, $log, $ionicActionSheet) ->
    _.extend $scope, 

      showAction: ->
        $ionicActionSheet.show
          buttons: [
            { text: 'SSH', cmd: 'ssh' }
            { text: 'Up', cmd: 'up' }
            { text: 'Down', cmd: 'down' }
            { text: 'Resume', cmd: 'resume' }
            { text: 'Suspend', cmd: 'suspend' }
            { text: 'Restart', cmd: 'restart' }
          ]
          buttonClicked: (index, button) ->
            if button.cmd == 'ssh'
              window.open "#{env.sshUrl}?port=#{$scope.model.port.ssh}"
            else      
              $scope.model.cmd button.cmd
            return true

      delete: ->
        $scope.collection.remove $scope.model
        
      up: ->  
        $scope.model.up()
          .catch $log.error
          
      down: ->  
        $scope.model.down()
          .catch $log.error

      resume: ->
        $scope.model.resume()
          .catch $log.error

      suspend: ->
        $scope.model.suspend()
          .catch $log.error

      restart: ->
        $scope.model.restart()
          .catch $log.error
     
  .controller 'ListCtrl', ($rootScope, $stateParams, $scope, collection, $location, resources, $ionicModal, $filter, FileSaver, Blob, $ionicListDelegate) ->
    _.extend $scope,
      
      collection: collection
      
      loadMore: ->
        collection.$fetch()
          .then ->
            $scope.$broadcast('scroll.infiniteScrollComplete')
          .catch alert
              
  .controller 'VmCtrl', ($rootScope, $scope, model, $location, Upload) ->
    _.extend $scope,
      model: model
      
      save: ->      
        $scope.model.$save()
          .then ->
            $location.url "/list"
          .catch (err) ->
            alert {data:{error: "VM already exist."}}  
