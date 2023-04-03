public with sharing class nearestServiceResourceController {
    @AuraEnabled( cacheable = true )  

    public static List<ServiceResource> fetchServiceResources(String serviceAppointmentId) {
        ServiceAppointment sa = [SELECT Id, FSL__InternalSLRGeolocation__c FROM ServiceAppointment WHERE Id = :serviceAppointmentId LIMIT 1];
        Location loc = sa.FSL__InternalSLRGeolocation__c;

        List<ServiceResource> resources = [SELECT Id, Name, ResourceType, LastKnownLocation FROM ServiceResource ORDER BY DISTANCE(LastKnownLocation, :loc, 'mi') LIMIT 5];
        return resources;
        
        /*Map<Id, Double> closestResources = new Map<Id, Double>();
        for(r : resources) {
            Double dist = Location.getDistance(sa.FSL__InternalSLRGeolocation__c, r.LastKnownLocation, 'mi');
            closestResources.put(r.Id, dist);
        }
        Set<Id> srIdSet = closestResources.keySet();*/
    }

    public static ServiceAppointment scheduleAppointment(String serviceAppointmentId, String serviceResourceId) {
        ServiceAppointment sa = [SELECT Id, FSL__InternalSLRGeolocation__c, ParentRecordId, Subject FROM ServiceAppointment WHERE Id = :serviceAppointmentId LIMIT 1];
        
        Date dueDate = Date.today();

        ServiceAppointment newSa = new ServiceAppointment(
            ParentRecordId = sa.ParentRecordId,
            Subject = 'Backup Call',
            Duration = 3,
            DueDate = dueDate
        );

        ServiceResourcePreference newSrp = new ServiceResourcePreference(
            ServiceResourceId = serviceResourceId,
            
        );

        insert newSa;
    }
}