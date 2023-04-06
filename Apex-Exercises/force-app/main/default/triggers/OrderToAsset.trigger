trigger OrderToAsset on Order (after update) {
    switch on Trigger.operationType{
        when AFTER_UPDATE{
            OrderToAssetHelper.createAssets(Trigger.new,Trigger.oldMap);
            OrderToAssetHelper.createUserRecords(Trigger.new);
            OrderToAssetHelper.updateAssets(Trigger.new,Trigger.oldMap);
            
            OrderToAssetHelper.contactToDripCampaign(Trigger.new,Trigger.oldMap);
            
        }
    }
}