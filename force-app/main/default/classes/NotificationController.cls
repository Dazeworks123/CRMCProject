public class NotificationController {

	@AuraEnabled
	public static Map<String,Object> getNotify()
	{
		Account myAccount = UserService.getAccount();
		String findConsumer = myAccount == null?'': ' AND Producer__c =\''+myAccount.Id+'\' ';
		Map<String,Object> res = new Map<String,Object>();	
		String soql = 'SELECT Id,'+
		'Name,'+
		'Bid_Price__c,'+
		'Bid_Volume__c,'+
		//'Consumer__r.Icon_URL__c,'+
		//'Consumer__r.Name,'+
		//'Buyer__r.Name,'+
		//'Buyer__c,'+

		//'Producer__r.Icon_URL__c,'+
		//'Producer__r.Name,'+
		//'Seller__r.Name,'+
		//'Seller__c,'+

		'CreatedBy.Contact.Account.Icon_URL__c,'+
		'CreatedBy.Id,'+
		'CreatedBy.Name,'+
		'Quotation_Status__c,'+
		'Primary_Quotation__c,'+
		'CreatedDate FROM Quotation_Iteration__c '+
		'WHERE Bid_Price__c != NULL '+
		findConsumer +
		'ORDER BY CreatedDate DESC LIMIT 10';
		System.debug('soql : '+soql);
		List<Quotation_Iteration__c> listAccount = Database.query(soql);
		res.put('list',listAccount);

		return res;
	}
}