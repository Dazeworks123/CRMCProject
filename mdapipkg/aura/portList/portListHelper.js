({
	pqgrid:null,
	convertData : function(portData) {
		res = [];
		for(var i in portData)
		{
			var rowData = portData[i];
			row = {};
			for(var j in rowData)
			{
				var data = rowData[j];
				row[data.fieldname] = data.value;
			}	
			res.push(row);
		}
		return res;
	},
	convertColumns : function(portHeader)
	{
		var res = [];
		for(var i in portHeader)
		{
			var header = portHeader[i];
			var headerFormat = {
				title:header.label,
				dataType:header.type,
				dataIndx:header.name,
				editable:header.editable,
			};
			if(header.type =='float')
			{
				headerFormat.format = '#,###.00';
			}
			res.push(headerFormat);
		}
		return res;
	},
	setTable : function(portData) {
		if(this.pqgrid)
		{	
			var columnsModel = this.pqgrid.pqGrid('getColModel');
			for(var rowIndx in portData)
			{
				var row = portData[rowIndx];
				for(var i in row)
				{
					var fieldData = row[i];
					if(fieldData.status == 'Draft')
					{
						this.pqgrid.pqGrid('addClass',{rowIndx: rowIndx, dataIndx: fieldData.fieldname, cls: 'data-draft'});
					}
					else if(fieldData.status == 'Trade')
					{
						this.pqgrid.pqGrid('addClass',{rowIndx: rowIndx, dataIndx: fieldData.fieldname, cls: 'data-trade'});
					} 

				}
			}
			//set editable
			for(var i in columnsModel)
			{
				var columns = columnsModel[i];
				columns.editable = function(ui)
				{
					return portData[ui.rowIndx][ui.colIndx].editable;
				}	
			}
			this.pqgrid.pqGrid( "option", "colModel", columnsModel );	
		}
	}
})