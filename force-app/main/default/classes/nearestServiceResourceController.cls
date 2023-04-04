public class nearestServiceResourceController {
    @AuraEnabled (cacheable = true)
    public static List<ServiceResource> fetchServiceResources(String serviceAppointmentId) {
        ServiceAppointment sa = [SELECT Id, FSL__InternalSLRGeolocation__c FROM ServiceAppointment WHERE Id = :serviceAppointmentId LIMIT 1];
        Location loc = sa.FSL__InternalSLRGeolocation__c;

        List<ServiceResource> resources = [SELECT Id, Name, ResourceType, LastKnownLocation FROM ServiceResource WHERE ResourceType = 'T' ORDER BY DISTANCE(LastKnownLocation, :loc, 'mi') LIMIT 5];
        return resources;
        
        /*Map<Id, Double> closestResources = new Map<Id, Double>();
        for(r : resources) {
            Double dist = Location.getDistance(sa.FSL__InternalSLRGeolocation__c, r.LastKnownLocation, 'mi');
            closestResources.put(r.Id, dist);
        }
        Set<Id> srIdSet = closestResources.keySet();*/
    }

    @AuraEnabled (cacheable = false)
    public static ServiceAppointment scheduleAppointment(String serviceAppointmentId, String serviceResourceId) {
        ServiceAppointment sa = [SELECT Id, FSL__InternalSLRGeolocation__c, ParentRecordId, Subject, Address FROM ServiceAppointment WHERE Id = :serviceAppointmentId LIMIT 1];
        WorkOrder wo = [SELECT Id, Subject, Address FROM WorkOrder WHERE Id = :sa.ParentRecordId LIMIT 1];

        DateTime dueDate = DateTime.newInstance(Date.today(), Time.newInstance(18, 0, 0, 0));
        DateTime earliestStart = DateTime.newInstance(Date.today(), Time.newInstance(6, 0, 0, 0));

        WorkOrder newWo = wo.clone(false, false, false, false);
        newWo.ParentWorkOrderId = wo.Id;
        newWo.Subject = 'Backup Call';
        insert newWo;

        ServiceAppointment newSa = new ServiceAppointment(
            ParentRecordId = newWo.Id,
            Subject = 'Backup Call',
            Duration = 3,
            DueDate = dueDate,
            EarliestStartTime = earliestStart        );
        insert newSa;

        ResourcePreference newRp = new ResourcePreference(
            ServiceResourceId = serviceResourceId,
            RelatedRecordId = newWo.Id,
            PreferenceType = 'Required'
        );
        insert newRp;

        return newSa;
    }
}