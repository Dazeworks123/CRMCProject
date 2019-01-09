({
	init : function(component, event, helper) {
		
	},
	loadScript : function(component, event, helper) {
		$(function () {
			var dataPort = component.get('v.port_list');
		   	
		    var obj = {
		    	animModel:  { on: true, duration: 400 },
		        numberCell:{resizable:true,title:"#",width:30,minWidth:30},
		        editor: {type: 'textbox'},
				sortable:true,
				freezeCols: 2,
				fillHandle: '' ,
		        scrollModel:{autoFit:true},
		        dragColumns: { enabled: false }
		    };

		    obj.colModel = helper.convertColumns(dataPort.header);
		    obj.dataModel = { data: helper.convertData(dataPort.data) };

		    obj.cellSave = function(e,ui)
		    {
		    	$(e.target).pqGrid("addClass",{rowIndx: ui.rowIndx, dataIndx: ui.dataIndx, cls: 'data-draft'});	
		    	return ui;
		    };

		    helper.pqgrid = $("#grid_json").pqGrid(obj);
		    helper.setTable(dataPort.data);
		    helper.pqgrid.pqGrid( {
				cellClick: function( event, ui){
					// console.log(dataPort.data[ui.rowIndx][ui.colIndx]);
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
							var cellIndex = dataPort.data[update.rowIndx].findIndex(function(row){return row.fieldname ==colIndx});
							dataPort.data[update.rowIndx][cellIndex].value = update.newRow[colIndx];
							dataPort.data[update.rowIndx][cellIndex].status = 'Draft';
						}
					}
					component.set('v.port_list',dataPort);
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
			var dataPort = component.get('v.port_list');
			var data = helper.convertData(dataPort.data);
			helper.pqgrid.pqGrid("option", "dataModel.data",data);
			helper.pqgrid.pqGrid("refreshDataAndView");
			helper.setTable(dataPort.data);
			helper.pqgrid.pqGrid( {
				cellClick: function( event, ui){
					// console.log(dataPort.data[ui.rowIndx][ui.colIndx]);
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
							var cellIndex = dataPort.data[update.rowIndx].findIndex(function(row){return row.fieldname ==colIndx});
							dataPort.data[update.rowIndx][cellIndex].value = update.newRow[colIndx];
							dataPort.data[update.rowIndx][cellIndex].status = 'Draft';
						}
					}
					component.set('v.port_list',dataPort);
				}
			});
			helper.pqgrid.pqGrid('hideLoading');
		}
	}
})