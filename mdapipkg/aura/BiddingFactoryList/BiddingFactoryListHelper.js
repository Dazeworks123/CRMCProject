({
	pqgrid:null,
	convertData : function(factoryData) {
		res = [];
		for(var i in factoryData)
		{
			var rowData = factoryData[i];
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
	convertColumns : function(factoryHeader)
	{
		var res = [];
		for(var i in factoryHeader)
		{
			var header = factoryHeader[i];
			var headerFormat = {
				title:header.label,
				dataType:header.type,
				dataIndx:header.name,
				width: header.width,
			};
			if(header.type =='float')
			{
				headerFormat.format = '#,###.00'; 
			}
			res.push(headerFormat);
		}
		return res;
	},
	setTable : function(factoryData) {
		
		if(this.pqgrid)
		{	
			// var columnsModel = this.pqgrid.pqGrid('getColModel');
			for(var rowIndx in factoryData)
			{
				var row = factoryData[rowIndx];
				for(var i in row)
				{
					var fieldData = row[i];
					if(fieldData.type == 'quote' && fieldData.status == 'Trade')
					{
						this.pqgrid.pqGrid('addClass',{rowIndx: rowIndx, dataIndx: fieldData.fieldname, cls: 'data-trade'});
					} 
					if(fieldData.type == 'quote' && fieldData.status == 'Open')
					{
						this.pqgrid.pqGrid('addClass',{rowIndx: rowIndx, dataIndx: fieldData.fieldname, cls: 'data-open'});
					} 

				}
			}
		}
	}
})