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
            { text: 'backup', cmd: 'backup' }
            { text: 'restore', cmd: 'restore' }
          ]
          buttonClicked: (index, button) ->
            $scope.model.cmd button.cmd
            return true

  .controller 'ListCtrl', ($rootScope, $stateParams, $scope, $log, collection, $location, resources, $ionicModal, $filter, FileSaver, Blob, $ionicListDelegate) ->
    _.extend $scope,
      
      collection: collection
      
      loadMore: ->
        collection.$fetch()
          .then ->
            $scope.$broadcast('scroll.infiniteScrollComplete')
          .catch $log.error
              
  .controller 'VmCtrl', ($rootScope, $scope, model, $location, $log, Upload) ->
    _.extend $scope,
      model: model
      
      save: ->      
        $scope.model.$save()
          .then ->
            $location.url "/list"
          .catch $log.error
