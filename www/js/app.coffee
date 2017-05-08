env = require './env.coffee'
require './templates'
require './locale.coffee'
require './controller.coffee'
require './model.coffee'
require 'ngCordova'
require 'angular-touch'
require 'log_toast'
require 'util.auth'

angular
  .module 'starter', [
    'ionic'
    'util.auth'
    'starter.controller'
    'starter.model'
    'http-auth-interceptor'
    'ngTouch'
    'ngAnimate'
    'locale'
    'logToast'
  ]
  
  .run (authService) ->
    authService.login env.oauth2.opts
          
  .run ($rootScope, $ionicPlatform) ->
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
                                
  .config ($stateProvider, $urlRouterProvider) ->
  
    $stateProvider.state 'app',
      url: ""
      abstract: true
      controller: 'MenuCtrl'
      templateUrl: "templates/menu.html"
      resolve:
        resources: 'resources'
        me: (resources) ->
          resources.User.me().$fetch()
        model: (me) ->
          me
  
    $stateProvider.state 'app.create',
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
          
    $stateProvider.state 'app.list',
      url: "/vm/list"
      cache: false
      views:
        'menuContent':
          templateUrl: "templates/vm/list.html"
          controller: 'ListCtrl'
      resolve:
        resources: 'resources'  
        collection: (me, resources) ->
          ret = new resources.VmList()
          ret.$fetch()

    $urlRouterProvider.otherwise('/vm/list')
