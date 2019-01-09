({
	init : function(component, event, helper) {
		var action = component.get("c.setTime");
        $A.enqueueAction(action); 
	},

	setTime : function(component, event, helper)
	{
		var action = component.get("c.getTimestamp");
		var start = Date.now();
        action.setCallback(this, function(response) {

        	var resVal = response.getReturnValue() ;
        	var error = response.getError();
        	if(resVal)
	        {
	        	var local = Date.now();
        		var diff = local - resVal;
	         	helper.startClock(component,diff);
	        }
	        else
	        {
	        	setTimeout(function(){
	        		var action = component.get("c.setTime");
        			$A.enqueueAction(action); 
	        	}, 1000);
	        }
        });
        $A.enqueueAction(action); 	
	},
	destroy : function(component, event, helper) {
		window.clearInterval(helper.clockReal);
	}

});