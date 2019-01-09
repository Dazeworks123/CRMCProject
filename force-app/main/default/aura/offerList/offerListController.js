({
	init :function(component, event, helper) {
		component.set('v.confirm_popup_info',{
			open :false,
			eventName:'',
			description:'',
		});

		component.set('v.ConsumerSelected','All');
		helper.setUpAllFilter(component);
	},

	changeConsumer : function(component, event, helper) {
		helper.setUpCountry(component);
	},
	changeCountry : function(component, event, helper) {
		helper.onChangeFilter(component);
	},

	last6Month : function(component, event, helper) {
		component.set('v.DateSelected',component.get('v.DateList.date_pre'));
		helper.getOfferList(component);
	},
	next6Month : function(component, event, helper) {
		component.set('v.DateSelected',component.get('v.DateList.date_next'));
		helper.getOfferList(component);
	},
	setUpPusher : function(component, event, helper) {
		var pusher = new Pusher('0b9b27954005b8211a97', {
	      cluster: 'ap1',
	      forceTLS: true
	    });
		
	    var channel = pusher.subscribe('All');
	    channel.bind('update_quote', $A.getCallback(function(data) {
			var isEdited = component.get('v.isEdited');
			console.log('isEdited : '+isEdited);
			if(isEdited)
			{
				component.set('v.warningRefresh',true);
			}
			else
			{
				helper.getOfferList(component);
				// helper.getOfferList(component,
				// function(){ // preloading
				// 	var myEvent = $A.get("e.c:ReloadEvent");
				// 	myEvent.setParam('loading',true);
				// 	myEvent.fire(); 
				// },
				// function(){ // after loading
				// 	var myEvent = $A.get("e.c:ReloadEvent");
				// 	myEvent.setParam('loading',false);
				// 	myEvent.fire(); 	
				// });	
			}
	    }));
	},

	refreshData : function(component, event, helper) {
		component.set('v.isEdited',false);
		component.set('v.warningRefresh',false);
		helper.getOfferList(component);
		// helper.getOfferList(component,
		// function(){ // preloading
		// 	var myEvent = $A.get("e.c:ReloadEvent");
		// 	myEvent.setParam('loading',true);
		// 	myEvent.fire(); 
		// },
		// function(){ // after loading
		// 	var myEvent = $A.get("e.c:ReloadEvent");
		// 	myEvent.setParam('loading',false);
		// 	myEvent.fire(); 	
		// });	
	},

	saveList : function(component, event, helper) {
		component.set('v.confirm_popup_info',{
			open :true,
			eventName:'c.onSaveConfirm',
			description:'Are you sure you want to save?',
		});
	},
	postToCustomer : function(component, event, helper) {
		component.set('v.confirm_popup_info',{
			open :true,
			eventName:'c.onPostToCustomerConfirm',
			description:'Are you sure you want to post to customer?',
		});
	},
	pullAllOffer : function(component, event, helper) {
		component.set('v.confirm_popup_info',{
			open :true,
			eventName:'c.onPullAllConfirm',
			description:'Are you sure that you want to PULL ALL OFFERS?',
		});
	},
	factoryView : function(component, event, helper) {
		component.set('v.view','factory');
		helper.getOfferList(component);
	},
	portView : function(component, event, helper) {
		component.set('v.view','port');	
		helper.getOfferList(component);
	},
	onConfirm: function(component, event, helper) {
		var eventName = event.getParam('eventName');
		var action = component.get(eventName);
		$A.enqueueAction(action); 
	},
	onSaveConfirm : function(component, event, helper) {
		component.set('v.isEdited',false);
		component.set('v.warningRefresh',false);
		component.set('v.confirm_popup_info.open',false);
		component.set('v.saveStatus','Draft');
		helper.saveOffer(component);
	},
	onPostToCustomerConfirm : function(component, event, helper) {
		component.set('v.isEdited',false);
		component.set('v.warningRefresh',false);
		component.set('v.confirm_popup_info.open',false);
		component.set('v.saveStatus','Open');
		helper.saveOffer(component);
	},
	onPullAllConfirm : function(component, event, helper) {
		component.set('v.isEdited',false);
		component.set('v.warningRefresh',false);
		component.set('v.confirm_popup_info.open',false);
		component.set('v.saveStatus','Pulled');
		helper.saveOffer(component);
	},
	onOfferConfirm : function(component, event, helper) {
		component.set('v.isEdited',false);
		component.set('v.warningRefresh',false);
		component.set('v.confirm_popup_info.open',false);
		component.set('v.isConfirm',true);
		helper.saveOffer(component);
	},
})