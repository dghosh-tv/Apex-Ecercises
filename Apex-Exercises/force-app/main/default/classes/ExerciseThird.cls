public class ExerciseThird {
    public static List<String> getConsultantName(ID accountId)
    {
        List<Consultant__c> consultantList = [Select Name from Consultant__c where Employer__r.Id= :accountId];
        List<String> consultantName = new List<String>();
        for(Integer i=0;i<consultantList.size();i++)
        {
            consultantName.add(consultantList[i].Name);
        }
        system.debug(consultantName);
        return consultantName;
    }
    public static Map<Account,Set<Id>> getRelatedConsultant()
    {
        Map<Account, Set<Id>> employerConsultantMap = new Map<Account, Set<Id>>();
        List<Account> accountList=[Select Id, (Select Id from Consultants__r) from Account where Id IN (Select Employer__c from Consultant__c)];
        Set<Id> ConsultantIdSet;
        for(Account account:accountList){
            consultantIdSet = new Set<Id>();
            for(Consultant__c consultant:account.Consultants__r){
                ConsultantIdSet.add(consultant.Id);
            }
            employerConsultantMap.put(account, consultantIdSet);
        }
        for(Account acc: employerConsultantMap.keySet()){
            System.debug('Id-->' + acc.Id + 'set'+ employerConsultantMap.get(acc));
       }
        return employerConsultantMap;
    }
    public static Integer getWorkingDays(Date startDate, Date endDate)
    {
        Integer workingDays=0;
        Integer totalDays=startDate.daysBetween(endDate);
        
        for(Integer i=0;i<totalDays;i++)
        {
            DateTime current= (DateTime)startDate.addDays(i);
            if(!current.format('E').equals('Sat')&&!current.format('E').equals('Sun'))
            {
                workingDays++;
            }
        }
        return workingDays;
    }
}