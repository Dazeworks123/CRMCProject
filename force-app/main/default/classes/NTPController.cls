public class NTPController {
	
	@AuraEnabled
	public static Long getTimestamp()
	{
		Datetime dateNow = DateTime.now();
		return dateNow.getTime();
	}
}