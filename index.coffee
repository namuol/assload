Q = require 'q'
{EventEmitter} = require 'events'

assload = ->
  load = (emitter, allAssets) ->
    all = []
    complete = 0

    for own type,assets of allAssets
      if not loaders[type]?
        return Q.reject new Error "No loader specified for type '#{type}'. Provide one with assets.use(...)."
        
      for own name,whatToLoad of assets
        do (name, whatToLoad) =>
          {resolve, reject, notify, promise} = Q.defer()

          loaders[type](whatToLoad, resolve, reject, notify)

          promise = promise.progress (amount) =>
            emitter.emit 'asset.progress',
              type: type
              name: name
              params: whatToLoad
              amount: amount
          .then (asset) =>
            manager[type][name] = asset
            complete += 1
            
            emitter.emit 'asset.progress',
              type: type
              name: name
              params: whatToLoad
              amount: 1

            emitter.emit 'asset.complete',
              type: type
              name: name
              params: whatToLoad
              asset: asset
              totalCount: all.count
              totalComplete: complete

          all.push promise

    return Q.all all

  class AssetBundle extends EventEmitter
    constructor: (@allAssets) ->
    load: ->
      load @, @allAssets

  class AssetManager
    use: (_loaders) ->
      for own type,loader of _loaders
        loaders[type] = loader
        @[type] ?= {}

      return @

    bundle: (allAssets) ->
      return new AssetBundle allAssets

  loaders = {}
  manager = new AssetManager

  return manager

module.exports = assload
