({
	isDoneDeal : function(component) {
		var isDoneDeal = component.get('v.trade_item.Quotation_Status__c');
		var result = isDoneDeal == 'Done Deal' ? true : false;
		return result;
	}
})