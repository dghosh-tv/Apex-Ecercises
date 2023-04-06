public class OrderToAssetHelper {
    public static void createAssets(List<Order> orderList, Map<Id,Order> oldOrderList)
    {
        Set<Id> activatedOrder=new Set<Id>();
        for(Order ord:orderList)
        {
            if(oldOrderList.containsKey(ord.Id)&& oldOrderList.get(ord.Id).Status=='Draft' && ord.Status=='Activated')
            {
                activatedOrder.add(ord.Id);
            }
        }
        
       	if (activatedOrder.size() == 0) return; 
        
        List<OrderItem> orderValues=[select OrderId,UnitPrice,Order.EffectiveDate,Product2.POC__c,Order.OpportunityId,
                                     Order.AccountId,Order.status,Product2.Id,Product2.Name,Product2.ProductCode, 
                                     Product2.Family,Quantity from OrderItem where Product2.Family='Software' and OrderId In :activatedOrder];
        List<Asset> allAssets=new List<Asset>();
        Map<String, Entitlement> mapEntitlement=new Map<String, Entitlement>();
        Set<Id> assetOppId =new Set<Id>();
        List<BusinessHours> businessHours= [Select Id from BusinessHours where Name='Entitlement Business Hours'];
        for(OrderItem ordItem : orderValues)
        {
            Integer totalAsset=(Integer)ordItem.Quantity;
            for(Integer i=0;i<totalAsset;i++)
            {
                Asset assets=new Asset(
                    Name='Asset '+ ordItem.Product2.Name +' '+ ordItem.Product2.ProductCode + i,
                    AccountId= ordItem.Order.AccountId,
                    Opportunity__c=ordItem.Order.OpportunityId,
                    Product2Id=ordItem.Product2.Id,
                    Price=ordItem.UnitPrice,
                    PurchaseDate=ordItem.Order.EffectiveDate,
                    Status='Purchased',
                    Quantity=ordItem.Quantity
                );
                assetOppId.add(ordItem.Order.OpportunityId);
                allAssets.add(assets);
                //Create Entitlement
                        Entitlement entitle=new Entitlement(
                        Name='Ent ' + ordItem.Product2.Name +' '+ ordItem.Product2.ProductCode+ i,
                        AccountId=ordItem.Order.AccountId,
                        StartDate=ordItem.Order.EffectiveDate,
                        EndDate=ordItem.Order.EffectiveDate.addDays(ordItem.Product2.POC__c ? 90 : 365),
                        BusinessHoursId=businessHours[0].Id
                        );
                        mapEntitlement.put(assets.Name, entitle);
            }
        }
              insert allAssets;
        for(Asset asset : allAssets)
        {
            mapEntitlement.get(asset.Name).AssetId=asset.Id;
        }
        insert mapEntitlement.values();
        List<OpportunityContactRole> oppo=[Select ContactId, role, OpportunityId from OpportunityContactRole where role='Primary Support' and OpportunityId In :assetOppId];
        List<EntitlementContact> entitlementContactList = new List<EntitlementContact>();
        for(OpportunityContactRole op : oppo)
        {
            for(Entitlement entitlment : mapEntitlement.values())
            {
                EntitlementContact entitlmentCon=new EntitlementContact();
                entitlmentCon.ContactId= op.ContactId;
                entitlmentCon.EntitlementId=entitlment.Id;
                
                entitlementContactList.add(entitlmentCon);
            }
        }
        insert entitlementContactList;
    }
    public static void updateAssets(List<Order> orderList, Map<Id,Order> oldOrderList)
    {
        Set<Id> shippedOrder=new Set<Id>();
        for(Order ord:orderList)
        {
            if(oldOrderList.containsKey(ord.Id)&& oldOrderList.get(ord.Id).Status=='Activated' && ord.Status=='Shipped')
            {
                shippedOrder.add(ord.Id);
            }
        }
        if(shippedOrder.size()==0) return;
        
         List<OrderItem> orderValues=[select OrderId,UnitPrice,Order.EffectiveDate,Product2.POC__c,Order.OpportunityId,
                                     Order.AccountId,Order.status,Product2.Id,Product2.Name,Product2.ProductCode, 
                                     Product2.Family,Quantity from OrderItem where Product2.Family='Software' and OrderId In :shippedOrder];
        List<String> assetName = new List<String>();
        for(OrderItem ordItem : orderValues)
        {
            Integer totalAsset=(Integer)ordItem.Quantity;
            for(Integer i=0;i<totalAsset;i++)
            {
                String Name=(String)'Asset '+ ordItem.Product2.Name +' '+ ordItem.Product2.ProductCode + i;
                System.debug(Name);
                assetName.add(Name);
            }  
        }
        List<Asset> allAssets =[select Status,Actual_Ship_Date__c,Name from Asset where Name In :assetName];
        System.debug('Asset List :- '+allAssets);
        for(Asset assets: allAssets)
        {
            assets.Status='Shipped';
            assets.Actual_Ship_Date__c=Date.today();  
        }
        update allAssets;
    }
    public static void createUserRecords(List<Order> orderList)
    {
         Set<Id> oppIdSet = new Set<Id>();
        for (Order order : orderList) {
            if (order.Status == 'Shipped' && order.OpportunityId != null) {
                oppIdSet.add(order.OpportunityId);
            }
        }

        List<OpportunityContactRole> opportunityContactRoleList = [Select Id, Contact.Id, Contact.Name, Contact.Email, OpportunityId, IsPrimary from OpportunityContactRole where IsPrimary = true and OpportunityId in :oppIdSet and Contact.Email != null];

        Map<String, String> usernameToNameMap = new Map<String, String>();
        for (OpportunityContactRole opportunityContactRole : opportunityContactRoleList) {
            usernameToNameMap.put(opportunityContactRole.Contact.Email, opportunityContactRole.Contact.Name);
        }

        if (usernameToNameMap.size() == 0) return;

        Profile customerCommunityLoginUserProfile = [Select Id, Name from Profile where Name = 'Customer Community Login User' limit 1];
        

        List<User> userList = [Select Id, Name, Email, Username, IsActive from User where Username in :usernameToNameMap.keySet()];
        Set<Id> userIdSet = new Set<Id>();
        List<User> newUserList = new List<User>();
        for (String username : usernameToNameMap.keySet()) {
            Boolean isUserExists = false;
            for (User iteratedUser : userList) {
                if (iteratedUser.Username == username) {
                    isUserExists = true;
                    // User Exists
                    if (iteratedUser.IsActive != null && iteratedUser.IsActive == false) {
                        iteratedUser.IsActive = true;
                        userIdSet.add(iteratedUser.Id);
                    }
                }
            }

            if (!isUserExists) {
                Id contactId;
                for (OpportunityContactRole opportunityContactRole : opportunityContactRoleList) {
                    if (opportunityContactRole.Contact.Email == username) {
                        contactId = opportunityContactRole.Contact.Id;
                        break;
                    }
                }
                User user = new User();
                user.Username = username;
                user.FirstName = usernameToNameMap.get(username);
                user.LastName = usernameToNameMap.get(username);
                user.Alias = usernameToNameMap.get(username).substring(0, 5);
                user.Email = username;
                user.TimeZoneSidKey = 'America/New_York';
                user.LocaleSidKey = 'en_US';
                user.EmailEncodingKey = 'ISO-8859-1';
                user.ProfileId = customerCommunityLoginUserProfile.Id;
                user.LanguageLocaleKey = 'en_US';
                user.IsActive = true;
                user.ContactId = contactId;

                System.debug(user);
                newUserList.add(user);
            }
        }

        if (userIdSet.size() != 0) {
            updateUserToActive(userIdSet);
        }
        if (newUserList.size() != 0) {
            insert newUserList;
        }

    }

    @future
    static void updateUserToActive(Set<Id> userIdSet) {
        List<User> userList = [Select Id, IsActive from User where Id in :userIdSet];

        for (User user : userList) {
            user.IsActive = true;
        }

        update userList;
    }
      
    public static void contactToDripCampaign(List<Order> orderList, Map<Id,Order> oldOrderList)
    {
        Set<Id> ShippedOrder=new Set<Id>();
        for(Order ord:orderList)
        {
            if(oldOrderList.containsKey(ord.Id)&& oldOrderList.get(ord.Id).Status=='Activated' && ord.Status=='Shipped')
            {
                ShippedOrder.add(ord.OpportunityId);
            }
        } 
       	if (ShippedOrder.size() == 0) return;
        List<OpportunityContactRole> oppoConRole= [Select ContactId, role, OpportunityId from OpportunityContactRole where role='Primary Support' and OpportunityId In :ShippedOrder];
        List<Id> contactId=new List<Id>();
        
        for(OpportunityContactRole oppConRole : oppoConRole)
        {
            contactId.add(oppConRole.ContactId);
        }
        List<Contact> contactList=[Select Id, DripCampaign__c from Contact where Id In : contactId];
        List<Contact> updatedContactList = new List<Contact>();
        for(Contact con : contactList)
        {
            if(con.DripCampaign__c== false)
            {
                con.DripCampaign__c=true;
                updatedContactList.add(con);
            }
        }
        update updatedContactList;
    }
}