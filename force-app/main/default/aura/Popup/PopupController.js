({
	myAction : function(component, event, helper) {
	},

	closeModal : function(component,event){
		var popupEvent = component.getEvent("popupCloseEvent");
		popupEvent.fire();
		// console.log(component.get('v.info'));
		// component.set('v.info',{
		// 	show:false
		// });
		// console.log(component.get('v.info'));
		// alert('555');
		// component.set('v.show',false);
	}	
})