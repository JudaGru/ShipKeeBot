public  class ClientAssets {

    @AuraEnabled
    public static Ownership getOwnerAssetsHierarchal (String ownerId,Integer maxDepth){

        if(maxDepth == null)
            maxDepth = 10;

        system.debug(ownerId);
        system.debug(maxDepth);

        List<Ownership__c> ownershipsScrambled = getOwnershipsScrambled(new List<String>{ownerId},maxDepth,new list<ownership__c>());
        system.debug('ownershipsScrambled.size()>>>>>>  ' + ownershipsScrambled.size());
        ownership ownerAssets = new ownership(ownerId,null,null,ownershipsScrambled,maxDepth,0,true);
        system.debug('ownerAssets>>>>>>>>  ' + ownerAssets);
        return ownerAssets;

    }

    @AuraEnabled
    public static OwnershipsGroupedByType getOwnerAssetsGroupedByAssetType (String ownerId,Integer maxDepth){

        if(maxDepth == null)
            maxDepth = 10;

        system.debug(ownerId);
        system.debug(maxDepth);

        List<Ownership__c> ownershipsScrambled = getOwnershipsScrambled(new List<String>{ownerId},maxDepth,new list<ownership__c>());

        OwnershipsGroupedByType ogt = new OwnershipsGroupedByType();
        ogt.artsAndCollectibles = new List<Ownership>();
        ogt.lifeInsurancePolicies =  new List<Ownership>();
        ogt.bankAccounts =  new List<Ownership>();
        ogt.loansReceivables =  new List<Ownership>();
        ogt.loansPayable =  new List<Ownership>();
        ogt.investmentProperties =  new List<Ownership>();
        ogt.personalProperties =  new List<Ownership>();
        ogt.entities =  new List<Ownership>();  

        ogt.totalArtsAndCollectibles = 0;
        ogt.totalLifeInsurancePolicies = 0;
        ogt.totalBankAccounts = 0;
        ogt.totalLoansReceivables = 0;
        ogt.totalLoansPayable = 0;
        ogt.totalInvestmentProperties = 0;
        ogt.totalPersonalProperties = 0;
        ogt.totalEntities = 0;


        for (Ownership__c ownership : ownershipsScrambled) {

            ownership own = new ownership(ownership.asset_Id__c,ownership.Asset_Name__c,ownership,ownershipsScrambled,maxDepth,0,false);
            system.debug(own.assetOrEntityType);

            if(own.assetOrEntityType == 'Valuables'){
                ogt.artsAndCollectibles.add(own);
                ogt.totalArtsAndCollectibles += ownership.Asset_Ownership_Value__c;
            } 
            else if(ownership.Asset_Type__c == 'Life_Insurance_Policy'){
                ogt.lifeInsurancePolicies.add(own);
                ogt.totalLifeInsurancePolicies += ownership.Asset_Ownership_Value__c;
            }
            else if(ownership.Asset_Type__c == 'Bank_Investment_Account'){
                ogt.bankAccounts.add(own);
                ogt.totalBankAccounts  += ownership.Asset_Ownership_Value__c;
                // if(ownership.Asset_Record_Type_Name__c == 'Bank Account')
                //     ogt.totalCash += ownership.Asset_Ownership_Value__c;
            }
            else if(ownership.Asset_Type__c == 'Loan'){
                
                if(ownership.Ownership_Type__c == 'Borrower'){
                    ogt.loansPayable.add(own);
                    ogt.totalLoansPayable  += ownership.Asset_Ownership_Value__c;
                }
                else if(ownership.Ownership_Type__c == 'Lender'){
                    ogt.loansReceivables.add(own);
                    ogt.totalLoansReceivables  += ownership.Asset_Ownership_Value__c;
                }
            }
            else if(ownership.Asset_Type__c == 'Property'){
                if(own.assetOrEntityType == 'Investment Property'){
                    ogt.investmentProperties.add(own);
                    ogt.totalInvestmentProperties += ownership.Asset_Ownership_Value__c;
                }
                else if(own.assetOrEntityType == 'Personal Property'){
                    ogt.personalProperties.add(own);
                    ogt.totalPersonalProperties += ownership.Asset_Ownership_Value__c;

                }

            }
            else if(ownership.Asset_Type__c == 'Entity'){
                ogt.entities.add(own);
                ogt.totalEntities += ownership.Asset_Ownership_Value__c;
            }
        
        }

        system.debug('ogt>>>>>>>>>>>>>>>  ' + ogt);

        return ogt;

    }

   
    // gets all ownerships within heirarchy of given owner 
    public static List<Ownership__c> getOwnershipsScrambled (List<String> ownerIds, Integer maxDepth, list<ownership__c> ownerships){
    
        List<Ownership__c> entityOwnerships = [
        select id,name,Asset_Id__c,Asset_Type__c,Asset_Value__c,Owner__c,Owner__r.Name,Asset_Name__c,Asset_Ownership_Value__c,Asset_Record_Type_Name__c, Ownership_Type__c,Ownership_Percent__c,
        Arts_and_Collectables__c,Arts_and_Collectables__r.Name,
        Life_Insurance_Policy__c,Life_Insurance_Policy__r.Name,
        Entity__c,Entity__r.Name,
        Bank_Investment_Account__c,Bank_Investment_Account__r.Name,
        Property__c,Property__r.Name,
        Loan__c,Loan__r.name 
        from Ownership__c where owner__c in :ownerIds  ];
    
        ownerships.addAll(entityOwnerships);
    
        List<String> entityIds = new List<String>();
        for (Ownership__c ownership : entityOwnerships) {
            if(ownership.Entity__c != null ){
                entityIds.add(ownership.Entity__c);
            }
        }
    
        if(entityIds.size() > 0 && maxDepth > 1 ){
            system.debug('>>>>'+ maxDepth);
            return getOwnershipsScrambled(entityIds,maxDepth -=1,ownerships);
        }
        else 
        {

            Set<Ownership__c> ownershipSets = new Set<Ownership__c>(ownerships);
            List<Ownership__c> ownershipsList = new List<Ownership__c>(ownershipSets);
            return  ownershipsList;
        }
          
    }

    public static sobject generateAssetFromOwnership (Ownership__c ownership){

        sobject sobj;
        if(ownership.Asset_Type__c == 'Valuables'){
            Arts_and_Collectables__c ac = new Arts_and_Collectables__c();
            ac.id = ownership.Arts_and_Collectables__c;
            ac.name = ownership.Arts_and_Collectables__r.name;
            sobj = ac;
        }
        else if(ownership.Asset_Type__c == 'Life_Insurance_Policy'){
            Life_Insurance_Policy__c lip = new Life_Insurance_Policy__c();
            lip.id = ownership.Life_Insurance_Policy__c;
            lip.name = ownership.Life_Insurance_Policy__r.name;
            sobj = lip;
        }
        else if(ownership.Asset_Type__c == 'Bank_Investment_Account'){
            Bank_Investment_Account__c bia = new Bank_Investment_Account__c();
            bia.id = ownership.Bank_Investment_Account__c;
            bia.name = ownership.Bank_Investment_Account__r.name;
            sobj = bia;
        }
        else if(ownership.Asset_Type__c == 'Loan'){
            Loan__c loan = new Loan__c();
            loan.id = ownership.Loan__c;
            // loan.name = ownership.Loan__r.name;
            sobj = loan;
        }
        else if(ownership.Asset_Type__c == 'Property'){
            Property__c property = new Property__c();
            property.id = ownership.property__c;
            property.name = ownership.property__r.name;
            sobj = property;
        }

        else if(ownership.Asset_Type__c == 'Entity'){
            Account entity = new Account();
            entity.id = ownership.Entity__c;
            entity.name = ownership.Entity__r.name;
            sobj = entity;
        }
        return sobj;
    }
   

    public class Ownership {

        @AuraEnabled public integer depthLevel {get;set;}
        @AuraEnabled public integer currentLevel {get;set;}
        @AuraEnabled public string assetOrEntityId {get;set;}
        @AuraEnabled public string assetOrEntityName {get;set;}
        @AuraEnabled public string assetOrEntityLink {get;set;}
        @AuraEnabled public string assetOrEntityType {get;set;}
        @AuraEnabled public decimal assetOrEntityValue {get;set;}
        @AuraEnabled public decimal assetOrEntityOwnershipValue {get;set;}
        @AuraEnabled public string assetOrEntityOwnershipType {get;set;}
        @AuraEnabled public decimal assetOrEntityOwnershipPercent {get;set;}
        @AuraEnabled public string ownerName {get;set;}
        @AuraEnabled public sobject assetOrEntity {get;set;}
        @AuraEnabled public Ownership__c ownershipDetails {get;set;}
        @AuraEnabled public List<Ownership> childOwnerships {get;set;}
 
        public Ownership(String assetOrEntityId,String assetOrEntityName, Ownership__c ownershipDetails, List<Ownership__c> ownershipsScrambled,Integer depthLevel,Integer currentLevel,boolean getChildren){

            this.depthLevel = depthLevel;
            this.currentLevel = currentLevel;
            this.assetOrEntityId = assetOrEntityId;
            this.assetOrEntityName = assetOrEntityName ;
            this.assetOrEntityType = ownershipDetails != null ? ownershipDetails.Asset_Record_Type_Name__c : '';
            this.assetOrEntityValue = ownershipDetails != null ? ownershipDetails.Asset_Value__c : 0;
            this.assetOrEntityOwnershipValue = ownershipDetails != null ? ownershipDetails.Asset_Ownership_Value__c : 0;
            this.assetOrEntityOwnershipType = ownershipDetails != null ? ownershipDetails.Ownership_Type__c : '';
            this.assetOrEntityOwnershipPercent = 0;
            if(ownershipDetails !=null){
                this.assetOrEntityOwnershipPercent = ownershipDetails.Ownership_Percent__c != null ? ownershipDetails.Ownership_Percent__c / 100: 0;
            }
            this.ownerName = ownershipDetails != null ? ownershipDetails.Owner__r.Name : '';
            this.assetOrEntityLink = '/'+assetOrEntityId;
            // this.assetOrEntity = assetOrEntity;
            this.assetOrEntity = ownershipDetails !=null ? generateAssetFromOwnership(ownershipDetails):null;
            this.ownershipDetails = ownershipDetails;
            this.childOwnerships = new List<Ownership>();

            if(getChildren)
                findChildOwnerships(ownershipsScrambled,currentLevel +=1);
        }
        
        public void findChildOwnerships(List<Ownership__c> ownershipsScrambled, Integer currentLevel){
            for(Ownership__c o : ownershipsScrambled)
            {
                if(o.owner__c == this.assetOrEntityId && currentLevel <= depthLevel){
                    this.childOwnerships.add(new ownership(o.asset_Id__c,o.Asset_Name__c,o,ownershipsScrambled,depthLevel,currentLevel,true));
                }
            }
        }
     }

     public class OwnershipsGroupedByType {

        @AuraEnabled public list<ownership> artsAndCollectibles {get;set;}
        @AuraEnabled public list<ownership> lifeInsurancePolicies {get;set;}
        @AuraEnabled public list<ownership> bankAccounts {get;set;}
        @AuraEnabled public list<ownership> loansReceivables {get;set;}
        @AuraEnabled public list<ownership> loansPayable {get;set;}
        @AuraEnabled public list<ownership> investmentProperties {get;set;}
        @AuraEnabled public list<ownership> personalProperties {get;set;}
        @AuraEnabled public list<ownership> entities {get;set;}

        @AuraEnabled public decimal totalArtsAndCollectibles {get;set;}
        @AuraEnabled public decimal totalLifeInsurancePolicies {get;set;}
        @AuraEnabled public decimal totalBankAccounts {get;set;}
        @AuraEnabled public decimal totalLoansReceivables {get;set;}
        @AuraEnabled public decimal totalLoansPayable {get;set;}
        @AuraEnabled public decimal totalInvestmentProperties {get;set;}
        @AuraEnabled public decimal totalPersonalProperties {get;set;}
        @AuraEnabled public decimal totalEntities {get;set;}





     }

}