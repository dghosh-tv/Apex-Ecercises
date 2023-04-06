public class PrimaryContactHelper {
      public static void checkIsPrimary(List<Contact> contactList) {
        List<Id> accountIdList = new List<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact contact : contactList) {
            if (contact.isPrimary__c) {
            accountIdList.add(contact.AccountId);
                contactMap.put(contact.AccountId, contact);
            }
        }
        List<Account> accountList = [Select Id, Name, (Select Id, isPrimary__c from Contacts) from Account where Id in :accountIdList];
        for (Account account : accountList) {
            Integer isPrimarycount = 0;
            if(contactMap.containsKey(account.Id)){
                for (Contact contact : account.Contacts) {
                if (contact.isPrimary__c) {
                    isPrimarycount++;
                }
            }
            }
            
            if (isPrimarycount>1) {
                contactMap.get(account.Id).addError('Primary Contact Already Exists');
            } 
        }
    }
    public static void copyEmailToParentAccountPrimary(List<Contact> contactList)
    {
        List<Id> accountIdList = new List<Id>();
        Map<Id,String> mapList=new Map<Id,String>();
        for(Contact conList:contactList)
        {
            
            if(conList.IsPrimary__c && conList.Email!=null)
            {
                accountIdList.add(conList.AccountId);
                mapList.put(conList.AccountId,conList.Email);
            }
        }
        List<Account> parentAccount = [Select Id, ParentId from Account where ParentId != null and Id IN :accountIdList];
        Map<Id,String> ParentEmail= new Map<Id,String>();
        List<Id> parentIdList = new List<Id>();
        for(Account acc : parentAccount)
        {
            ParentEmail.put(acc.ParentId, mapList.get(acc.Id));
            parentIdList.add(acc.ParentId);
        }
        
        List<Account> accountContact=[Select Id, (Select Id, IsPrimary__c,Email from Contacts) from Account where Id IN :parentIdList];
        List<Contact> updateMain=new List<Contact>();
        for(Account main : accountContact)
        {
            for(Contact con : main.Contacts)
            {
                if(con.IsPrimary__c)
                {
                    con.Email=ParentEmail.get(main.Id);
                }
                updateMain.add(con);
            }
        }
        update updateMain;
        
    }
    public static void contactCount(List<Contact> ContactList)
    {
        List<ID> accountIdList =new List<Id>();
        for(Contact con : ContactList)
        {
            accountIdList.add(con.AccountId);
        } 
        AggregateResult[] count=[select Account.Id, count(Id) from Contact group by Account.Id having Account.Id IN :accountIdList];
        Map<Id,Integer> contactMap=new Map<Id, Integer>();
        for(AggregateResult result : count)
        {
            contactMap.put((Id)result.get('Id'),(Integer)result.get('expr0'));
        }
        List<Account> accountList=[Select Id, Contact_Count__c from Account where Id IN :contactMap.keySet()];
        for(Account acc:accountList)
        {
            acc.Contact_Count__c=contactMap.get(acc.Id);
        }
        update accountList;
    }
    
    
    
}