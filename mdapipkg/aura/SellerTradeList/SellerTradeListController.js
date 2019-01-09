({
	init: function (component, event, helper) {
		console.log(component.get('v.trade_list'));
	},
	sortClick: function (component, event, helper) {
		var field = event.target.dataset.field;

		var tradeEvent = component.getEvent("onChangeSort");
		var sort_info = component.get("v.sort_info");
		var columns = '';
		var type = '';
		console.log(field, sort_info);
		if (field != sort_info.columns) {
			type = 'ASC';
			columns = field;
		}
		else {
			if (sort_info.type == 'ASC') {
				columns = sort_info.columns;
				type = 'DESC';
			}
		}

		tradeEvent.setParam('columns', columns);
		tradeEvent.setParam('type', type);
		tradeEvent.fire();

	},

	afterScriptsLoaded: function (component, event, helper) {
		console.log('load script success');
	}
})