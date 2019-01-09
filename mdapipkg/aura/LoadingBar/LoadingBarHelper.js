({
	toggleProgress: function (cmp) {
		// start
		cmp.set('v.progress', 0);
		cmp._interval = setInterval($A.getCallback(function () {
			var progress = cmp.get('v.progress');
			cmp.set('v.progress', progress === 100 ? clearInterval(cmp._interval) : progress + 1);
		}), 2);
	}
})