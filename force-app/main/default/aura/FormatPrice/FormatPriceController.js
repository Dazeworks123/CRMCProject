({
	init : function(component, event, helper) {
		var price = component.get('v.price');
		if(price){
			var format = Number(price).toFixed(2).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
			component.set('v.price_format',format);
		}else{
			component.set('v.price_format',null);
		}
		
	}
})