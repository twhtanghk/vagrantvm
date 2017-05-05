module.exports = 
  http:
    middleware:
      order: [
        'bodyParser'
        'compress'
        'methodOverride'
        'router'
        'www'
        'favicon'
        '404'
        '500'
      ]        
