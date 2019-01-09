@isTest
private class Test_OfferPanelController {

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
	
	@isTest static void test_getFilterInfo() {
		Test.StartTest();
		Account myAccount = UserService.getAccount();
		Map<String,Object>  result =  OfferPanelController.getFilterInfo();
		Test.StopTest();
	}
	
	@isTest static void test_getInformation() {
		Test.StartTest();
		Map<String,Object> result =  OfferPanelController.getInformation(new Map<String,String>{
			'consumer'=>'All',
			'country'=>'Indonesia',
			'date'=>'2019-01-01'
		});
		Test.StopTest();
	}
		@isTest static void test_getOfferList() {
		Test.StartTest();
		Map<String,Object> result =  OfferPanelController.getOfferList(new Map<String,String>{
			'consumer'=>'All',
			'country'=>'Indonesia',
			'date'=>'2019-01-01'
		});
		Test.StopTest();
	}

	@isTest static void test_getQuoteFormat() {
		Test.StartTest();
		Account myAccount = UserService.getAccount();
		Map<String,Object> result =  OfferPanelController.getQuoteFormat('All','Indonesia',Date.valueOf('2019-01-01'));
		Test.StopTest();
	}
	
}