({
	checkRef : function(component) {
		var action = component.get("c.refUser");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
            	component.set('v.isLoading',false);
            }
        });
        $A.enqueueAction(action);
	}
})