<center>
  ![Assload](http://i.imgur.com/9DCd9dD.jpg)
</center>

# assload [![Build Status](https://drone.io/github.com/gitsubio/assload/status.png)](https://drone.io/github.com/gitsubio/assload/latest) [![dependency Status](https://david-dm.org/gitsubio/assload/status.svg?style=flat-square)](https://david-dm.org/gitsubio/assload#info=dependencies) [![devDependency Status](https://david-dm.org/gitsubio/assload/dev-status.svg?style=flat-square)](https://david-dm.org/gitsubio/assload#info=devDependencies)

Modular, extensible asset manager with preloading capabilities.

**NOTE:** This is experimental software; use at your own risk. (And please [report issues](http://github.com/gitsubio/assload/issues))

```js
var assload = require('assload'),
    loadImages = require('assload-image'),
    loadAudio = require('assload-audio'),
    assets, loader, music;

// Create a new asset manager:
assets = assload();

// Configure the asset manager to use specific loaders
//  for different asset types
assets.use({
  images: loadImages(),
  sounds: loadAudio({preload: 'full'}),
  music: loadAudio()
});

// Create a bundle for our game's essential assets:
essentials = assets.bundle({
  images: {
    bacon: 'bacon.png',
    eggs: 'eggs.jpg'
  },
  sounds: {
    quack: ['quack.ogg', 'quack.wav']
  }
});

// Create a different bundle for non-essential background music:
backgroundMusic = assets.bundle({
  music: {
    level1: ['level1.ogg', 'level1.mp3', 'level1.m4a'],
    battle: ['battle.ogg', 'battle.mp3', 'battle.m4a']
  }
});

// Listen for asset's progressive loading events:
essentials.on('asset.progress', function (info) {
  console.log(info.type + ':' + info.name + ': %' + Math.round(info.amount*100));
});

// Listen for asset loading completion events:
essentials.on('asset.complete', function (info) {
  console.log(info.totalComplete + ' out of ' + info.totalCount + ' assets loaded');
});

// Load the essentials first:
essentials.load().then(function () {
  console.log('Bacon:', assets.images.bacon); // Bacon: <img src='bacon.png' />
  console.log('Eggs:', assets.images.eggs);   // Eggs: <img src='eggs.jpg' />
  console.log('Quack:', assets.sounds.quack); // Quack: <audio src='quack.ogg' />
}).then(function () {
  // The important stuff loaded, now start the game...
  // mainLoop() or whatever you use...

  // ...and now load our music in the background
  return backgroundMusic.load();
}).done(function () {
  // Now the background music has loaded, go ahead and play it:
  assets.music.level1.play();
}).catch(function (err) {
  throw err;
});
```

## API

```js
var assload = require('assload');
```

### Create a new asset manager

```js
var assets = assload();
```

### Configure an asset manager to load specific asset types

Assload knows nothing about how to load specific types of assets.

You must supply a loader function for any type of asset you wish to load.

```js
assets.use({
  images: loadImages(),
  sounds: loadAudio(),
  foobars: function (whatToLoad, resolve, reject, notify) { /* ... */ }
});
```

See also: [Create a custom loader](#create-a-custom-loader)

### Create a bundle of assets to load

```js
var bundle = assets.bundle({
  images: {
    bacon: 'bacon.png',
    eggs: 'eggs.jpg'
  },
  sounds: {
    quack: ['quack.ogg', 'quack.mp3', 'quack.wav']
  }
})
```

### Load a bundle of assets

```js
bundle.load().then(function () {
  console.log('All assets have been loaded!');
}, function (err) {
  console.error(err);
});
```

`bundle.load()` returns a [Q](https://github.com/kriskowal/q) promise that
resolves when all assets have completed.

### Access loaded assets

Once an asset is loaded, it can be accessed simply with `assets.<type>.<name>`.

Prior to loading, the `assets.<type>.<name>` is undefined.

For example:

```js
bundle = assets.bundle({
  images: {
    player: 'player.png'
  }
});

bundle.load(function () {
  console.log('Player:', assets.images.player); // Player: <img src='player.png' />
});
```

### Listen for progress events

If a loader function uses `notify` to report partially-loaded asset progress,
`asset.progress` events will be fired.

```js
bundle.on('asset.progress', function (info) {
  console.log('Asset type', info.type);
  console.log('Asset name', info.name);
  console.log('Asset parameters', info.params);
  console.log('Percentage loaded', Math.round(info.amount*100));
});
```

### Listen for completion events

Whenever a single asset is successfully loaded, an `asset.complete` event is fired.

```js
bundle.on('asset.complete', function (info) {
  console.log('Asset type', type);
  console.log('Asset name', name);
  console.log('Asset parameters', params);
  console.log('The loaded asset', asset);
  console.log('The total number of assets being loaded', totalCount);
  console.log('The total number of assets that have loaded', totalComplete);
});
```

### Create a custom loader <a name='create-a-custom-loader' />

Loader functions take on the following format:

```js
assets.use({
  custom: function (whatToLoad, resolve, reject, notify) {
    // load the asset here
  }
});
```

> **`whatToLoad`**
> A value passed from `assets.load(...)`; this is usually a filename/uri, but can be any value.

> **`resolve(asset)`**
> A function to call when the asset has successfully loaded.
>
> > **`asset`**
> > The loaded asset.

> **`reject(reason)`**
> A function to call when the asset failed to load.
>
> > **`reason`**
> > A `new Error` with a message describing why the asset failed to load.

> **`notify(progress)`**
> A function to optionally call periodically as the asset progressively loads.
> 
> > **`progress`**
> > Value from 0 to 1 representing the percentage of the asset that has loaded.

## License

MIT

## Install

```bash
npm install assload --save
```

----

[![Analytics](https://ga-beacon.appspot.com/UA-33247419-2/assload/README.md)](https://github.com/igrigorik/ga-beacon)
