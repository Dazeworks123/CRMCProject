public with sharing class BuyerTradePanelController {
	@AuraEnabled
	public static List<Object> getTradeList(Map<String,String> sort_info){

		String columns =sort_info.get('columns');
		String typeOfSort =sort_info.get('type');
		String sortBy = columns != ''?columns + ' ' + typeOfSort:'LastModifiedDate DESC';
		Id UserLogin = userinfo.getUserId();
		Account myAccount = UserService.getAccount();
		String findByUser = myAccount == null?'': ' Buyer__c =\''+UserLogin+'\' AND ';
		String findConsumer = myAccount == null?'': ' Consumer__c =\''+myAccount.Id+'\' AND ';

		String sql = 'SELECT Id,'+
		'Favorite_Consumer__c,'+
		'Comment__c,'+
		'Destination__c,'+
		'Destination__r.Destination_Country__c,'+
		'Producer__r.Name,'+
		'Producer__r.Icon_URL__c,'+
		'Seller__r.Id,'+
		'Seller__r.Name,'+
		'Factory__r.Name,'+
		'Factory__r.Factory_Code__c,'+
		'Factory__r.Port__c,'+
		'Factory_Symbol__c,'+
		'Month__c,'+
		'Quotation_Status__c,'+
		'Grade__r.Name,'+
		'Grade__c,'+
		'Packing__c,'+
		'Packing__r.Name,'+
		'Payment_Term__c,'+
		'Payment_Term__r.Payment_Term__c,'+
		'Shipment_Information__r.Incoterm__c,'+
		'All_or_Nothing__c,'+
		'Bid_Price__c,'+
		'Bid_Volume__c,'+
		'Ask_Price__c,'+
		'Ask_Volume__c,'+
		'Consumer__c,'+
		'Shipment_Information__c,'+
		'LastModifiedBy.Name,'+
		'LastModifiedDate '+
		'FROM Quotation__c WHERE '+
		//findByUser +
		findConsumer +
		'Quotation_Status__c NOT IN (\'Draft\',\'Pulled\',\'Cancelled\') ORDER BY Favorite_Consumer__c DESC,'+sortBy;
		
		List<Quotation__c> quoteList =Database.query(sql);
		return quoteList;
	}

	@AuraEnabled 
	public static Map<String,Object> pullBid(Quotation__c quoteObj) {
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Id UserLogin = userinfo.getUserId();
			Account myAccount = UserService.getAccount();
			if(myAccount == null)
			{
				throw new ApiException('Current user cannot get consumer data');   
			}

			Quotation__c quote = BuyerTradePanelController.getQuote(quoteObj.Id);
			quote.Quotation_Status__c = 'Pulled';

			quote.Buyer__c = UserLogin;
			update quote;
			result.put('success',true);
			
			List<String> channelList = new List<String>{'All'};
			BuyerTradePanelController.updatePusher(channelList,'Pulled');	
		}
		catch(ApiException e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		return result;
	}

	@AuraEnabled
	public static Map<String,Object> pullAllBid(){
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Id UserLogin = userinfo.getUserId();
			Account myAccount = UserService.getAccount();
			if(myAccount == null)
			{
				throw new ApiException('Current user cannot get consumer data');   
			}

			List<Quotation__c> quoteList = [SELECT Id,
			Favorite_Consumer__c,
			Producer__r.Name, //Brand
			Producer__r.Icon_URL__c, //Icon
			Seller__r.Name, //name
			Factory__r.Name,
			Factory_Symbol__c,
			Month__c,
			Quotation_Status__c,
			Grade__r.Name, 
			Bid_Price__c,
			Bid_Volume__c,
			Ask_Price__c,
			Ask_Volume__c,
			LastModifiedDate
			FROM Quotation__c WHERE 
			Consumer__c =:myAccount.Id AND 
			Quotation_Status__c NOT IN ('Draft','Pulled', 'Done Deal','Cancelled','Rejected')   ORDER BY Favorite_Consumer__c DESC,LastModifiedDate DESC];

			for(Quotation__c quoteItem:quoteList)
			{	
				quoteItem.Quotation_Status__c = 'Pulled';
			}
			update quoteList;

			result.put('success',true);

			//Query
			List<String> channelList = new List<String>{'All'};
			BuyerTradePanelController.updatePusher(channelList,'Pulled');
			
		}
		catch(ApiException e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		return result;
	}

	@AuraEnabled
	public static Map<String,Object> tradeConfirm(Quotation__c quoteObj){
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Id UserLogin = userinfo.getUserId();
			Account myAccount = UserService.getAccount();
			if(myAccount == null)
			{
				throw new ApiException('Current user cannot get consumer data');   
			}

			Quotation__c quote = BuyerTradePanelController.getQuote(quoteObj.Id);
			quoteObj.Quotation_Status__c = 'Done Deal';
			quote.Quotation_Status__c = quoteObj.Quotation_Status__c;
			quote.Bid_Price__c = quoteObj.Ask_Price__c;
			quote.Bid_Volume__c = quoteObj.Ask_Volume__c;
			quote.Agreed_Price__c = quoteObj.Ask_Price__c;
			quote.Agreed_Volume__c = quoteObj.Ask_Volume__c;
			quote.Comment__c = quoteObj.Comment__c;
			quote.All_or_Nothing__c = quoteObj.All_or_Nothing__c;
			quote.Buyer__c = UserLogin;
			update quote;
			result.put('success',true);

			BuyerTradePanelController.createQuoteIteration(quote);
			BuyerTradePanelController.createContract(quote);
			List<String> channelList = new List<String>{'All'};
			BuyerTradePanelController.updatePusher(channelList,'Done Deal');

			if(quote.All_or_Nothing__c == false)
			{
				BuyerTradePanelController.onAllOrNotting(quoteObj);
			}
		}
		catch(ApiException e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		return result;
	}	

	@AuraEnabled
	public static Map<String,Object> rejectConfirm(Quotation__c quoteObj){
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Id UserLogin = userinfo.getUserId();
			Account myAccount = UserService.getAccount();
			if(myAccount == null)
			{
				throw new ApiException('Current user cannot get consumer data');   
			}

			Quotation__c quote = BuyerTradePanelController.getQuote(quoteObj.Id);
			quote.Quotation_Status__c = 'Rejected';
			quote.Comment__c = quoteObj.Comment__c;
			quote.All_or_Nothing__c = quoteObj.All_or_Nothing__c;
			quote.Buyer__c = UserLogin;
			update quote;
			result.put('success',true);

			List<String> channelList = new List<String>{'All'};
			BuyerTradePanelController.updatePusher(channelList,'Rejected');	
			BuyerTradePanelController.createQuoteIteration(quote);
		}
		catch(ApiException e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		return result;
	}

	@AuraEnabled
	public static Map<String,Object> counterConfirm(Quotation__c quoteObj){
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Id UserLogin = userinfo.getUserId();
			Account myAccount = UserService.getAccount();
			Quotation__c quote = null;
			if(myAccount == null)
			{
				throw new ApiException('Current user cannot get consumer data');   
			}

			if(quoteObj.Id != null)
			{
				quote = BuyerTradePanelController.getQuote(quoteObj.Id);
				quote.Quotation_Status__c = 'Counter';
				quote.Bid_Price__c = quoteObj.Bid_Price__c;
				quote.Bid_Volume__c = quoteObj.Bid_Volume__c;
				quote.Comment__c = quoteObj.Comment__c;
				quote.All_or_Nothing__c = quoteObj.All_or_Nothing__c;
				quote.Buyer__c = UserLogin;
				update quote;
			}
			else
			{
				quote = quoteObj; 
				quote.Buyer__c = UserLogin;
				quote.Quotation_Status__c ='Counter';
				insert 	quote;
			}

			result.put('success',true);

			List<String> channelList = new List<String>{'All'};
			BuyerTradePanelController.updatePusher(channelList,'Counter');
			BuyerTradePanelController.createQuoteIteration(quote);
		}
		catch(ApiException e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		return result;
	}

	@AuraEnabled
	public static Map<String,Object> onChangeFavorite(Quotation__c quoteObj){
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Quotation__c quote = BuyerTradePanelController.getQuote(quoteObj.Id);
			quote.Favorite_Consumer__c = !quoteObj.Favorite_Consumer__c;
			update quote;
			result.put('success',true);
			
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		return result;
	}

	@Future(callout=true)
	public static void updatePusher(List<String> channelList,String status)
	{
		PusherService pusher = new PusherService();
		pusher.push(channelList,'update_quote',new Map<String,Object>{
			'success'=>true,
			'status'=>status
		});
	}

	@AuraEnabled
	public static List<Quotation_Iteration__c> getHistoryList(Quotation__c quoteObj) {
		Id quoteId = null;

		Id UserLogin = userinfo.getUserId();
		List<Quotation_Iteration__c> historyList = [SELECT Id,
		//Agreed_Price__c,
		//Agreed_Volume__c,
		//All_or_Nothing__c,
		Ask_Price__c,
		Ask_Volume__c,
		Bid_Price__c,
		Bid_Volume__c,
		Seller__c,
		Seller__r.Name,
		Comment__c,
		//Consumer__r.Name,
		//Destination__r.Name,
		//Favorite_Consumer__c,
		//Favorite_Producer__c,
		Factory_Symbol__c,
		//Factory__r.Name,
		//Grade__r.Name,
		//Producer__r.Name,
		//Month__c,
		//Name,
		//Port__c,
		//Packing__r.Name, 
		Payment_Term__r.Payment_Term__c,
		//Quote_Effective_Month__c,
		Quotation_Status__c,
		Primary_Quotation__r.Id,
		LastModifiedBy.Name,
		//Revision__c,
		// Seller__r.Name,
		Shipment_Information__r.Incoterm__c,
		LastModifiedDate
		FROM Quotation_Iteration__c 
		WHERE Primary_Quotation__r.Id =: quoteObj.Id
		//Seller__c =: UserLogin AND 
		ORDER BY LastModifiedDate DESC];

		return historyList;
	}

	

	public static Quotation__c getQuote(Id QuoteId)
	{
		return [SELECT 
		Ask_Price__c,
		Ask_Volume__c,
		Bid_Price__c,
		Bid_Volume__c,
		Buyer__c,
		Seller__c,
		Comment__c,
		Quotation_Status__c,
		Factory__c,
		Producer__c,
		Consumer__c,
		Destination__c,
		Destination__r.Destination_Country__c,
		Factory__r.Port__c,
		Payment_Term__c,
		Shipment_Information__r.Incoterm__c,
		Shipment_Information__r.Destination__c,
		Shipment_Information__r.Destination__r.Destination_Country__c,
		Shipment_Information__c,
		Month__c,
		Packing__c,
		All_or_Nothing__c,
		Grade__c,
		Payment_Term__r.Payment_Term__c,
		Id
		FROM Quotation__c
		WHERE Id=:QuoteId];
	}


	public static void createQuoteIteration(Quotation__c quoteObj)
	{
		Quotation_Iteration__c quoteInteration = new Quotation_Iteration__c();
		quoteInteration.Ask_Price__c = quoteObj.Ask_Price__c;
		quoteInteration.Ask_Volume__c = quoteObj.Ask_Volume__c;
		quoteInteration.Bid_Price__c = quoteObj.Bid_Price__c;
		quoteInteration.Bid_Volume__c = quoteObj.Bid_Volume__c;
		quoteInteration.Buyer__c = quoteObj.Buyer__c;
		quoteInteration.Seller__c = quoteObj.Seller__c;
		quoteInteration.Comment__c = quoteObj.Comment__c;
		quoteInteration.Quotation_Status__c = quoteObj.Quotation_Status__c;
		quoteInteration.Factory__c = quoteObj.Factory__c;
		quoteInteration.Producer__c = quoteObj.Producer__c;
		quoteInteration.Consumer__c = quoteObj.Consumer__c;
		quoteInteration.Primary_Quotation__c = quoteObj.Id;
		insert quoteInteration;
	}

	@AuraEnabled
	public static Map<String,Object> checkPreCounter(Quotation__c quoteObj){
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Id UserLogin = userinfo.getUserId();
			Account myAccount = UserService.getAccount();
			if(myAccount == null)
			{
				throw new ApiException('Current user cannot get consumer data');   
			}


			Factory__c factoryData = [SELECT Id,
				(SELECT Id,floor_price__c FROM Grades__r WHERE Product__r.Id =: quoteObj.Grade__c),
				(SELECT Id,Ceiling_Price__c FROM Factory_Approval_List__r WHERE Approval_Status__c = 'Approved' AND Consumer__c =: quoteObj.Consumer__c)
				FROM Factory__c
				WHERE Id =: quoteObj.Factory__c];


			List<Product_Approval_List__c> ProductApproveList = factoryData.Grades__r;
			List<Factory_Approvals__c> FactoryApproveList = factoryData.Factory_Approval_List__r;
			
			//if(ProductApproveList.size()>0)
			//{
			//	Product_Approval_List__c productApprove = ProductApproveList.get(0);
			//	Decimal min = productApprove.floor_price__c == null ? 0 : productApprove.floor_price__c;
			//	if(min > 0)
			//	{
			//		if(quoteObj.Bid_Price__c < min)
			//		{
			//			throw new ApiException('Minimum price should not be less than '+min);	
			//		}	
			//	}
			//}

			if(FactoryApproveList.size()>0)
			{
				Factory_Approvals__c factoryApprove = FactoryApproveList.get(0);
				Decimal max = factoryApprove.Ceiling_Price__c == null ? 0 : factoryApprove.Ceiling_Price__c;
				if(max > 0)
				{
					if(quoteObj.Bid_Price__c > max)
					{
						throw new ApiException('Maximum price should not be more than '+max);	
					}	
				}
			}

			if(quoteObj.Bid_Price__c == null)
			{
				throw new ApiException('Bid price is require');	
			}

			if(quoteObj.Bid_Volume__c == null)
			{
				throw new ApiException('Bid valume is require');	
			}

			result.put('success',true);
		}
		catch(ApiException e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());	
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}

		return result;
	}

	@AuraEnabled
	public static Map<String,Object> checkPreAccept(Quotation__c quoteObj){
		Map<String,Object> result = new Map<String,Object>();
		try
		{
			Id UserLogin = userinfo.getUserId();
			Account myAccount = UserService.getAccount();
			if(myAccount == null)
			{
				throw new ApiException('Current user cannot get consumer data');   
			}
			
			if(quoteObj.Ask_Price__c == null)
			{
				throw new ApiException('Ask price is empty');	
			}

			if(quoteObj.Ask_Volume__c == null)
			{
				throw new ApiException('Ask valume is empty');	
			}

			result.put('success',true);
		}
		catch(ApiException e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());	
		}
		catch(Exception e)
		{
			result.put('success',false);
			result.put('error',e.getMessage());
		}
		return result;
	}

	public static void createContract(Quotation__c quoteObj)
	{
		Contract__c contract = new Contract__c();
		contract.Buyer__c = quoteObj.Buyer__c;
		contract.Destination__c = quoteObj.Shipment_Information__r.Destination__c;
		contract.Destination_Country__c = quoteObj.Shipment_Information__r.Destination__r.Destination_Country__c;
		contract.Factory__c = quoteObj.Factory__c;
		contract.Port__c = quoteObj.Factory__r.Port__c;
		contract.Incoterm__c = quoteObj.Shipment_Information__r.Incoterm__c;
		contract.Material__c = quoteObj.Grade__c;
		contract.Month__c = quoteObj.Month__c;
		contract.Packing__c = quoteObj.Packing__c;
		contract.Payment_Term__c = quoteObj.Payment_Term__c;
		contract.Price__c = quoteObj.Agreed_Price__c;
		contract.Seller__c = quoteObj.Seller__c;
		contract.Shipment__c = quoteObj.Shipment_Information__c;
		contract.Trade_Date__c = Datetime.now();
		contract.Volume__c = quoteObj.Agreed_Volume__c;
		contract.Producer__c = quoteObj.Producer__c;
		contract.Consumer__c = quoteObj.Consumer__c;
		contract.Payment_Term_Description__c = quoteObj.Payment_Term__r.Payment_Term__c;
		insert contract;
	}

	public static void onAllOrNotting(Quotation__c quoteObj)
	{
		Id UserLogin = userinfo.getUserId();

		Decimal newVolume = quoteObj.Bid_Volume__c - quoteObj.Ask_Volume__c;

		if(newVolume > 0)
		{
			Quotation__c newQuote = new Quotation__c();
			newQuote.Buyer__c = quoteObj.Buyer__c;
	        newQuote.Consumer__c = quoteObj.Consumer__c;
	        newQuote.Grade__c = quoteObj.Grade__c;
	        newQuote.Packing__c = quoteObj.Packing__c;
	        newQuote.Payment_Term__c = quoteObj.Payment_Term__c;
	        newQuote.Shipment_Information__c = quoteObj.Shipment_Information__c;
	        newQuote.Factory__c = quoteObj.Factory__c;
	        newQuote.Bid_Price__c = quoteObj.Bid_Price__c;
	        newQuote.Bid_Volume__c = newVolume;
	        newQuote.Month__c = quoteObj.Month__c;
	        newQuote.Quote_Effective_Month__c = quoteObj.Quote_Effective_Month__c;
	        newQuote.All_or_Nothing__c = true;
	        newQuote.Producer__c = quoteObj.Producer__c;
			Map<String,Object> res =  BuyerTradePanelController.counterConfirm(newQuote);

			if((Boolean)res.get('success') == false)
			{
				throw new ApiException((String) res.get('error'));
			}
		}
	}
}