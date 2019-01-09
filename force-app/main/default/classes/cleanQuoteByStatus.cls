public with sharing class cleanQuoteByStatus {
	List<Quotation__c> quoteList {set;get;}
	List<Quotation__c> quoteListUpdate {set;get;}
	public cleanQuoteByStatus(List<sObject> scope)
 	{
 		this.quoteList = new List<Quotation__c>();
        for(sObject s : scope){
        	this.quoteList.add((Quotation__c)s);
        }	
 	}

 	public void cleanQuote()
 	{
 		this.quoteListUpdate = new List<Quotation__c>();
 		for(Quotation__c quoteModel :this.quoteList)
 		{
 			quoteModel.Quotation_Status__c = 'Cancelled';
 			this.quoteListUpdate.add(quoteModel);
 		}

 	}

 	public void updateQuote()
 	{
 		upsert this.quoteListUpdate;
 	}
}