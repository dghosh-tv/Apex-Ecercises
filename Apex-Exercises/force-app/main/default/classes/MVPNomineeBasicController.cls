public with sharing class MVPNomineeBasicController {
    @AuraEnabled(cacheable=true)
    public static Id fetchContactData(Id recordId){
        List<Designation__c> designationList =[Select Contact__r.Id from Designation__c where Id=:recordId];
        Id contactRecordId;
        for(Designation__c designation : designationList){
            contactRecordId=designation.Contact__r.Id;
        }
        return contactRecordId;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getFieldSet(String sObjectName, String fieldSetName) {
        List<String> feilds = new List<String>();
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = d.fieldSets.getMap();
            if(fieldSetMap.containsKey(fieldSetName)){
                for(Schema.FieldSetMember f : fieldSetMap.get(fieldSetName).getFields()) {
                    feilds.add(f.getFieldPath()); 
            }
        }
        return feilds;
    }
}