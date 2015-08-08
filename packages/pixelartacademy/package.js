Package.describe({
  name: 'pixelartacademy',
  version: '0.1.0'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');

	api.use('templating');
	api.use('spacebars');
	api.use('coffeescript');
	api.use('stylus');

	api.use('peerlibrary:blaze-components@0.12.0');
  api.use('iron:router@1.0.9');

	api.use('artificial');
	api.use('typography');

	api.export('PixelArtAcademy');

	api.addFiles('main.coffee', 'client');

	api.addFiles('pixelartacademy.html');
	api.addFiles('pixelartacademy.coffee');
	api.addFiles('pixelartacademy.styl');
});
