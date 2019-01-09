({
	setFormatPicklist : function(picklist)
	{
		result = [];
		for(var value in picklist)
		{
			result.push({
				text:picklist[value],
				value:value
			});
		}
		return result
	},

	getFilterInfo : function(component, changed) {
        
		var helper = this;
		var data_filter = component.get('v.data_filter');		
		var filter_info = component.get('v.filter_info');        
		var action = component.get('c.getFilterInfo');
		
		if(changed != 'product_selection')
		{
			data_filter.packing = '';
			data_filter.payment = '';
			data_filter.shipping = '';
		}
		if(changed == 'country')
		{            
			data_filter.grade = '';
		}   
        if(changed == 'grade')
		{            
			data_filter.country = 'All';
		}

		component.set('v.onLoadingProductSelection',true);
		action.setParam('data_filter',data_filter);
		action.setCallback(this, function(response) {
            
			var res = response.getReturnValue(); 
			component.set('v.onLoadingProductSelection',false);
			if(res.success){
                
				var data_filterNew = res.data_filter;
				var filter,productSelect;
				if(changed == 'init'){
					filter = {
						destination: helper.setFormatPicklist(res.filter_info.destination),
						country: helper.setFormatPicklist(res.filter_info.country),
						port:helper.setFormatPicklist(res.filter_info.port),
						producer:helper.setFormatPicklist(res.filter_info.producer),
					}
				}else if (changed == 'country'){
                    
						filter = {
							destination: helper.setFormatPicklist(res.filter_info.destination),
							country: filter_info.filter.country,
							port:helper.setFormatPicklist(res.filter_info.port),
							producer:helper.setFormatPicklist(res.filter_info.producer),
						};
						data_filterNew.grade = res.filter_info.defaultGrade;
				} else if(changed == 'grade') {
                    
                    filter = {
						destination: filter_info.filter.destination,
						country: filter_info.filter.country,
						port: filter_info.filter.port, 
						producer:filter_info.filter.producer,                   
					}                    
                    data_filterNew.country = res.filter_info.defaultCountry ;
                    
                } else {                    
					filter = {
						destination: filter_info.filter.destination,
						country: filter_info.filter.country,
						port: filter_info.filter.port, 
						producer:filter_info.filter.producer,
					}
				}

				if(changed =='product_selection' || changed == 'grade')
				{                    
					productSelect = {
						grade:filter_info.product.grade,
						packing:helper.setFormatPicklist(res.filter_info.packing),
						payment:helper.setFormatPicklist(res.filter_info.payment),
						shipping:helper.setFormatPicklist(res.filter_info.shipping)
					};
				}
				else
				{                    
					productSelect = {
						grade:helper.setFormatPicklist(res.filter_info.grade),
						packing:helper.setFormatPicklist(res.filter_info.packing),
						payment:helper.setFormatPicklist(res.filter_info.payment),
						shipping:helper.setFormatPicklist(res.filter_info.shipping)
					};	
				}	

				component.set('v.filter_info', {
					filter: filter,
					product:productSelect
				});


				component.set('v.data_filter',data_filterNew);
			}
		});
		$A.enqueueAction(action); 
	},
	
})