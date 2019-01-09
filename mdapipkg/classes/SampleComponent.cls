public with sharing class SampleComponent {
	
	@AuraEnabled 
	public static Account getAccount(Id AccountId) 
	{
		Account account = [SELECT Id,Name From Account WHERE Id =:AccountId ];

		return account;
	}
}