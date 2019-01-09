({
	init :function(component, event, helper) {        
		component.set('v.data_filter',{
			destination : 'All',
			country : 'All',
			port : 'All',
			producer : 'All',
			grade:'',
			packing:'',
			payment:'',
			shipping:'',
		});
		// component.set('v.data_filter',{
		// 	country: "Indonesia",
		// 	destination: "Mechelin Super Center 1",
		// 	grade: "SIR 20",
		// 	packing: "Shrink-wrapped (Wooden)",
		// 	payment: "30 Days After Invoice",
		// 	port: "PALEMBANG",
		// 	producer: "Hevea Global",
		// 	shipping: "FOB"
		// });
		helper.getFilterInfo(component,'init');
	},
	
	onSubmit :function(component, event, helper){
		var filter_event = component.getEvent("filter");
		//console.log(component.get('v.data_filter'))
        filter_event.setParams({
			"data_filter": component.get('v.data_filter')
		});
		filter_event.fire(); 
	},

	onChangeFilter :function(component, event, helper){
		helper.toggleProgress(component);
		helper.getFilterInfo(component, '');
	},

	onChangeDestination: function(component, event, helper){
		var changed = 'destination'
		helper.getFilterInfo(component, changed);
	},
	onChangeCountry: function(component, event, helper){
		var changed = 'country'
		helper.getFilterInfo(component, changed);
	},
	onChangePort: function(component, event, helper){
		var changed = 'port'
		helper.getFilterInfo(component, changed);
	},
	onChangeProducer: function(component, event, helper){
		var changed = 'producer'
		helper.getFilterInfo(component, changed);
	},
	onChangeGrade: function(component, event, helper){
		var changed = 'grade'
		helper.getFilterInfo(component, changed);
	},
	onChangeProductSelect: function(component, event, helper){
		var changed = 'product_selection'
		helper.getFilterInfo(component, changed);
	},
})