import { LightningElement, api, track, wire } from 'lwc';
import CUSTOM_OBJECT from '@salesforce/schema/Feedback__c'
import getFields from '@salesforce/apex/MVPNomineeBasicController.getFieldSet'
import getDataId from '@salesforce/apex/MVPNomineeContributionsController.getSelfFeedbackId'
export default class SelfFeedbackContribution extends LightningElement {
    objectApiName=CUSTOM_OBJECT;
    @api recordId;
    @api column;
    @track feedbackIds=[];
    @wire(getFields,{sObjectName: 'Feedback__c', fieldSetName: 'CustomSelfFeedback'})
    wiredFields({data})
    {
        if(data){
            console.log("SelfFeedback Fields >>"+ JSON.stringify(data));
            this.column=data;
        }
    }

    @wire(getDataId, {disgnationId : '$recordId', recordTypeName : 'Self-Feedback'})
    wireDataList({data})
    {
        if(data){
            console.log("SelfFeedback Data >>"+ JSON.stringify(data))
            var conts = data;
            for(var item in conts){
                this.feedbackIds.push({value:conts[item], key:item});
            }
        }
    }

}