import { LightningElement, wire, api } from 'lwc';
import fetchContactFields from '@salesforce/apex/MVPNomineeBasicController.fetchContactData'
import getFieldSet from '@salesforce/apex/MVPNomineeBasicController.getFieldSet'
import CONTACT_OBJECT from '@salesforce/schema/Contact'
export default class MVPNomineeBasicInfo extends LightningElement {
    objectApiName=CONTACT_OBJECT;
    @api title
    @api columnView
    @api FieldSet
    @api showHeader
    @api recordId
    @api contactId
    @api column;
    @wire(getFieldSet, {sObjectName : 'Contact',fieldSetName : '$FieldSet'})
    wiredFields({data}){
        if(data){
            this.column=data;
        }
    }

    @wire(fetchContactFields,{recordId : '$recordId'})
    wireAccount({data}){
        if(data){
            this.contactId = data;
        }
    }
    

}