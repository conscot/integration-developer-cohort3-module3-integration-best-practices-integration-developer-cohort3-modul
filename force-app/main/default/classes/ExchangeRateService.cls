/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */
public class ExchangeRateService {
    
    // The named credential to use for the callout
    private static final String NAMED_CREDENTIAL = 'callout:ExchangeRate_API';
    
    // The base currency to use for exchange rates
    private static final String BASE_CURRENCY = 'USD';
    
    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public static ExchangeRateWrapper getLatestRates() {
        try {
            // 1. Build the HTTP Request
            HttpRequest req = new HttpRequest();
            // Appends base currency endpoint: callout:ExchangeRate_API/latest/USD
            req.setEndpoint(NAMED_CREDENTIAL + '/latest/' + BASE_CURRENCY);
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json');
            req.setTimeout(120000); // Set timeout to 120 seconds
            
            // 2. Send the Request via Http
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // 3. Process Response & Handle Errors
            if (res.getStatusCode() == 200) {
                // Pass raw JSON text to our wrapper's parse method
                return ExchangeRateWrapper.parse(res.getBody());
            } else {
                System.debug(LoggingLevel.ERROR, 'HTTP Callout Failed with Status: ' + res.getStatus() + ' Code: ' + res.getStatusCode());
                throw new CalloutException('Failed to retrieve rates. HTTP Status Code: ' + res.getStatusCode() + ' Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getLatestRates: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw e; // Re-throw so caller/logs are aware of the failure
        }
    }
    
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        if (rateData == null) {
            return new List<Exchange_Rate__c>();
        }
        
        try {
            // 1. Convert wrapper data to SObject records
            List<Exchange_Rate__c> ratesToUpsert = rateData.toExchangeRates();
            
            // 2. Perform Upsert using the External ID field to prevent duplicate records
            if (!ratesToUpsert.isEmpty()) {
                // Upsert match field: Exchange_Rate__c.External_Id__c
                upsert ratesToUpsert External_Id__c;
            }
            
            return ratesToUpsert;
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR, 'DML Error processing exchange rates: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Combines getting and processing rates into a single operation
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> updateExchangeRates() {
        // 1. Call getLatestRates to retrieve and parse data from API
        ExchangeRateWrapper rateData = getLatestRates();
        
        // 2. Call processRates to create/update Exchange_Rate__c records in Salesforce
        List<Exchange_Rate__c> processedRecords = processRates(rateData);
        
        // 3. Return the processed records
        return processedRecords;
    }
}