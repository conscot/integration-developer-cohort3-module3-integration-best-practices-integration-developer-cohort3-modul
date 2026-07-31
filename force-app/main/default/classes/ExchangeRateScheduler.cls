/**
 * @description Schedulable class to automatically trigger exchange rate updates on a schedule
 */
public class ExchangeRateScheduler implements Schedulable {

    /**
     * @description Standard Schedulable interface method called by Salesforce job engine
     * @param sc The SchedulableContext provided by Salesforce system
     */
    public void execute(SchedulableContext sc) {
        try {
            ExchangeRateService.updateExchangeRates();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error occurred in ExchangeRateScheduler execute method: ' + e.getMessage());
        }
    }

    /**
     * @description Optional helper method to programmatically schedule this class via Apex
     * @return String The Job ID from System.schedule
     */
    public static String scheduleDaily() {
        String cronExpression = '0 0 1 * * ?'; 
        return System.schedule('Daily Exchange Rate Sync', cronExpression, new ExchangeRateScheduler());
    }
}