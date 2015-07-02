Package.describe({
  name: 'typography',
  version: '0.1.0'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');

	api.use('stylus');

	api.addFiles('typography.css');
  api.addFiles('typography.styl');
	api.addFiles('typography.import.styl');
});
