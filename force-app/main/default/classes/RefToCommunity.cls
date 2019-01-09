public with sharing class RefToCommunity {
	public RefToCommunity() {
		
	}

	@AuraEnabled
    public static String refUser() {
    	Profile profileObj = [Select Name from Profile where Id =: userinfo.getProfileId()];
    	if(profileObj.Name == 'Consumer User')
    	{
		    ApexPages.PageReference ref = new ApexPages.PageReference('/consumer');
            aura.redirect(ref);
            return null;
    	}
    	else if(profileObj.Name == 'Producer User')
    	{
    		ApexPages.PageReference ref = new ApexPages.PageReference('/producer');
            aura.redirect(ref);
    		return null;
    	}
    	else
    	{
    		return profileObj.Name;	
    	}
    }
}