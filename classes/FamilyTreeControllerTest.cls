@isTest
public class FamilyTreeControllerTest 
{
    private static testMethod void test1() 
    {

        String clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        String householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

       
       
        Account lineage = new Account();
        lineage.RecordTypeId = householdRecordTypeId;
        lineage.Name = 'lineage';
        insert lineage;
 
        
        Account client = new Account();
        client.RecordTypeId = clientRecordTypeId;
        client.lastname = 'client';
        client.Household__c = lineage.id;
        insert client;

        
        Account spouse = new Account();
        spouse.RecordTypeId = clientRecordTypeId;
        spouse.lastname = 'spouse';
        spouse.Household__c = lineage.id;
        insert spouse;


        Account houshold = new Account();
        houshold.RecordTypeId = householdRecordTypeId;
        houshold.Name = 'household1';
        houshold.Client__c = client.id;
        houshold.Spouse__c = spouse.id;
        insert houshold;

        
        Account child1 = new Account();
        child1.RecordTypeId = clientRecordTypeId;
        child1.lastname = 'child1';
        child1.Household__c = houshold.id;
        insert child1;

        Account child1spouse = new Account();
        child1spouse.RecordTypeId = clientRecordTypeId;
        child1spouse.lastname = 'child1spouse';
        insert child1spouse;

        Account houshold2 = new Account();
        houshold2.RecordTypeId = householdRecordTypeId;
        houshold2.Name = 'household1';
        houshold2.Client__c = child1.id;
        houshold2.Spouse__c = child1spouse.id;
        insert houshold2;

                
        Account grandchild1 = new Account();
        grandchild1.RecordTypeId = clientRecordTypeId;
        grandchild1.lastname = 'grandchild1';
        grandchild1.Household__c = houshold2.id;
        insert grandchild1;


        FamilyTreeController.generateFamilyTree(client.id);
        FamilyTreeController.generateFamilyTree(houshold.id);
    }
}