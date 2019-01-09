({
	// text : 'Hello world',

	alert : function(text) {
		alert(text);
	},

	getAccount : function(component,accountId,callbackFN)
	{
		var action = component.get('c.getAccount');
		action.setParam('AccountId',accountId);
		action.setCallback(this, function(response) {
			
			component.set('v.record',response.getReturnValue());
			if(typeof callbackFN != 'undefined')
			{
				callbackFN();	
			}
		});
	 	$A.enqueueAction(action); 
	}
})