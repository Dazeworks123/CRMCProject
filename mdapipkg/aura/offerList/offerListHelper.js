({
	setUpAllFilter : function(component)
	{
		var helper = this;
		var ConsumerSelected = component.get('v.ConsumerSelected');
		var action = component.get('c.getFilterInfo');
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			component.set('v.filter_info',res.filter_info);
			component.set('v.DateSelected',res.date_now);
			var consumerList = [];
			
			for(var indexVar in res.filter_info)
			{
				consumerList.push({
					label : res.filter_info[indexVar].label,
					value : indexVar
				});
			}
			component.set('v.ConsumerList',consumerList);
			helper.setUpCountry(component);
		});
		$A.enqueueAction(action); 
	},

	setUpCountry : function(component)
	{
		var helper = this;
		var filter_info = component.get('v.filter_info');
		var consumerSelected = component.get('v.ConsumerSelected');
		var countrySelected = component.get('v.CountrySelected');
		var countryListFormat = filter_info[consumerSelected].country_list;
		var countryList = [];

		for(var indexVar in countryListFormat)
		{
			countryList.push({
				label : countryListFormat[indexVar],
				value : indexVar
			});
		}
		if(!countryListFormat[countrySelected])
		{
			component.set('v.CountrySelected',countryList[0].value);
		}
		component.set('v.CountryList',countryList);
		helper.onChangeFilter(component);
	},

	onChangeFilter : function(component)
	{
		var helper = this;
		helper.getOfferList(component);
		var filter_event = component.getEvent("onChangeFilter");
        filter_event.setParams({
			"data_filter": {
				consumer : component.get('v.ConsumerSelected'),
				country : component.get('v.CountrySelected'),
				date : component.get('v.DateSelected')
			}
		});
		filter_event.fire(); 
	},
	getOfferList : function(component,preloadCallback,afterloadCallback)
	{
		if(typeof preloadCallback =='function'){ preloadCallback(); }
		else{ component.set('v.onLoading',true) }
		
		var filter_info = {
			consumer : component.get('v.ConsumerSelected'),
			country : component.get('v.CountrySelected'),
			date : component.get('v.DateSelected'),
			view : component.get('v.view'),
		}
		var action = component.get('c.getOfferList');
		action.setParam('FilterInfo',filter_info);
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			component.set('v.data_list',res);
			component.set('v.DateList',{
				date_pre:res.date_pre,
				date_next:res.date_next,
			});
			if(typeof afterloadCallback =='function'){ afterloadCallback(); }
			else{ component.set('v.onLoading',false) }
		});
		$A.enqueueAction(action); 
	},


	saveOffer : function(component)
	{
		var helper = this;	
		var status = component.get('v.saveStatus');
		var view = component.get('v.view');
		var offerList = component.get('v.data_list');
		var offerData = offerList.data;
		var dataIndex = view == 'factory'?4:2;
		var saveList = [];
		var saveInfo = {
			consumer : component.get('v.ConsumerSelected'),
			country : component.get('v.CountrySelected'),
			date : component.get('v.DateSelected'),
			view : view,
			status : status,
		};
		if(component.get('v.isConfirm'))
		{
			saveInfo.confirm = 'confirm';			
		}

		for(var rowIndex in offerData)
		{
			var row = offerData[rowIndex];
			for(var colIndex = dataIndex;colIndex<row.length;colIndex++ )
			{
				var obj = row[colIndex];
				if(obj.status =='Draft' || (status == 'Pulled' && obj.status != '') )
				{
					var objectSave = {
						COUNTRY:row[0].value,
						PORTS:row[1].value,
						FACTORY: view == 'factory'?row[2].value:'',
						DATE : obj.fieldname,
						value:obj.value,
					}
					saveList.push(objectSave);
				}
			}
		}
		// component.set('v.onLoading',true);
		var action = component.get('c.saveOffer');
		action.setParam('SaveInfo',saveInfo);
		action.setParam('SaveList',JSON.stringify(saveList));
		action.setCallback(this, function(response) {
			var res = response.getReturnValue();
			component.set('v.isConfirm',false);
			if(res.success)
			{
				component.set('v.error','');
				if(res.warning)
				{
					component.set('v.confirm_popup_info',{
						open :true,
						eventName:'c.onOfferConfirm',
						description:res.warning,
					});
				}
				// helper.getOfferList(component);
			}
			else
			{	
				component.set('v.error',res.error);
				// alert(res.error);
				// helper.getOfferList(component);
			}
		});
		$A.enqueueAction(action); 
	}
})