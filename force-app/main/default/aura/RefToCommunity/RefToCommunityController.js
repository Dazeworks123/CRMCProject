({
	initialize : function(component, event, helper) {
		// helper.checkRef(component);

		window.setTimeout(
	        $A.getCallback(function() { 
	            helper.checkRef(component);
	        })
        , 100);
	}
})