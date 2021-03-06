Package.describe({
  name: 'landingpage',
  version: '0.1.0'
});

Package.onUse(function (api) {
  api.versionsFrom('1.0.3.1');

	api.use('templating');
	api.use('spacebars');
	api.use('coffeescript');
	api.use('stylus');
	api.use('jquery');

	api.use('peerlibrary:reactive-field@0.1.0');
	api.use('peerlibrary:computed-field@0.3.0');

	api.use('typography');
	api.use('pixelartacademy');
	api.use('artificial');

	api.export('PixelArtAcademy');

	api.addFiles('LZWEncoder.js', 'client');
	api.addFiles('NeuQuant.js', 'client');
	api.addFiles('GIFEncoder.js', 'client');
	api.addFiles('lake.js', 'client');
  api.addFiles('landingpage.html');
	api.addFiles('landingpage.styl');
	api.addFiles('landingpage.coffee');
});
