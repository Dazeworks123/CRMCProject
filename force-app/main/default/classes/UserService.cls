public with sharing class UserService {

	private static Account tmpAccount {set;get;}
	private static User tmpUser {set;get;}

	public static User getUser()
	{
		Id UserLogin = userinfo.getUserId();
		//Id UserLogin = '0050l000002Ht7p';
		//Id UserLogin = '0050l000002Ht7p';
		if(UserService.tmpUser == null)
		{
			System.debug('Find User');
			UserService.tmpUser = [SELECT Id,Name,Contact.Name,Contact.AccountId From User WHERE Id =: UserLogin];
		}
		return UserService.tmpUser;
	}

	public static Account getAccount()
	{
		Account res = null;
		
		User userData = UserService.getUser();
		if(userData.Contact.AccountId != null)
		{
			if(UserService.tmpAccount == null)
			{
				System.debug('Find Account');
				UserService.tmpAccount = [SELECT Id,Name FROM Account WHERE Id =: userData.Contact.AccountId];	
			}
			res = UserService.tmpAccount;
		}
		return res;
	}
}