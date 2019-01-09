global class Schedule_cleanQuoteByStatus implements Schedulable {
	global void execute(SchedulableContext sc) {
		Batch_cleanQuoteByStatus b = new Batch_cleanQuoteByStatus();
		database.executebatch(b);
	}
}