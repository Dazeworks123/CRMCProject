({
	init : function(component, event, helper) {
		// component.set('v.grade_info',{
		// 	header:[
		// 		{
		// 			name:"grade",
		// 			label:"GRADE"
		// 		},
		// 		{
		// 			name:"AdditionalPremium",
		// 			label:"ADDITIONAL PREMIUM"
		// 		},
		// 	],
		// 	data:[
		// 		[
		// 			{fieldname:'grade',value:'SIR20'},
		// 			{fieldname:'AdditionalPremium',value:'$0.00'}
		// 		],
		// 		[
		// 			{fieldname:'grade',value:'SIR10'},
		// 			{fieldname:'AdditionalPremium',value:'$10.00'}
		// 		],
		// 		[
		// 			{fieldname:'grade',value:'SIR5'},
		// 			{fieldname:'AdditionalPremium',value:'$50.00'}
		// 		],
		// 		[
		// 			{fieldname:'grade',value:'SIR20MR'},
		// 			{fieldname:'AdditionalPremium',value:'$35.00'}
		// 		],
		// 		[
		// 			{fieldname:'grade',value:'SIR10MR'},
		// 			{fieldname:'AdditionalPremium',value:'$45.00'}
		// 		],
		// 		[
		// 			{fieldname:'grade',value:'SIR20VK'},
		// 			{fieldname:'AdditionalPremium',value:'$55.00'}
		// 		],
		// 		[
		// 			{fieldname:'grade',value:'SIR10VK'},
		// 			{fieldname:'AdditionalPremium',value:'$65.00'}
		// 		]
		// 	]
		// });
		// component.set('v.packing_info',{
		// 	header:[
		// 		{
		// 			name:"packing",
		// 			label:"PACKING"
		// 		},
		// 		{
		// 			name:"pricing",
		// 			label:"PRICING"
		// 		},
		// 	],
		// 	data:[
		// 		[
		// 			{fieldname:'packing',value:'Loose Bale'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'packing',value:'Shrink-wrapped (Wooden)'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'packing',value:'Shrink-wrapped (Plactic)'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'packing',value:'Shrink-wrapped (DNP)'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'packing',value:'MB4'},
		// 			{fieldname:'pricing',value:'-$5.00'}
		// 		],[
		// 			{fieldname:'packing',value:'MB5'},
		// 			{fieldname:'pricing',value:'-$5.00'}
		// 		],[
		// 			{fieldname:'packing',value:'GPS MB'},
		// 			{fieldname:'pricing',value:'-$5.00'}
		// 		]
		// 	]
		// });
		// component.set('v.payment_info',{
		// 	header:[
		// 		{
		// 			name:"payment",
		// 			label:"PAYMENT"
		// 		},
		// 		{
		// 			name:"pricing",
		// 			label:"PRICING"
		// 		},
		// 	],
		// 	data:[
		// 		[
		// 			{fieldname:'payment',value:'Loose Bale'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'payment',value:'Shrink-wrapped (Wooden)'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'payment',value:'Shrink-wrapped (Plactic)'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'payment',value:'Shrink-wrapped (DNP)'},
		// 			{fieldname:'pricing',value:'$0.00'}
		// 		],[
		// 			{fieldname:'payment',value:'MB4'},
		// 			{fieldname:'pricing',value:'-$5.00'}
		// 		],[
		// 			{fieldname:'payment',value:'MB5'},
		// 			{fieldname:'pricing',value:'-$5.00'}
		// 		],[
		// 			{fieldname:'payment',value:'GPS MB'},
		// 			{fieldname:'pricing',value:'-$5.00'}
		// 		]
		// 	]

		// })
		// component.set('v.destination_info',{
		// 	header:[
		// 		{
		// 			name:"destination",
		// 			label:"DESTINATION"
		// 		},
		// 		{
		// 			name:"cif",
		// 			label:"CIF"
		// 		},
		// 		{
		// 			name:"cfrcnf",
		// 			label:"CFR/CNF"
		// 		},
		// 	],
		// 	data:[
		// 		[
		// 			{fieldname:'destination',value:'America'},
		// 			{fieldname:'cif',value:'$20.00'},
		// 			{fieldname:'cfrcnf',value:'$18.00'}
		// 		],[
		// 			{fieldname:'destination',value:'Brazil'},
		// 			{fieldname:'cif',value:'$22.00'},
		// 			{fieldname:'cfrcnf',value:'$20.00'}
		// 		],[
		// 			{fieldname:'destination',value:'China'},
		// 			{fieldname:'cif',value:'$10.00'},
		// 			{fieldname:'cfrcnf',value:'$9.00'}
		// 		],[
		// 			{fieldname:'destination',value:'Europe'},
		// 			{fieldname:'cif',value:'$15.00'},
		// 			{fieldname:'cfrcnf',value:'$13.00'}
		// 		]
		// 	]

		// })

	},

	setUpInformation : function(component, event, helper) {

		var FilterInfo = event.getParam("data_filter");
		var action = component.get('c.getInformation');
		action.setParam('FilterInfo',FilterInfo);
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			console.log(res);
			component.set('v.grade_info',res.grade_info);
			component.set('v.packing_info',res.packing_info);
			component.set('v.payment_info',res.payment_info);
			component.set('v.destination_info',res.destination_info);

		});
		$A.enqueueAction(action); 

	},
	onOpenInfo : function(component, event, helper) {
		var open_info = component.get('v.open_info');
		component.set('v.open_info',!open_info);
	},
	onClickSideBar : function(component, event, helper) {
		var isClick = component.get('v.isClickSidebar');
		setTimeout(function(){
			window.dispatchEvent(new Event('resize'));
		},500);
		
		component.set('v.isClickSidebar',!isClick);
	}
})