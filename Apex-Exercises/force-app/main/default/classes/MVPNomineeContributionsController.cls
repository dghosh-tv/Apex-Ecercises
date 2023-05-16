public with sharing class MVPNomineeContributionsController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getAllFieldSets(String objectApiName){
        try {
            Map<String, List<String>> allFields = new  Map<String, List<String>>();
           Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
           Map<String, Schema.FieldSet> fieldSetObj= GlobalDescribeMap.get(objectApiName).getDescribe().FieldSets.getMap(); 
            for(String fieldset : fieldSetObj.keySet())
            {
                for(Schema.FieldSetMember fields : fieldSetObj.get(fieldset).getFields())
                {
                    if(allFields.containsKey(fieldset)){
                        allFields.get(fieldset).add(fields.getFieldPath());
                    }
                    else{
                        List<String> fieldApiName= new List<String>();
                        fieldApiName.add(fields.getFieldPath());
                        allFields.put(fieldset, fieldApiName);
                     }
                }
            }
            return allFields;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<Integer, List<Contribution__c>> getContributionId(Id disgnationId){
        try {
            List<Designation__c> designationList = [Select contact__r.Id from Designation__c where Id=:disgnationId];
            Id contactId=designationList[0].Contact__c;
            system.debug(designationList);
            List<contribution__c> allContributions = [Select Date__c, Id from contribution__c where contact__r.Id=:contactId Order by Date__c desc];
            Map<Integer, List<Contribution__c>> mapList=new Map<Integer, List<Contribution__c>>();
            for(contribution__c conList : allContributions){
                if(mapList.containsKey(conList.Date__c.year())){
                    
                    mapList.get(conList.Date__c.year()).add(conList);
                 }else{
                    List<contribution__c> contributionId = new List<contribution__c>();
                    contributionId.add(conList);
                    mapList.put(conList.Date__c.year(), contributionId);
                 }
            }
            return mapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<Integer, List<Feedback__c>> getSelfFeedbackId(Id disgnationId, String recordTypeName){
        try {
            List<Designation__c> designationList = [Select contact__r.Id from Designation__c where Id=:disgnationId];
            Id contactId=designationList[0].Contact__c;
            system.debug(designationList);
            List<Feedback__c> allContributions;
            if(recordTypeName== 'Feedback'){
                string feedbackId = [SELECT id from RecordType where Name ='Feedback'].Id;
                allContributions = [Select Date__c, RecordTypeId, Id from Feedback__c where Nominator__r.Id=:contactId and RecordTypeId=:feedbackId];
            }else if(recordTypeName== 'Self-Feedback'){
                string selfFeedbackId = [SELECT id from RecordType where Name ='Self-Feedback'].Id;
               allContributions = [Select Date__c, RecordTypeId, Id from Feedback__c where Nominator__r.Id=:contactId and RecordTypeId=:selfFeedbackId];
            }
           
            Map<Integer, List<Feedback__c>> mapList=new Map<Integer, List<Feedback__c>>();
            for(Feedback__c conList : allContributions){
                if(mapList.containsKey(conList.Date__c.year())){
                    
                    mapList.get(conList.Date__c.year()).add(conList);
                 }else{
                    List<Feedback__c> contributionId = new List<Feedback__c>();
                    contributionId.add(conList);
                    mapList.put(conList.Date__c.year(), contributionId);
                 }
            }
            return mapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}