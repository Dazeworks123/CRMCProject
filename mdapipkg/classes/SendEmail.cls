public class SendEmail {

    private Opportunity opp;
    private Contact contact;
    
    public SendEmail(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
    }
    
    public String fixDecimalPlaces (String inputNumber){
        String res = inputNumber; 
        if(res.substringAfter('.').length() == 0){
            res = res + '.00';
        }else if(res.substringAfter('.').length() == 1){
            res = res + '0';
        }
        return res;
    }
    
    public PageReference triggerEmail(){
        // OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
        Contact contact = [Select id, Email, Salutation, Name from Contact Where Id =: opp.Contact__c];
        Opportunity currentRecordValues = [Select o.Owner.Name, o.Contract_Email_Validator__c from Opportunity o where o.id =: opp.Id];
        User currentUser = [Select Name, companyName, User_Group__c from User where Name =: currentRecordValues.Owner.Name];
        Id SaleRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('1. Sales to Customer').getRecordTypeId();
        Id PurchaseRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('2. Purchase from Supplier').getRecordTypeId();
        
        String buyerName = '';
        String sellerName = '';
        String dealerName = '';
        String brokerName = '';
        String additionalCostItems = '';
        String shippingInfoItems_Loading = '';
        String shippingInfoItems_Destination = '';
        String sales_purchase_No = '';
        String EmailSubject = 'Trade Confirmation';
        String RecordTypeName = '';
        String CountyOfLoading = 'NIL';
        String CountyOfDest = 'NIL';
        String ForeignExchange = 'NIL';
        String ExchangeRate = 'NIL';
        String ExternalId;
        String SecondFactory = '';
        
        if(currentUser.User_Group__c == 'NCE'){
            if(opp.Factory_2nd_Opt__c != Null){
                SecondFactory = '<li><b>Factory (2nd Opt)</b>: '+ opp.Factory_2nd_Opt__c +'</li>';
            }else{
                SecondFactory = '<li><b>Factory (2nd Opt)</b>: NIL</li>';
            }
        }
        
        List<String> args = new String[] { '0', 'number', '#,###,###.##' };
        
        if(opp.Dealer__c != null){
            Account dealer = [Select Name from Account where Id =: opp.Dealer__c];
			dealerName = '<li><b>Dealer</b>:'+ dealer.Name +'</li>';
        }else{
            dealerName = '<li><b>Dealer</b>: NIL</li>';
        }
        if(opp.Agent_Broker__c != null){
            Account broker = [Select Name from Account where Id =: opp.Agent_Broker__c];
            brokerName = '<li><b>Agent/Broker</b>:'+ broker.Name +'</li>';
        }else{
            brokerName = '<li><b>Agent/Broker</b>: NIL</li>';
        }
        
        if(opp.Foreign_Exchange__c != null){
            Decimal ExchangeRateAmt = (opp.Exchange_Rate__c).setScale(2);
            ExchangeRate =  '$' + fixDecimalPlaces (String.format(ExchangeRateAmt.format(), args));
        }
        
       	if(opp.Country_of_Loading__c != null){
            CountyOfLoading = opp.Country_of_Loading__c;
        }
        if(opp.Country_of_Destination__c != null){
            CountyOfDest = opp.Country_of_Destination__c;
        }
        
        if(opp.ExternalID__c != null){
            ExternalId = '<li><b>External Reference No</b>: '+ opp.ExternalID__c +'</li>';
        }else{
            ExternalId = '<li><b>External Reference No</b>: NIL</li>';
        }
        
        if(opp.RecordTypeId ==  SaleRecordtypeId){
            if(opp.Buyer__c != null){
                Account buyer = [Select Name from Account where Id =: opp.Buyer__c];
                buyerName = buyer.Name;
            }
            sellerName = currentUser.CompanyName + ' - ' + currentUser.Name;
            sales_purchase_No = '<li><b>Sales No</b>:' + opp.Sales_No__c + '</li>';
            EmailSubject = 'Sales Confirmation - ' + opp.Sales_No__c + ' - ' + buyerName;
            RecordTypeName = 'Sales to Customer';
        }else if (opp.RecordTypeId == PurchaseRecordtypeId){
            if(opp.Seller__c != null){
                Account seller = [Select Name from Account where Id =: opp.Seller__c];
                sellerName = seller.Name;
            }
            buyerName = currentUser.CompanyName + ' - ' + currentUser.Name;
            sales_purchase_No = '<li><b>Purchase No</b>:' + opp.Purchase_No__c + '</li>';
            EmailSubject = 'Purchase Confirmation - ' + opp.Purchase_No__c + ' - ' + sellerName;
            RecordTypeName = 'Purchase from Supplier';
        }
        
        User UserRecord = [Select Id, User_Group__c From User Where Id =: opp.OwnerId];
        if(UserRecord.User_Group__c == 'Hevea Global'){
            EmailSubject = 'HEVEA Global ' + EmailSubject;
        }else if(UserRecord.User_Group__c == 'NCE '){
            EmailSubject = 'NCE ' + EmailSubject;
        }
        
        // Show and hide Additional Cost Items
        if(opp.Freight__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Freight</b>: $' + opp.Freight__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Freight</b>: NIL</li>';
        }
        if(opp.Insurance__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Insurance</b>: $' + opp.Insurance__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Insurance</b>: NIL</li>';
        }
        if(opp.Terminal_Handling__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Terminal Handling</b>: $' + opp.Terminal_Handling__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Terminal Handling</b>: NIL</li>';
        }
        if(opp.Stuffing__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Stuffing</b>: $' + opp.Stuffing__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Stuffing</b>: NIL</li>';
        }
        if(opp.Haulage__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Haulage</b>: $' + opp.Haulage__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Haulage</b>: NIL</li>';
        }
        if(opp.Financing__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Financing</b>: $' + opp.Financing__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Financing</b>: NIL</li>';
        }
        if(opp.Bank_charges__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Bank Charges</b>: $' + opp.Bank_charges__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Bank Charges</b>: NIL</li>';
        }
        if(opp.ISPM_15__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>ISPM#15</b>: $' + opp.ISPM_15__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>ISPM#15</b>: NIL</li>';
        }
        if(opp.Mosquito_Certification__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Mosquito Certification</b>: $' + opp.Mosquito_Certification__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Mosquito Certification</b>: NIL</li>';
        }
        if(opp.Plywood__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Plywood</b>: $' + opp.Plywood__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Plywood</b>: NIL</li>';
        }
        if(opp.Phytosanitary_Certification__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Phytosanitary Certification</b>: $' + opp.Phytosanitary_Certification__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Phytosanitary Certification</b>: NIL</li>';
        }
        if(opp.Commission_Brokerage_Fees__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Commission Brokerage Fees</b>: $' + opp.Commission_Brokerage_Fees__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Commission Brokerage Fees</b>: NIL</li>';
        }
        if(opp.Small_bales__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Small Bales</b>: $' + opp.Small_bales__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Small Bales</b>: NIL</li>';
        }
        if(opp.Thick_polybags__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Thick Polybags</b>: $' + opp.Thick_polybags__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Thick Polybags</b>: NIL</li>';
        }
        if(opp.Logistics__c > 0){
            additionalCostItems = additionalCostItems + '<li><b>Logistics</b>: $' + opp.Logistics__c + '</li>';
        }else{
            additionalCostItems = additionalCostItems + '<li><b>Logistics</b>: NIL</li>';
        }
        
        // Show or hide Shipping Info Items (Loading)
		String LoadingOpt1 = ' - ';
        String LoadingOpt2 = ' - ';
        String LoadingOpt3 = ' - ';
        String LoadingOpt1Row = ' ';
        String LoadingOpt2Row = ' ';
        String LoadingOpt3Row = ' ';
        if(opp.Port_of_Loading_1st_Opt__c != null || opp.Warehouse_of_Loading_1st_Opt__c != null){
            if(opp.Port_of_Loading_1st_Opt__c != null){
                LoadingOpt1 = opp.Port_of_Loading_1st_Opt__c;
            }
            if(opp.Warehouse_of_Loading_1st_Opt__c != null){
                LoadingOpt1 = LoadingOpt1 + ' / ' +opp.Warehouse_of_Loading_1st_Opt__c;
            }
            LoadingOpt1Row = '<li><I>Loading Port (1st Opt)</I>: ' + LoadingOpt1 + '</li>';
        }else{
            LoadingOpt1Row = '';
        }
        
        if(opp.Port_of_Loading_2nd_Opt__c != null || opp.Warehouse_of_Loading_2nd_Opt__c != null){
            if(opp.Port_of_Loading_2nd_Opt__c != null){
                LoadingOpt2 = opp.Port_of_Loading_2nd_Opt__c;
            }
            if(opp.Warehouse_of_Loading_2nd_Opt__c != null){
                LoadingOpt2 = LoadingOpt2 + ' / ' + opp.Warehouse_of_Loading_2nd_Opt__c;
            }
            LoadingOpt2Row = '<li><I>Loading Port (2nd Opt)</I>: ' + LoadingOpt2 + '</li>';
        }else{
            LoadingOpt2Row = '';
        }
        
        if(opp.Port_of_Loading_3rd_Opt__c != null || opp.Warehouse_of_Loading_3rd_Opt__c != null){
            if(opp.Port_of_Loading_3rd_Opt__c != null){
                LoadingOpt3 = opp.Port_of_Loading_3rd_Opt__c;
            }
            if(opp.Warehouse_of_Loading_3rd_Opt__c != null){
                LoadingOpt3 = LoadingOpt3 + ' / ' + opp.Warehouse_of_Loading_3rd_Opt__c;
            }
            LoadingOpt3Row = '<li><I>Loading Port (3rd Opt)</I>: ' + LoadingOpt3 + '</li>';
        }else{
            LoadingOpt3Row = '';
        }
        
        shippingInfoItems_Loading = '<Ul>' + LoadingOpt1Row + LoadingOpt2Row + LoadingOpt3Row + '</Ul>';
        
        // Show or hide Shipping Info Items (Destination)
		String DestOpt1 = ' - ';
        String DestOpt2 = ' - ';
        String DestOpt3 = ' - ';
        String DestOpt1Row = ' ';
        String DestOpt2Row = ' ';
        String DestOpt3Row = ' ';
        if(opp.Port_of_Destination_1st_Opt__c != null || opp.Warehouse_of_Destination_1st_Opt__c != null){
            if(opp.Port_of_Destination_1st_Opt__c != null){
                DestOpt1 = opp.Port_of_Destination_1st_Opt__c;
            }
            if(opp.Warehouse_of_Destination_1st_Opt__c != null){
                DestOpt1 = DestOpt1 + ' / ' +opp.Warehouse_of_Destination_1st_Opt__c;
            }
            DestOpt1Row = '<li><I>Destination Port (1st Opt)</I>: ' + DestOpt1 + '</li>';
        }else{
            DestOpt1Row = '';
        }
        
        if(opp.Port_of_Destination_2nd_Opt__c != null || opp.Warehouse_of_Destination_2nd_Opt__c != null){
            if(opp.Port_of_Destination_2nd_Opt__c != null){
                DestOpt2 = opp.Port_of_Destination_2nd_Opt__c;
            }
            if(opp.Warehouse_of_Destination_2nd_Opt__c != null){
                DestOpt2 = DestOpt2 + ' / ' + opp.Warehouse_of_Destination_2nd_Opt__c;
            }
            DestOpt2Row = '<li><I>Destination Port (2nd Opt)</I>: ' + DestOpt2 + '</li>';
        }else{
            DestOpt2Row = '';
        }
        
        if(opp.Port_of_Destination_3rd_Opt__c != null || opp.Warehouse_of_Destination_3rd_Opt__c != null){
            if(opp.Port_of_Destination_3rd_Opt__c != null){
                DestOpt3 = opp.Port_of_Destination_3rd_Opt__c;
            }
            if(opp.Warehouse_of_Destination_3rd_Opt__c != null){
                DestOpt3 = DestOpt3 + ' / ' + opp.Warehouse_of_Destination_3rd_Opt__c;
            }
            DestOpt3Row = '<li><I>Destination Port (3rd Opt)</I>: ' + DestOpt3 + '</li>';
        }else{
            DestOpt3Row = '';
        }
        
        shippingInfoItems_Destination = '<Ul>' + DestOpt1Row + DestOpt2Row + DestOpt3Row + '</Ul>';
        
        Decimal ContractValueAmt = 0;
        Decimal FinaleValueAmt = 0;
        Decimal TotalValueAmt = 0;
        Decimal FOBPriceAmt = 0;
        Decimal TradedPriceAmt = 0;
        
        if(opp.Contract_Value__c > 0){
            ContractValueAmt = (opp.Contract_Value__c).setScale(2);
        }
        if(opp.Final_Price__c > 0){
            FinaleValueAmt = (opp.Final_Price__c).setScale(2);
        }
        if(opp.Total_Cost__c > 0){
            TotalValueAmt = (opp.Total_Cost__c).setScale(2);
        }
        if(opp.FOB_Price__c > 0){
            FOBPriceAmt = (opp.FOB_Price__c).setScale(2);
        }
        if(opp.Price__c > 0){
            TradedPriceAmt = (opp.Price__c).setScale(2); 
        }
        
        String ContractValue =  '$' + fixDecimalPlaces (String.format(ContractValueAmt.format(), args));
        String FinalValue = '$' + fixDecimalPlaces(String.format(FinaleValueAmt.format(), args));
        String TotalValue = '$' + fixDecimalPlaces(String.format(TotalValueAmt.format(), args));
        String FOBPriceValue = '$' + fixDecimalPlaces(String.format(FOBPriceAmt.format(), args));
        String TradedPriceValue = '$' + fixDecimalPlaces(String.format(TradedPriceAmt.format(), args));
        
        // Send Email to Trader & Contract Team
        // Contract Team : contracts@halcyonagri.com
        // Tester : BeeChien@halcyonagri.com
		Custom_Fields__c CustomFields = Custom_Fields__c.getInstance();
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {CustomFields.Contract_Email__c};
        message.ccaddresses = new String[] {opp.OwnerId};
        // message.setOrgWideEmailAddressId(owa.id);  
        // ' + opp.Shipping_Month_Year__c.day() + ' / ' + opp.Shipping_Month_Year__c.month() + ' / ' + opp.Shipping_Month_Year__c.year()+ '
        Datetime tempStartDate = opp.Start_Shipping_Period__c;
        String StartDate = tempStartDate.format('dd MMM YYYY');
        Datetime tempEndtDate = opp.End_Shipping_Period__c;
        String EndDate = tempEndtDate.format('dd MMM YYYY');
        String htmlBodyToContractTeam = '<div style="font-size : 16px;"><h3>This is to confirm our transaction today:</h3><br/><b>A. Customer Information</b><ol>' + sales_purchase_No + '<li><b>Contract No</b>:'+ opp.Name +'</li>' + ExternalId + '<li><b>Type</b>: ' + RecordTypeName + '</li><li><b>Buyer</b>: ' + buyerName + '</li><li><b>Seller</b>: ' + sellerName + '</li><li><b>Contact</b>: ' + contact.Name + '</li>' + dealerName + brokerName + '<li><b>Rubber Grade</b>: ' + opp.Grade__c + '</li><li><b>Rubber Origin</b>: ' + opp.Rubber_Origin__c + '</li><li><b>Currency</b>: ' + opp.Currency__c + '</li><li><b>Tonnes</b>: ' + opp.Tonnes__c + '</li><li><b>Unit Price</b>: ' + opp.Price_Unit__c + '</li><li><b>Traded Price</b>: ' + TradedPriceValue + '</li><li><b>Total Cost Component</b>: ' + TotalValue + '</li><li><b>FOB Price</b>: ' + FOBPriceValue + '</li><li><b>Contract Value</b>: ' + ContractValue + '</li><li><b>Payment Terms</b>: ' + opp.Payment_Terms__c + '</li><li><b>Factory Name</b>:' + opp.Factory__r.Name + '</li>'+ SecondFactory +'</ol><br/><br/><b>B. Cost Components</b><ol><li><b>Shipping Terms</b>: ' + opp.Shipping_Terms__c + '</li> ' + additionalCostItems +'<li><b>Total Cost Component</b>: ' + TotalValue + '</li><li><b>Foreign Exchange</b>: ' + ForeignExchange + '</li><li><b>Foreign Exchange Rate</b>: ' + ExchangeRate + '</li><li><b>Contract Value (USD)</b>: ' + FinalValue+ '</li></ol><br/><br/><b>C. Shipping Information</b><ol><li><b>Start Shipping Period</b>: '+ StartDate + '</li><li><b>End Shipping Period</b>: '+ EndDate + '</li><li><b>Unit Size</b>: ' + opp.Unit_Size__c + '</li><li><b>Packing</b>: ' + opp.Packing__c + '</li><li><b>Country of Loading</b>: ' + CountyOfLoading + '</li>' + shippingInfoItems_Loading +'<li><b>Destination Country</b>: '+ CountyOfDest +'</li>'+ shippingInfoItems_Destination +'</ol>Thank you,<br/>' + opp.Owner.Name + '<br/>'+ opp.Owner.companyName +'</div><br/> <p>Please click <a href = "'+ System.URL.getSalesforceBaseUrl().ToExternalForm() +'/lightning/r/Opportunity/' + opp.Id + '/view">here</a> for more details.</p>';
        message.setHtmlBody(htmlBodyToContractTeam);
        message.subject = EmailSubject;
        Messaging.SingleEmailMessage[] messagesToContractTeam = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] resultsToContractTeam = Messaging.sendEmail(messagesToContractTeam);
        if (resultsToContractTeam[0].success) {
            System.debug('The email was sent successfully.');
            currentRecordValues.Contract_Email_Validator__c = 'Email Sent';
            update currentRecordValues;
        } else {
            System.debug('The email failed to send: '
                  + resultsToContractTeam[0].errors[0].message);
        }
        
        return null;
    }

}