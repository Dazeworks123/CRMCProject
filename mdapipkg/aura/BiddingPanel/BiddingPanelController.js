({
	init :function(component, event, helper) {
	},
	onFilter :function(component, event, helper){
		var filter = event.getParam("data_filter");
		component.set('v.data_filter',filter);
		helper.filterData(component,filter);
	},
	onChangeTrade :function(component, event, helper){
		var filter = component.get('v.data_filter');
		helper.filterData(component,filter);
	},
	last6Month :function(component, event, helper){
		component.set('v.DateSelected',component.get('v.DateList.date_pre'));
		var filter = component.get('v.data_filter');
		helper.filterData(component,filter);
	},
	next6Month :function(component, event, helper){
		component.set('v.DateSelected',component.get('v.DateList.date_next'));
		var filter = component.get('v.data_filter');
		helper.filterData(component,filter);
	},
	setUpPusher : function(component, event, helper) {
		var pusher = new Pusher('0b9b27954005b8211a97', {
	      cluster: 'ap1',
	      forceTLS: true
	    });
		
	    var channel = pusher.subscribe('All');
	    channel.bind('update_quote', $A.getCallback(function(data) {
	    	var showTable = component.get('v.showTable');
	    	var filter = component.get('v.data_filter');
	    	if(showTable)
	    	{
	    		helper.setFilterList(component,filter);	
				// helper.setFilterList(component,filter,
				// function(){ // preloading
				// 	console.log('preloading');
				// 	var myEvent = $A.get("e.c:ReloadEvent");
				// 	myEvent.setParam('loading',true);
				// 	myEvent.fire(); 
				// },
				// function(){ // after loading
				// 	console.log('after loading');
				// 	var myEvent = $A.get("e.c:ReloadEvent");
				// 	myEvent.setParam('loading',false);
				// 	myEvent.fire(); 	
				// });	
	    	}
			
	    }));
	}
})