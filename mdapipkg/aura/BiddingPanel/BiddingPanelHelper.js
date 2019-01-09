({
	filterData : function(component, filter){
		var helper = this;
		if(!component.get('v.DateSelected'))
		{
			component.set('v.DateSelected',filter.date_now);
		}
		filter.date = component.get('v.DateSelected');
		helper.setFilterList(component, filter);
		// if(filter.grade !='' && filter.packing !='' && filter.payment !='' && filter.shipping != '')
		// {
		// 	helper.setFilterList(component, filter);
		// }
		// else
		// {
		// 	alert('Product selection not empty');
		// }
	},
	setFilterList : function(component, filter,preloadCallback,afterloadCallback){
		var helper = this;
		component.set('v.showTable',true);
		
		if(typeof preloadCallback =='function'){ preloadCallback(); }
		else{ component.set('v.onLoading',true) }

		var action = component.get('c.getBiddingList');
		action.setParam('data_filter',filter);
		action.setCallback(this, function(response) {
			var res = response.getReturnValue(); 
			if(res.success)
			{
				component.set('v.data_list',res);
				component.set('v.DateList',{
					date_pre:res.date_pre,
					date_next:res.date_next,
				});
			}
			else
			{
				alert(res.error);
				component.set('v.showTable',false);	
			}

			if(typeof afterloadCallback =='function'){ afterloadCallback(); }
			else{ component.set('v.onLoading',false) }
		});

		$A.enqueueAction(action);
	}
})