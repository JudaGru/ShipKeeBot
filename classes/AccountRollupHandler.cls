public class AccountRollupHandler {

    public static void rollUpAccounts(){
         

        SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
        if(! (string.valueOf(triggerType) == 'Account')) // ensure we are in the account trigger context 
            return;
        
        if(trigger.isAfter ){
            
            List<Account> businesses = new List<Account>();
            if(trigger.isDelete)
                businesses = trigger.old;
            else
                businesses = trigger.new;
            
            Set<Id> businessIdSet = new set<id>();

            // id recid = (id)'0016t000001mvRFAAY';
            // system.debug( Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(recid).getName());
            // account.sObjectType.getDescribe().getRecordTypeInfosById().getName();

            for (Account business : businesses) {
                system.debug('business.RecordTypeName__c '+ business.RecordTypeName__c);
                if(! (business.RecordTypeName__c== 'Business'))
                    return;
                if(business.Business_Net_Value__c != 0 ){
                    businessIdSet.add(business.id);
                }
                
                if(trigger.isUpdate){
                    Account oldbusiness = (Account)trigger.oldMap.get(business.id);
                    if(oldbusiness.Business_Net_Value__c != null && oldbusiness.Business_Net_Value__c != business.Business_Net_Value__c) {
                        businessIdSet.add(oldbusiness.id);
                    }
                }
            }
            List<Ownership__c> businessOwnerships = new list<Ownership__c>();
            
            if(businessIdSet.size() > 0)
                businessOwnerships = [select id,owner__c from Ownership__c where Entity__c in :businessIdSet ];
            
            Set<Id> entityIdSet = new set<id>();
    
            for (Ownership__c businessOwnership : businessOwnerships) {
                if(businessOwnership.Owner__c != null)
                    entityIdSet.add(businessOwnership.Owner__c);
            }
    
            if(entityIdSet.size() > 0)
                EntityRollups.rollUpEntities(entityIdSet);
        }
    }
    
}