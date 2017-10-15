(function() {
	// We return the global jQuery object, assuming that it will always
	// be on the page. This prevents race conditions with Require modules possibly
	// reloading jQuery, overwriting the global one (and any already loaded plugins)
	define('jquery', function() { return jQuery; });
	define('twttr', ['//platform.twitter.com/widgets.js'], function() { return twttr; });

	var require_options = {
		'packagePaths':  {
			'gu' : 'http://static.gu.com/js/gu'
		}
	};

	var require_script = document.getElementById('require-js');
	var modules = require_script.getAttribute('data-modules').split(/\s?,\s?/);
	var callback = require_script.getAttribute('data-callback');

	require(require_options, modules, function() {
		if (window[callback] && typeof window[callback] === 'function') {
			window[callback]();
		}
	});
})();

