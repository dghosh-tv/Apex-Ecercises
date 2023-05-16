import { LightningElement, wire,api, track } from 'lwc';
import CUSTOM_OBJECT from '@salesforce/schema/Feedback__c'
import OBJECTS_NAME from '@salesforce/schema/Contribution__c'
import getDataId from '@salesforce/apex/MVPNomineeContributionsController.getSelfFeedbackId'
import getFieldSet from '@salesforce/apex/MVPNomineeContributionsController.getAllFieldSets'
import { NavigationMixin } from 'lightning/navigation';
export default class FeedbackDesignation extends NavigationMixin(LightningElement) {
    @api recordId
    @track column
    @track feedbackIds = [];
    @track objectApiName=CUSTOM_OBJECT.objectApiName;

    @wire(getFieldSet, {objectApiName : 'Feedback__c'})
    wiredFields({data}){
        if(data){
            console.log("Feedback fields >> "+JSON.stringify(data));
            this.column=data;
        }
    }

    @wire(getDataId, {disgnationId : '$recordId', recordTypeName : 'Feedback'})
    wireDataList({data})
    {
        if(data){
            console.log("Feedback Data >>"+ JSON.stringify(data))
            console.log(`feedbackIds : ${JSON.stringify(this.feedbackIds)}`);
            var conts = data;
            for(var item in conts){
               this.feedbackIds.push({value:conts[item], key:item});
            }
            console.log(`bhai ye he mera data : ${JSON.stringify(this.feedbackIds)}`);
        }
    }

    refresh(){
        const customEvent = new CustomEvent('refresh');
        this.dispatchEvent(customEvent);
    }

    addContribution(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: `${OBJECTS_NAME.objectApiName}`,
                actionName: 'new'
            }
        });
    }

    get isFeedbackAvailable() {
        return this.feedbackIds.length !== 0;
    }

    get verticalFieldSet() {
        return this.column['verticalfieldsetfeedback'];
    }

    get horizontalFieldSet() {
        return this.column['horizontalfieldsetfeedback'];
    }

    get detailFieldSet() {
        return this.column['detailfieldsetfeedback'];
    }

}