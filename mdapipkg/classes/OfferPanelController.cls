public with sharing class OfferPanelController {
	

    @AuraEnabled
    public static Map<String,Object> getFilterInfo() {
        Map<String,Object> response = new Map<String,Object>();
        
        Account myAccount = UserService.getAccount();
        String findMyFactory = myAccount != null?' AND Factory_Approval__r.Producer_group__c = \''+myAccount.Id+'\' ':'';
        String soql = 
            'SELECT Id,'+
            'Name,'+
            '(SELECT Id ,Factory_Approval__r.Factory_Location__c FROM Factory_Approval_List__r WHERE Approval_Status__c =\'Approved\' '+findMyFactory+' ORDER BY Factory_Approval__r.Factory_Location__c ASC) '+
            'FROM Account '+
            'WHERE RecordType.Name = \'Consumer\' '+
            'AND Id In (SELECT Consumer__c FROM Factory_Approvals__c WHERE Approval_Status__c =\'Approved\' '+findMyFactory+')';
        System.debug('getFilterInfo soql :'+soql);
        List<Account> listConsumerObj = Database.query(soql);
        Map<String,Object> consumerList = new Map<String,Object>{
            'All'=>new Map<String,Object>{
                'label'=>'All',
                'country_list'=>new Map<String,String>()
            }
        };

        for(Account account :listConsumerObj)
        {
            List<Factory_Approvals__c> factoryApproveList =  account.Factory_Approval_List__r;
            Map<String,Object> allConsumer = (Map<String,Object>)consumerList.get('All');
            Map<String,String> allCountry = (Map<String,String>)allConsumer.get('country_list');

            
            Map<String,String> consumerCountry = new Map<String,String>();
            for(Factory_Approvals__c factoryApprove : factoryApproveList)
            {
                allCountry.put(factoryApprove.Factory_Approval__r.Factory_Location__c,factoryApprove.Factory_Approval__r.Factory_Location__c);
                consumerCountry.put(factoryApprove.Factory_Approval__r.Factory_Location__c,factoryApprove.Factory_Approval__r.Factory_Location__c);
            }

            Map<String,Object> consumer = new Map<String,Object>();

            allConsumer.put('country_list', allCountry);
            consumerList.put('All',allConsumer);
            consumerList.put(account.Id,new Map<String,Object>{
                'label'=>account.Name,
                'country_list'=>consumerCountry
            });
        }

        Date OneStDateNow = Helper.get1stDateNow();
        response.put('filter_info',consumerList);
        response.put('date_now',OneStDateNow);

        return response;
    }

	@AuraEnabled
    public static Map<String,Object> getInformation(Map<String,String> FilterInfo) {
    	Map<String,Object> response = new Map<String,Object>();
    
        Map<String,Object> grade_info = new Map<String,Object>{
            'header'=>new List<Object>{
                new Map<String,Object>{'name'=>'grade','label'=>'GRADE'},   
                new Map<String,Object>{'name'=>'AdditionalPremium','label'=>'ADDITIONAL PREMIUM'}  
            },
            'data'=>new List<Object>()
        };
        Map<String,Object> packing_info = new Map<String,Object>{
            'header'=>new List<Object>{
                new Map<String,Object>{'name'=>'packing','label'=>'PACKING'},   
                new Map<String,Object>{'name'=>'pricing','label'=>'PRICING'}  
            },
            'data'=>new List<Object>()
        };
        Map<String,Object> payment_info = new Map<String,Object>{
            'header'=>new List<Object>{
                new Map<String,Object>{'name'=>'payment','label'=>'PAYMENT'},   
                new Map<String,Object>{'name'=>'pricing','label'=>'PRICING'}   
            },
            'data'=>new List<Object>()
        };
        Map<String,Object> destination_info = new Map<String,Object>{
            'header'=>new List<Object>{
                new Map<String,Object>{'name'=>'destination','label'=>'DESTINATION'},   
                new Map<String,Object>{'name'=>'Incoterm','label'=>'INCOTERM'},   
                new Map<String,Object>{'name'=>'Freight_Charges__c','label'=>'FREIGHT CHARGES'}
            },
            'data'=>new List<Object>()
        };

        String ConsumerSelect = FilterInfo.get('consumer');
        String CountrySelect = FilterInfo.get('country');
        Account myAccount = UserService.getAccount();
        String findMyFactory = myAccount != null?' AND Producer_group__c = \''+myAccount.Id+'\' ':'';
        String findConsumer = ConsumerSelect =='All'?'':'AND Consumer__c =\''+ConsumerSelect+'\'';
        String searchQuery = 'SELECT Id,Name,Factory_Location__c,Factory_Code__c, Port__c, Producer_s_Group__c, '
        +'(SELECT Id,floor_price__c, Product__r.Price__c,Product__r.Name,Product__r.Id FROM Grades__r ORDER BY Default__c DESC), '
        +'(SELECT Id,floor_price__c, Product__r.Name,Product__r.Id, Product__r.Price__c FROM Packing__r ORDER BY Default__c DESC),'
        +'(SELECT Id, Payment_Term__c,Additional_Charge__c FROM Payment_Terms__r ORDER BY Default_Payment_Term__c DESC), '
        +'(SELECT Id,Freight_Charges__c,Incoterm__c,Destination__r.Name FROM Shipment_Information__r ORDER BY Default_Shipment__c DESC) '
        +'FROM Factory__c '
        +'WHERE Id IN (SELECT Factory_Approval__c FROM Factory_Approvals__c WHERE Approval_Status__c =\'Approved\' '+findConsumer+') '
        +'AND Factory_Location__c =\''+CountrySelect+'\' '
        +findMyFactory;

        List<Factory__c> productSelectList = Database.query(searchQuery);
        

        Map<String,Product_Approval_List__c> gradeList = new Map<String,Product_Approval_List__c>(); 
        Map<String,Product_Approval_List__c> packingList = new Map<String,Product_Approval_List__c>();
        Map<String,Payment_Term__c> paymentList = new Map<String,Payment_Term__c>();
        Map<String,Shipment__c> shippingList = new Map<String,Shipment__c>();

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
                    gradeList.put(gradeObj.Product__r.Name,gradeObj);
                }       
            }
            if(packingObjList != null)
            {
                for(Product_Approval_List__c packingObj : packingObjList)
                {
                    packingList.put(packingObj.Product__r.Name,packingObj);
                }
            }
            if(paymentObjList != null)
            {
                for(Payment_Term__c paymentObj : paymentObjList)
                {
                    paymentList.put(paymentObj.Payment_Term__c,paymentObj);
                }
            }
            if(shippingObjList != null)
            {
                for(Shipment__c shippingObj : shippingObjList)
                {
                    shippingList.put(shippingObj.Incoterm__c,shippingObj);
                }
            }
        }

        
        List<Object> dataRowGrade = new List<Object>();
        for(String keyName : gradeList.keySet())
        {
            
            Product_Approval_List__c dataInfo = gradeList.get(keyName);
            dataRowGrade.add(new List<Object>{
                new Map<String,Object>{'fieldname'=>'grade','value'=>dataInfo.Product__r.Name},
                new Map<String,Object>{'fieldname'=>'AdditionalPremium','value'=>  Helper.convertDecimalToDecimalWithComma(dataInfo.Product__r.Price__c)}
            });
        }     
        grade_info.put('data',dataRowGrade);

        List<Object> dataRowPacking = new List<Object>();
        for(String keyName : packingList.keySet())
        {
            Product_Approval_List__c dataInfo = packingList.get(keyName);
            dataRowPacking.add(new List<Object>{
                new Map<String,Object>{'fieldname'=>'packing','value'=>dataInfo.Product__r.Name},
                new Map<String,Object>{'fieldname'=>'pricing','value'=>Helper.convertDecimalToDecimalWithComma(dataInfo.Product__r.Price__c)}
            });
        }     
        packing_info.put('data',dataRowPacking);

        List<Object> dataRowPayment = new List<Object>();
        for(String keyName : paymentList.keySet())
        {
            Payment_Term__c dataInfo = paymentList.get(keyName);
            dataRowPayment.add(new List<Object>{
                new Map<String,Object>{'fieldname'=>'payment','value'=>dataInfo.Payment_Term__c},
                new Map<String,Object>{'fieldname'=>'pricing','value'=>Helper.convertDecimalToDecimalWithComma(dataInfo.Additional_Charge__c)}
            });
        }     
        payment_info.put('data',dataRowPayment);

        List<Object> dataRowShipment = new List<Object>();
        for(String keyName : shippingList.keySet())
        {
            Shipment__c dataInfo = shippingList.get(keyName);
            dataRowShipment.add(new List<Object>{
                new Map<String,Object>{'fieldname'=>'destination','value'=>dataInfo.Destination__r.Name},
                new Map<String,Object>{'fieldname'=>'Incoterm','value'=>dataInfo.Incoterm__c},
                new Map<String,Object>{'fieldname'=>'Freight_Charges__c','value'=>Helper.convertDecimalToDecimalWithComma(dataInfo.Freight_Charges__c)}

            });
        }     
        destination_info.put('data',dataRowShipment);

        response.put('grade_info',grade_info);
        response.put('packing_info',packing_info);
        response.put('payment_info',payment_info);
        response.put('destination_info',destination_info);

    	return response;
    }

	@AuraEnabled
    public static Map<String,Object> getOfferList(Map<String,String> FilterInfo) {
    	Map<String,Object> response = new Map<String,Object>();
    	
    	String ConsumerSelect = FilterInfo.get('consumer');
    	String CountrySelect = FilterInfo.get('country');
        Date dateNow = Date.valueOf(FilterInfo.get('date'));
    	String view = FilterInfo.get('view');
    	
        Map<String,Object> quoteFormat = OfferPanelController.getQuoteFormat(ConsumerSelect,CountrySelect,dateNow);
        Map<String,Object> factoryConsumerFormat = OfferPanelController.getFactoryFormat(ConsumerSelect,CountrySelect);

    	List<Object> Header = new List<Object>();
    	Header.add(new Map<String,String>{'name'=>'COUNTRY','label'=>'COUNTRY','type'=>'string'});
		Header.add(new Map<String,String>{'name'=>'PORTS','label'=>'PORTS','type'=>'string'});
		if(view == 'factory')
		{
            Header.add(new Map<String,String>{'name'=>'SYMBOL','label'=>'SYMBOL','type'=>'string'});  
			Header.add(new Map<String,String>{'name'=>'FACTORY','label'=>'FACTORY','type'=>'string'});	
		}

        for(Integer addMonthNo =0;addMonthNo<6;addMonthNo++)
        {
            Date currentMonth = dateNow.addMonths(addMonthNo);
            Header.add(new Map<String,String>{'name'=>Helper.getDateIndex(currentMonth),'label'=> (Helper.getMonthStr(currentMonth.month())+'/'+currentMonth.year() ),'type'=>'float'});    
        }

    	List<Object> Data = new List<Object>();

        Account myAccount = UserService.getAccount();
        String findMyFactory = myAccount != null?' AND Producer_group__c = \''+myAccount.Id+'\' ':'';
        String findConsumer = ConsumerSelect =='All'?'':'AND Consumer__c =\''+ConsumerSelect+'\'';
        String factoryField = view == 'factory'?',Name,Factory_Code__c':'';
        List<AggregateResult> listObj = Database.query('SELECT Factory_Location__c,Port__c'+factoryField+' FROM Factory__c WHERE Id in (SELECT Factory_Approval__c FROM Factory_Approvals__c WHERE Approval_Status__c =\'Approved\' '+findConsumer+' ) AND Factory_Location__c =\''+CountrySelect+'\' '+findMyFactory+' GROUP BY Factory_Location__c,Port__c'+factoryField);
    	for(AggregateResult offerItem :listObj)
    	{
    		List<Object> Row = new List<Object>();	
    		Row.add(new Map<String,Object>{'fieldname'=>'COUNTRY','value'=> offerItem.get('Factory_Location__c'),'status'=>'','editable'=>false});
			Row.add(new Map<String,Object>{'fieldname'=>'PORTS','value'=>offerItem.get('Port__c'),'status'=>'','editable'=>false});
			if(view == 'factory')
			{
                Row.add(new Map<String,Object>{'fieldname'=>'FACTORY','value'=>offerItem.get('Name'),'status'=>'','editable'=>false});  
				Row.add(new Map<String,Object>{'fieldname'=>'SYMBOL','value'=>offerItem.get('Factory_Code__c'),'status'=>'','editable'=>false});	
			}

            for(Integer addMonthNo =0;addMonthNo<6;addMonthNo++)
            {
                Date currentMonth = dateNow.addMonths(addMonthNo);
                Row.add(OfferPanelController.getOfferListCell(factoryConsumerFormat,quoteFormat, offerItem ,currentMonth,view,ConsumerSelect));
            }
			Data.add(Row);
    	}

    	response.put('header', Header);	
    	response.put('data', Data);
        response.put('date_pre',dateNow.addMonths(-6));
        response.put('date_next',dateNow.addMonths(6));

    	return response;
    }

    public static Map<String,Object> getOfferListCell(Map<String,Object> factoryConsumerFormat,Map<String,Object> quoteFormat,AggregateResult offerItem ,Date currentMonth,String view,String ConsumerSelect) {
        String dateIndex = Helper.getDateIndex(currentMonth);
        Map<String,Object> result = new Map<String,Object>{
            'fieldname'=>dateIndex,
            'value'=>'',
            'status'=>'',
            'editable'=>true
        };
        
        if(quoteFormat.containsKey(dateIndex))
        {
            Map<String,Object> portFormat= (Map<String,Object>) quoteFormat.get(dateIndex);

            if(portFormat.containsKey((String)offerItem.get('Port__c')) && factoryConsumerFormat.containsKey((String)offerItem.get('Port__c')))
            {   
                Map<String,Object> factoryFormat = (Map<String,Object>) portFormat.get((String)offerItem.get('Port__c'));
                Map<String,Object> factoryNameFormat = (Map<String,Object>) factoryConsumerFormat.get((String)offerItem.get('Port__c'));
                List<Quotation__c> quoteAllList = new List<Quotation__c>();
                
                Set<String> factoryNameList = view =='factory'?new Set<String>{(String)offerItem.get('Name')} : factoryNameFormat.keySet();
                for(String factory:factoryNameList)
                {
                    if(factoryNameFormat.containsKey(factory))
                    {
                        Map<String,Object>  consumerList = (Map<String,Object>) factoryNameFormat.get(factory);
                        
                        if(factoryFormat.containsKey(factory))
                        {
                            Map<String,Quotation__c> listQuoteInFactory = (Map<String,Quotation__c>)factoryFormat.get(factory);
                            for(String consumerId : consumerList.keySet())
                            {
                                if(ConsumerSelect == 'All' || ConsumerSelect == consumerId)
                                {   
                                    if(listQuoteInFactory.containsKey(consumerId))
                                    {
                                        quoteAllList.add(listQuoteInFactory.get(consumerId));
                                    }
                                    else
                                    {
                                        quoteAllList.add(null);
                                    }
                                }
                            }
                        }
                        else
                        {
                            quoteAllList.add(null);
                        }
                    }
                    
                }

                if(quoteAllList.size() > 0)
                {

                    System.debug('quoteAllList :'+quoteAllList);
                    //find cell case 
                    Boolean isEmpty = false;
                    Boolean isDraft = true;
                    Boolean isBidding = false;

                    List<Decimal> listAskPrice = new List<Decimal>();
                    List<Decimal> listBidPrice = new List<Decimal>();
                    for(Quotation__c quote : quoteAllList)
                    {
                        if(quote != null)
                        {
                            if(quote.Ask_Price__c != null)
                            {
                                listAskPrice.add(quote.Ask_Price__c);
                            }
                            else if(quote.Bid_Price__c != null)
                            {
                                isBidding = true;
                                listBidPrice.add(quote.Bid_Price__c);
                            }

                            if(quote.Quotation_Status__c != 'Draft')
                            {
                                isDraft = false;
                            }
                        }
                        else
                        {
                           isEmpty = true; 
                        }
                    }
                    Boolean isMultiplePrice = listAskPrice.size() > 1;
                    // End cell case

                    if(!isEmpty)
                    {
                        //Add Status
                        if(isDraft)
                        {
                            if(isMultiplePrice)
                            {
                                result.put('status','Draft');    
                            }
                            else
                            {
                                result.put('status','Draft');
                            }
                        }
                        else
                        {
                            result.put('status','Trade');
                            result.put('editable',false);
                        }

                        //Add Value
                        if(isMultiplePrice)
                        {
                            listAskPrice.sort();
                            Decimal min = listAskPrice.get(0);
                            Decimal max = listAskPrice.get(listAskPrice.size()-1);
                            if(max-min  == 0)
                            {
                                result.put('value',min);
                                if(isDraft)
                                {
                                    result.put('status','Draft');    
                                }
                            }
                            else
                            {
                                result.put('value',Helper.convertDecimalToDecimalWithComma(min)  +'-'+Helper.convertDecimalToDecimalWithComma(max));
                                result.put('editable',false);
                            }
                        }
                        else
                        {
                            if(isBidding)
                            {
                                result.put('value','(Ask for Offer)');
                                result.put('editable',false);   
                            }    
                            else
                            {
                                if(listAskPrice.size() > 0)
                                {
                                    result.put('value',listAskPrice.get(0));
                                }
                                else
                                {
                                    result.put('value','N/A');
                                    result.put('status','Error');
                                    result.put('editable',false);   
                                }
                            }
                        }
                    }
                }
            }
        }

        return result;
    }

    public static Map<String,Object> getQuoteFormat(String ConsumerSelect,String CountrySelect,Date OneStDateNow)
    {
        String findConsumer = ConsumerSelect =='All'?'':'AND Consumer__c =\''+ConsumerSelect+'\'';
        Date OneStDate6Month = OneStDateNow.addMonths(6);
        
        Account myAccount = UserService.getAccount();
        String findProducer = myAccount != null?' AND Producer__c = \''+myAccount.Id+'\' ':'';
        String findMyFactory = myAccount != null?' AND Producer_group__c = \''+myAccount.Id+'\' ':'';
        String soql = 'SELECT Consumer__c,'
        +'Ask_Price__c,'
        +'Ask_Volume__c,'
        +'Bid_Price__c,'
        +'Bid_Volume__c,'
        +'Buyer__c,'
        +'Seller__c,'
        +'Comment__c,'
        +'Quotation_Status__c,'
        +'Month__c,'
        +'Port__c,'
        +'Quote_Effective_Month__c,'
        +'Factory__r.Name,'
        +'Factory__c,'
        +'Producer__c,'
        +'Id '
        +'FROM Quotation__c '
        +'WHERE Quotation_Status__c NOT IN (\'Pulled\',\'Cancelled\', \'Done Deal\',\'Rejected\') '
        +'AND Factory__c in (SELECT Id From Factory__c WHERE  Factory_Location__c=\''+CountrySelect+'\' '+findMyFactory+') '
        +findProducer
        +findConsumer;
        

        soql += ' AND (Quote_Effective_Month__c >= '+ Helper.ConvertDateSOQLFormat(OneStDateNow)
             +' AND Quote_Effective_Month__c < '+ Helper.ConvertDateSOQLFormat(OneStDate6Month) +')';

        System.debug(soql);
        List<Quotation__c> quoteList = Database.query(soql); 
        Map<String,Object> quoteFormat = new Map<String,Object>();

        for(Quotation__c quote: quoteList)
        {       
            Map<String,Object> portFormat = new Map<String,Object>();   
            Map<String,Object> factoryFormat = new Map<String,Object>();
            Map<String,Quotation__c> listQuoteInFactory = new Map<String,Quotation__c>();
            String dateIndex = Helper.getDateIndex(quote.Quote_Effective_Month__c);

            if(quoteFormat.containsKey(dateIndex))
            {
                portFormat = (Map<String,Object>) quoteFormat.get(dateIndex);
            }

            if(portFormat.containsKey(quote.Port__c))
            {
                factoryFormat = (Map<String,Object>) portFormat.get(quote.Port__c);
            }

            if(factoryFormat.containsKey(quote.Factory__r.Name))
            {
                listQuoteInFactory = (Map<String,Quotation__c>) factoryFormat.get(quote.Factory__r.Name);
            }
            listQuoteInFactory.put(quote.Consumer__c, quote);

            factoryFormat.put(quote.Factory__r.Name,listQuoteInFactory);
            portFormat.put(quote.Port__c,factoryFormat);
            quoteFormat.put(dateIndex,portFormat);
        }
        return quoteFormat;
    }

    public static Map<String,Object> getFactoryFormat(String ConsumerSelect,String CountrySelect)
    {
        Map<String,Object> portFormat = new Map<String,Object>();
        Account myAccount = UserService.getAccount();
        String findMyFactory = myAccount != null?' AND Producer_group__c = \''+myAccount.Id+'\' ':'';
        String findConsumer = ConsumerSelect =='All'?'':'AND Consumer__c =\''+ConsumerSelect+'\'';
        String soql = 'SELECT Id,Name,Factory_Location__c,Factory_Code__c, Port__c, Producer_s_Group__c, '
        +'(SELECT Id,floor_price__c, Product__r.Price__c,Product__r.Name,Product__r.Id FROM Grades__r WHERE Default__c = true), '
        +'(SELECT Id,floor_price__c, Product__r.Name,Product__r.Id, Product__r.Price__c FROM Packing__r WHERE Default__c = true),'
        +'(SELECT Id, Payment_Term__c,Additional_Charge__c FROM Payment_Terms__r WHERE Default_Payment_Term__c = true), '
        +'(SELECT Id,Freight_Charges__c,Incoterm__c,Destination__r.Name FROM Shipment_Information__r  WHERE Default_Shipment__c = true) ,'
        +'(SELECT Id,Consumer__c FROM Factory_Approval_List__r WHERE  Factory_Approval__r.Factory_Location__c=\''+CountrySelect+'\' AND Approval_Status__c =\'Approved\' '+findConsumer+') '
        +'FROM Factory__c '
        +'WHERE Id In '
        +'(SELECT Factory_Approval__c FROM Factory_Approvals__c WHERE  Factory_Approval__r.Factory_Location__c=\''+CountrySelect+'\' AND Approval_Status__c =\'Approved\' '+findConsumer+') '
        +findMyFactory;

        List<Factory__c> listFactoryObj = Database.query(soql);
        for(Factory__c factoryObj : listFactoryObj)
        {     

            List<Factory_Approvals__c> factoryApprovedList = factoryObj.Factory_Approval_List__r;
            for(Factory_Approvals__c factoryApprove : factoryApprovedList)
            {
                Map<String,Object> factoryNameFormat = new Map<String,Object>();
                Map<String,Object> factoryFormat = new Map<String,Object>();
                
                if(portFormat.containsKey(factoryObj.Port__c))
                {
                    factoryNameFormat = (Map<String,Object>) portFormat.get(factoryObj.Port__c);
                }

                if(factoryNameFormat.containsKey(factoryObj.Name))
                {
                    factoryFormat = (Map<String,Object>) factoryNameFormat.get(factoryObj.Name);
                }

                factoryFormat.put(factoryApprove.Consumer__c,factoryObj);
                factoryNameFormat.put(factoryObj.Name,factoryFormat);
                portFormat.put(factoryObj.Port__c,factoryNameFormat);
            }
        }

        return portFormat;
    }

    @AuraEnabled
    public static Map<String,Object> saveOffer(Map<String,String> SaveInfo,String SaveList) {
        Map<String,Object> response = new Map<String,Object>();
        Id UserLogin = userinfo.getUserId();

        String consumer = SaveInfo.get('consumer');
        String country = SaveInfo.get('country');
        String view = SaveInfo.get('view');
        String quoteStatus = SaveInfo.get('status');
        Boolean confirm = SaveInfo.containsKey('confirm')?true:false;
        Date dateNow = Date.valueOf(SaveInfo.get('date'));

        response.put('success', true);

        Map<String,Object> quoteFormat = OfferPanelController.getQuoteFormat(consumer,country,dateNow);
        Map<String,Object> factoryConsumerFormat = OfferPanelController.getFactoryFormat(consumer,country);
        List<Object> SaveListFormat =  (List<Object>) JSON.deserializeUntyped(SaveList);

        List<Quotation__c> listDelete = new List<Quotation__c>();
        List<Quotation__c> listInsert = new List<Quotation__c>();
        List<Quotation__c> listUpdate = new List<Quotation__c>();
        try
        {
            Account myAccount = UserService.getAccount();
            if(myAccount == null)
            {
                throw new ApiException('Current user cannot get producer data');   
            }

            for(Object saveObj : SaveListFormat)
            {
                Map<String,Object> saveMap = (Map<String,Object>)saveObj;   
                Map<String,Object> portFormat = new Map<String,Object>();   
                Map<String,Object> factoryFormat = new Map<String,Object>();
                

                if(quoteFormat.containsKey((String)saveMap.get('DATE')))
                {
                    portFormat = (Map<String,Object>) quoteFormat.get((String)saveMap.get('DATE'));
                }
                if(portFormat.containsKey((String)saveMap.get('PORTS')))
                {
                    factoryFormat = (Map<String,Object>) portFormat.get((String)saveMap.get('PORTS'));
                }

                Map<String,Object> factoryNameFormat = new Map<String,Object>();
                if(factoryConsumerFormat.containsKey((String)saveMap.get('PORTS')))
                {
                    factoryNameFormat = (Map<String,Object>) factoryConsumerFormat.get((String)saveMap.get('PORTS'));
                }
                
                Set<String> factoryNameList = view =='factory'?new Set<String>{(String)saveMap.get('FACTORY')} : factoryNameFormat.keySet();

                for(String factoryName :factoryNameList)
                {
                    if(factoryNameFormat.containsKey(factoryName))
                    {
                        Map<String,Quotation__c> listQuoteInFactory = new Map<String,Quotation__c>();
                        Map<String,Object>  consumerList = (Map<String,Object>) factoryNameFormat.get(factoryName);
                        for(String consumerId : consumerList.keySet())
                        {
                            if(consumer =='All' || consumer == consumerId)
                            {
                                Factory__c factory = (Factory__c) consumerList.get(consumerId);
                                Boolean isNew = true;
                                Quotation__c quoteObj = new Quotation__c();
                                
                                List<Product_Approval_List__c> gradeList = factory.Grades__r;
                                List<Product_Approval_List__c> packingList = factory.Packing__r;
                                List<Payment_Term__c> paymentList = factory.Payment_Terms__r;
                                List<Shipment__c> shipmentList = factory.Shipment_Information__r;

                                Decimal Ask_Price = Helper.isNumeric(saveMap.get('value'))?Decimal.valueOf(''+saveMap.get('value')):null;

                                if(gradeList.size()>0 && quoteStatus !='Pulled')
                                {
                                    Product_Approval_List__c productApprove = gradeList.get(0);
                                    Decimal min = productApprove.floor_price__c == null ? 0 : productApprove.floor_price__c;
                                    if(min > 0 && Ask_Price != null)
                                    {
                                        if(Ask_Price < min)
                                        {
                                            throw new ApiException('Factory \''+factory.Name +'\' minimum price should not be less than '+min);   
                                        }   
                                    }
                                }

                                System.debug('factoryName :'+factoryName);

                                if(factoryFormat.containsKey(factoryName))
                                {
                                    listQuoteInFactory = (Map<String,Quotation__c>) factoryFormat.get(factoryName);
                                }

                                if(listQuoteInFactory.containsKey(consumerId))
                                {
                                    isNew = false;
                                    quoteObj = listQuoteInFactory.get(consumerId);
                                }
                                else
                                {
                                    Date dateQuote = Date.valueOf((String)saveMap.get('DATE'));
                                    
                                    quoteObj.Seller__c = UserLogin;
                                    quoteObj.Factory__c = factory.Id;
                                    quoteObj.Ask_Volume__c = 100.8;
                                    quoteObj.Bid_Volume__c = 100.8;
                                    quoteObj.Month__c = Helper.getMonthStr(dateQuote.month());
                                    quoteObj.Quote_Effective_Month__c = dateQuote;
                                    quoteObj.Producer__c = myAccount.Id;
                                    quoteObj.Consumer__c = consumerId;
                                    quoteObj.Grade__c = gradeList.get(0).Product__r.Id;
                                    quoteObj.All_or_Nothing__c = true;
                                    
                                    if(gradeList.size()>0)
                                    {
                                        quoteObj.Grade__c = gradeList.get(0).Product__r.Id;
                                    }
                                    else
                                    {
                                        throw new ApiException('Factory \''+factory.Name +'\' no default grade');
                                    }

                                    if(packingList.size() > 0)
                                    {
                                        quoteObj.Packing__c = packingList.get(0).Product__r.Id;
                                    }
                                    else
                                    {
                                        throw new ApiException('Factory \''+factory.Name +'\' no default packing');
                                    }

                                    if(paymentList.size() > 0)
                                    {
                                        quoteObj.Payment_Term__c = paymentList.get(0).Id;
                                    }
                                    else
                                    {
                                        throw new ApiException('Factory \''+factory.Name +'\' no default payment');
                                    }

                                    if(shipmentList.size() > 0)
                                    {
                                        quoteObj.Shipment_Information__c = shipmentList.get(0).Id;
                                    }
                                    else
                                    {
                                        throw new ApiException('Factory \''+factory.Name +'\' no default shipment');
                                    }
                                }
                                
                                if(Ask_Price == null && ''+saveMap.get('value') == 'null')
                                {
                                    if(!isNew)
                                    {
                                        listDelete.add(quoteObj);
                                    }
                                }
                                else
                                {
                                    if(quoteStatus =='Pulled')
                                    {
                                        if(!isNew)
                                        {
                                            if(quoteObj.Quotation_Status__c =='Draft')
                                            {
                                                listDelete.add(quoteObj);
                                            }
                                            else
                                            {
                                                quoteObj.Quotation_Status__c = quoteStatus;        
                                                listUpdate.add(quoteObj);
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if(isNew)
                                        {
                                            quoteObj.Quotation_Status__c = quoteStatus;
                                            quoteObj.Ask_Price__c = Ask_Price;
                                            listInsert.add(quoteObj);
                                        }
                                        else
                                        {
                                            if(quoteObj.Quotation_Status__c == 'Draft')
                                            {
                                                if(view =='factory' && consumer != 'All')
                                                {
                                                    quoteObj.Ask_Price__c = Ask_Price;
                                                    quoteObj.Quotation_Status__c = quoteStatus;
                                                    listUpdate.add(quoteObj);
                                                }
                                                else
                                                {
                                                    if(confirm || quoteObj.Ask_Price__c == Ask_Price)
                                                    {
                                                        quoteObj.Quotation_Status__c = quoteStatus;
                                                        listUpdate.add(quoteObj);
                                                    }
                                                    else
                                                    {
                                                        ApiException e = new ApiException('This factory in port "'+factory.Port__c+'" have Quotation');
                                                        e.Warning();
                                                        throw e;
                                                    }    
                                                }
                                            }
                                            
                                        }     
                                    }
                                }
                            
                            }
                        }
                    }
                }
            }
            
            System.debug('listInsert :'+listInsert);
            System.debug('listUpdate :'+listUpdate);
            System.debug('listDelete :'+listDelete);
            if(listDelete.size()>0) delete listDelete;
            if(listInsert.size()>0) insert listInsert;
            if(listUpdate.size()>0) update listUpdate;

            if(quoteStatus == 'Open')
            {
                List<Quotation__c> quoteList = new List<Quotation__c>();
                quoteList.addAll(listInsert);
                quoteList.addAll(listUpdate);
                OfferPanelController.createQuoteInteration(quoteList);
            }

            List<String> channelList = new List<String>{'All'};
            SellerTradePanelController.updatePusher(channelList,quoteStatus);
        }
        catch(ApiException e)
        {
            if(e.isWarning())
            {
                response.put('success', true);
                response.put('warning', e.getMessage());
            }
            else
            {
                response.put('success', false);
                response.put('error', e.getMessage());    
            }
            
        }
        catch(Exception e)
        {
            response.put('success', false);
            response.put('error', e.getMessage());
        }
        


        return response;
    }    

    public static void createQuoteInteration(List<Quotation__c> quoteList)
    {
        List<Quotation_Iteration__c> quoteInterationList = new List<Quotation_Iteration__c>();
        for(Quotation__c quoteObj:quoteList)
        {
            Quotation_Iteration__c quoteInteration = new Quotation_Iteration__c();
            quoteInteration.Ask_Price__c = quoteObj.Ask_Price__c;
            quoteInteration.Ask_Volume__c = quoteObj.Ask_Volume__c;
            quoteInteration.Bid_Price__c = quoteObj.Bid_Price__c;
            quoteInteration.Bid_Volume__c = quoteObj.Bid_Volume__c;
            quoteInteration.Buyer__c = quoteObj.Buyer__c;
            quoteInteration.Seller__c = quoteObj.Seller__c;
            quoteInteration.Comment__c = quoteObj.Comment__c;
            quoteInteration.Quotation_Status__c = quoteObj.Quotation_Status__c;
            quoteInteration.Factory__c = quoteObj.Factory__c;
            quoteInteration.Producer__c = quoteObj.Producer__c;
            quoteInteration.Consumer__c = quoteObj.Consumer__c;
            quoteInteration.Primary_Quotation__c = quoteObj.Id;
            quoteInterationList.add(quoteInteration);
        }
    
        insert quoteInterationList;
    }

    @Future(callout=true)
    public static void updatePusher(List<String> channelList)
    {
        PusherService pusher = new PusherService();
        pusher.push(channelList,'update_quote',new Map<String,Object>{
            'success'=>true
        });
    }




}