/* ceHandlerController.js */
({
    handleComponentEvent : function(cmp, event) {
        var message = event.getParam("message");
        console.log('ceHandler Work');
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
    },

    openPopup : function (cmp){
        var popupEvent = cmp.getEvent("popupOpenEvent");
        popupEvent.fire();
    }
})