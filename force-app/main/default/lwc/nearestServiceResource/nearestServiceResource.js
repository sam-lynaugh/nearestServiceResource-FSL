import { LightningElement, api, wire, track} from 'lwc';
import fetchServiceResources from '@salesforce/apex/NearestServiceResourceController.fetchServiceResources';
import scheduleAppointment from '@salesforce/apex/NearestServiceResourceController.scheduleAppointment';

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

export default class NearestServiceResource extends LightningElement {

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
            
        }         
    }

    /*connectedCallback() {
        //fetch today's todos from server
        this.fetchResources();
    }*/

    //Fetch 5 closest service resources from server
    /*fetchResources() {
        fetchServiceResources(this.recordId)
        .then(result => {
            if (result) {
            //update todos property with result
            this.serviceResources = result;
            console.log(this.serviceResources);
            }
        })
        .catch(error => {
            console.error("Error in fetching services resources: " + error);
        });
    }*/
}