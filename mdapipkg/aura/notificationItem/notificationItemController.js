({
	init : function(component, event, helper) {
		var date = new Date(component.get('v.notify.CreatedDate'));
		var timeString = date.toTimeString();
		component.set('v.date',date.toLocaleDateString());		
		component.set('v.time',timeString.substr(0,8));		
	}
})