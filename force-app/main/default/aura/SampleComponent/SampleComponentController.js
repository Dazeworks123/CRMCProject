({
	init : function(component, event, helper) {
		// alert('Loaded SampleComponent');
		console.log('Loaded SampleComponent');
		// component.set('v.info',{
		// 	popup_info:{
		// 		show:false
		// 	}
		// });

		console.log(component.get('v.isPopup'));

		helper.getAccount(component,'0010l00000W46hdAAB');
	},
	destroy : function(component, event, helper) {
		alert('remove SampleComponent');
		// console.log(component.get('v.record'));
	},
	goodbye : function(component, event, helper) {

		var accountId = prompt("Add Account Id","0010l00000W46hdAAB");

		helper.getAccount(component,accountId,function(){
			component.set('v.sample_name',"Good bye!");	
		});
	},

	viewAll: function(component, event, helper) {
		var text = component.get('v.sample_name');
		helper.alert(text);
	},

	openModel: function(component){
		component.set('v.isPopup',true);
		// component.set('v.info.popup_info.show',true);
	},
	closeModel : function(component,event){

		console.log('SampleComponent Popup Close');
		component.set('v.isPopup',false);
	}



})