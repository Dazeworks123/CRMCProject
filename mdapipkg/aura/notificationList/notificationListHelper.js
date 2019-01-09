({
    notifyReal : {},
	handleResponse : function (response, component){
        var resVal = response.getReturnValue() ;
        var error = response.getError();
        if(resVal)
        {
            component.set("v.error",''); 
            component.set("v.numberOfNotify",resVal.count); 
            component.set("v.notifyList",resVal.list); 
        }
        else
        {
            if(error)
            {
                component.set("v.error",error[0].message); 
            }
        }
        
    },
    callApexMethod : function (component,helper){    
        var action = component.get("c.getNotify");        
        action.setCallback(this, function(response) {
            this.handleResponse(response, component);
        });
        $A.enqueueAction(action); 
    } 
})