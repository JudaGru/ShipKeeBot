public class FamilyTreeController 
{
    @AuraEnabled
    public static FamilyTree generateFamilyTree(String recordId)
    {
        system.debug('recid>>>>>>'+recordId);
        string recordTypeId = [select recordTypeid From account where id =:recordId limit 1].recordTypeid; 
        system.debug('recordTypeId>>>>>>'+recordTypeId);

        
        Account currentAccount = new Account();
        
        FamilyTree fTree = new FamilyTree();
        fTree.householdName = '';
        fTree.householdLink = '';
        fTree.householdId = '';
        fTree.clientFatherName = '';
        fTree.clientFatherLink = '';
        fTree.clientMotherName = '';
        fTree.clientMotherLink = '';
        fTree.clientName = '';
        fTree.clientLink = '';
        fTree.spouseFatherName = '';
        fTree.spouseFatherLink = '';
        fTree.spouseMotherName = '';
        fTree.spouseMotherLink = '';
        fTree.spouseName = '';
        fTree.spouseLink = '';
        fTree.children = new List<Child>();
        
        String clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        String householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        if(recordTypeId == clientRecordTypeId)
        {
            currentAccount = database.query(FamilyTreeController.query +  'From Account Where Id = \''+ recordId +'\' limit 1');
        }
        else if(recordTypeId == householdRecordTypeId){
            String clientId = [select client__c from account where id = :recordId].client__c;
            currentAccount = database.query(FamilyTreeController.query +  'From Account Where Id = \''+ clientId +'\' limit 1');
        }      
        system.debug(currentAccount);

        fTree.householdName = currentAccount.Clients__r[0].Name;
        fTree.householdId =currentAccount.Clients__r[0].id;
        fTree.householdLink = '/'+  currentAccount.Clients__r[0].id;

        fTree.clientFatherName = currentAccount.household__r.client__r.name + (currentAccount.household__r.client__r.age__c !=null ? '  (' + currentAccount.household__r.client__r.age__c + ')' : '');
        fTree.clientFatherLink = '/'+ currentAccount.household__r.client__c;
        fTree.clientFatherGender = currentAccount.household__r.client__r.Gender__pc;
        fTree.clientFatherPrimaryResidence = currentAccount.household__r.client__r.Primary_Residence__r.City_and_State__c;

        fTree.clientMotherName = currentAccount.household__r.spouse__r.name + (currentAccount.household__r.spouse__r.age__c !=null ? '  (' + currentAccount.household__r.spouse__r.age__c + ')' : '');
        fTree.clientMotherLink = '/'+ currentAccount.household__r.spouse__c;
        fTree.clientMotherGender = currentAccount.household__r.spouse__r.Gender__pc;
        fTree.clientMotherPrimaryResidence = currentAccount.household__r.spouse__r.Primary_Residence__r.City_and_State__c;


        fTree.clientName = currentAccount.Name + (currentAccount.age__c !=null ? '  (' + currentAccount.age__c + ')' : '');
        fTree.clientLink = '/'+ currentAccount.Id;
        fTree.clientGender = currentAccount.Gender__pc;
        fTree.clientLineageName = currentAccount.household__r.name;
        fTree.clientLineageLink =currentAccount.household__c != null ? '/'+ currentAccount.household__c : ''; 
        fTree.clientPrimaryResidence = currentAccount.Primary_Residence__r.City_and_State__c;

        fTree.spouseFatherName = currentAccount.Clients__r[0].spouse__r.household__r.client__r.name + (currentAccount.Clients__r[0].spouse__r.household__r.client__r.age__c !=null ? '  (' + currentAccount.Clients__r[0].spouse__r.household__r.client__r.age__c + ')' : '');
        fTree.spouseFatherLink = '/'+  currentAccount.Clients__r[0].spouse__r.household__r.client__c;
        fTree.spouseFatherGender =  currentAccount.Clients__r[0].spouse__r.household__r.client__r.Gender__pc;
        fTree.spouseFatherPrimaryResidence =  currentAccount.Clients__r[0].spouse__r.household__r.client__r.Primary_Residence__r.City_and_State__c;

        fTree.spouseMotherName = currentAccount.Clients__r[0].spouse__r.household__r.Spouse__r.name + (currentAccount.Clients__r[0].spouse__r.household__r.Spouse__r.age__c !=null ? '  (' + currentAccount.Clients__r[0].spouse__r.household__r.Spouse__r.age__c + ')' : '');
        fTree.spouseMotherLink = '/'+  currentAccount.Clients__r[0].spouse__r.household__r.Spouse__c;
        fTree.spouseMotherGender = currentAccount.Clients__r[0].spouse__r.household__r.Spouse__r.Gender__pc;
        fTree.spouseMotherPrimaryResidence = currentAccount.Clients__r[0].spouse__r.household__r.Spouse__r.Primary_Residence__r.City_and_State__c;

        if(currentAccount.Clients__r[0].Spouse__c != null){
            fTree.spouseName = currentAccount.Clients__r[0].Spouse__r.Name + (currentAccount.Clients__r[0].Spouse__r.age__c !=null ? '  (' + currentAccount.Clients__r[0].Spouse__r.age__c + ')' : '');
            fTree.spouseLink = '/'+ currentAccount.Clients__r[0].Spouse__c;
            fTree.spouseGender = currentAccount.Clients__r[0].Spouse__r.Gender__pc;
            fTree.spousePrimaryResidence = currentAccount.Clients__r[0].Spouse__r.Primary_Residence__r.City_and_State__c;
        }

        fTree.spouseLineageName = currentAccount.Clients__r[0].spouse__r.household__r.name;
        fTree.spouseLineageLink =currentAccount.Clients__r[0].spouse__r.household__c !=null ? '/'+  currentAccount.Clients__r[0].spouse__r.household__c : '';

        List<Account>  children = database.query(FamilyTreeController.query +  ' From Account Where HouseHold__c = \''+ currentAccount.Clients__r[0].id + '\' order by age__c desc nulls last' );
        fTree.totalChildren = children.size();
        fTree.totalGrandChildren = 0;
        fTree.totalMarriedChildren = 0;
        
        if(children.size() > 0)
        {
            for(Account child : children)
            {

                Child c = new Child();
                c.childLink = '/' + child.Id;
                c.childName = child.Name + (child.age__c !=null ? '  (' + child.age__c + ')' : '');
                c.childGender = child.Gender__pc;
                c.childPrimaryResidence = child.Primary_Residence__r.City_and_State__c;
              
                c.householdName = '';
                if(child.Clients__r.size() > 0){
                   
                    c.householdLink = child.Clients__r[0].id != null ? '/'+ child.Clients__r[0].id : '';
                    c.householdId =  child.Clients__r[0].id;
                    c.householdName =  child.Clients__r[0].name ;
                    // c.householdName = child.Gender__pc == 'Male' ? child.lastname : '' ;

                    if(child.Clients__r[0].Spouse__c !=null){
                        fTree.totalMarriedChildren  ++;
                        // c.householdName =  c.householdName == '' ? child.Clients__r[0].Spouse__r.lastname : c.householdName  ;


                        c.childSpouseLink ='/'+ child.Clients__r[0].Spouse__c;
                        c.childSpouseName = child.Clients__r[0].Spouse__r.Name + (child.Clients__r[0].Spouse__r.Maiden_Name__pc !=null ?'('+child.Clients__r[0].Spouse__r.Maiden_Name__pc+')':'') +(child.Clients__r[0].Spouse__r.age__c !=null ? '  (' + child.Clients__r[0].Spouse__r.age__c + ')' : '');
                        c.childSpouseGender = child.Clients__r[0].Spouse__r.Gender__pc;
                        
                    }

                    c.grandchildren = new List<Grandchild>();

                    List<Account>  grandchildren = database.query(FamilyTreeController.query +  ' From Account Where HouseHold__c = \''+ child.Clients__r[0].id + '\' order by age__c desc nulls last' );
                    
                    system.debug('grandchildren.size()  ::::  ' + grandchildren.size());
                    if(grandchildren.size() > 0)
                    {
                        for(Account gc : grandchildren)
                        {
                            fTree.totalGrandChildren ++;
                            Grandchild g = new Grandchild();
                            g.grandchildLink = '/' + gc.Id;
                            g.grandchildGender = gc.Gender__pc;
                            g.grandchildPrimaryResidence = gc.Primary_Residence__r.City_and_State__c;
                            // if(gc.Gender__pc == 'Male')
                            g.name = gc.Name;
                            // else
                                // g.name = gc.Name;

                            // g.relationship = gc.Gender__pc == 'Male'? 'Grandson' : 'Granddaughter';
                            g.name += (gc.age__c !=null ? '  (' + gc.age__c + ')' : '');
                            c.grandchildren.add(g);
                        }
                    }
                    // }
                }
                fTree.children.add(c);
            }
        }
        
        return fTree;
    }
    
	public class FamilyTree
    {
        @AuraEnabled public String householdName {get;set;}
        @AuraEnabled public String householdLink {get;set;}
        @AuraEnabled public String householdId {get;set;}
        @AuraEnabled public integer totalChildren {get;set;}
        @AuraEnabled public integer totalGrandChildren {get;set;}
        @AuraEnabled public integer totalMarriedChildren {get;set;}

        @AuraEnabled public String clientFatherName {get;set;}
        @AuraEnabled public String clientFatherLink {get;set;}
        @AuraEnabled public String clientFatherGender {get;set;}
        // @AuraEnabled public String clientFatherAge {get;set;}
        @AuraEnabled public String clientFatherPrimaryResidence {get;set;}

        @AuraEnabled public String clientMotherName {get;set;}
        @AuraEnabled public String clientMotherLink {get;set;}
        @AuraEnabled public String clientMotherGender {get;set;}
        // @AuraEnabled public String clientMotherAge {get;set;}
        @AuraEnabled public String clientMotherPrimaryResidence {get;set;}


        @AuraEnabled public String clientName {get;set;}
        @AuraEnabled public String clientLink {get;set;}
        @AuraEnabled public String clientGender {get;set;}
        // @AuraEnabled public String clientLocation {get;set;}
        // @AuraEnabled public String clientAge {get;set;}
        @AuraEnabled public String clientLineageName {get;set;}
        @AuraEnabled public String clientLineageLink {get;set;}
        @AuraEnabled public String clientPrimaryResidence {get;set;}

        @AuraEnabled public String spouseFatherName {get;set;}
        @AuraEnabled public String spouseFatherLink {get;set;}
        @AuraEnabled public String spouseFatherGender {get;set;}
        // @AuraEnabled public String spouseFatherAge {get;set;}
        // @AuraEnabled public String spouseFatherLocation {get;set;}
        @AuraEnabled public String spouseFatherPrimaryResidence {get;set;}

        @AuraEnabled public String spouseMotherName {get;set;}
        @AuraEnabled public String spouseMotherLink {get;set;}
        @AuraEnabled public String spouseMotherGender {get;set;}
        // @AuraEnabled public String spouseMotherAge {get;set;}
        @AuraEnabled public String spouseMotherPrimaryResidence {get;set;}

        @AuraEnabled public String spouseName {get;set;}
        @AuraEnabled public String spouseGender {get;set;}
        @AuraEnabled public String spouseLink {get;set;}
        // @AuraEnabled public String spouseAge {get;set;}s
        @AuraEnabled public String spousePrimaryResidence {get;set;}

        @AuraEnabled public String spouseLineageName {get;set;}
        @AuraEnabled public String spouseLineageLink {get;set;}

        @AuraEnabled public List<Child> children{get;set;}
    }
    

    public class Child
    {
        @AuraEnabled public String childName {get;set;}
        @AuraEnabled public String childLink {get;set;}
        @AuraEnabled public String childGender {get;set;}
        // @AuraEnabled public String childAge {get;set;}
        // @AuraEnabled public String childLocation {get;set;}
        @AuraEnabled public String householdName {get;set;}
        @AuraEnabled public String householdLink {get;set;}
        @AuraEnabled public String householdId {get;set;}
        // @AuraEnabled public String primaryResidence {get;set;}


        @AuraEnabled public String childSpouseName {get;set;}
        // @AuraEnabled public String childSpouseMaidenName {get;set;}
        @AuraEnabled public String childSpouseLink {get;set;}
        @AuraEnabled public String childSpouseGender {get;set;}
        // @AuraEnabled public String childSpouseAge {get;set;}
        @AuraEnabled public String childPrimaryResidence {get;set;}

        // @AuraEnabled public String relationship {get;set;}
        @AuraEnabled public List<Grandchild> grandchildren {get;set;}
    }
    
    public class Grandchild
    {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String grandchildLink {get;set;}
        @AuraEnabled public String grandchildGender {get;set;}
        // @AuraEnabled public String grandchildAge {get;set;}
        // @AuraEnabled public String relationship {get;set;}
        @AuraEnabled public String grandchildPrimaryResidence {get;set;}
    }



    public static String query = 'Select Id,'+
    'Name,'+
    'FirstName,'+
    'LastName,'+
    'Spouse__c,'+
    'Gender__pc,'+
    'Maiden_Name__pc,'+
    'Age__c,'+
    'Primary_Residence__r.City_and_State__c,'+
    ' '+
    'client__c,'+
    'client__r.name,'+
    'client__r.firstname,'+
    'client__r.lastname,'+
    'client__r.Age__c,'+
    'client__r.Primary_Residence__r.City_and_State__c,'+
    ' '+
    'household__c,'+
    'household__r.Name,'+
    ' '+
    'household__r.client__c,'+
    'household__r.client__r.name,'+
    'household__r.client__r.firstname,'+
    'household__r.client__r.lastname,'+
    'household__r.client__r.Gender__pc,'+
    'household__r.client__r.Age__c,'+
    'household__r.client__r.Primary_Residence__r.City_and_State__c,'+
    ' '+
    'household__r.spouse__c,'+
    'household__r.spouse__r.name,'+
    'household__r.spouse__r.firstname,'+
    'household__r.spouse__r.lastname,'+
    'household__r.spouse__r.Gender__pc,'+
    'household__r.spouse__r.Age__c,'+
    'household__r.spouse__r.Primary_Residence__r.City_and_State__c,'+
    ' '+
    '(select id,'+
    'name,'+
    'firstname,'+
    'lastname,'+
    'Gender__pc,'+
    'Maiden_Name__pc,'+
    'Age__c,'+
    'Primary_Residence__r.City_and_State__c,'+
    ' '+
    'client__c,'+
    'client__r.name,'+
    'client__r.firstname,'+
    'client__r.lastname,'+
    'client__r.Maiden_Name__pc,'+
    'client__r.Gender__pc,'+
    'client__r.Age__c,'+
    'client__r.Primary_Residence__r.City_and_State__c,'+
    ' '+
    'spouse__c,'+
    'spouse__r.name,'+
    'spouse__r.firstname,'+
    'spouse__r.lastname,'+
    'spouse__r.Gender__pc,'+
    'spouse__r.Maiden_Name__pc,'+
    'spouse__r.Age__c,'+
    'spouse__r.Primary_Residence__r.City_and_State__c,'+
    ' '+
    'spouse__r.household__c,'+
    'spouse__r.household__r.name,'+
    ' '+
    'spouse__r.household__r.client__c,'+
    'spouse__r.household__r.client__r.name,'+
    'spouse__r.household__r.client__r.firstname,'+
    'spouse__r.household__r.client__r.lastname,'+
    'spouse__r.household__r.client__r.Maiden_Name__pc,'+
    'spouse__r.household__r.client__r.Gender__pc,'+
    'spouse__r.household__r.client__r.Age__c,'+
    'spouse__r.household__r.client__r.Primary_Residence__r.City_and_State__c,'+
    ' '+
    'spouse__r.household__r.spouse__c,'+
    'spouse__r.household__r.spouse__r.name,'+
    'spouse__r.household__r.spouse__r.firstname,'+
    'spouse__r.household__r.spouse__r.lastname,'+
    'spouse__r.household__r.spouse__r.Gender__pc ,'+
    'spouse__r.household__r.spouse__r.Maiden_Name__pc,'+
    'spouse__r.household__r.spouse__r.Age__c,'+
    'spouse__r.household__r.spouse__r.Primary_Residence__r.City_and_State__c'+
    ' '+
    ' from Clients__r )' ;
}