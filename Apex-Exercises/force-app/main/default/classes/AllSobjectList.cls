public class AllSobjectList {
    public static List<String> getSobjects()
    {
        List<String> objects=new List<String>();
        for(Schema.SObjectType obj:Schema.getGlobalDescribe().values())
        {
            String name=obj.getDescribe().getName();
            objects.add(name);
        }
        return objects;
    }

}