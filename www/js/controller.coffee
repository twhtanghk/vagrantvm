env = require './env.coffee'

require './model.coffee'

angular.module 'starter.controller', [ 'ionic', 'http-auth-interceptor', 'ngCordova',  'starter.model', 'platform']

  .controller 'MenuCtrl', ($scope) ->
    $scope.env = env
    $scope.navigator = navigator

  .controller 'ListCtrl', ($rootScope, $stateParams, $scope, collection, $location, resources, $ionicModal, $filter, FileSaver, Blob, $ionicListDelegate) ->
    _.extend $scope,
      
      collection: collection
      
      delete: (item) ->
        collection.remove item
        
      up: (item)->  
        item.up()
          .then (data)->  
            data.status = env.vmStatus.up
            $ionicListDelegate.closeOptionButtons()  
          .catch alert
          
      down: (item)->  
        item.down()
          .then (data)->  
            data.status = env.vmStatus.down
            $ionicListDelegate.closeOptionButtons()  
          .catch alert        

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
