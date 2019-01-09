global class Batch_cleanQuoteByStatus implements Database.Batchable<sObject> {
	
	String query;
	
	global Batch_cleanQuoteByStatus() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Datetime now = Datetime.now();
		query = 'SELECT Id,Quotation_Status__c FROM Quotation__c WHERE Quotation_Status__c in (\'Rejected\',\'Done Deal\') AND LastModifiedDate < '+now.addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		cleanQuoteByStatus Cal = new cleanQuoteByStatus(scope);
		Cal.cleanQuote();
		Cal.updateQuote();
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}