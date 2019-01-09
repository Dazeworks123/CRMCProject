({
	init : function(component, event, helper) {
		console.log('list init');
	},
	loadScript : function(component, event, helper) {
		$(function () {
			var dataFactory = component.get('v.factory_list');
		   
		    var obj = {
		    	animModel:  { on: true, duration: 400 },
		        numberCell:{resizable:true,title:"#",width:30,minWidth:30},
		        editor: {type: 'textbox'},
				sortable:true,
				freezeCols: 4,
				fillHandle: '' ,
				editable:false,
		        scrollModel:{autoFit:true},
		        dragColumns: { enabled: false }
		    };

		    obj.colModel = helper.convertColumns(dataFactory.header);
		    obj.dataModel = { data: helper.convertData(dataFactory.data) };

		    helper.pqgrid = $("#grid_json").pqGrid(obj);
		    helper.setTable(dataFactory.data);
		    helper.pqgrid.pqGrid( {
				cellClick: function( event, ui){
					var factoryCell = dataFactory.data[ui.rowIndx][ui.colIndx];
					if(factoryCell.type == 'quote')
					{
						component.set('v.trade_item',factoryCell.quote);
						component.set('v.trade_open',true);
						component.set('v.trade_view','view');
					}
				}
			});
		});
	},

	reloadData : function(component, event, helper) {
		var onLoading = event.getParam('loading');
		if(onLoading)
		{
			helper.pqgrid.pqGrid('showLoading');
		}
		else
		{
			var dataFactory = component.get('v.factory_list');
			var data = helper.convertData(dataFactory.data);
			helper.pqgrid.pqGrid("option", "dataModel.data",data);
			helper.setTable(dataFactory.data);
			helper.pqgrid.pqGrid( {
				cellClick: function( event, ui){
					var factoryCell = dataFactory.data[ui.rowIndx][ui.colIndx];
					if(factoryCell.type == 'quote')
					{
						component.set('v.trade_item',factoryCell.quote);
						component.set('v.trade_open',true);
						component.set('v.trade_view','view');
					}
				}
			});
			helper.pqgrid.pqGrid("refreshDataAndView");
			helper.pqgrid.pqGrid('hideLoading');
		}
	}
})