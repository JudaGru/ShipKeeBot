public class EntityRollups {

    public static void rollUpEntities(Set<Id> entityIds) { 

        system.debug('>>>>>>> in EntityRollups.rollUpEntities() entityIds>>>>>>>>> '+entityIds);

        Map<Id,Account> entitiesToUpdate = new Map<Id,Account>();

        List<Ownership__c> ownerships = [
            select id,name,Asset_Id__c,Asset_Type__c,Asset_Value__c,Owner__c,Asset_Name__c,Asset_Ownership_Value__c,Asset_Record_Type_Name__c, 
            Ownership_Type__c,Ownership_Percent__c
            from Ownership__c where owner__c in :entityIds ];

        for (Ownership__c ownership : ownerships) {

            system.debug('ownership>>>>>>>>>  '+ ownership);

            if(entitiesToUpdate.get(ownership.Owner__c) == null){
                Account entity = new Account();
                entity.Id = ownership.Owner__c;
                entity.Total_Cash_Direct__c = 0;
                entity.Total_Securities__c = 0;
                entity.Loans_Receivables__c = 0;
                entity.Loans_Payables__c = 0;
                entity.Personal_Residences__c = 0;
                entity.Real_Estate__c = 0;
                entity.Businesses__c = 0;
                entitiesToUpdate.put(ownership.Owner__c,entity);
            }
            Account currentEntity = entitiesToUpdate.get(ownership.owner__c);
            system.debug('currentEntity' +currentEntity);
            system.debug('ownership.Asset_Ownership_Value__c' +ownership.Asset_Ownership_Value__c);
            system.debug('ownership.Asset_Type__c>>>>' + ownership.Asset_Type__c);
            system.debug('ownership.Asset_Record_Type_Name__c>>>>' + ownership.Asset_Record_Type_Name__c);
            system.debug('ownership.ownership.Ownership_Type__c>>>>' + ownership.Asset_Record_Type_Name__c);

            if(ownership.Asset_Type__c == 'Bank_Investment_Account'){

                if(ownership.Asset_Record_Type_Name__c == 'Bank Account'){
                    currentEntity.Total_Cash_Direct__c += ownership.Asset_Ownership_Value__c;
                }
                else if(ownership.Asset_Record_Type_Name__c == 'Investment Account'){
                    currentEntity.Total_Securities__c += ownership.Asset_Ownership_Value__c;
                }

            }
            else if(ownership.Asset_Type__c == 'Loan'){

                if(ownership.Ownership_Type__c == 'Borrower'){
                    currentEntity.Loans_Payables__c += ownership.Asset_Ownership_Value__c;
                }
                else if(ownership.Ownership_Type__c == 'Lender'){
                    currentEntity.Loans_Receivables__c += ownership.Asset_Ownership_Value__c;
                }
            }

            else if(ownership.Asset_Type__c == 'Property'){

                if(ownership.Asset_Record_Type_Name__c == 'Investment Property'){
                    currentEntity.Real_Estate__c += ownership.Asset_Ownership_Value__c;
                }
                else if(ownership.Asset_Record_Type_Name__c == 'Personal Property'){
                    currentEntity.Personal_Residences__c += ownership.Asset_Ownership_Value__c;
                }
            }

            else if(ownership.Asset_Record_Type_Name__c == 'Business'){
                currentEntity.Businesses__c += ownership.Asset_Ownership_Value__c;

            }
         
        }
        system.debug('entitiesToUpdate.values()' + entitiesToUpdate.values());
        update entitiesToUpdate.values();
    }

}