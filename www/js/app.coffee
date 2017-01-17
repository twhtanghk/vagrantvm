env = require './env.coffee'

angular.module 'starter', ['ngFancySelect', 'ionic', 'util.auth', 'starter.controller', 'starter.model', 'http-auth-interceptor', 'ngTagEditor', 'ActiveRecord', 'ngFileUpload', 'ngFileSaver', 'ngTouch', 'ngAnimate', 'pascalprecht.translate', 'locale']
	
	.run (authService) ->
		authService.login env.oauth2.opts
	        
	.run ($rootScope, platform, $ionicPlatform, $location, $http) ->
		$ionicPlatform.ready ->
			if (window.cordova && window.cordova.plugins.Keyboard)
				cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
			if (window.StatusBar)
				StatusBar.styleDefault()

	.run ($rootScope, $ionicModal) ->
		$rootScope.$on 'activitiImg', (event, inImg) ->
			_.extend $rootScope,
				imgUrl: inImg
			
			$ionicModal.fromTemplateUrl 'templates/modal.html', scope: $rootScope
				.then (modal) ->
					modal.show()
					$rootScope.modal = modal
																
	.config ($stateProvider, $urlRouterProvider, $translateProvider) ->
	
		$stateProvider.state 'app',
			url: ""
			abstract: true
			templateUrl: "templates/menu.html"
	
		# Apps
		$stateProvider.state 'app.Vms',
			url: "/vm/list?createdBy&sort"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/vm/list.html"
					controller: 'ListCtrl'
			resolve:
				createdBy: ($stateParams) ->
					return $stateParams.createdBy
				resources: 'resources'
				collection: (resources, createdBy) ->
					ret = new resources.VmList()
					ret.$fetch({params: {createdBy: createdBy, sort: 'path asc'}})
					
		$stateProvider.state 'app.VmCreate',
			url: "/vm/create"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/vm/create.html"
					controller: 'VmCtrl'
			resolve:
				resources: 'resources'	
				model: (resources) ->
					ret = new resources.Vm()
		###			
		$stateProvider.state 'app.VmEdit',
			url: "/vm/edit/:id"
			cache: false
			views:
				'menuContent':
					templateUrl: "templates/vm/edit.html"
					controller: 'VmCtrl'
			resolve:
				id: ($stateParams) ->
					$stateParams.id
				resources: 'resources'	
				model: (resources, id) ->
					ret = new resources.Vm({id: id})
					ret.$fetch()			
		###	
		$urlRouterProvider.otherwise('/vm/list?createdBy=me&sort=port asc')
