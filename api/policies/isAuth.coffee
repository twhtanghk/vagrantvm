{isAuth} = require 'sails_policy'

module.exports = (req, res, next) ->
  isAuth req, res, ->
    sails.models.user
      .findOrCreate email: req.user.email
      .then ->
        next()
      .catch res.negotiate
