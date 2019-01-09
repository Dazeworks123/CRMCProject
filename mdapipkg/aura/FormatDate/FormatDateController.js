({
	init: function (component, event, helper) {
		var date = new Date(component.get('v.date'));

		var monthNames = [
			"Jan", "Feb", "Mar",
			"Apr", "May", "Jun", "Jul",
			"Aug", "Sep", "Oct",
			"Nov", "Dec"
		  ];
		var day = date.getDate();
		day = day > 9 ? day : '0' + day;

		var month = date.getMonth()+1;
		month = month > 9 ? month : '0' + month;

		var year = date.getFullYear();

		var hour = date.getHours();
		hour = hour > 9 ? hour : '0' + hour;

		var minutes = date.getMinutes();
		minutes = minutes > 9 ? minutes : '0' + minutes;
		
		var sec = date.getSeconds();
		sec = sec > 9 ? sec : '0' + sec;

		var format = year+'-'+month+'-'+day+' '+hour+':'+minutes+':'+sec
 		component.set('v.date_format', format);
	}
})