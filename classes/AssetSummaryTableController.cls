public class AssetSummaryTableController 
{
    @AuraEnabled
    public static list<TableData> getAssets( String ownerId)
    {
        List<account> household = [select id,name from account where  RecordType.Name = 'Household' and (client__c = :ownerId or id= :ownerId or spouse__c= :ownerId )];
        Account acct = new Account();
        
        Boolean hasHousehold = household.size() == 1;

        system.debug('hasHousehold>>>>>>>' + hasHousehold);
        
        if(hasHousehold){
             acct =  [select id,name,Total_Cash_Direct__c,Total_Securities__c,Loans_Receivables__c,Loans_Payables__c,Personal_Residences__c,Real_Estate__c,Businesses__c,
                            client__c,client__r.name,client__r.Total_Cash_Direct__c,client__r.Total_Securities__c,client__r.Loans_Receivables__c,client__r.Loans_Payables__c,client__r.Personal_Residences__c,client__r.Real_Estate__c,client__r.Businesses__c,
                            spouse__c,spouse__r.name,spouse__r.Total_Cash_Direct__c,spouse__r.Total_Securities__c,spouse__r.Loans_Receivables__c,spouse__r.Loans_Payables__c,spouse__r.Personal_Residences__c,spouse__r.Real_Estate__c,spouse__r.Businesses__c
            from account  where  id =: household[0].id];
        }
        else {
             acct = [select id,name,Total_Cash_Direct__c,Total_Securities__c,Loans_Receivables__c,Loans_Payables__c,Personal_Residences__c,Real_Estate__c,Businesses__c
                            from account where  id = :ownerId];
        }


        list<TableData> tableData = new List<TableData>();

        TableData cash = new tableData();
        cash.assetType = 'Cash';
        cash.client =  hasHousehold == true ? acct.client__r.Total_Cash_Direct__c : acct.Total_Cash_Direct__c ; 
        cash.household = hasHousehold == true ? acct.Total_Cash_Direct__c : 0 ; 
        cash.spouse =  hasHousehold == true ? acct.spouse__r.Total_Cash_Direct__c : 0 ; 
        cash.total = cash.client  + cash.household +  cash.spouse ;

        cash.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        cash.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        cash.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(cash);

        TableData cashInEntities = new tableData();
        cashInEntities.assetType = 'Cash Held in Entities';
        cashInEntities.client =  hasHousehold == true ? 0 : 0; 
        cashInEntities.household = hasHousehold == true ? 0: 0 ; 
        cashInEntities.spouse =  hasHousehold == true ? 0 : 0 ; 
        cashInEntities.total = cashInEntities.client  + cashInEntities.household +  cashInEntities.spouse ;

        cashInEntities.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        cashInEntities.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        cashInEntities.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(cashInEntities);

        TableData Securities = new tableData();
        Securities.assetType = 'Securities'; 
        Securities.client =  hasHousehold == true ? acct.client__r.Total_Securities__c : acct.Total_Securities__c ; 
        Securities.household = hasHousehold == true ? acct.Total_Securities__c : 0 ; 
        Securities.spouse =  hasHousehold == true ?  acct.spouse__r.Total_Securities__c : 0 ; 
        Securities.total = Securities.client  + Securities.household +  Securities.spouse ;

        Securities.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        Securities.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        Securities.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(Securities);

        TableData retirementAssets  = new tableData();
        retirementAssets.assetType = 'Retirement Assets';
        retirementAssets.client =  hasHousehold == true ? 0 : 0 ; 
        retirementAssets.household = hasHousehold == true ? 0: 0 ; 
        retirementAssets.spouse =  hasHousehold == true ? 0 : 0 ; 
        retirementAssets.total = retirementAssets.client  + retirementAssets.household +  retirementAssets.spouse ;

        retirementAssets.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        retirementAssets.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        retirementAssets.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(retirementAssets);

        TableData receivables = new tableData();
        receivables.assetType = 'Receivables';
        receivables.client =  hasHousehold == true ? acct.client__r.Loans_Receivables__c : acct.Loans_Receivables__c ; 
        receivables.household = hasHousehold == true ?  acct.Loans_Receivables__c : 0 ; 
        receivables.spouse =  hasHousehold == true ?  acct.spouse__r.Loans_Receivables__c : 0 ; 
        receivables.total = receivables.client  + receivables.household +  receivables.spouse ;

        receivables.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        receivables.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        receivables.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(receivables);

        TableData payables = new tableData();
        payables.assetType = 'Payables';
        payables.client =  hasHousehold == true ? acct.client__r.Loans_Payables__c : acct.Loans_Payables__c ; 
        payables.household = hasHousehold == true ?  acct.Loans_Payables__c : 0 ; 
        payables.spouse =  hasHousehold == true ? acct.spouse__r.Loans_Payables__c : 0 ; 
        payables.total = payables.client + payables.household +  payables.spouse ;

        payables.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        payables.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        payables.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(payables);

        TableData personalResidences = new tableData();
        personalResidences.assetType = 'Personal Residences';
        personalResidences.client =  hasHousehold == true ? acct.client__r.Personal_Residences__c : acct.Personal_Residences__c ; 
        personalResidences.household = hasHousehold == true ? acct.Personal_Residences__c : 0 ;
        personalResidences.spouse =  hasHousehold == true ? acct.spouse__r.Personal_Residences__c : 0 ; 
        personalResidences.total = personalResidences.client + personalResidences.household +  personalResidences.spouse ;

        personalResidences.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        personalResidences.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        personalResidences.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(personalResidences);


        TableData realEstate = new tableData();
        realEstate.assetType = 'Real Estate';
        realEstate.client =  hasHousehold == true ? acct.client__r.Real_Estate__c : acct.Real_Estate__c ; 
        realEstate.household = hasHousehold == true ? acct.Real_Estate__c : 0 ;
        realEstate.spouse =  hasHousehold == true ? acct.spouse__r.Real_Estate__c : 0 ; 
        realEstate.total = realEstate.client + realEstate.household +  realEstate.spouse ;

        realEstate.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        realEstate.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        realEstate.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(realEstate);

        TableData businesses = new tableData();
        businesses.assetType = 'Business & Investments';
        businesses.client =  hasHousehold == true ?  acct.client__r.Businesses__c : acct.Businesses__c ; 
        businesses.household = hasHousehold == true ? acct.Businesses__c : 0 ;
        businesses.spouse =  hasHousehold == true ? acct.spouse__r.Businesses__c : 0 ; 
        businesses.total = businesses.client + businesses.household +  businesses.spouse ;

        businesses.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        businesses.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        businesses.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(businesses);
        
        TableData trusts = new tableData();
        trusts.assetType = 'Trusts';
        trusts.client =  hasHousehold == true ? 0 : 0 ; 
        trusts.household = hasHousehold == true ? 0: 0 ; 
        trusts.spouse =  hasHousehold == true ? 0 : 0 ; 
        trusts.total = trusts.client + trusts.household +  trusts.spouse ;

        trusts.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        trusts.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        trusts.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(trusts);
        
        TableData insuranceCashSurrender = new tableData();
        insuranceCashSurrender.assetType = 'Insurance Cash Surrender Value';
        insuranceCashSurrender.client =  hasHousehold == true ? 0 : 0 ; 
        insuranceCashSurrender.household = hasHousehold == true ? 0: 0 ; 
        insuranceCashSurrender.spouse =  hasHousehold == true ? 0 : 0 ; 
        insuranceCashSurrender.total = insuranceCashSurrender.client + insuranceCashSurrender.household +  insuranceCashSurrender.spouse ;

        insuranceCashSurrender.clientId = hasHousehold == true ? acct.client__c: acct.id ; 
        insuranceCashSurrender.spouseId = hasHousehold == true ? acct.Spouse__c:'' ; 
        insuranceCashSurrender.householdId = hasHousehold == true ? acct.id:''; 
        tableData.add(insuranceCashSurrender);

        
        TableData totals = new tableData();
        totals.assetType = 'Totals:';
        totals.client =  0;
        totals.household =  0;
        totals.spouse =  0;
        totals.total =  0;

        for (TableData td : tableData) {
            totals.client += td.client;
            totals.household += td.household;
            totals.spouse += td.spouse;
            totals.total += td.total;
        }

        tableData.add(totals);

        return tableData;
    }

    public class TableData
    {
        @AuraEnabled public Decimal household {get;set;}
        @AuraEnabled public Decimal client {get;set;}
        @AuraEnabled public Decimal spouse {get;set;}
        @AuraEnabled public Decimal total {get;set;}

        @AuraEnabled public string assetType {get;set;}
        @AuraEnabled public string clientId {get;set;}
        @AuraEnabled public String householdId {get;set;}
        @AuraEnabled public string spouseId {get;set;}
    }

}