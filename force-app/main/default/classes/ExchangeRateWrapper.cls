/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 */
public class ExchangeRateWrapper {
    
    // Properties matching JSON keys
    public String base_code;
    public String time_last_update_unix; // Type String matches ExchangeRateServiceTest expectation
    public Map<String, Decimal> conversion_rates;
    
    /**
     * @description Converts the wrapper data to a list of Exchange_Rate__c records
     * @return List<Exchange_Rate__c> The list of exchange rate records
     */
    public List<Exchange_Rate__c> toExchangeRates() {
        List<Exchange_Rate__c> rateList = new List<Exchange_Rate__c>();
        
        if (conversion_rates == null || conversion_rates.isEmpty()) {
            return rateList;
        }
        
        // Convert Unix timestamp string to DateTime safely
        DateTime lastUpdatedDt;
        if (String.isNotBlank(this.time_last_update_unix)) {
            Long timestampInSeconds = Long.valueOf(this.time_last_update_unix);
            lastUpdatedDt = DateTime.newInstance(timestampInSeconds * 1000);
        } else {
            lastUpdatedDt = System.now(); // Fallback if timestamp is blank/null
        }
        
        for (String targetCurrency : conversion_rates.keySet()) {
            Decimal rate = conversion_rates.get(targetCurrency);
            
            Exchange_Rate__c rateRec = new Exchange_Rate__c();
            rateRec.Base_Currency__c = this.base_code;
            rateRec.Target_Currency__c = targetCurrency;
            rateRec.Rate__c = rate;
            rateRec.External_Id__c = this.base_code + '_' + targetCurrency;
            
            // Populate mandatory required field
            rateRec.Last_Updated__c = lastUpdatedDt;
            
            rateList.add(rateRec);
        }
        
        return rateList;
    }
    
    /**
     * @description Static method to parse the JSON response into the wrapper class
     * @param jsonResponse The JSON response from the API
     * @return ExchangeRateWrapper The parsed wrapper instance
     */
    public static ExchangeRateWrapper parse(String jsonResponse) {
        return (ExchangeRateWrapper) JSON.deserialize(jsonResponse, ExchangeRateWrapper.class);
    }
}