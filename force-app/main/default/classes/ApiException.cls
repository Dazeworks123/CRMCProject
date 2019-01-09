public class ApiException extends Exception {

	private Boolean warning = false;

	public static void test()
	{
		System.debug('for run test');
	}

	public void Warning()
	{
		this.warning = true;
	}

	public Boolean isWarning()
	{
		return this.warning;
	}
}