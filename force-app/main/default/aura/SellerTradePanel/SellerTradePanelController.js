({
	init : function(component, event, helper) {
		component.set('v.sort_info',{
			columns:'',
			type:''
		});
		helper.getTradeList(component);
	},

	onFavorite : function(component, event, helper) {

		helper.getTradeList(component);
	},

	changeSort : function(component, event, helper) {
		component.set('v.sort_info',{
			columns:event.getParam('columns'),
			type:event.getParam('type'),
		});
		helper.getTradeList(component);
	},


	showLoading : function(component, event, helper) {
		component.set('v.onLoading',true);
	},
	
	setUpPusher : function(component, event, helper) {
	    var pusher = new Pusher('0b9b27954005b8211a97', {
	      cluster: 'ap1',
	      forceTLS: true
	    });

	    var channel = pusher.subscribe('All');
	    channel.bind('update_quote', function(data) {
			helper.getTradeList(component);	      
	    });
	},
	
	onPullPopup : function(component, event, helper) {
		component.set('v.confirm_open',true);
	},

	onPopupConfirm : function(component, event, helper) {
		if(event.getParam('eventName') == 'PullAllConfirm')
		{
			var action = component.get('c.on'+event.getParam('eventName'));
			$A.enqueueAction(action); 
		}
	},

	onPullAllConfirm : function(component, event, helper) {
		
		component.set('v.confirm_open',false);
		component.set('v.onLoading',true);
			var action = component.get('c.pullAllOffer');
			action.setCallback(this, function(response) {
				var res = response.getReturnValue();
				if(res.success){ 
					//Reload Screen
					// $A.get('e.force:refreshView').fire();
					console.log(component.get('v.data_list'));

				}else{
					alert(res.error)
				}	
			});
			$A.enqueueAction(action); 
			component.set('v.onLoading',false);
	},
})