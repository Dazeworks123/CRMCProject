@isTest
private class ProfileControllerTest
{
    @isTest
    static void profileNameMethod()
    {
        Profile p = [SELECT Id,Name FROM Profile WHERE Id =: userinfo.getProfileId() LIMIT 1]; 
        String result = ProfileController.getUserProfile();
        System.assertEquals(p.Name, result);
    }
}