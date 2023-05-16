import { LightningElement, api,wire, track } from 'lwc';
import getAllFieldSets from '@salesforce/apex/MVPNomineeContributionsController.getAllFieldSets'
import getContributionId from '@salesforce/apex/MVPNomineeContributionsController.getContributionId'
import CONTRIBUTION_OBJECT from '@salesforce/schema/Contribution__c'
export default class MVPNomineeContributions extends LightningElement {
    objectApiName=CONTRIBUTION_OBJECT;
    @api recordId
    @track coulmn
    @track contributionIds=[];
    @wire(getAllFieldSets, {objectApiName: 'Contribution__c' })
    wiredContributions({data})
    {
        if(data){
            console.log("Contribution fields >> "+JSON.stringify(data));
           // console.log(data.horizontalfieldsetcontribution);
            this.coulmn=data;
        }
    }

    @wire(getContributionId, {disgnationId : '$recordId'})
    wireRecordIds({data})
    {
        if(data){
            var conts = data;
            for(var item in conts){
                this.contributionIds.push({value:conts[item], key:item});
            }
            console.log("contribution data >> "+this.contributionIds);
        }
    }

    get isContributionAvailable() {
        return this.contributionIds.length !== 0;
    } 

    get verticalFieldSet() {
        return this.coulmn['verticalfieldsetcontribution'];
    }

    get horizontalFieldSet() {
        return this.coulmn['horizontalfieldsetcontribution'];
    }

    get detailFieldSet() {
        return this.coulmn['detailfieldsetcontribution'];
    }

}