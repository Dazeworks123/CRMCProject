({
	init : function(component, event, helper) {
		console.log(component.get('v.trade_item'));	
		component.set('v.isDoneDeal',helper.isDoneDeal(component))
	},
	onPullBidPopup : function(component, event, helper) {
		component.set('v.confirm_open',true);
	},
	onPullBidConfirm : function(component, event, helper) {
		// component.set('v.confirm_open',false);
		// component.set('v.trade_item.pull',true);
		// console.log(component.get('v.trade_item'));

		var tradeItem = component.get('v.trade_item');
		var eventObj = component.getEvent('onPulled');
		var action = component.get('c.pullBid');
		action.setParam('quoteObj',tradeItem);
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			if(res.success){
				component.set('v.confirm_open',false);
				eventObj.setParam('trade_data',tradeItem);
				eventObj.fire();
			}	
			else
			{
				alert(res.error);
			}
		});
		$A.enqueueAction(action); 

	},
	onTradePopup : function(component, event, helper) {
		component.set('v.trade_view','view');
		component.set('v.trade_open',true);
		console.log(component.get('v.trade_item'));
		var tradeItem = component.get('v.trade_item');
		var action = component.get('c.getHistoryList');
		action.setParam('quoteObj',tradeItem);
		action.setCallback(this, function(response){
			component.set('v.history_list', response.getReturnValue());
			console.log(component.get('v.history_list'))
		});
		$A.enqueueAction(action); 
	},
	onChangeTrade : function(component, event, helper) {
		console.log(event.getParam('trade_data'));
	},
	onClickStar : function(component, event, helper){
		var tradeItem = component.get('v.trade_item');
		var eventObj = component.getEvent('onFavorite');
		var action = component.get('c.onChangeFavorite');
		action.setParam('quoteObj',tradeItem);
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			if(res.success){
				eventObj.setParam('trade_data',tradeItem);
				eventObj.fire();
			}	
			else
			{
				alert(res.error);
			}
		});
		$A.enqueueAction(action); 
	},
	onHistoryPopup : function(component, event, helper){
		var tradeItem = component.get('v.trade_item');
		component.set('v.history_open',true);
		component.set('v.onLoadingHistory',true);
		var action = component.get('c.getHistoryList');
		action.setParam('quoteObj',tradeItem);
		action.setCallback(this, function(response){
			component.set('v.history_list', response.getReturnValue());
			component.set('v.onLoadingHistory',false);
			console.log(component.get('v.history_list'))
		});
		$A.enqueueAction(action); 
		

	},
})