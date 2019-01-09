({
	onCancel : function(component, event, helper) {
		component.set('v.open',false);
		component.set('v.status_view','view');
		component.set('v.error','');
	},
	onAccept : function(component, event, helper) {
		component.set('v.onLoading',true);
		var trade_data = component.get('v.offer_data');
		console.log(trade_data);
		var action = component.get('c.checkPreAccept');
		action.setParam('quoteObj',trade_data);
		action.setCallback(this, function(response) {
			component.set('v.onLoading',false);
			var res = response.getReturnValue();
			if(res.success){
				component.set('v.error','');
				component.set('v.status_view','accept');
			}	
			else
			{
				component.set('v.error',res.error);
			}
		});
		$A.enqueueAction(action); 
	},
	onReject : function(component, event, helper) {
		component.set('v.error','');
		component.set('v.status_view','reject');
		console.log(component.get('v.history_list'));
	},
	onCounter : function(component, event, helper) {
		component.set('v.onLoading',true);
		var trade_data = component.get('v.offer_data');
		var action = component.get('c.checkPreCounter');
		action.setParam('quoteObj',trade_data);
		action.setCallback(this, function(response) {
			component.set('v.onLoading',false);
			var res = response.getReturnValue();
			if(res.success){
				component.set('v.error','');
				component.set('v.status_view','counter');
			}	
			else
			{
				component.set('v.error',res.error);
			}
		});
		$A.enqueueAction(action); 
	},
	backToView : function(component, event, helper) {
		component.set('v.status_view','view');
	},
	onConfirmAccept : function(component, event, helper) {
		// component.set('v.open',false);
		// var tradeEvent = component.getEvent("onChangeTrade");
		// tradeEvent.setParam('trade_data',component.get('v.offer_data'));
		// tradeEvent.fire();

		component.set('v.open',false);
		var comment = component.get('v.Comment__c_temp');
		component.set('v.offer_data.Comment__c',comment);
		var trade_data = component.get('v.offer_data');
		var tradeEvent = component.getEvent("onChangeTrade");
		var action = component.get('c.tradeConfirm');
		//Sample data---------
		action.setParam('quoteObj',trade_data);
		//--------------------
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			console.log('res form trade confirm: '+res.success);
			if(res.success){
				component.set('v.confirm_open',false);
				tradeEvent.setParam('trade_data',trade_data);
				tradeEvent.fire();
			}	
			else
			{
				alert(res.error);
			}
		});
		$A.enqueueAction(action); 
	},
	onConfirmReject : function(component, event, helper) {
		// component.set('v.open',false);
		// var tradeEvent = component.getEvent("onChangeTrade");
		// tradeEvent.setParam('trade_data',component.get('v.offer_data'));
		// tradeEvent.fire();

		component.set('v.open',false);
		var comment = component.get('v.Comment__c_temp');
		component.set('v.offer_data.Comment__c',comment);
		var trade_data = component.get('v.offer_data');
		var tradeEvent = component.getEvent("onChangeTrade");
		var action = component.get('c.rejectConfirm');
		//Sample data---------
		action.setParam('quoteObj',trade_data);
		//--------------------
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			console.log('res form reject confirm: '+res.success);
			if(res.success){
				component.set('v.confirm_open',false);
				tradeEvent.setParam('trade_data',trade_data);
				tradeEvent.fire();
			}	
			else
			{
				alert(res.error);
			}
		});
		$A.enqueueAction(action); 
	},
	onConfirmCounter : function(component, event, helper) {
		// component.set('v.open',false);
		// var tradeEvent = component.getEvent("onChangeTrade");
		// tradeEvent.setParam('trade_data',component.get('v.offer_data'));
		// tradeEvent.fire();

		component.set('v.open',false);
		var comment = component.get('v.Comment__c_temp');
		component.set('v.offer_data.Comment__c',comment);
		var trade_data = component.get('v.offer_data');
		var tradeEvent = component.getEvent("onChangeTrade");
		var action = component.get('c.counterConfirm');
		//Sample data---------
		action.setParam('quoteObj',trade_data);
		//--------------------
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			console.log('res form counter confirm: '+res.success);
			if(res.success){
				component.set('v.confirm_open',false);
				tradeEvent.setParam('trade_data',trade_data);
				tradeEvent.fire();
			}	
			else
			{
				alert(res.error);
			}
		});
		$A.enqueueAction(action); 
	},
})