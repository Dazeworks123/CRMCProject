trigger ValidateParentRecordStatus on Amendment_Slip__c (before insert) {
	Amendment_Slip__c AmendmentSlip = Trigger.New[0];
    Id CurrentLoginUser = UserInfo.getUserId();
    Opportunity Opty = [Select LastModifiedById, OwnerId from Opportunity Where Id =: AmendmentSlip.Opportunity__c Limit 1];
    
    if(Opty.OwnerId == CurrentLoginUser){
        User usr = [SELECT ProfileId FROM User Where Id =: Opty.LastModifiedById];
        Profile UserProfile = [Select Name from Profile Where Id =: usr.ProfileId];
        if(UserProfile.Name != 'Contract Team'){
            AmendmentSlip.addError('You will not be able to create Amendment slip before Contract team finalize the Contract number');
        }else{
            System.debug('Everything is Good');
        }
    }else{
        AmendmentSlip.addError('Only respective trade owner can create Amendment slip.');
    }
}