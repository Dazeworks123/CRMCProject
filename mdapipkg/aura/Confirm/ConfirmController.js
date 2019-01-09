({
	init : function(component, event, helper) {
		var label = component.get('v.confirm_label');
		if(label == NaN){
			component.set('v.confirm_label',"Confirm");
		}
	},
	onConfirm : function(component, event, helper) {
		var onConfirm = component.getEvent('onConfirm');
		onConfirm.setParam('eventName',component.get('v.eventName'));
		onConfirm.fire();
	},
	onCancel : function(component, event, helper) {
		component.set('v.open',false);
	}
})