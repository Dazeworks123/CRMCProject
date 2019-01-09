@isTest
private class Test_BuyerTradePanelController {

	static Map<String,Object> mockupConsumerData(){
		RecordType producerRecordType = [Select Id,name From RecordType where sobjecttype = 'Account' and Name = 'Producer'];
		RecordType consumerRecordType = [Select Id,name From RecordType where sobjecttype = 'Account' and Name = 'Consumer'];

		User userLogin =  UserService.getUser();

		Account producer = new Account();
		producer.Name = 'Halcyon';
		producer.RecordTypeId = producerRecordType.Id;
		insert producer;

		Account consumer = new Account();
		consumer.Name = 'Consumer1';
		consumer.RecordTypeId = consumerRecordType.Id;
		insert consumer;

		Contact myContact = new Contact();
		myContact.LastName = 'Consumer User1';
		myContact.AccountId = consumer.Id;
		myContact.ownerid = UserInfo.getUserId();
		insert myContact;

		userLogin.Contact = myContact;
		update userLogin;


		Factory__c factory = new Factory__c();
		factory.Name = 'Factory 1';
		factory.Factory_Location__c = 'Thailand';
		insert factory;


		User Seller = [SELECT Id FROM User WHERE Username = 'producer1@heveaconnect.test'];
		Date dateQuote = Helper.get1stDateNow();
    	Quotation__c quoteObj = new Quotation__c();
    	quoteObj.Seller__c = Seller.Id;
        quoteObj.Producer__c = producer.Id;
        //quoteObj.Grade__c = filterGrades.Product__r.Id;
        //quoteObj.Packing__c = filterPacking.Product__r.Id;
        //quoteObj.Payment_Term__c = filterPaymentTerms.Id;
        //quoteObj.Shipment_Information__c = filterShipmentInformation.Id;
        quoteObj.Factory__c = factory.Id;

        quoteObj.Bid_Price__c = 1000;
        quoteObj.Bid_Volume__c = 100.8;
		quoteObj.Ask_Price__c = 1000;
		quoteObj.Ask_Volume__c = 100.8;
        quoteObj.Month__c = Helper.getMonthStr(dateQuote.month());
        quoteObj.Quote_Effective_Month__c = dateQuote;
        quoteObj.All_or_Nothing__c = false;
        quoteObj.Consumer__c = consumer.Id;
        insert quoteObj;
		
		return new Map<String,Object>
		{
			'quoteObj'=>quoteObj
		};		
	}

	@isTest static void test_ApiException(){
		Test.StartTest();
			ApiException.test();
			ApiException ex = new ApiException();
			ex.Warning();
			ex.isWarning();

		Test.StopTest();
	}
	
	@isTest static void test_getTradeList() {
		Test.StartTest();
		Test_BuyerTradePanelController.mockupConsumerData();
		Account myAccount = UserService.getAccount();

		List<Object> result = BuyerTradePanelController.getTradeList(new Map<String,String>{
			'columns'=>'',
			'type'=>''
		});
		Test.StopTest();
	}
	
	@isTest static void test_pullBid() {
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = BuyerTradePanelController.pullBid(testQuote);

		Test.StopTest();
	}

	@isTest static void test_pullBid_no_account() {
		Test.StartTest();
		
		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = BuyerTradePanelController.pullBid(testQuote);

		Test.StopTest();
	}

	@isTest static void test_pullBid_exception() {
		Test.StartTest();
		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('xxx');
		Map<String,Object> result = BuyerTradePanelController.pullBid(testQuote);

		Test.StopTest();
	}	

	@isTest static void test_pull_all_bid(){
		Test.StartTest();
		Test_BuyerTradePanelController.mockupConsumerData();
		Map<String,Object> result = BuyerTradePanelController.pullAllBid();
		Test.StopTest();
	}

	@isTest static void test_pull_all_bid_no_account(){
		Test.StartTest();
		Map<String,Object> result = BuyerTradePanelController.pullAllBid();
		Test.StopTest();
	}

	@isTest static void test_trade_confirm(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = BuyerTradePanelController.tradeConfirm(testQuote);

		Test.StopTest();
	}
	@isTest static void test_trade_confirm_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = BuyerTradePanelController.tradeConfirm(testQuote);

		Test.StopTest();
	}
	@isTest static void test_counter_confirm(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = BuyerTradePanelController.counterConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_counter_null_id(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		testQuote.Id = null;
		Map<String,Object> result = BuyerTradePanelController.counterConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_counter_confirm_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = BuyerTradePanelController.counterConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_counter_confirm_exception(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('xxx');
		Map<String,Object> result = BuyerTradePanelController.counterConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_reject_confirm(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = BuyerTradePanelController.rejectConfirm(testQuote);

		Test.StopTest();
	}
	@isTest static void test_reject_confirm_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = BuyerTradePanelController.rejectConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_reject_confirm_exception(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('xxx');
		Map<String,Object> result = BuyerTradePanelController.rejectConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_favorite(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = BuyerTradePanelController.onChangeFavorite(testQuote);

		Test.StopTest();
	}
	@isTest static void test_favorite_no_account(){
		Test.StartTest();

		
		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = BuyerTradePanelController.onChangeFavorite(testQuote);

		Test.StopTest();
	}
	@isTest static void test_checkPreCounter(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = BuyerTradePanelController.checkPreCounter(testQuote);

		Test.StopTest();
	}
	@isTest static void test_checkPreCounter_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = BuyerTradePanelController.checkPreCounter(testQuote);

		Test.StopTest();
	}
	@isTest static void test_checkPreCounter_exception(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('xxx');
		Map<String,Object> result = BuyerTradePanelController.checkPreCounter(testQuote);

		Test.StopTest();
	}
	@isTest static void test_checkPreAccept(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = BuyerTradePanelController.checkPreAccept(testQuote);

		Test.StopTest();
	}
	@isTest static void test_getHistoryList(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		BuyerTradePanelController.getHistoryList(testQuote);

		Test.StopTest();
	}
	@isTest static void test_createQuoteIteration(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		BuyerTradePanelController.createQuoteIteration(testQuote);

		Test.StopTest();
	}
	@isTest static void test_createContract(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		BuyerTradePanelController.createContract(testQuote);

		Test.StopTest();
	}
	@isTest static void test_onAllOrNotting(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_BuyerTradePanelController.mockupConsumerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		testQuote.Bid_Volume__c = 201.6;
		BuyerTradePanelController.onAllOrNotting(testQuote);

		Test.StopTest();
	}
	

}