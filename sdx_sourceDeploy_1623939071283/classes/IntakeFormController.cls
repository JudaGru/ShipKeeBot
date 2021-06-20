public class IntakeFormController 
{
    @AuraEnabled
    public static string saveForLater(String formName, String jsonObj)
    {
        String response = '';
        
        try
        {
            Intake_Form__c iForm = new Intake_Form__c();
            iForm.Name = formName;
            iForm.Status__c = 'In Progress';
            iForm.Form_Json__c = jsonObj;
            
            insert iForm;
            
            response = 'success';
        }
        catch(Exception e)
        {
            response = e.getMessage();
        }
        
        return response;
    }
    
    @AuraEnabled
    public static string getIntakeForm(String formId)
    {
        try
        {
            return [Select Form_Json__c From Intake_Form__c Where Id = : formId].Form_Json__c;
        }
        catch(Exception e)
        {
            return '';
        }
        
    }
    
    @AuraEnabled
    public static void generateClientData(String jsonObj, String intakeFormId)
    {   
        system.debug('jsonObj>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>::' + jsonObj);

        IntakeFormHelper.ClientDataWrapper cdw = new IntakeFormHelper.ClientDataWrapper();
        cdw = (IntakeFormHelper.ClientDataWrapper)JSON.deserialize(jsonObj, IntakeFormHelper.ClientDataWrapper.class);

        // system.debug('cdw>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>::' + cdw);
        
        // try
        // {
            if(cdw.husbandData.lastName != '')
            {

                List<Email_Address__c> eaList = new List<Email_Address__c>();
                List<Phone_Number__c> phoneList = new List<Phone_Number__c>();
                List<ContactPointAddress> cpa = new List<ContactPointAddress>();
                
                Id fatherId = IntakeFormHelper.upsertFather(cdw);
                Id motherId = IntakeFormHelper.upsertMother(cdw);

                String fatherHouseHoldId = cdw.husbandData.householdId;
                if(String.isBlank(fatherHouseHoldId))
                    fatherHouseHoldId = IntakeFormHelper.upsertHousehold(cdw.husbandData.lastName + ', ' + cdw.husbandData.fatherFirstName + (cdw.husbandData.motherFirstName != '' ? ' & ' + cdw.husbandData.motherFirstName : '') + ' Household', fatherId, motherId );
                
                Id wifesFatherId = IntakeFormHelper.upsertWifesFather(cdw);
                Id wifesMotherId = IntakeFormHelper.upsertWifesMother(cdw);

                String wifeFatherHouseholdId = cdw.wifeData.householdId;
                if(String.isBlank(wifeFatherHouseholdId))
                    wifeFatherHouseholdId = IntakeFormHelper.upsertHousehold(cdw.wifeData.maidenName + ', ' + cdw.wifeData.fatherFirstName + (cdw.wifeData.motherFirstName != '' ? ' & ' + cdw.wifeData.motherFirstName : '') + ' Household', wifesFatherId, wifesMotherId );
                
                Id clientId = IntakeFormHelper.upsertClient(cdw, fatherHouseHoldId);

                if(! String.isBlank(cdw.husbandData.email))
                    eaList.add(IntakeFormHelper.createEmailAddress(clientId, cdw.husbandData.email, 'E-mail'));
                if(! String.isBlank(cdw.husbandData.mobilePhone))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(clientId, cdw.husbandData.mobilePhone, '', 'Mobile'));
                if(! String.isBlank(cdw.husbandData.workPhone))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(clientId, cdw.husbandData.workPhone, cdw.husbandData.workPhoneExtension, 'Business'));
                if(! String.isBlank(cdw.husbandData.workEmail))
                    eaList.add(IntakeFormHelper.createEmailAddress(clientId, cdw.husbandData.workEmail, 'E-mail'));
                if(! String.isBlank(cdw.husbandData.workFax))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(clientId, cdw.husbandData.workFax, '', 'Business Fax'));
        
                
                Id spouseId = IntakeFormHelper.upsertWife(cdw, wifeFatherHouseholdId);

                if(! String.isBlank(cdw.wifeData.email))
                    eaList.add(IntakeFormHelper.createEmailAddress(spouseId, cdw.wifeData.email, 'E-mail'));
                if(! String.isBlank(cdw.wifeData.mobilePhone))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(spouseId, cdw.wifeData.mobilePhone, '', 'Mobile'));
                if(! String.isBlank(cdw.wifeData.workPhone))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(spouseId, cdw.wifeData.workPhone, cdw.wifeData.workPhoneExtension, 'Business'));
                if(! String.isBlank(cdw.wifeData.workEmail))
                    eaList.add(IntakeFormHelper.createEmailAddress(spouseId, cdw.wifeData.workEmail, 'E-mail'));
                if(! String.isBlank(cdw.wifeData.workFax))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(spouseId, cdw.wifeData.workFax, '', 'Business Fax'));

                if(! String.isBlank(cdw.householdData.homePhone))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(clientId, cdw.householdData.homePhone, '', 'Residence'));
                if(! String.isBlank(cdw.householdData.homeFax))
                    phoneList.add(IntakeFormHelper.createPhoneNumber(clientId, cdw.householdData.homeFax, '', 'Residence Fax'));

                
                if( (! String.isBlank(cdw.householdData.residenceStreet) ) || (! String.isBlank(cdw.householdData.residenceCity) ) )
                    cpa.add(IntakeFormHelper.createResidenceAdress(cdw.householdData,clientId));

                if( (! String.isBlank(cdw.householdData.mailingStreet) ) || (! String.isBlank(cdw.householdData.mailingCity) ) )
                    cpa.add(IntakeFormHelper.createMailingAdress(cdw,clientId));

                if( (! String.isBlank(cdw.husbandData.workStreet) ) || (! String.isBlank(cdw.husbandData.workCity) ) )    
                    cpa.add(IntakeFormHelper.createWorkAdress(cdw.husbandData,clientId));

                if( (! String.isBlank(cdw.wifeData.workStreet) ) || (! String.isBlank(cdw.wifeData.workCity) ) )    
                    cpa.add(IntakeFormHelper.createWorkAdress(cdw.wifeData,spouseId));

                String clientHouseholdId = cdw.householdData.householdId;
                if(String.isBlank(clientHouseholdId))
                    clientHouseholdId = IntakeFormHelper.upsertHousehold(cdw.husbandData.lastName + ', ' + cdw.husbandData.firstName + (cdw.wifeData.firstName != '' ? ' & ' + cdw.wifeData.firstName : '') + ' Household', clientId, spouseId );
            
                IntakeFormHelper.ChildrenInfoWrapper ciw = IntakeFormHelper.upsertChildren(cdw,clientHouseholdId);
                cpa.addAll(ciw.cpa);
                phoneList.addAll(ciw.phoneList);
                eaList.addAll(ciw.eaList);
                
                if(cpa.size() > 0)
                    upsert cpa;

                if(phoneList.size() > 0)
                    upsert phoneList;

                if(eaList.size() > 0)
                    upsert eaList;

                IntakeFormHelper.upsertAdvisors(cdw,clientId);

                if(intakeFormId != '')
                    IntakeFormHelper.updateIntakeFormStatus(intakeFormId, jsonObj);
            }
        // }
        // catch(Exception e)
        // {
        //     system.debug(e.getMessage());
        //     system.debug(e.getLineNumber());
        //     system.debug(e.getCause());
        //     throw new AuraHandledException(e.getMessage());
        // }
        
        // return '';
    }
    
    // @AuraEnabled
    // public static ClientDataWrapper editClientData(String recordId)
    // {
    //     ClientDataWrapper cdw = new ClientDataWrapper();
    //     cdw.husbandData = new HusbandData();
    //     cdw.wifeData = new WifeData();
    //     cdw.householdData = new HouseholdData();
    //     cdw.children = new List<ChildData>();
    //     cdw.advisors = new List<AdvisorData>();
        
    //     Account husbandData = [select id,FirstName,MiddleName,LastName,Salutation,Lineage__r.Husband__r.LastName,PersonHomePhone,
    //                            Suffix,Hebrew_Name__pc, Full_Hebrew_Name__pc,Lineage__r.Husband__r.FirstName, Fax, Spouse__c,
    //                            Lineage__r.Wife__r.FirstName, Lineage__r.Wife__r.LastName,PersonBirthdate, SSN__pc,
    //                            Is_US_Citizen__pc, Marital_Status__pc, Married_Date__pc, PersonMobilePhone, PersonEmail,
    //                            Occupation__pc, Firm__pc, PersonTitle, Work_Phone__pc, Work_Fax__pc, Work_Email__pc,
    //                            (Select AddressType, Street, City, State, Country, PostalCode From ContactPointAddresses)
    //                            from Account where Id =: recordId limit 1];
        
    //     cdw.husbandData.husbandId = husbandData.Id;
    //     cdw.husbandData.husbandFirstName = husbandData.FirstName;
    //     cdw.husbandData.husbandMiddleName = husbandData.MiddleName;
    //     cdw.husbandData.husbandLastName = husbandData.LastName;
    //     cdw.husbandData.husbandSalutation = husbandData.Salutation;
    //     cdw.husbandData.husbandSuffix = husbandData.Suffix;
    //     cdw.husbandData.husbandHebrewName = husbandData.Hebrew_Name__pc;
    //     cdw.husbandData.husbandFullHebrewName = husbandData.Full_Hebrew_Name__pc;
    //     cdw.husbandData.husbandFatherFirstName = husbandData.Lineage__r.Husband__r.FirstName;
    //     cdw.husbandData.husbandMotherFirstName = husbandData.Lineage__r.Wife__r.FirstName;
    //     cdw.husbandData.husbandParentsLastName = husbandData.Lineage__r.Husband__r.LastName;
    //     if(husbandData.PersonBirthdate != null)
    //         cdw.husbandData.husbandDOB = String.valueOf(husbandData.PersonBirthdate);
    //     cdw.husbandData.husbandSSN = husbandData.SSN__pc;
    //     cdw.husbandData.husbandIsCitizen = husbandData.Is_US_Citizen__pc;
    //     cdw.husbandData.husbandMaritalStatus = husbandData.Marital_Status__pc;
    //     cdw.husbandData.husbandMarriageDate = String.valueOf(husbandData.Married_Date__pc);
    //     cdw.husbandData.husbandMobilePhone = husbandData.PersonMobilePhone;
    //     cdw.husbandData.husbandEmail = husbandData.PersonEmail;
    //     cdw.husbandData.husbandOccupation = husbandData.Occupation__pc;
    //     cdw.husbandData.husbandFirm = husbandData.Firm__pc;
    //     cdw.husbandData.husbandTitle = husbandData.PersonTitle;
    //     cdw.husbandData.husbandWorkPhone = husbandData.Work_Phone__pc;
    //     cdw.husbandData.husbandWorkFax = husbandData.Work_Fax__pc;
    //     cdw.husbandData.husbandWorkEmail = husbandData.Work_Email__pc;
        
    //     cdw.householdData.homePhone = husbandData.PersonHomePhone;
    //     cdw.householdData.homeFax = husbandData.Fax;
        
        
    //     for(ContactPointAddress address : husbandData.ContactPointAddresses)
    //     {
    //         if(address.addressType == 'Mailing')
    //         {
    //             cdw.householdData.mailingStreet = address.street;
    //             cdw.householdData.mailingCity = address.city;
    //             cdw.householdData.mailingState = address.state;
    //             cdw.householdData.mailingCountry = address.country;
    //             cdw.householdData.mailingZip = address.PostalCode;
                
    //         }
    //         if(address.addressType == 'Residence')
    //         {
    //             cdw.householdData.residenceStreet = address.street;
    //             cdw.householdData.residenceCity = address.city;
    //             cdw.householdData.residenceState = address.state;
    //             cdw.householdData.residenceCountry = address.country;
    //             cdw.householdData.residenceZip = address.PostalCode;
    //         }
    //         if(address.addressType == 'Work')
    //         {
    //             cdw.husbandData.husbandWorkStreet = address.street;
    //             cdw.husbandData.husbandWorkCity = address.city;
    //             cdw.husbandData.husbandWorkState = address.state;
    //             cdw.husbandData.husbandWorkCountry = address.country;
    //             cdw.husbandData.husbandWorkZip = address.PostalCode;
    //         }
    //     }
        
    //     if(husbandData.Spouse__c != null)
    //     {
    //         Account wifeData = [select id,FirstName,MiddleName,LastName,Salutation,Lineage__r.Husband__r.LastName,PersonHomePhone,
    //                             Suffix,Hebrew_Name__pc, Full_Hebrew_Name__pc,Lineage__r.Husband__r.FirstName, Fax, Spouse__c,
    //                             Lineage__r.Wife__r.FirstName, Lineage__r.Wife__r.LastName,PersonBirthdate, SSN__pc,
    //                             Is_US_Citizen__pc, Maiden_Name__pc, PersonMobilePhone, PersonEmail,
    //                             Occupation__pc, Firm__pc, PersonTitle, Work_Phone__pc, Work_Fax__pc, Work_Email__pc,
    //                             (Select AddressType, Street, City, State, Country, PostalCode From ContactPointAddresses)
    //                             from Account where Id =: husbandData.Spouse__c limit 1];
            
    //         cdw.wifeData.wifeId = wifeData.Id;
    //         cdw.wifeData.wifeFirstName = wifeData.FirstName;
    //         cdw.wifeData.wifeMiddleName = wifeData.MiddleName;
    //         cdw.wifeData.wifeLastName = wifeData.LastName;
    //         cdw.wifeData.wifeSalutation = wifeData.Salutation;
    //         cdw.wifeData.wifeSuffix = wifeData.Suffix;
    //         cdw.wifeData.wifeHebrewName = wifeData.Hebrew_Name__pc;
    //         cdw.wifeData.wifeFullHebrewName = wifeData.Full_Hebrew_Name__pc;
    //         cdw.wifeData.wifeFatherFirstName = wifeData.Lineage__r.Husband__r.FirstName;
    //         cdw.wifeData.wifeMotherFirstName = wifeData.Lineage__r.Wife__r.FirstName;
    //         cdw.wifeData.wifeParentsLastName = wifeData.Lineage__r.Husband__r.LastName;
    //         if(wifeData.PersonBirthdate != null)
    //             cdw.wifeData.wifeDOB = String.valueOf(wifeData.PersonBirthdate);
    //         cdw.wifeData.wifeSSN = wifeData.SSN__pc;
    //         cdw.wifeData.wifeIsCitizen = wifeData.Is_US_Citizen__pc;
    //         cdw.wifeData.wifeMobilePhone = wifeData.PersonMobilePhone;
    //         cdw.wifeData.wifeEmail = wifeData.PersonEmail;
    //         cdw.wifeData.wifeOccupation = wifeData.Occupation__pc;
    //         cdw.wifeData.wifeFirm = wifeData.Firm__pc;
    //         cdw.wifeData.wifeTitle = wifeData.PersonTitle;
    //         cdw.wifeData.wifeWorkPhone = wifeData.Work_Phone__pc;
    //         cdw.wifeData.wifeWorkFax = wifeData.Work_Fax__pc;
    //         cdw.wifeData.wifeWorkEmail = wifeData.Work_Email__pc;
            
    //         for(ContactPointAddress address : wifeData.ContactPointAddresses)
    //         {
                
    //             if(address.addressType == 'Work')
    //             {
    //                 cdw.wifeData.wifeWorkStreet = address.street;
    //                 cdw.wifeData.wifeWorkCity = address.city;
    //                 cdw.wifeData.wifeWorkState = address.state;
    //                 cdw.wifeData.wifeWorkCountry = address.country;
    //                 cdw.wifeData.wifeWorkZip = address.PostalCode;
    //             }
    //         }
    //         List<Account> children = [select id,FirstName,MiddleName,LastName,Salutation,Lineage__r.Husband__r.LastName,PersonHomePhone,
    //                                   Suffix,Hebrew_Name__pc, Full_Hebrew_Name__pc,Lineage__r.Husband__r.FirstName, Fax, Spouse__c,
    //                                   Lineage__r.Wife__r.FirstName, Lineage__r.Wife__r.LastName,PersonBirthdate, SSN__pc,Spouse__r.Firm__pc,
    //                                   Is_US_Citizen__pc, Marital_Status__pc, Married_Date__pc, PersonMobilePhone, PersonEmail,
    //                                   Occupation__pc, Firm__pc, PersonTitle, Work_Phone__pc, Work_Fax__pc, Work_Email__pc,
    //                                   Spouse__r.FirstName,Spouse__r.MiddleName,Spouse__r.LastName,Spouse__r.Salutation,Gender__pc,
    //                                   Spouse__r.Lineage__r.Husband__r.LastName,Spouse__r.PersonHomePhone,Spouse__r.Suffix,Spouse__r.Maiden_Name__pc,
    //                                   Spouse__r.Hebrew_Name__pc, Spouse__r.Full_Hebrew_Name__pc,Spouse__r.Lineage__r.Husband__r.FirstName, Spouse__r.Occupation__pc,
    //                                   Spouse__r.Fax, Spouse__r.Spouse__c,Spouse__r.Lineage__r.Wife__r.FirstName, Spouse__r.Lineage__r.Wife__r.LastName,
    //                                   Spouse__r.PersonBirthdate, Spouse__r.SSN__pc,Spouse__r.Is_US_Citizen__pc, Spouse__r.PersonMobilePhone, Spouse__r.PersonEmail,
    //                                   Spouse__r.PersonTitle, Spouse__r.Work_Phone__pc, Spouse__r.Work_Fax__pc, Spouse__r.Work_Email__pc,
    //                                   (Select AddressType, Street, City, State, Country, PostalCode From ContactPointAddresses)
    //                                   from Account where Lineage__r.Husband__c =: husbandData.Id AND Lineage__r.Wife__c =: wifeData.Id];
            
    //         for(Account child: children)
    //         {
    //             ChildData cd = new ChildData();
    //             cd.childId = child.Id;
    //             cd.childGender = child.Gender__pc;
    //             cd.childFirstName = child.FirstName;
    //             cd.childMiddleName = child.MiddleName;
    //             cd.childLastName = child.LastName;
    //             cd.childSalutation = child.Salutation;
    //             cd.childSuffix = child.Suffix;
    //             cd.childHebrewName = child.Hebrew_Name__pc;
    //             cd.childFullHebrewName = child.Full_Hebrew_Name__pc;
    //             if(child.PersonBirthdate != null)
    //                 cd.childDOB = String.valueOf(child.PersonBirthdate);
    //             cd.childSSN = child.SSN__pc;
    //             cd.childMaritalStatus = child.Marital_Status__pc;
    //             if(child.Married_Date__pc != null)
    //                 cd.childMarriageDate = String.valueOf(child.Married_Date__pc);
    //             cd.childHomePhone = child.PersonHomePhone;
    //             cd.childMobilePhone = child.PersonMobilePhone;
    //             cd.childEmail = child.PersonEmail;
    //             cd.childFax = child.Fax;
                
    //             cd.childOccupation = child.Occupation__pc;
    //             cd.childFirm = child.Firm__pc;
    //             cd.childTitle = child.PersonTitle;
    //             cd.childWorkPhone = child.Work_Phone__pc;
    //             cd.childWorkFax = child.Work_Fax__pc;
    //             cd.childWorkEmail = child.Work_Email__pc;
    //             cd.spouseId = child.Spouse__c;
    //             cd.spouseFirstName = child.Spouse__r.FirstName;
    //             cd.spouseMiddleName = child.Spouse__r.MiddleName;
    //             cd.spouseLastName = child.Spouse__r.LastName;
    //             cd.spouseMaidenName = child.Spouse__r.Maiden_Name__pc;
    //             cd.spouseSalutation = child.Spouse__r.Salutation;
    //             cd.spouseSuffix = child.Spouse__r.Suffix;
    //             cd.spouseHebrewName = child.Spouse__r.Hebrew_Name__pc;
    //             cd.spouseFullHebrewName = child.Spouse__r.Full_Hebrew_Name__pc;
    //             if(child.Spouse__r.PersonBirthdate != null)
    //                 cd.spouseDOB = String.valueOf(child.Spouse__r.PersonBirthdate);
    //             cd.spouseSSN = child.Spouse__r.SSN__pc;
    //             cd.spouseMobilePhone = child.Spouse__r.PersonMobilePhone;
    //             cd.spouseEmail = child.Spouse__r.PersonEmail;
    //             cd.spouseFax = child.Spouse__r.Fax;
    //             cd.spouseOccupation = child.Spouse__r.Occupation__pc;
    //             cd.spouseFirm = child.Spouse__r.Firm__pc;
    //             cd.spouseTitle = child.Spouse__r.PersonTitle;
    //             cd.spouseWorkPhone = child.Spouse__r.Work_Phone__pc;
    //             cd.spouseWorkFax = child.Spouse__r.Work_Fax__pc;
    //             cd.spouseWorkEmail = child.Spouse__r.Work_Email__pc;
                
    //             cd.grandchildren = new List<GrandchildData>();
                
    //             List<Account> grandchildren = [Select Id, FirstName, MiddleName, LastName, PersonBirthdate, Gender__pc 
    //                                            From Account
    //                                            Where Lineage__r.Husband__c =: child.Id AND Lineage__r.Wife__c =: child.Spouse__r.Id];
                
    //             for(Account gc: grandchildren)
    //             {
    //                 GrandchildData gcd = new GrandchildData();
    //                 gcd.childId = gc.Id;
    //                 gcd.childGender = gc.Gender__pc;
    //                 gcd.childFirstName = gc.FirstName;
    //                 gcd.childMiddleName = gc.MiddleName;
    //                 gcd.childLastName = gc.LastName;
    //                 if(gc.PersonBirthdate != null)
    //                     gcd.childDOB = String.valueOf(gc.PersonBirthdate);
                    
    //                 cd.grandchildren.add(gcd);
                    
    //             }
                
    //             cdw.children.add(cd);
                
    //         }
            
            
    //         List<AccountContactRelation> advisors = [SELECT contactId, Contact.accountId FROM AccountContactRelation acr where accountId =:husbandData.Id];
            
    //         for(AccountContactRelation acr: advisors)
    //         {
    //             AdvisorData ad = new AdvisorData();
    //             ad.advisorId = acr.contactId;
    //             ad.advisorFirmId = acr.Contact.accountId;
                
    //             cdw.advisors.add(ad);
    //         }
            
    //   }
        
    //     return cdw;
    // }

 
    
    @AuraEnabled
    public static List<String> getSalutationPickListValues()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<String> getMaritalStatusPickListValues()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Marital_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<String> getStatePickListValues()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Property__c.Property_State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<String> getCountryPickListValues()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Property__c.Property_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<String> getAccountTypePickListValues()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Account_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static List<String> getGenderPickListValues()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Gender__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static ContactWrapper getAccountContacts(String accId)
    {        
        ContactWrapper cw = new ContactWrapper();
        cw.conList = new List<Contact>();
        cw.msg = '';
        
        try
        {
            cw.conList = [Select Id, Name, Title From Contact Where AccountId = :accId];
            cw.msg = 'success';
        }
        catch(Exception e)
        {
            cw.msg = e.getMessage();
            
            system.debug('e.getMessage()______________'+ e.getMessage());
        }
        
        return cw;
    }

    public class ContactWrapper
    {
        @AuraEnabled public List<Contact> conList {get;set;}
        @AuraEnabled public String msg {get;set;}
    }
}