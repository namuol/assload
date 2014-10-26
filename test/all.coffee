tape = require 'tape'
assload = require '../index'
_ = require 'lodash'
Q = require 'q'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'assload', (it) ->
  it 'should have a main export that is a function', (t) ->
    t.true typeof assload is 'function'
    t.end()

  it 'should return an object that has .load defined', (t) ->
    assets = assload()
    t.true typeof assets?.load is 'function'
    t.end()

  it 'should return a promise when .load is called', (t) ->
    assets = assload()
    t.true Q.isPromise assets.load()
    t.end()

  it 'should fail when attempting to load unspecified asset types', (t) ->
    assets = assload()
    
    failed = false

    assets.load
      unspecified:
        test: 'unspecified'
    .fail (err) ->
      failed = true
    .fin ->  
      t.true failed
      t.end()

  it 'should succeed when loading an asset type specified by .use', (t) ->
    assets = assload()

    data =
      test: 42

    assets.use
      custom: (name, resolve) ->
        resolve data[name]
    
    assets.load
      custom:
        test: 'test'
    .fin ->
      t.equal assets.custom.test, data.test
      t.end()

  it 'should be able to load multiple assets', (t) ->
    assets = assload()

    data =
      'a.custom': 'AAA'
      'b.custom': 'BBB'
      'c.custom': 'CCC'

    assets.use
      custom: (name, resolve) ->
        resolve data[name]
    
    assets.load
      custom:
        a: 'a.custom'
        b: 'b.custom'
        c: 'c.custom'
    .fin ->
      t.deepEqual assets.custom,
        a: 'AAA'
        b: 'BBB'
        c: 'CCC'
      t.end()

  it 'should emit asset.complete once for each asset that loads', (t) ->
    assets = assload()

    data =
      'a.custom': 'AAA'
      'b.custom': 'BBB'
      'c.custom': 'CCC'

    assets.use
      custom: (name, resolve, reject) ->
        resolve data[name]
    
    complete = 0
    
    notLoaded = ['a', 'b', 'c']
    
    assets.on 'asset.complete', (info) ->
      complete += 1
      
      t.equal info.type, 'custom'
      t.true info.name in notLoaded
      t.equal info.params, info.name + '.custom'

      notLoaded = _.without notLoaded, info.name

    assets.load
      custom:
        a: 'a.custom'
        b: 'b.custom'
        c: 'c.custom'
    .fin ->
      t.equal notLoaded.length, 0
      t.end()

  it 'should emit asset.progress whenever a loader calls a `notify`', (t) ->
    assets = assload()

    data =
      a: 'AAA'
      b: 'BBB'
      c: 'CCC'

    notLoaded = ['a', 'b', 'c']

    assets.use
      custom: (name, resolve, reject, notify) ->
        for i in [1...10]
          do (i) ->
            setTimeout ->
              notify i / 10
            , i

        setTimeout ->
          resolve data[name]
        , 11
    
    assets.on 'asset.progress', (info) ->
      t.true info.amount >= 0
      t.equal info.type, 'custom'
      t.true info.name in notLoaded
      t.equal info.params, info.name + '.custom'

      if info.amount >= 1
        notLoaded = _.without notLoaded, info.name

    assets.load
      custom:
        a: 'a.custom'
        b: 'b.custom'
        c: 'c.custom'
    .fin ->
      t.end()

  it 'should allow bundles to be loaded independently from the same manager', (t) ->
    assets = assload()

    data =
      'a.custom': 'AAA'
      'b.custom': 'BBB'

    assets.use
      custom: (name, resolve, reject) ->
        resolve data[name]
    
    complete = 0

    bundleA = assets.bundle
      custom:
        a: 'a.custom'

    bundleB = assets.bundle
      custom:
        b: 'b.custom'

    bundleA.load().then ->
      t.equal assets.custom.a, 'AAA'
      t.equal assets.custom.b, undefined
      bundleB.load()
    .then ->
      t.equal assets.custom.b, 'BBB'
    .fin ->
      t.equal assets.custom.a, 'AAA'
      t.equal assets.custom.b, 'BBB'
      t.end()