trigger ContainIsPrimary on Contact (after insert, after update) {
    switch on Trigger.operationType{
        when AFTER_UPDATE{
            PrimaryContactHelper.checkIsPrimary(Trigger.new);
            PrimaryContactHelper.copyEmailToParentAccountPrimary(Trigger.new);
        }
        when AFTER_INSERT{
            PrimaryContactHelper.checkIsPrimary(Trigger.new);
            PrimaryContactHelper.copyEmailToParentAccountPrimary(Trigger.new);
            PrimaryContactHelper.contactCount(Trigger.new);
        } 
      
    } 
}