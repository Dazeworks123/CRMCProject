({
	init : function(component, event, helper) {
		helper.callApexMethod(component,helper);
	},
	setUpPusher : function(component, event, helper) {
		var pusher = new Pusher('0b9b27954005b8211a97', {
	      cluster: 'ap1',
	      forceTLS: true
	    });

	    var channel = pusher.subscribe('All');
	    channel.bind('update_quote', function(data) {
			if(data.status != 'Pulled')
			{
				helper.callApexMethod(component,helper);
			}
	    });
		
	}
})