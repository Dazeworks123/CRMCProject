({
	init: function (component, event, helper) {
		var date = new Date(component.get('v.date'));

		var hour = date.getHours();
		hour = hour > 9 ? hour : '0' + hour;

		var minutes = date.getMinutes();
		minutes = minutes > 9 ? minutes : '0' + minutes;
		
		var sec = date.getSeconds();
		sec = sec > 9 ? sec : '0' + sec;

		var format = hour+':'+minutes;
 		component.set('v.time_format', format);
	}
})