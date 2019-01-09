@isTest
private class Test_SellerTradePanelController {
	
	static Map<String,Object> mockupProducerData() {
		
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
		myContact.LastName = 'Helcyon User1';
		myContact.AccountId = producer.Id;
		myContact.ownerid = UserInfo.getUserId();
		insert myContact;

		userLogin.Contact = myContact;
		update userLogin;


		Factory__c factory = new Factory__c();
		factory.Name = 'Factory 1';
		factory.Factory_Location__c = 'Thailand';
		insert factory;


		User Buyer = [SELECT Id FROM User WHERE Username = 'consumer1@heveaconnect.test'];
		Date dateQuote = Helper.get1stDateNow();
    	Quotation__c quoteObj = new Quotation__c();
    	quoteObj.Buyer__c = Buyer.Id;
        quoteObj.Consumer__c = consumer.Id;
        //quoteObj.Grade__c = filterGrades.Product__r.Id;
        //quoteObj.Packing__c = filterPacking.Product__r.Id;
        //quoteObj.Payment_Term__c = filterPaymentTerms.Id;
        //quoteObj.Shipment_Information__c = filterShipmentInformation.Id;
        quoteObj.Factory__c = factory.Id;

        quoteObj.Bid_Price__c = 1000;
        quoteObj.Bid_Volume__c = 100.8;
        quoteObj.Month__c = Helper.getMonthStr(dateQuote.month());
        quoteObj.Quote_Effective_Month__c = dateQuote;
        quoteObj.All_or_Nothing__c = false;
        quoteObj.Producer__c = producer.Id;
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
		Test_SellerTradePanelController.mockupProducerData();
		Account myAccount = UserService.getAccount();

		List<Object> result =  SellerTradePanelController.getTradeList(new Map<String,String>{
			'columns'=>'',
			'type'=>''
		});

		Test.StopTest();
	}

	@isTest static void test_pullOffer() {
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = SellerTradePanelController.pullOffer(testQuote);
		System.assertEquals(result,null);

		Test.StopTest();
	}

	@isTest static void test_pullOffer_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = SellerTradePanelController.pullOffer(testQuote);

		Test.StopTest();

	}

	@isTest static void test_pull_all_offer(){
		Test.StartTest();
		Test_SellerTradePanelController.mockupProducerData();
		Map<String,Object> result = SellerTradePanelController.pullAllOffer();
		Test.StopTest();
	}

	@isTest static void test_pull_all_offer_no_account(){
		Test.StartTest();
		Map<String,Object> result = SellerTradePanelController.pullAllOffer();
		Test.StopTest();
	}

	@isTest static void test_trade_confirm(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = SellerTradePanelController.tradeConfirm(testQuote);

		Test.StopTest();
	}
		@isTest static void test_trade_confirm_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = SellerTradePanelController.tradeConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_counter_confirm(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = SellerTradePanelController.counterConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_counter_confirm_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = SellerTradePanelController.counterConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_reject_confirm(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = SellerTradePanelController.rejectConfirm(testQuote);

		Test.StopTest();
	}

	@isTest static void test_reject_confirm_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = SellerTradePanelController.rejectConfirm(testQuote);

		Test.StopTest();
	}
	
	@isTest static void test_favorite(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = SellerTradePanelController.onChangeFavorite(testQuote);

		Test.StopTest();
	}

	@isTest static void test_favorite_no_account(){
		Test.StartTest();

		Quotation__c testQuote =  new Quotation__c();
		Map<String,Object> result = SellerTradePanelController.onChangeFavorite(testQuote);

		Test.StopTest();
	}

	@isTest static void test_checkPreCounter(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = SellerTradePanelController.checkPreCounter(testQuote);

		Test.StopTest();
	}

	@isTest static void test_checkPreAccept(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		Map<String,Object> result = SellerTradePanelController.checkPreAccept(testQuote);

		Test.StopTest();
	}

	@isTest static void test_getHistoryList(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		SellerTradePanelController.getHistoryList(testQuote);

		Test.StopTest();
	}

	@isTest static void test_createQuoteIteration(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		SellerTradePanelController.createQuoteIteration(testQuote);

		Test.StopTest();
	}
	
	@isTest static void test_createContract(){
		Test.StartTest();

		Map<String,Object> MockupData = Test_SellerTradePanelController.mockupProducerData();
		Quotation__c testQuote =  (Quotation__c)MockupData.get('quoteObj');
		SellerTradePanelController.createContract(testQuote);

		Test.StopTest();
	}

	
}