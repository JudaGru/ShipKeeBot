@isTest
public class AssetControllerTest 
{
    private static testMethod void testInsert() 
    {


        Account client = new Account();
        client.Name = 'testClient';
        client.Share_With_Smart_Office__c = false;
        insert client;

        Account spouse = new Account();
        spouse.Name = 'testspouse';
        spouse.Share_With_Smart_Office__c = false;

        insert spouse;

        Account household = new Account();
        household.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        household.Name = 'testHousehold';
        household.Client__c = client.id;
        household.Spouse__c = spouse.id;
        household.Share_With_Smart_Office__c = false;

        insert household;

        Arts_and_Collectables__c ac = new Arts_and_Collectables__c();
        ac.Name = 'test';
        insert ac;

        Ownership__c o1 = new Ownership__c();
        o1.Arts_and_Collectables__c = ac.id;
        o1.Owner__c = client.id;

        Life_Insurance_Policy__c lip = new Life_Insurance_Policy__c();
        lip.Name = 'test';
        insert lip;

        Ownership__c o2 = new Ownership__c();
        o2.Life_Insurance_Policy__c = lip.id;
        o2.Owner__c = client.id;

        Bank_Investment_Account__c bia = new Bank_Investment_Account__c();
        bia.Name = 'test';
        insert bia;

        Ownership__c o3 = new Ownership__c();
        o3.Bank_Investment_Account__c = bia.id;
        o3.Owner__c = client.id;

        Property__c p = new Property__c();
        p.Name = 'testProp';
        insert p;

        Ownership__c o4 = new Ownership__c();
        o4.Property__c = p.id;
        o4.Owner__c = client.id;
   
        Loan__c l = new Loan__c();
        insert l;
   
        Ownership__c o5 = new Ownership__c();
        o5.Loan__c = l.id;
        o5.Owner__c = client.id;

        Account business = new Account();
        business.Name = 'testBuss';
        insert business;
   
        Ownership__c o6 = new Ownership__c();
        o6.Entity__c = business.id;
        o6.Owner__c = client.id;

        List<Ownership__c> ownerships = new List<Ownership__c>{o1,o2,o3,o4,o5,o6};
        insert ownerships;

        AssetController.Recordtype rt = new AssetController.Recordtype();
        rt.lookUpField = 'Property__c';

        ClientAssets.getOwnerAssetsHierarchal(client.id, null);
        ClientAssets.getOwnerAssetsGroupedByAssetType(client.id, null);

        ViewFinancialInterestsController.fetchClientAssets(client.id);
        AssetSummaryTableController.getAssets(client.id);

        AssetController.generateClientAssets(ownerships, p.id, rt);
        AssetController.getHousehold(client.id);
        AssetController.getAssetRecordTypes();
        AssetController.getOwners('Property__c', p.id);

        ViewFinancialInterestsController.deleteRecord(o6.id);

    }
}