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
            { text: 'ssh', cmd: 'ssh' }
            { text: 'up', cmd: 'up' }
            { text: 'down', cmd: 'down' }
            { text: 'resume', cmd: 'resume' }
            { text: 'suspend', cmd: 'suspend' }
            { text: 'restart', cmd: 'restart' }
          ]
          buttonClicked: (index, button) ->
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
