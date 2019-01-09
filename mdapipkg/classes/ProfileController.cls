public class ProfileController {
    
    @AuraEnabled
    public static String getUserProfile() {
        List<Profile> myProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        return myProfile[0].Name;
    }
}