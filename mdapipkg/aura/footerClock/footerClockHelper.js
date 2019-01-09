({
	clockReal : null,
	startClock : function(component,diff)
	{
		var helper = this;
		helper.setClock(diff,component,helper);
		window.clearInterval(helper.clockReal);
		helper.clockReal = window.setInterval(
	        $A.getCallback(function() { 
				helper.setClock(diff,component,helper);
	        })
        , 1000);      
	},

	setClock : function(diff,component,helper)
	{
		var local = Date.now();
		var serverTime = local - diff;
		var datetime = new Date(serverTime);
		var dateTimeFormat = datetime.toString();
		component.set('v.TimeString',helper.getTimeFormat(dateTimeFormat));
		component.set('v.DateString',helper.getDateFormat(dateTimeFormat));
	},

	getDateFormat: function(dateTimeFormat)
	{
		var month = dateTimeFormat.substr(4,3);
		var day = dateTimeFormat.substr(8,2);
		var year = dateTimeFormat.substr(13,2);
		var GMT = dateTimeFormat.substr(25,6);
		return day+'-'+month+'-'+year+' BE('+GMT+')';
	},

	getTimeFormat: function(dateTimeFormat)
	{
		var time = dateTimeFormat.substr(16,8);
		var hours = parseInt(time.substr(0,2));
		var minsec = time.substr(3,5);
		var ampm = hours >= 12 ? 'PM' : 'AM';
		hours = hours % 12;
		hours = hours ? hours : 12; 
		hours = hours < 10 ? '0'+hours : hours;
		return hours + ':' + minsec + ' ' + ampm;;
	}
})