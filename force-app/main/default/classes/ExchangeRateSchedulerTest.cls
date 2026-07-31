@IsTest
private class ExchangeRateSchedulerTest {

    @IsTest
    static void testExecute() {
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock());

        Test.startTest();
        // Directly invoke execute method to guarantee execution within the test context
        ExchangeRateScheduler scheduler = new ExchangeRateScheduler();
        scheduler.execute(null);
        Test.stopTest();

        // Verify exchange rate records were inserted
        List<Exchange_Rate__c> rates = [SELECT Id FROM Exchange_Rate__c];
        System.assert(rates.size() > 0, 'Exchange rate records should have been created by the scheduled execution.');
    }

    @IsTest
    static void testScheduleDaily() {
        Test.startTest();
        // Execute static scheduling helper method to cover lines in scheduleDaily()
        String jobId = ExchangeRateScheduler.scheduleDaily();
        Test.stopTest();

        System.assert(String.isNotBlank(jobId), 'The job ID returned from scheduleDaily should not be blank.');
    }
}