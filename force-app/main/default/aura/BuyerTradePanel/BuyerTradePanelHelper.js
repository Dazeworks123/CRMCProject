({
	helperMethod : function() {
	},
	getTradeList : function(component,callbackFN)
	{
		component.set('v.onLoading',true);
		var sort_info = component.get('v.sort_info');
		var action = component.get('c.getTradeList');
		action.setParam('sort_info',sort_info);
		action.setCallback(this, function(response) {
			component.set('v.data_list',response.getReturnValue());
			component.set('v.onLoading',false);
			if(typeof callbackFN != 'undefined')
			{
				callbackFN();	
			}
		});
	 	$A.enqueueAction(action); 
	},
})