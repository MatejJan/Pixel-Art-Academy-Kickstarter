Package.describe({
  name: 'artificial',
  version: '0.1.0'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');

	api.use('coffeescript');
	api.use('tracker');
	api.use('underscore');
	api.use('jquery');
	api.use('templating');
	api.use('spacebars');
	api.use('stylus');

	api.use('peerlibrary:assert@0.2.5');
	api.use('peerlibrary:blaze-components@0.12.0');
	api.use('peerlibrary:reactive-field@0.1.0');
	api.use('peerlibrary:computed-field@0.3.0');

	api.export('Artificial');

	api.addFiles('artificial.coffee');
	api.addFiles('base.coffee');
	api.addFiles('everywhere.coffee');
	api.addFiles('mirage.coffee');

	api.addFiles('base/app.coffee');
	api.addFiles('base/services.coffee');

	api.addFiles('everywhere/jquery/positioncss.coffee', 'client');
	api.addFiles('everywhere/rectangle.coffee');

	api.addFiles('mirage/component.coffee');
	api.addFiles('mirage/csshelper.coffee');
	api.addFiles('mirage/debugfont.css');
	api.addFiles('mirage/display.html');
	api.addFiles('mirage/display.coffee');
	api.addFiles('mirage/display.styl');
	api.addFiles('mirage/window.coffee');

});
