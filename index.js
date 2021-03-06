// Generated by CoffeeScript 1.8.0
(function() {
  var EventEmitter, Q, assload,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  EventEmitter = require('events').EventEmitter;

  assload = function() {
    var AssetBundle, AssetManager, load, loaders, manager;
    load = function(emitter, allAssets) {
      var all, assets, complete, deferred, loadedAssets, name, type, whatToLoad, _fn;
      deferred = Q.defer();
      all = [];
      complete = 0;
      loadedAssets = {};
      for (type in allAssets) {
        if (!__hasProp.call(allAssets, type)) continue;
        assets = allAssets[type];
        if (loaders[type] == null) {
          return Q.reject(new Error("No loader specified for type '" + type + "'. Provide one with loader.use({'" + type + "': function () {...}})."));
        }
        loadedAssets[type] = {};
        _fn = (function(_this) {
          return function(name, whatToLoad) {
            var notify, promise, reject, resolve, _ref;
            _ref = Q.defer(), resolve = _ref.resolve, reject = _ref.reject, notify = _ref.notify, promise = _ref.promise;
            loaders[type](whatToLoad, resolve, reject, notify);
            promise = promise.progress(function(amount) {
              return emitter.emit('asset.progress', {
                type: type,
                name: name,
                params: whatToLoad,
                amount: amount
              });
            }).then(function(asset) {
              loadedAssets[type][name] = asset;
              complete += 1;
              emitter.emit('asset.progress', {
                type: type,
                name: name,
                params: whatToLoad,
                amount: 1
              });
              return emitter.emit('asset.complete', {
                type: type,
                name: name,
                params: whatToLoad,
                asset: asset,
                totalCount: all.count,
                totalComplete: complete
              });
            });
            return all.push(promise);
          };
        })(this);
        for (name in assets) {
          if (!__hasProp.call(assets, name)) continue;
          whatToLoad = assets[name];
          _fn(name, whatToLoad);
        }
      }
      Q.all(all).then(function() {
        deferred.resolve(loadedAssets);
      })["catch"](function(err) {
        deferred.reject(err);
      });
      return deferred.promise;
    };
    AssetBundle = (function(_super) {
      __extends(AssetBundle, _super);

      function AssetBundle(allAssets) {
        this.allAssets = allAssets;
      }

      AssetBundle.prototype.load = function() {
        return load(this, this.allAssets);
      };

      return AssetBundle;

    })(EventEmitter);
    AssetManager = (function() {
      function AssetManager() {}

      AssetManager.prototype.use = function(_loaders) {
        var loader, type;
        for (type in _loaders) {
          if (!__hasProp.call(_loaders, type)) continue;
          loader = _loaders[type];
          loaders[type] = loader;
          if (this[type] == null) {
            this[type] = {};
          }
        }
        return this;
      };

      AssetManager.prototype.bundle = function(allAssets) {
        return new AssetBundle(allAssets);
      };

      return AssetManager;

    })();
    loaders = {};
    manager = new AssetManager;
    return manager;
  };

  module.exports = assload;

}).call(this);
