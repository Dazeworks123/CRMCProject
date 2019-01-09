/* ceNotifierController.js */
({
    fireComponentEvent : function(cmp, event) {
        // Get the component event by using the
        // name value from aura:registerEvent
        var cmpEvent = cmp.getEvent("cmpEvent");
        cmpEvent.setParams({
            "message" : "A component event fired me. " +
            "It all happened so fast. Now, I'm here!" });
        cmpEvent.fire();   

        var popupEvent = cmp.getEvent("popupOpenEvent");
        popupEvent.fire();
    },
    alert : function(cmp, event) {
    	alert('popup close');
    },
    closePopup : function(cmp, event) {
    	var cmpEvent = cmp.getEvent("popupCloseEvent");
        cmpEvent.fire();
    }
})