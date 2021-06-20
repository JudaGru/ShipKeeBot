public class IntakeFormHelper {


    public static Id upsertHousehold(String houseHoldName, Id  husbandId, Id wifeId)
    {
        Id householdAccId = null;
        if( ! String.isBlank(husbandId)){

            Account householdAcc = new Account();
            householdAcc.Name = houseHoldName;
            householdAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            householdAcc.Stages__c = 'Engagement';
            householdAcc.Client__c = husbandId;
            householdAcc.Spouse__c = wifeId != null ? wifeId : null;
            upsert householdAcc;
            householdAccId = householdAcc.Id;
        }

        return householdAccId;   

    }

    public static Id upsertFather(IntakeFormHelper.ClientDataWrapper cdw)
    {

        Id husFatherAccId = null;

        if( (! String.isBlank(cdw.husbandData.fatherFirstName)) && (! String.isBlank(cdw.husbandData.parentsLastName))  ){

            Account husFatherAcc = new Account();
            husFatherAcc.FirstName = cdw.husbandData.fatherFirstName; 
            husFatherAcc.LastName = cdw.husbandData.parentsLastName; 
            husFatherAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
            husFatherAcc.Gender__pc = 'Male';

            system.debug('husFatherAcc>>>>>>>'+husFatherAcc);

            upsert husFatherAcc;
            husFatherAccId = husFatherAcc.Id;
        }

        return   husFatherAccId;
        

    }

    public static Id upsertMother(IntakeFormHelper.ClientDataWrapper cdw)
    {

        Id husMotherAccId = null;

        if( (! String.isBlank(cdw.husbandData.motherFirstName)) && (! String.isBlank(cdw.husbandData.parentsLastName))  ){
            
            Account husMotherAcc = new Account();
            husMotherAcc.FirstName =  cdw.husbandData.motherFirstName; 
            husMotherAcc.LastName =  cdw.husbandData.parentsLastName; 
            husMotherAcc.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
            husMotherAcc.Gender__pc = 'Female';
            
            upsert husMotherAcc;
            husMotherAccId = husMotherAcc.id;
        }

        return husMotherAccId;
    }

    public static Id upsertWifesMother(ClientDataWrapper cdw)
    {

        Id wifesMotherAccId = null;
        if( (! String.isBlank(cdw.wifeData.motherFirstName)) && (! String.isBlank(cdw.wifeData.parentsLastName))  ){

            Account wifesMotherAcc = new Account();
            wifesMotherAcc.FirstName =  cdw.wifeData.motherFirstName; 
            wifesMotherAcc.LastName =  cdw.wifeData.parentsLastName; 
            wifesMotherAcc.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
            wifesMotherAcc.Gender__pc = 'Female';
            
            Id husMotherAccId = null;
            
            upsert wifesMotherAcc;
            wifesMotherAccId = wifesMotherAcc.Id; 
        }
        return wifesMotherAccId;
    }

    public static Id upsertWifesFather(ClientDataWrapper cdw)
    {

        Id wifesFatherAccId = null;

        if( (! String.isBlank(cdw.wifeData.fatherFirstName)) && (! String.isBlank(cdw.wifeData.parentsLastName))  ){

            Account wifesFatherAcc = new Account();
            wifesFatherAcc.FirstName =  cdw.wifeData.fatherFirstName; 
            wifesFatherAcc.LastName =  cdw.wifeData.parentsLastName; 
            wifesFatherAcc.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();
            wifesFatherAcc.Gender__pc = 'Male';

            upsert wifesFatherAcc;
            wifesFatherAccId = wifesFatherAcc.Id;
        }

        return wifesFatherAccId;

    }


    public static id upsertClient(ClientDataWrapper cdw,Id houseHoldId)
    {
        PersonData hd = cdw.husbandData;

        Account husbandAcc = new Account();
        if(hd.Id != '' && hd.Id != null)
            husbandAcc.Id =  hd.Id;
        husbandAcc.Gender__pc = 'Male';
        husbandAcc.Household__c = houseHoldId;
        husbandAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        husbandAcc.Is_Primary_Client__c = true;
        husbandAcc.FirstName = hd.firstName;
        husbandAcc.LastName = hd.lastName; 
        husbandAcc.MiddleName = hd.middleName;
        husbandAcc.Salutation = hd.salutation;
        if(hd.DOB != '' && hd.DOB != null)
            husbandAcc.PersonBirthdate = Date.valueOf(hd.DOB);
        husbandAcc.SSN__pc = hd.SSN;
        husbandAcc.Hebrew_Name__pc = hd.hebrewName;
        husbandAcc.Full_Hebrew_Name__pc = hd.fullHebrewName;
        husbandAcc.Marital_Status__pc = hd.maritalStatus;
        if(hd.marriageDate != '' && hd.marriageDate != null)
            husbandAcc.Married_Date__pc = Date.valueOf(hd.marriageDate);
        husbandAcc.Is_US_Citizen__pc = hd.isCitizen;
        husbandAcc.PersonTitle = hd.title;

    
        husbandAcc.Occupation__pc = hd.occupation;
        husbandAcc.Firm__pc = hd.firm;

        husbandAcc.Stages__c = 'Engagement';
        
        upsert husbandAcc;
        return husbandAcc.id;

    }

    public static Id upsertWife(ClientDataWrapper cdw,Id houseHoldId)
    {
        PersonData wd = cdw.wifeData;
                    
        Account wifeAcc = new Account();
        if(wd.id != '' && wd.id != null)
            wifeAcc.Id = wd.id;
        wifeAcc.Household__c = houseHoldId;
        wifeAcc.Gender__pc = 'Female';
        wifeAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        wifeAcc.FirstName = wd.firstName;
        wifeAcc.LastName = wd.lastName; 
        wifeAcc.MiddleName = wd.middleName;
        wifeAcc.Salutation = wd.salutation;
        if(wd.DOB != '' && wd.DOB != null)
            wifeAcc.PersonBirthdate = Date.valueOf(wd.DOB);
        wifeAcc.SSN__pc = wd.SSN;
        wifeAcc.Maiden_Name__pc = wd.maidenName;
        wifeAcc.Hebrew_Name__pc = wd.hebrewName;
        wifeAcc.Full_Hebrew_Name__pc = wd.fullHebrewName;
        wifeAcc.Marital_Status__pc = cdw.husbandData.maritalStatus;
        if(cdw.husbandData.marriageDate != '' && cdw.husbandData.marriageDate != null)
            wifeAcc.Married_Date__pc = Date.valueOf(cdw.husbandData.marriageDate);
    
        
        wifeAcc.Is_US_Citizen__pc = wd.isCitizen;
        wifeAcc.PersonTitle = wd.title;
        wifeAcc.Occupation__pc = wd.occupation;
        wifeAcc.Firm__pc = wd.firm;
        wifeAcc.Stages__c = 'Engagement';
        
        upsert wifeAcc;
        return wifeAcc.Id;

    }


    public static ContactPointAddress createResidenceAdress(HouseholdData hd, Id clientId)
    {
        ContactPointAddress residenceAdd = new ContactPointAddress();
        residenceAdd.Name = 'Residence Address';
        residenceAdd.ParentId = clientId;
        residenceAdd.AddressType = 'Residence';
        residenceAdd.IsDefault = true;
        residenceAdd.Street = hd.residenceStreet;
        residenceAdd.City = hd.residenceCity;
        residenceAdd.State = hd.residenceState;
        residenceAdd.Country = hd.residenceCountry;
        residenceAdd.PostalCode = hd.residenceZip;

        return residenceAdd;
                
    }


    public static ContactPointAddress createMailingAdress(ClientDataWrapper cdw, Id clientId)
    {
        ContactPointAddress mailingAdd = new ContactPointAddress();
        mailingAdd.Name = 'Mailing Address';
        mailingAdd.ParentId = clientId;
        mailingAdd.AddressType = 'Mailing';
        mailingAdd.Street = cdw.householdData.mailingStreet;
        mailingAdd.City = cdw.householdData.mailingCity;
        mailingAdd.State = cdw.householdData.mailingState;
        mailingAdd.Country = cdw.householdData.mailingCountry;
        mailingAdd.PostalCode = cdw.householdData.mailingZip;
        return mailingAdd;
    }

    public static ContactPointAddress createWorkAdress(PersonData person, Id ownerId)
    {
        PersonData p = person;
        ContactPointAddress workAdd = new ContactPointAddress();
        workAdd.Name = 'Work Address';
        workAdd.ParentId = ownerId;
        workAdd.AddressType = 'Work';
        workAdd.Street = p.workStreet;
        workAdd.City = p.workCity;
        workAdd.State = p.workState;
        workAdd.Country = p.workCountry;
        workAdd.PostalCode = p.workZip;

        return workAdd;
        
    }



    public static void upsertAdvisors(ClientDataWrapper cdw, Id clientId)
    {
        List<AccountContactRelation> advisorList = new List<AccountContactRelation>();

        for(AdvisorData add : cdw.advisors)
        {                            
            
            
            // advisor already in salesfore
            if(add.advisorid != '' && add.advisorid != null)
            {                                
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = clientId;
                acr.ContactId = add.advisorid;
                
                advisorList.add(acr);
                
                // AccountContactRelation acr2 = new AccountContactRelation();
                // acr2.AccountId = wifeId;
                // acr2.ContactId = add.advisorId;
                
                // advisorList.add(acr2);
            }


            // firm already in salesfore but not advisor
            else if(add.advisorFirmId != '' && add.advisorFirmId != null && (add.advisorid == null || add.advisorid == ''))
            {
                
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = clientId;
                
                Contact con =  new Contact(AccountId=add.advisorFirmId,FirstName=add.advisorFirstName,LastName=add.advisorLastName,Salutation=add.advisorSalutation,
                                           Title=add.advisorTitle,Phone=add.advisorOfficePhone,MobilePhone=add.advisorMobilePhone,Email=add.advisorEmail,Fax=add.advisorFax);
                insert con;
                
                acr.ContactId = con.Id;
                
                advisorList.add(acr);
                
                // AccountContactRelation acr2 = new AccountContactRelation();
                // acr2.AccountId = wifeId;
                // acr2.ContactId = con.Id;
                
                // advisorList.add(acr2);
            }

             // neither firm nor advisor in salesforce
            else if((add.advisorFirmId == null || add.advisorFirmId == '') && (add.advisorId == null || add.advisorId == '') && add.advisorFirmName != '' && add.advisorFirmName != null)
            {
                
                AccountContactRelation acr = new AccountContactRelation();

                String professionalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('General').getRecordTypeId();
                
                Account acc = new Account(RecordTypeId=professionalRecordTypeId,Name=add.advisorFirmName,Account_Type__c=add.advisorFirmType);
                
                insert acc;
                
                system.debug('________add.advisorLastName__________' + add.advisorLastName);
                
                Contact con = new Contact(AccountId=acc.Id,FirstName=add.advisorFirstName,LastName=add.advisorLastName,Salutation=add.advisorSalutation,
                                          Title=add.advisorTitle,Phone=add.advisorOfficePhone,MobilePhone=add.advisorMobilePhone,Email=add.advisorEmail,Fax=add.advisorFax);
                insert con;
                
                system.debug('________con.Id__________' + con.Id);
                
                acr.AccountId = clientId;
                acr.ContactId = con.Id; 
                
                
                advisorList.add(acr);
            }
        }
        if(advisorList.size() > 0)
            upsert advisorList;
    }
    public static ChildrenInfoWrapper upsertChildren(ClientDataWrapper cdw, Id clientHouseHoldId )
    {
        String familyMemberRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship').getRecordTypeId();

        ChildrenInfoWrapper ciw = new ChildrenInfoWrapper();
        ciw.cpa = new List<ContactPointAddress>();
        ciw.eaList = new List<Email_Address__c>();
        ciw.phoneList = new List<Phone_Number__c>();

        List<Account> grandChildren = new List<Account>();

        for(ClientDataWrapper childWrapper : cdw.children)
        {   
            PersonData child = childWrapper.husbandData; 
            HouseholdData childHouseholdData = childWrapper.householdData; 

            if(child.lastName != '')
            {                            
                Account childAcc = new Account();
                childAcc.RecordTypeId = familyMemberRecordTypeId;
                if(child.id != '' && child.id != null)
                    childAcc.Id = child.id;
                childAcc.Household__c = clientHouseholdId;
                
                childAcc.Salutation = child.salutation;
                childAcc.Gender__pc = child.gender;
                childAcc.FirstName = child.firstName;
                childAcc.MiddleName = child.middleName;
                childAcc.LastName = child.lastName;
                childAcc.Hebrew_Name__pc = child.hebrewName;
                childAcc.Full_Hebrew_Name__pc = child.fullHebrewName;
                if(child.DOB != '' && child.DOB != null)
                    childAcc.PersonBirthdate = Date.valueOf(child.DOB);
                childAcc.SSN__pc = child.SSN;
                childAcc.Marital_Status__pc = child.maritalStatus;
                if(child.marriageDate != '' && child.marriageDate != null)
                    childAcc.Married_Date__pc = Date.valueOf(child.marriageDate);

                childAcc.Occupation__pc = child.occupation;
                childAcc.Firm__pc = child.firm;
                childAcc.PersonTitle = child.title;
           
                upsert childAcc;

                if(! String.isBlank(child.email))
                    ciw.eaList.add(IntakeFormHelper.createEmailAddress(childAcc.id, child.email, 'E-mail'));
                if(! String.isBlank(child.mobilePhone))
                    ciw.phoneList.add(IntakeFormHelper.createPhoneNumber(childAcc.id, child.mobilePhone, '', 'Mobile'));
                if(! String.isBlank(child.workPhone))
                    ciw.phoneList.add(IntakeFormHelper.createPhoneNumber(childAcc.id, child.workPhone, child.workPhoneExtension, 'Business'));
                if(! String.isBlank(child.workEmail))
                    ciw.eaList.add(IntakeFormHelper.createEmailAddress(childAcc.id, child.workEmail, 'E-mail'));
                if(! String.isBlank(child.workFax))
                    ciw.phoneList.add(IntakeFormHelper.createPhoneNumber(childAcc.id, child.workFax, '', 'Business Fax'));

                if(! String.isBlank(childHouseholdData.homePhone))
                    ciw.phoneList.add(IntakeFormHelper.createPhoneNumber(childAcc.id, childHouseholdData.homePhone, '', 'Residence'));
                if(! String.isBlank(childHouseholdData.homeFax))
                    ciw.phoneList.add(IntakeFormHelper.createPhoneNumber(childAcc.id, childHouseholdData.homeFax, '', 'Residence Fax'));

                if( (! String.isBlank(childHouseholdData.residenceStreet) ) || (! String.isBlank(childHouseholdData.residenceCity) ) )
                    ciw.cpa.add(IntakeFormHelper.createResidenceAdress(childHouseholdData,childAcc.id));
                    

                if( (! String.isBlank(child.workStreet) ) || (! String.isBlank(child.workCity) ) )    
                    ciw.cpa.add(IntakeFormHelper.createWorkAdress(child,childAcc.id));

                // if( (! String.isBlank(cdw.wifeData.workStreet) ) || (! String.isBlank(cdw.wifeData.workCity) ) )    
                //     cpa.add(IntakeFormHelper.createWorkAdress(cdw.wifeData,spouseId));
                
                // ContactPointAddress childResidenceAdd = new ContactPointAddress();
                // childResidenceAdd.Name = child.firstName + ' ' + child.lastName + 'Residence Address';
                // childResidenceAdd.ParentId = childAcc.Id;
                // childResidenceAdd.AddressType = 'Residence';
                // childResidenceAdd.IsDefault = true;
                // childResidenceAdd.Street = childHouseholdData.mailingStreet;
                // childResidenceAdd.City = childHouseholdData.mailingCity;
                // childResidenceAdd.State = childHouseholdData.mailingState;
                // childResidenceAdd.Country = childHouseholdData.mailingCountry;
                // childResidenceAdd.PostalCode = childHouseholdData.mailingZip;
                
                // cpa.add(childResidenceAdd);
                
                //Create the child Work Address ContactPointAddress Record
                // if(child.workStreet != '')
                // {
                //     ContactPointAddress childWorkAdd = new ContactPointAddress();
                //     childWorkAdd.Name = 'Work Address';
                //     childWorkAdd.ParentId = childAcc.Id;
                //     childWorkAdd.AddressType = 'Work';
                //     childWorkAdd.Street = child.workStreet;
                //     childWorkAdd.City = child.workCity;
                //     childWorkAdd.State = child.workState;
                //     childWorkAdd.Country = child.workCountry;
                //     childWorkAdd.PostalCode = child.workZip;
                    
                // cpa.add(childWorkAdd);
                // }

                PersonData spouse = childWrapper.wifeData; 
                
                if(child.maritalStatus == 'Married' && spouse.lastName != '')
                {

                    Account childSpouseAcc = new Account();
                    if(spouse.Id != '' && spouse.Id != null)
                        childSpouseAcc.Id = spouse.id;
                    childSpouseAcc.RecordTypeId = familyMemberRecordTypeId;
                    childSpouseAcc.Salutation = spouse.salutation;
                    if(child.gender == 'Male')
                        childSpouseAcc.Gender__pc = 'Female';
                    else
                        childSpouseAcc.Gender__pc = 'Male';
                    childSpouseAcc.FirstName = spouse.firstName;
                    childSpouseAcc.MiddleName = spouse.middleName;
                    childSpouseAcc.LastName = spouse.lastName;
                    childSpouseAcc.Hebrew_Name__pc = spouse.hebrewName;
                    childSpouseAcc.Full_Hebrew_Name__pc = spouse.fullHebrewName;
                    if(child.DOB != '' && spouse.DOB != null)
                        childSpouseAcc.PersonBirthdate = Date.valueOf(spouse.DOB);
                    childSpouseAcc.SSN__pc = spouse.SSN;
                    childSpouseAcc.Marital_Status__pc = spouse.maritalStatus;
                    if(child.marriageDate != '' && child.marriageDate != null)
                        childSpouseAcc.Married_Date__pc = Date.valueOf(child.marriageDate);


                    // childSpouseAcc.PersonMobilePhone = spouse.mobilePhone;
                    // childSpouseAcc.PersonEmail = spouse.email;
                    // childSpouseAcc.Fax = spouse.homefax;
                    childSpouseAcc.Occupation__pc = spouse.occupation;
                    childSpouseAcc.Firm__pc = spouse.firm;
                    childSpouseAcc.PersonTitle = spouse.title;

                    
                    // childSpouseAcc.Work_Phone__pc = spouse.workPhone;
                    // childSpouseAcc.Work_Email__pc = spouse.workEmail;
                    // childSpouseAcc.Work_Fax__pc = spouse.workFax;
                    
                    upsert childSpouseAcc;

                    if(! String.isBlank(spouse.email))
                        ciw.eaList.add(IntakeFormHelper.createEmailAddress(childSpouseAcc.id, spouse.email, 'E-mail'));
                    if(! String.isBlank(spouse.mobilePhone))
                        ciw.phoneList.add(IntakeFormHelper.createPhoneNumber(childSpouseAcc.id, spouse.mobilePhone, '', 'Mobile'));

                    //Create the child spouse Work Address ContactPointAddress Record
                    // if(child.spouseWorkStreet != '')
                    // {
                    //     ContactPointAddress childSpouseWorkAdd = new ContactPointAddress();
                    //     childSpouseWorkAdd.Name = 'Work Address';
                    //     childSpouseWorkAdd.ParentId = childAcc.Id;
                    //     childSpouseWorkAdd.AddressType = 'Work';
                    //     childSpouseWorkAdd.Street = child.spouseWorkStreet;
                    //     childSpouseWorkAdd.City = child.spouseWorkCity;
                    //     childSpouseWorkAdd.State = child.spouseWorkState;
                    //     childSpouseWorkAdd.Country = child.spouseWorkCountry;
                    //     childSpouseWorkAdd.PostalCode = child.spouseWorkZip;
                        
                    //     cpa.add(childSpouseWorkAdd);
                    // }
                    
                    
                    String childHouseholdId = childHouseholdData.householdId;
                    if(String.isBlank(childHouseholdId))
                        childHouseholdId = IntakeFormHelper.upsertHousehold(childWrapper.husbandData.lastName + ', ' + childWrapper.husbandData.firstName + (childWrapper.wifeData.firstName != '' ? ' & ' + childWrapper.wifeData.firstName : '') + ' Household', childAcc.id, childSpouseAcc.Id );
                    
                    //Create the grandchildren records
                    if(childWrapper.children.size() > 0)
                    {                                
                        long externalId = System.currentTimeMillis();
                        integer index = 1;
                        
                        for( ClientDataWrapper grandChildWrapper  : childWrapper.children)
                        {

                            PersonData gc = grandChildWrapper.husbandData;
                            if(gc.lastName != '')
                            {
                                Account grandchild = new Account();
                                if(gc.id != '' && gc.id != null)
                                    grandchild.Id = gc.Id;
                                grandchild.Apex_External_Id__c = externalId + index;
                                grandchild.RecordTypeId = familyMemberRecordTypeId;
                                grandchild.Household__c = childHouseholdId;
                                grandchild.FirstName = gc.firstName;
                                grandchild.MiddleName = gc.middleName;
                                grandchild.LastName = gc.lastName;
                                grandchild.Gender__pc = gc.gender;
                                if(gc.DOB != '' && gc.DOB != null)
                                    grandchild.PersonBirthdate = Date.valueOf(gc.DOB);
                                
   
                                grandChildren.add(grandchild);                                        
                            }
                            index++;
                        }
                    }
                }
            }
        }
        if(grandChildren.size() > 0)
            upsert grandChildren;
        return ciw;
        // return aarList;
    }
    public static Email_Address__c createEmailAddress(String whoId, String email, String type)
    {
        Email_Address__c e =  new Email_Address__c();
        e.Account__c = whoId;
        e.Email__c = email;
        e.Type__c = type;

        return e;
    }

    public static Phone_Number__c createPhoneNumber(String whoId, String phoneNumber, String extensionNumber, String type )
    {

        Phone_Number__c p = new Phone_Number__c();

        p.Account__c = whoId;
        p.Phone_Number__c = extensionNumber;
        p.Extension_Number__c = extensionNumber;
        p.Type__c = type;

        if(type == 'Mobile')
            p.Primary__c = true;
        
        return p;
    }

    

    
    public static void updateIntakeFormStatus(String intakeFormId, String jsonObj)
    {
        Intake_Form__c iForm = new Intake_Form__c(Id=intakeFormId);
        iForm.Status__c = 'Completed';
        iForm.Form_Json__c = jsonObj;
        
        update iForm;
    }

    public class ClientDataWrapper
    {        
        @AuraEnabled public PersonData husbandData {get;set;}
        @AuraEnabled public PersonData wifeData {get;set;}
        @AuraEnabled public HouseholdData householdData {get;set;}

        @AuraEnabled public List<ClientDataWrapper> children {get;set;}
        @AuraEnabled public List<AdvisorData> advisors {get;set;}
    }

    public class PersonData
    {
        @AuraEnabled public string id {get;set;}
        @AuraEnabled public string firstName {get;set;}
        @AuraEnabled public string middleName {get;set;}
        @AuraEnabled public string lastName {get;set;}
        @AuraEnabled public string salutation {get;set;}
        @AuraEnabled public string suffix {get;set;}
        @AuraEnabled public string hebrewName {get;set;}
        @AuraEnabled public string maidenName {get;set;}
        @AuraEnabled public string fullHebrewName {get;set;}
        @AuraEnabled public string fatherFirstName {get;set;}
        @AuraEnabled public string motherFirstName {get;set;}
        @AuraEnabled public string parentsLastName {get;set;}
        @AuraEnabled public string householdId {get;set;}
        @AuraEnabled public string DOB {get;set;}
        @AuraEnabled public string SSN {get;set;}
        @AuraEnabled public string gender {get;set;}
        @AuraEnabled public boolean isCitizen {get;set;}
        @AuraEnabled public string maritalStatus {get;set;}
        @AuraEnabled public string marriageDate {get;set;}
        @AuraEnabled public string mobilePhone {get;set;}
        @AuraEnabled public string email {get;set;}
        @AuraEnabled public string occupation {get;set;}
        @AuraEnabled public string firm {get;set;}
        @AuraEnabled public string title {get;set;}
        @AuraEnabled public string workPhone {get;set;}
        @AuraEnabled public string workPhoneExtension {get;set;}
        @AuraEnabled public string workFax {get;set;}
        @AuraEnabled public string workEmail {get;set;}
        @AuraEnabled public string workStreet {get;set;}
        @AuraEnabled public string workCity {get;set;}
        @AuraEnabled public string workState {get;set;}
        @AuraEnabled public string workCountry {get;set;}
        @AuraEnabled public string workZip {get;set;}

       
    
    }

    public class HouseholdData
    {
        @AuraEnabled public string householdId {get;set;}
        @AuraEnabled public string homePhone {get;set;}
        @AuraEnabled public string homeFax {get;set;}
        @AuraEnabled public string residenceStreet {get;set;}
        @AuraEnabled public string residenceCity {get;set;}
        @AuraEnabled public string residenceState {get;set;}
        @AuraEnabled public string residenceCountry {get;set;}
        @AuraEnabled public string residenceZip {get;set;}
        @AuraEnabled public string mailingStreet {get;set;}
        @AuraEnabled public string mailingCity {get;set;}
        @AuraEnabled public string mailingState {get;set;}
        @AuraEnabled public string mailingCountry {get;set;}
        @AuraEnabled public string mailingZip {get;set;}
    }

    public class AdvisorData
    {
        @AuraEnabled public string advisorId {get;set;}
        @AuraEnabled public string advisorFirstName {get;set;}
        @AuraEnabled public string advisorLastName {get;set;}
        @AuraEnabled public string advisorSalutation {get;set;}
        @AuraEnabled public string advisorSuffix {get;set;}
        @AuraEnabled public string advisorTitle {get;set;}
        @AuraEnabled public string advisorOfficePhone {get;set;}
        @AuraEnabled public string advisorOfficePhoneExtension {get;set;}
        @AuraEnabled public string advisorMobilePhone {get;set;}
        @AuraEnabled public string advisorEmail {get;set;}
        @AuraEnabled public string advisorFax {get;set;}
        @AuraEnabled public string advisorFirmName {get;set;}
        @AuraEnabled public string advisorFirmId {get;set;}
        @AuraEnabled public string advisorFirmType {get;set;}
    }

    public class ChildrenInfoWrapper
    {
        @AuraEnabled public List<Email_Address__c> eaList {get;set;}
        @AuraEnabled public List<Phone_Number__c> phoneList {get;set;}
        @AuraEnabled public List<ContactPointAddress> cpa {get;set;}
    }


}