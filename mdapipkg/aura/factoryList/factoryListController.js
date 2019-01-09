({
	init : function(component, event, helper) {
		
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
		        scrollModel:{autoFit:true},
		        dragColumns: { enabled: false }
		    };

		    obj.colModel = helper.convertColumns(dataFactory.header);
		    obj.dataModel = { data: helper.convertData(dataFactory.data) };

		    obj.cellSave = function(e,ui)
		    {
		    	$(e.target).pqGrid("addClass",{rowIndx: ui.rowIndx, dataIndx: ui.dataIndx, cls: 'data-draft'});	
		    	return ui;
		    };

		    helper.pqgrid = $("#grid_json").pqGrid(obj);
		    helper.setTable(dataFactory.data);
		    helper.pqgrid.pqGrid( {
				cellClick: function( event, ui){
					// console.log(dataFactory.data[ui.rowIndx][ui.colIndx]);
				},
				cellKeyDown : function( event, ui){
					component.set('v.isEdited',true);	
				},
				editorKeyDown: function( event, ui ) {
					component.set('v.isEdited',true);
				},
				change : function(event, ui){
					for(var i in ui.updateList)
					{
						var update = ui.updateList[i];
						for(var colIndx in update.newRow)
						{
							var cellIndex = dataFactory.data[update.rowIndx].findIndex(function(row){return row.fieldname ==colIndx});
							dataFactory.data[update.rowIndx][cellIndex].value = update.newRow[colIndx];
							dataFactory.data[update.rowIndx][cellIndex].status = 'Draft';
						}
					}
					component.set('v.factory_list',dataFactory);
				}
			});	
		});
	},

	reloadData : function(component, event, helper) {
		var onLoading = event.getParam('loading');
		var isEdited = component.get('v.isEdited');
		if(onLoading && !isEdited)
		{
			helper.pqgrid.pqGrid('showLoading');
		}
		else
		{
			var dataFactory = component.get('v.factory_list');
			var data = helper.convertData(dataFactory.data);
			helper.pqgrid.pqGrid("option", "dataModel.data",data);
			helper.pqgrid.pqGrid("refreshDataAndView");
			helper.setTable(dataFactory.data);
			helper.pqgrid.pqGrid( {
				cellClick: function( event, ui){
					// console.log(dataFactory.data[ui.rowIndx][ui.colIndx]);
				},
				cellKeyDown : function( event, ui){
					component.set('v.isEdited',true);	
				},
				editorKeyDown: function( event, ui ) {
					component.set('v.isEdited',true);
				},
				change : function(event, ui){
					for(var i in ui.updateList)
					{
						var update = ui.updateList[i];
						for(var colIndx in update.newRow)
						{
							var cellIndex = dataFactory.data[update.rowIndx].findIndex(function(row){return row.fieldname ==colIndx});
							dataFactory.data[update.rowIndx][cellIndex].value = update.newRow[colIndx];
							dataFactory.data[update.rowIndx][cellIndex].status = 'Draft';
						}
					}
					component.set('v.factory_list',dataFactory);
				}
			});
			helper.pqgrid.pqGrid('hideLoading');		
		}
	}
})