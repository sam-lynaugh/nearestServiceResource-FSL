import { LightningElement, api, wire, track} from 'lwc';
import fetchServiceResources from '@salesforce/apex/NearestServiceResourceController.fetchServiceResources';
import scheduleAppointment from '@salesforce/apex/NearestServiceResourceController.scheduleAppointment';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [  
    { label: 'Name', fieldName: 'Name' },
    { label: 'Id', fieldName: 'Id' }, 
    { label: 'Resource Type', fieldName: 'ResourceType' },
    { type: "button", typeAttributes: {  
        label: 'Book',  
        name: 'Book',  
        title: 'Book',  
        disabled: false,  
        value: 'Book',  
        iconPosition: 'left'  
    } }
];

export default class NearestServiceResource extends NavigationMixin(LightningElement) {

    @api recordId;
    @track columns = COLUMNS;
    @track tableData = [];

    @wire(fetchServiceResources, {serviceAppointmentId: '$recordId'}) serviceResources(result){
        console.log('result ' + result);
        if (result.data) {
            this.tableData = result.data;
            console.log('tabledata: ' + this.tableData);
            console.log(result);
        } else if (result.error) {
            this.tableData = undefined;
            console.log('error ' + result.error);
        }
    };

    callRowAction( event ) {  
          
        const recId =  event.detail.row.Id;  
        const actionName = event.detail.action.name;  
        if ( actionName === 'Book' ) {  
            //Create WO, SA, and book selected service resource (recId)
            scheduleAppointment( {serviceAppointmentId: this.recordId}, {serviceResourceId: recId} )
            .then((result)=>{
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.Id,
                        actionName: 'view',
                    },
                }).then((url) => {
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'New Service Appointment created! See it {0}!',
                        messageData: [
                            {
                                url,
                                label: 'here',
                            },
                        ],
                    });
                    this.dispatchEvent(event);
                });
            })
            .catch((error)=>{console.log(error);})
        }         
    }
}