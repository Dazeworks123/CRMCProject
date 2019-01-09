public with sharing class Helper {
	
	public static Boolean isNumeric(Object inputDate)
	{
		Boolean res = false;
		try
		{
			String input = String.valueOf(inputDate);
			Integer intVar =   Integer.valueOf(input);
			res = String.valueOf(intVar).isNumeric();
		}
		catch(Exception e)
		{

		}
		
		return res;
	}

	public static String getMonthStr(Integer MonthInt)
	{
		String res = 'none';
		Map<Integer,String> maping = new Map<Integer,String>{
			1=>'JAN',
			2=>'FEB',
			3=>'MAR',
			4=>'APR',
			5=>'MAY',
			6=>'JUN',
			7=>'JUL',
			8=>'AUG',
			9=>'SEP',
			10=>'OCT',
			11=>'NOV',
			12=>'DEC'
		};

		if(maping.containsKey(MonthInt))
		{
			res = maping.get(MonthInt);
		}
		return res;
	}

	public static Integer getMonthInt(String MonthStr)
	{
		Integer res = 0;
		Map<String,Integer> maping = new Map<String,Integer>{
			'JAN'=>1,
			'FEB'=>2,
			'MAR'=>3,
			'APR'=>4,
			'MAY'=>5,
			'JUN'=>6,
			'JUL'=>7,
			'AUG'=>8,
			'SEP'=>9,
			'OCT'=>10,
			'NOV'=>11,
			'DEC'=>12
		};

		if(maping.containsKey(MonthStr))
		{
			res = maping.get(MonthStr);
		}
		return res;
	}

	public static Date createDateMonthYear(String Month,Integer Year)
	{
		return Date.newInstance(Year, Helper.getMonthInt(Month) , 1);
	}

	public static Date get1stDateNow()
	{
		Datetime now = Datetime.now();
		Datetime newChang = now.addMonths(1);
		return Date.newInstance(newChang.year(), newChang.month(), 1);	
	}

	public static String getDateIndex(Date dateInput)
	{
		return DateTime.newInstance(
	        dateInput.year(), dateInput.month(), 1
	    ).format('yyyy-MM-dd');
	}

	public static String ConvertDateSOQLFormat(Date dateInput)
	{
		return DateTime.newInstance(
	        dateInput.year(), dateInput.month(), dateInput.day()
	    ).format('yyyy-MM-dd');
	}

	public static String convertDecimalToDecimalWithComma(Decimal myNumber){
        String numberString='';
        if(myNumber!=null){
            Integer firstDecimalNumber = Math.mod(Integer.valueOf((myNumber*100)),100)/10;
            Integer secondDecimalNumber = Math.mod(Integer.valueOf((myNumber*100)),10);
            numberString = String.format(myNumber.format(),  new String[]{'0','number','###,###,###,###,##0.00'});
            if(secondDecimalNumber==0 && firstDecimalNumber!=0){
               numberString=numberString+'0';
            }
            if(secondDecimalNumber==0 && firstDecimalNumber==0){
                numberString=numberString+'.00';
            }
          
        }else if(myNumber==null){
            numberString='0.00';
        }
        return numberString;
        
    }

}