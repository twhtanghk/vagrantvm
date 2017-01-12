env = require './env.coffee'

require './model.coffee'

angular.module 'starter.controller', [ 'ionic', 'http-auth-interceptor', 'ngCordova',  'starter.model', 'platform']

	.controller 'MenuCtrl', ($scope) ->
		$scope.env = env
		$scope.navigator = navigator

	.controller 'VmsCtrl', ($scope, model, $location) ->
		_.extend $scope,
			model: model
			save: ->			
				$scope.model.$save()
					.then ->
						$location.url "/list"
					.catch (err) ->
						alert {data:{error: "Apps already exist."}}	
	
	.controller 'ListCtrl', ($scope, collection, $location, createdBy) ->		
		_.extend $scope,
			collection: collection
			create: ->
				$location.url "/vm/create"					
			edit: (id) ->
				$location.url "/vm/edit/#{id}"			
			delete: (obj) ->
				collection.remove obj
			createdBy: createdBy
			loadMore: ->
				collection.$fetch({params: {createdBy: createdBy, sort: 'path asc'}})
					.then ->
						$scope.$broadcast('scroll.infiniteScrollComplete')
					.catch alert
					
