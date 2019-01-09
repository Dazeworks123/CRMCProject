({
	init : function(component, event, helper) {
		console.log(component.get('v.trade_item'));	
		component.set('v.isDoneDeal',helper.isDoneDeal(component))
	},
	onPullOfferPopup : function(component, event, helper) {
		component.set('v.confirm_open',true);
	},
	onPullOfferConfirm : function(component) {
		var tradeItem = component.get('v.trade_item');
		var eventObj = component.getEvent('onPulled');
		var action = component.get('c.pullOffer');
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
})