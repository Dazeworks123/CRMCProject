public with sharing class BiddingPanelController {
    
    @AuraEnabled
    public static Map<String,Object> getFilterInfo(Map<String,String> data_filter) {
        Map<String,Object> response = new Map<String,Object>();
        
        Account myAccount = UserService.getAccount();
        String findMyFactory = myAccount != null?' AND Consumer__c = \''+myAccount.Id+'\' ':'';
        
        try
        {
            response.put('success',true);

            String destination = data_filter.get('destination');
            String country = data_filter.get('country');
            String port = data_filter.get('port');
            String producer = data_filter.get('producer');
            String grade = data_filter.get('grade');
            String packing = data_filter.get('packing');
            String payment = data_filter.get('payment');
            String shipping = data_filter.get('shipping');

            String findDestination = destination !='All'?' AND Id IN (SELECT Factory__c FROM Shipment__c WHERE Destination__r.Name = \''+destination+'\')':'';
            
            String findContry = country !='All'?' AND Factory_Location__c = \''+country+'\'':'';
            String findPort = port !='All'?' AND Port__c = \''+port+'\'':'';
            String findProducer = producer !='All'?' AND Producer_group__r.Id = \''+producer+'\'':'';

            List<Factory__c> filterList = Database.query('SELECT Factory_Location__c, '
                +'Port__c, '
                +'Producer_group__r.Id,'
                +'Producer_group__r.Name,'
                +'Producer_s_Group__c, '
                +'(SELECT Id,floor_price__c, Product__r.Name, Product__r.Price__c,Product__r.Id FROM Grades__r), '
                +'(SELECT Id,floor_price__c, Product__r.Name, Product__r.Price__c,Product__r.Id FROM Packing__r),'
                +'(SELECT Id, Payment_Term__c FROM Payment_Terms__r), '
                +'(SELECT Id,Incoterm__c,Destination__r.Name FROM Shipment_Information__r) '
                +'FROM Factory__c '
                +'WHERE Id IN (SELECT Factory_Approval__c FROM Factory_Approvals__c WHERE Approval_Status__c =\'Approved\' '+findMyFactory+') '
                +'AND Producer_group__c != null'
                +findContry);
            
            if(filterList.size()>0)
            {
                Map<String,String> destinationList = new Map<String,String>{'All'=>'All'};
                Map<String,String> countryList = new Map<String,String>{'All'=>'All'};
                Map<String,String> portList = new Map<String,String>{'All'=>'All'};
                Map<String,String> producerList = new Map<String,String>{'All'=>'All'};
                Map<String,String> gradeList = new Map<String,String>{''=>'Default'};
                Map<String,String> packingList = new Map<String,String>{''=>'Default'};
                Map<String,String> paymentList = new Map<String,String>{''=>'Default'};
                Map<String,String> shippingList = new Map<String,String>{''=>'Default'};
                
                for(Factory__c filterObj : filterList)
                {
                    countryList.put(filterObj.Factory_Location__c,filterObj.Factory_Location__c);
                    portList.put(filterObj.Port__c,filterObj.Port__c);
                    producerList.put(filterObj.Producer_group__r.Id,filterObj.Producer_group__r.Name);
                    List<Shipment__c> destinationObjList = filterObj.Shipment_Information__r;
                    
                    if(destinationObjList != null)
                    {
                        for(Shipment__c destinationObj : destinationObjList)
                        {
                            destinationList.put(destinationObj.Destination__r.Name,destinationObj.Destination__r.Name);
                        }
                    }
                }
                
                String findProductSQL = 'SELECT Factory_Location__c, Port__c, Producer_group__r.Id, Producer_group__r.Name, Producer_s_Group__c, (SELECT Id,floor_price__c, Product__r.Name,Product__r.Id FROM Grades__r), (SELECT Id,floor_price__c, Product__r.Name,Product__r.Id FROM Packing__r),(SELECT Id, Payment_Term__c FROM Payment_Terms__r), (SELECT Id,Incoterm__c,Destination__r.Name FROM Shipment_Information__r) FROM Factory__c WHERE Id IN (SELECT Factory_Approval__c FROM Factory_Approvals__c WHERE Approval_Status__c =\'Approved\' '+findMyFactory+') '+findDestination+findContry+findPort+findProducer;
                
                if(grade != '')
                {
                    
                    List<String> idFromGrade = new List<String>{'\'\''};
                    for(Product_Approval_List__c findId: [SELECT factory_product__c FROM Product_Approval_List__c WHERE RecordType.Name ='Grade' AND Product__r.Name =:grade])
                    {
                        
                        idFromGrade.add('\''+findId.factory_product__c+'\'');
                        
                    }
                    findProductSQL += ' AND Id IN ('+ String.join(idFromGrade, ',') +')';
                    
                }
                
                if(packing != '')
                {
                    
                    List<String> idFromPacking = new List<String>{'\'\''};
                    for(Product_Approval_List__c findId: [SELECT Factory_Packing__c FROM Product_Approval_List__c WHERE RecordType.Name ='Packing' AND Product__r.Name =:packing])
                    {
                        idFromPacking.add('\''+findId.Factory_Packing__c+'\'');
                    }
                    findProductSQL += ' AND Id IN ('+ String.join(idFromPacking, ',') +')';
                }

                if(payment != '')
                {
                    List<String> idFromPayment = new List<String>{'\'\''};
                    for(Payment_Term__c findId: [SELECT Factory__c FROM Payment_Term__c WHERE Payment_Term__c =:payment ])
                    {
                        idFromPayment.add('\''+findId.Factory__c+'\'');
                    }
                    findProductSQL += ' AND Id IN ('+ String.join(idFromPayment, ',') +')';
                }

                if(shipping != '')
                {
                    List<String> idFromShipping = new List<String>{'\'\''};
                    for(Shipment__c findId: [SELECT Factory__c FROM Shipment__c WHERE Incoterm__c =:shipping ])
                    {
                        idFromShipping.add('\''+findId.Factory__c+'\'');
                    }
                    findProductSQL += ' AND Id IN ('+ String.join(idFromShipping, ',') +')';
                }
                
                
                List<Factory__c> productSelectList = Database.query(findProductSQL);
                if(productSelectList.size()>0)
                {
                    for(Factory__c productSelectObj : productSelectList)
                    {
                        List<Product_Approval_List__c> gradeObjList = productSelectObj.Grades__r;
                        List<Product_Approval_List__c> packingObjList = productSelectObj.Packing__r;
                        
                        List<Payment_Term__c> paymentObjList = productSelectObj.Payment_Terms__r;
                        List<Shipment__c> shippingObjList = productSelectObj.Shipment_Information__r;
                        
                        if(gradeObjList != null)
                        {
                            for(Product_Approval_List__c gradeObj : gradeObjList)
                            {
                                
                                gradeList.put(gradeObj.Product__r.Name,gradeObj.Product__r.Name);
                            }       
                        }
                        if(packingObjList != null)
                        {
                            for(Product_Approval_List__c packingObj : packingObjList)
                            {
                                packingList.put(packingObj.Product__r.Name,packingObj.Product__r.Name);
                            }
                        }
                        if(paymentObjList != null)
                        {
                            for(Payment_Term__c paymentObj : paymentObjList)
                            {
                                paymentList.put(paymentObj.Payment_Term__c,paymentObj.Payment_Term__c);
                            }
                        }
                        if(shippingObjList != null)
                        {
                            for(Shipment__c shippingObj : shippingObjList)
                            {
                                shippingList.put(shippingObj.Incoterm__c,shippingObj.Incoterm__c);
                            }
                        }
                    }
                }
                
                
                String defaultGrade = '';
                if(country != 'All')
                {   
                    Product2 gradeDefault = [SELECT Id,Name FROM Product2 WHERE Country__c =:country AND Default_Product__c = true AND Family ='Grade' limit 1];
                    if(gradeDefault != null)
                    {
                        defaultGrade = gradeDefault.Name;
                    }
                }
                //Added by Anjali for HC-163 starts here
                String defaultCountry = 'All';
              
                
                if(!String.isBlank(grade) && grade != 'Default' ) {
                    
                    Product2 gradeDefault = [SELECT Id,Name,Country__c FROM Product2 WHERE Name =:grade AND Default_Product__c = true AND Family ='Grade' limit 1];
                    
                    if(gradeDefault != null)
                    {
                        defaultCountry = gradeDefault.Country__c ;
                        
                    }  
                }
                //ends here

                if(!destinationList.containsKey(destination)) data_filter.put('destination','All'); 
                if(!countryList.containsKey(country)) data_filter.put('country','All'); 
                if(!portList.containsKey(port)) data_filter.put('port','All');  
                if(!producerList.containsKey(producer)) data_filter.put('producer','All');  

                if(!gradeList.containsKey(grade)) data_filter.put('grade','');  
                if(!packingList.containsKey(packing)) data_filter.put('packing','');    
                if(!paymentList.containsKey(payment)) data_filter.put('payment','');    
                if(!shippingList.containsKey(shipping)) data_filter.put('shipping',''); 
                
                response.put('filter_info',new Map<String,Object>{
                    'destination'=>destinationList,
                    'country'=>countryList,
                    'port'=>portList,
                    'producer'=>producerList,
                    'grade'=>gradeList,
                    'packing'=>packingList,
                    'payment'=>paymentList,
                    'shipping'=>shippingList,
                    'defaultGrade'=>defaultGrade,
                    'findProductSQL'=>findProductSQL,
                    'defaultCountry'=>defaultCountry 
                });
                
                Date OneStDateNow = Helper.get1stDateNow();
                data_filter.put('date_now', String.valueOf(OneStDateNow));
                response.put('data_filter',data_filter);
            }
            else
            {
                response.put('success',false);
                response.put('error','Not found factory data');
            }
        }
        catch(Exception e)
        {
            response.put('success',false);
            response.put('error',e.getMessage());
        }
        
        return response;
    }

    @AuraEnabled
    public static Map<String,Object> getBiddingList(Map<String,String> data_filter) {
        Map<String,Object> response = new Map<String,Object>();
        try
        {
            response.put('success',true);
            String destination = data_filter.get('destination');
            String country = data_filter.get('country');
            String port = data_filter.get('port');
            String producer = data_filter.get('producer');
            String grade = data_filter.get('grade');
            String packing = data_filter.get('packing');
            String payment = data_filter.get('payment');
            String shipping = data_filter.get('shipping');

            Date dateFilter = Date.valueOf(data_filter.get('date'));
        

            Account myAccount = UserService.getAccount();
            String findMyFactory = myAccount != null?' AND Consumer__c = \''+myAccount.Id+'\' ':'';

            String searchQuery = 'SELECT Id,'+
            'Name,'+
            'Factory_Location__c,'+
            'Factory_Code__c,'+
            'Port__c,'+
            'Producer_group__r.Id,'+
            'Producer_group__r.Name,'+
            'Producer_s_Group__c, '+
            '(SELECT Id,floor_price__c, Product__r.Name,Product__r.Id,Product__r.Price__c,Default__c FROM Grades__r), '+
            '(SELECT Id,floor_price__c, Product__r.Name,Product__r.Id,Product__r.Price__c,Default__c FROM Packing__r),'+
            '(SELECT Id, Payment_Term__c,Additional_Charge__c,Default_Payment_Term__c FROM Payment_Terms__r), '+
            '(SELECT Id,Freight_Charges__c,Incoterm__c,Destination__r.Name,Default_Shipment__c FROM Shipment_Information__r) '+
            'FROM Factory__c '+
            'WHERE Id IN (SELECT Factory_Approval__c FROM Factory_Approvals__c WHERE Approval_Status__c =\'Approved\' '+findMyFactory+') '+
            'AND Producer_group__c != null';

            if(destination !='All')
            {
                List<String> idFromShipment = new List<String>{'\'\''};
                for(Shipment__c findShipment: [SELECT Factory__c FROM Shipment__c WHERE Destination__r.Name =:destination])
                {
                    idFromShipment.add('\''+findShipment.Factory__c+'\'');
                }
                searchQuery += ' AND Id IN ('+ String.join(idFromShipment, ',') +')';
            }
            if(country !='All')
            {
                searchQuery += ' AND Factory_Location__c = \''+country+'\'';
            }
            if(port !='All')
            {
                searchQuery += ' AND Port__c = \''+port+'\'';
            }
            if(producer !='All')
            {
                searchQuery += ' AND Producer_group__r.Id = \''+producer+'\'';
            }

            if(String.isNotEmpty(grade))
            {
                List<String> idFromGrade = new List<String>{'\'\''};
                for(Product_Approval_List__c findId: [SELECT factory_product__c FROM Product_Approval_List__c WHERE RecordType.Name ='Grade' AND Product__r.Name =:grade])
                {
                    idFromGrade.add('\''+findId.factory_product__c+'\'');
                }
                searchQuery += ' AND Id IN ('+ String.join(idFromGrade, ',') +')';
            }

            if(String.isNotEmpty(packing))
            {
                List<String> idFromPacking = new List<String>{'\'\''};
                for(Product_Approval_List__c findId: [SELECT Factory_Packing__c FROM Product_Approval_List__c WHERE RecordType.Name ='Packing' AND Product__r.Name =:packing])
                {
                    idFromPacking.add('\''+findId.Factory_Packing__c+'\'');
                }
                searchQuery += ' AND Id IN ('+ String.join(idFromPacking, ',') +')';    
            }

            
            if(String.isNotEmpty(payment))
            {
                List<String> idFromPayment = new List<String>{'\'\''};
                for(Payment_Term__c findId: [SELECT Factory__c FROM Payment_Term__c WHERE Payment_Term__c =:payment ])
                {
                    idFromPayment.add('\''+findId.Factory__c+'\'');
                }
                searchQuery += ' AND Id IN ('+ String.join(idFromPayment, ',') +')';    
            }
            
            if(String.isNotEmpty(shipping))
            {
                List<String> idFromShipping = new List<String>{'\'\''};
                for(Shipment__c findId: [SELECT Factory__c FROM Shipment__c WHERE Incoterm__c =:shipping ])
                {
                    idFromShipping.add('\''+findId.Factory__c+'\'');
                }
                searchQuery += ' AND Id IN ('+ String.join(idFromShipping, ',') +')';
            }

            List<Object> Header = new List<Object>();
            Header.add(new Map<String,String>{'name'=>'SYMBOLS/PORT','label'=>'SYMBOLS/PORT','type'=>'string'});
            Header.add(new Map<String,String>{'name'=>'FACTORY','label'=>'FACTORY','type'=>'string'});
            Header.add(new Map<String,String>{'name'=>'PRODUCER','label'=>'PRODUCER','type'=>'string'});

            for(Integer addMonthNo =0;addMonthNo<6;addMonthNo++)
            {
                Date currentMonth = dateFilter.addMonths(addMonthNo);
                Header.add(new Map<String,String>{'name'=>Helper.getDateIndex(currentMonth),'label'=>(Helper.getMonthStr(currentMonth.month()) +'/'+currentMonth.year() ),'type'=>'float'});    
            }
            
            System.debug('searchQuery :'+searchQuery);

            List<Factory__c> factoryList = Database.query(searchQuery);
            List<String> idFactory = new List<String>{'\'\''};
            for(Factory__c factoryObj:factoryList)
            {
                idFactory.add('\''+factoryObj.Id+'\''); 
            }
            List<Object> Data = new List<Object>();

            Map<String,Object> factoryFormat = BiddingPanelController.getFactoryFormat(factoryList);
            Map<String,Object> quoteFormat = BiddingPanelController.getQuoteFormat(idFactory,dateFilter);

            System.debug('quoteFormat : '+ JSON.serialize(quoteFormat));

            for(Factory__c factoryItem :factoryList)
            {
                List<Object> Row = new List<Object>();  
                Map<String,Object> factoryInfo = (Map<String,Object>) factoryFormat.get(factoryItem.Id);
                Map<String,Quotation__c> quoteInfo = (Map<String,Quotation__c>) quoteFormat.get(factoryItem.Id);

                Row.add(new Map<String,Object>{'fieldname'=>'SYMBOLS/PORT','value'=> factoryItem.Port__c,'type'=>'label'});
                Row.add(new Map<String,Object>{'fieldname'=>'FACTORY','value'=>factoryItem.Name,'type'=>'label'});
                Row.add(new Map<String,Object>{'fieldname'=>'PRODUCER','value'=>factoryItem.Producer_group__r.Name,'type'=>'label'});
                try
                {
                    for(Integer addMonthNo =0;addMonthNo<6;addMonthNo++)
                    {
                        Date currentMonth = dateFilter.addMonths(addMonthNo);
                        Row.add(BiddingPanelController.getBiddingCell(factoryInfo,quoteInfo,currentMonth,data_filter));
                    }   
                }
                catch(ApiException e)
                {
                    continue;
                }
                

                Data.add(Row);
            }

            response.put('header', Header); 
            response.put('data', Data);
            response.put('date_pre',dateFilter.addMonths(-6));
            response.put('date_next',dateFilter.addMonths(6));

        }
        catch(ApiException e)
        {
            response.put('success',false);
            response.put('error',e.getMessage());   
        }
        catch(Exception e)
        {
            response.put('success',false);
            response.put('error',e.getMessage());   
        }

        return response;
    }


    public static Map<String,Object> getBiddingCell(Map<String,Object> factoryInfo,Map<String,Quotation__c> quoteInfo,Date currentMonth,Map<String,String> data_filter) {
        String dateIndex = Helper.getDateIndex(currentMonth);
        Map<String,Object> result = new Map<String,Object>{
            'fieldname'=>dateIndex,
            'value'=>'',
            'type'=>'quote',
            'quote'=>null,
            'status'=>''
        };
        Factory__c  Factory = (Factory__c) factoryInfo.get('Factory');
        Map<String,Product_Approval_List__c>  GradesPrice = (Map<String,Product_Approval_List__c> ) factoryInfo.get('GradesPrice');
        Map<String,Product_Approval_List__c> PackingPrice = (Map<String,Product_Approval_List__c>) factoryInfo.get('PackingPrice');
        Map<String,Payment_Term__c> PaymentTermsPrice = (Map<String,Payment_Term__c>) factoryInfo.get('PaymentTermsPrice');
        Map<String,Shipment__c> ShipmentInformationPrice = (Map<String,Shipment__c>) factoryInfo.get('ShipmentInformationPrice');
        
        Product_Approval_List__c filterGrades = String.isNotEmpty(data_filter.get('grade')) ? 
            GradesPrice.get(data_filter.get('grade')): 
            (Product_Approval_List__c) factoryInfo.get('DefaultGrade');
        if(filterGrades == null)
        {
            throw new ApiException('Factory "'+Factory.Name+'" default grade are not defined. Please select product selection' );
        }

        Product_Approval_List__c filterPacking = String.isNotEmpty(data_filter.get('packing')) ? 
            PackingPrice.get(data_filter.get('packing')): 
            (Product_Approval_List__c)factoryInfo.get('DefaultPacking');
        if(filterPacking == null)
        {
            throw new ApiException('Factory "'+Factory.Name+'" default packing are not defined. Please select product selection' );
        }
        Payment_Term__c filterPaymentTerms = String.isNotEmpty(data_filter.get('payment')) ? 
            PaymentTermsPrice.get(data_filter.get('payment')): 
            (Payment_Term__c)factoryInfo.get('DefaultPayment');
        if(filterPaymentTerms == null)
        {
            throw new ApiException('Factory "'+Factory.Name+'" default payment term are not defined. Please select product selection' );
        }
        Shipment__c filterShipmentInformation = String.isNotEmpty(data_filter.get('shipping')) ? 
            ShipmentInformationPrice.get(data_filter.get('shipping')): 
            (Shipment__c)factoryInfo.get('DefaultShipment');
        if(filterShipmentInformation == null)
        {
            throw new ApiException('Factory "'+Factory.Name+'" default shipment are not defined. Please select product selection' );
        }


        if(quoteInfo != null && quoteInfo.containsKey(dateIndex))
        {
            try
            {
                Quotation__c celQuotation = quoteInfo.get(dateIndex);
                Product_Approval_List__c quoteGrades = GradesPrice.get(celQuotation.Grade__r.Name); // floor_price__c;
                Product_Approval_List__c quotePacking = PackingPrice.get(celQuotation.Packing__r.Name); // floor_price__c;
                Payment_Term__c quotePaymentTerms = PaymentTermsPrice.get(celQuotation.Payment_Term__r.Payment_Term__c); // Additional_Charge__c;
                Shipment__c quoteShipmentInformation = ShipmentInformationPrice.get(celQuotation.Shipment_Information__r.Incoterm__c); // Freight_Charges__c;
                Decimal quoteGradesPrice = quoteGrades.Product__r.Price__c == null?0:quoteGrades.Product__r.Price__c;
                Decimal quotePackingPrice = quotePacking.Product__r.Price__c == null?0:quotePacking.Product__r.Price__c;
                Decimal quotePaymentTermsPrice = quotePaymentTerms.Additional_Charge__c == null?0:quotePaymentTerms.Additional_Charge__c;
                Decimal quoteShipmentInformationPrice = quoteShipmentInformation.Freight_Charges__c== null?0:quoteShipmentInformation.Freight_Charges__c;

                Decimal filterGradesPrice = filterGrades.Product__r.Price__c == null?0:filterGrades.Product__r.Price__c;
                Decimal filterPackingPrice = filterPacking.Product__r.Price__c == null?0:filterPacking.Product__r.Price__c;
                Decimal filterPaymentTermsPrice = filterPaymentTerms.Additional_Charge__c == null?0:filterPaymentTerms.Additional_Charge__c;
                Decimal filterShipmentInformationPrice = filterShipmentInformation.Freight_Charges__c== null?0:filterShipmentInformation.Freight_Charges__c;

                celQuotation.Grade__r = filterGrades.Product__r;
                celQuotation.Packing__r = filterPacking.Product__r;
                celQuotation.Payment_Term__r = filterPaymentTerms;
                celQuotation.Shipment_Information__r = filterShipmentInformation;
                celQuotation.Grade__c = filterGrades.Product__r.Id;
                celQuotation.Packing__c = filterPacking.Product__r.Id;
                celQuotation.Payment_Term__c = filterPaymentTerms.Id;
                celQuotation.Shipment_Information__c = filterShipmentInformation.Id;
                
                if(celQuotation.Bid_Price__c!=null)
                {
                    Decimal bid_price = celQuotation.Bid_Price__c;
                    Decimal originalBidPrice = bid_price - quoteGradesPrice - quotePackingPrice - quotePaymentTermsPrice - quoteShipmentInformationPrice;
                    Decimal newBidValue = originalBidPrice + filterGradesPrice + filterPackingPrice + filterPaymentTermsPrice + filterShipmentInformationPrice;
                    celQuotation.Bid_Price__c = newBidValue;    
                    result.put('value',newBidValue);
                }

                if(celQuotation.Ask_Price__c!=null)
                {
                    Decimal ark_price = celQuotation.Ask_Price__c;
                    Decimal originalArkPrice = ark_price - quoteGradesPrice - quotePackingPrice - quotePaymentTermsPrice - quoteShipmentInformationPrice;
                    Decimal newArkValue = originalArkPrice + filterGradesPrice + filterPackingPrice + filterPaymentTermsPrice + filterShipmentInformationPrice;
                    celQuotation.Ask_Price__c = newArkValue;    
                    result.put('value',newArkValue);
                }
                
                result.put('quote',celQuotation);   

                if(celQuotation.Quotation_Status__c == 'Open')
                {
                    result.put('status','Open');
                }
                else
                {
                    result.put('status','Trade');
                }
            }
            catch(Exception e)
            {
                throw new ApiException(e.getMessage());
                //System.debug(' Error text :'+e.getMessage());
                //System.debug(' Error factoryInfo :'+JSON.serialize(factoryInfo));
                //System.debug(' Error quoteInfo :'+JSON.serialize(quoteInfo));
                //Error for set cell
            }
            
        }
        else
        {
            Id UserLogin = userinfo.getUserId();
            Account myAccount = UserService.getAccount();

            Date dateQuote = Date.valueOf(dateIndex);
            Account  producer = (Account) Factory.Producer_group__r;
            if(producer == null)
            {
                throw new ApiException('Some factory no producer. please select producer');
            }

            Quotation__c quoteObj = new Quotation__c();
            quoteObj.Buyer__c = UserLogin;
            quoteObj.Consumer__c = myAccount == null?null:myAccount.Id;
            quoteObj.Grade__c = filterGrades.Product__r.Id;
            quoteObj.Packing__c = filterPacking.Product__r.Id;
            quoteObj.Payment_Term__c = filterPaymentTerms.Id;
            quoteObj.Shipment_Information__c = filterShipmentInformation.Id;
            quoteObj.Factory__c = Factory.Id;
            quoteObj.Factory__r = Factory;
            quoteObj.Bid_Price__c = 0;
            quoteObj.Bid_Volume__c = 100.8;
            //quoteObj.Ask_Price__c = 0;
            quoteObj.Ask_Volume__c = 100.8;
            quoteObj.Month__c = Helper.getMonthStr(dateQuote.month());
            quoteObj.Quote_Effective_Month__c = dateQuote;
            quoteObj.All_or_Nothing__c = true;
            quoteObj.Producer__c = producer.Id;
            quoteObj.Producer__r = producer;
            quoteObj.Grade__r = filterGrades.Product__r;
            quoteObj.Packing__r = filterPacking.Product__r;
            quoteObj.Payment_Term__r = filterPaymentTerms;
            quoteObj.Shipment_Information__r = filterShipmentInformation;

            result.put('quote',quoteObj);       
        }

        return result;
    }

    public static Map<String,Object> getQuoteFormat(List<String> idFactory,Date OneStDate) {
        //Should Find Consumer 
        Account myAccount = UserService.getAccount();
        String findConsumer = myAccount != null?' AND Consumer__c = \''+myAccount.Id+'\' ':'';

        Date OneStDate6Month = OneStDate.addMonths(6);

        String searchQuery = 'SELECT '
            +'Consumer__c,'
            +'Producer__r.Name,'
            +'Ask_Price__c,'
            +'Ask_Volume__c,'
            +'Bid_Price__c,'
            +'Bid_Volume__c,'
            +'Grade__r.Name,'
            +'Seller__r.Id,'
            +'Seller__r.Name,'
            +'Packing__r.Name,'
            +'Payment_Term__r.Payment_Term__c,'
            +'Shipment_Information__r.Incoterm__c,'
            +'Quotation_Status__c,'
            +'Month__c,'
            +'Port__c,'
            +'All_or_Nothing__c,'
            +'Factory__r.Id,'
            +'Factory__r.Name,'
            +'Factory__r.Factory_Code__c,'
            +'Quote_Effective_Month__c,'
            +'Factory__r.Port__c,'
            +'Id '
            +'FROM Quotation__c WHERE Quotation_Status__c NOT IN (\'Pulled\',\'Cancelled\', \'Done Deal\',\'Rejected\') AND Factory__c in ('+ String.join(idFactory, ',') +') '
            +findConsumer
            +'AND (Quote_Effective_Month__c >= '+ Helper.ConvertDateSOQLFormat(OneStDate) +' AND Quote_Effective_Month__c < '+ Helper.ConvertDateSOQLFormat(OneStDate6Month) +')';

        List<Quotation__c> listQuote = Database.query(searchQuery);
        Map<String,Object> quoteFormat = new Map<String,Object>();
        for(Quotation__c quoteObj :listQuote)
        {
            String dateIndex = Helper.getDateIndex(quoteObj.Quote_Effective_Month__c);
            Map<String,Quotation__c> factoryFormat = new Map<String,Quotation__c>();
            if(quoteFormat.containsKey(quoteObj.Factory__r.Id))
            {
                factoryFormat = (Map<String,Quotation__c>) quoteFormat.get(quoteObj.Factory__r.Id);
            }

            factoryFormat.put(dateIndex,quoteObj);
            quoteFormat.put(quoteObj.Factory__r.Id,factoryFormat);  
        }

        return quoteFormat;
    }

    public static Map<String,Object> getFactoryFormat(List<Factory__c> factoryList) {
        Map<String,Object> factoryFormat = new Map<String,Object>();
        for(Factory__c factoryObj :factoryList)
        {
            Map<String,Product_Approval_List__c> GradesPrice = new Map<String,Product_Approval_List__c>();
            Map<String,Product_Approval_List__c> PackingPrice = new Map<String,Product_Approval_List__c>();
            Map<String,Payment_Term__c> PaymentTermsPrice = new Map<String,Payment_Term__c>();
            Map<String,Shipment__c> ShipmentInformationPrice = new Map<String,Shipment__c>();
            Product_Approval_List__c defaultGrade = null;
            Product_Approval_List__c defaultPacking = null;
            Payment_Term__c defaultPayment = null;
            Shipment__c defaultShipment = null;

            //(SELECT Id,floor_price__c, Product__r.Name,Product__r.Id,Product__r.Price__c,Default__c FROM Grades__r),
            for(Product_Approval_List__c objPrice:factoryObj.Grades__r)
            {
                if(objPrice.Default__c)
                {
                    defaultGrade =  objPrice;
                }
                GradesPrice.put(objPrice.Product__r.Name, objPrice); // objPrice.floor_price__c);
            }
            //(SELECT Id,floor_price__c, Product__r.Name,Product__r.Id,Product__r.Price__c,Default__c FROM Packing__r),
            for(Product_Approval_List__c objPrice:factoryObj.Packing__r)
            {
                if(objPrice.Default__c)
                {
                    defaultPacking = objPrice;
                }
                PackingPrice.put(objPrice.Product__r.Name, objPrice); // objPrice.floor_price__c);
            }
            //(SELECT Id, Payment_Term__c,Additional_Charge__c,Default_Payment_Term__c FROM Payment_Terms__r), 
            for(Payment_Term__c objPrice:factoryObj.Payment_Terms__r)
            {
                if(objPrice.Default_Payment_Term__c)
                {
                    defaultPayment = objPrice;
                }
                PaymentTermsPrice.put(objPrice.Payment_Term__c, objPrice); // objPrice.Additional_Charge__c);
            }
            //(SELECT Id,Freight_Charges__c,Incoterm__c,Destination__r.Name,Default_Shipment__c FROM Shipment_Information__r)
            for(Shipment__c objPrice:factoryObj.Shipment_Information__r)
            {
                if(objPrice.Default_Shipment__c)
                {
                    defaultShipment = objPrice;
                }
                ShipmentInformationPrice.put(objPrice.Incoterm__c, objPrice); // objPrice.Freight_Charges__c);
            }
            
            factoryFormat.put(factoryObj.Id,new Map<String,Object>{
                'Factory'=>factoryObj,
                'GradesPrice'=>GradesPrice,
                'PackingPrice'=>PackingPrice,
                'PaymentTermsPrice'=>PaymentTermsPrice,
                'ShipmentInformationPrice'=>ShipmentInformationPrice,
                'DefaultGrade'=>defaultGrade,
                'DefaultPacking'=>defaultPacking,
                'DefaultPayment'=>defaultPayment,
                'DefaultShipment'=>defaultShipment
            }); 
        }

        return factoryFormat;
    }

}