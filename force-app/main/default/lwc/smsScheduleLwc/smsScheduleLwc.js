import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTemplates from '@salesforce/apex/SmsScheduleLwcController.getTemplates';
import getContentByType from '@salesforce/apex/SmsScheduleLwcController.getContentByType';
import reloadLogs from '@salesforce/apex/SmsScheduleLwcController.reloadLogs';
import createSMSLog from '@salesforce/apex/SmsScheduleLwcController.createSMSLog';

const actions = [
    { label: 'Preview', name: 'preview' }
];

const columns = [
    { label: 'Policy No.', fieldName: 'policyNo', hideDefaultActions: true },
    { label: 'Contact no.', fieldName: 'smsType', hideDefaultActions: true },
    { label: 'SMS type', fieldName: 'smsSubType', hideDefaultActions: true },
    { label: 'Trigger/Last update by', fieldName: 'smsContents', wrapText: true, hideDefaultActions: true },
    { label: 'Last update date/time', fieldName: 'smsContents', wrapText: true, hideDefaultActions: true },
];

export default class SmsScheduleLwc extends LightningElement {
    @api recordId;
    @api showPolicy;
    data = [];
    columns;
    typeOptions = [];
    subTypeOptions = undefined;
    _typesMap = null; 
    
    selPolicy = '';
    selSmsType = '';
    selSmsSubType = '';

    value = '';
    msgContent = '';

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    connectedCallback() {
        console.log('recordId:', this.recordId);
        let cols = columns;
        if (!this.showPolicy) {
            cols = columns.filter(col => col.label !== 'Policy No.');
        }
        this.columns = cols;
        // initial load
        this.reloadLogs();
    }

    reloadLogs() {
        if (!this.recordId) {
            this.data = [];
            return;
        }
        reloadLogs({ refRecordId: this.recordId })
            .then(rows => {
                this.data = rows || [];
            })
            .catch(() => {
                this.data = [];
            });
    }

    @wire(getTemplates)
    wiredTemplates({data, error}) {
        if (data) {
            const mapType = new Map();
            data.forEach(typeItem => {
                const typeKey = typeItem.smsType;
                const subType = typeItem.smsSubType;
                if (!mapType.has(typeKey)) {
                    mapType.set(typeKey, new Set());
                }
                if (subType != null && subType.trim().length > 0) {
                    mapType.get(typeKey).add(subType);
                }
            });
            this.typeOptions = Array.from(mapType.keys()).map(k => ({label: k, value: k}));
            this._typesMap = mapType; // internal reference
        }
    }

    handleChange(event) {
        // handle combobox changes by label
        const { label } = event.target;
        const val = event.detail.value;
        if (label === 'Policy No.') {
            this.selPolicy = val;
        } else if (label === 'SMS Type') {
            this.selSmsType = val;
            // rebuild sub-type options for chosen type
            const subs = this._typesMap && this._typesMap.get(val);
            if (subs && subs.size > 0) {
                this.subTypeOptions = Array.from(subs).map(subType => ({label: subType, value: subType}));
            } else {
                // no sub-types for chosen type
                this.selSmsSubType = '';
                this.subTypeOptions = undefined;
                this.updatePreview();
            }
        } else if (label === 'SMS Sub-type') {
            this.selSmsSubType = val;
            this.updatePreview();
        }
    }

    async updatePreview() {
        if (!this.selSmsType) {
            this.msgContent = '';
            return;
        }
        try {
            const content = await getContentByType({ smsType: this.selSmsType, smsSubType: this.selSmsSubType || null });
            this.msgContent = content || '';
        } catch (e) {
            this.msgContent = '';
        }
    }

    async handleSchedule() {
        try {
            // create SMS log record
            const params = {
                smsType: this.selSmsType,
                smsSubType: this.selSmsSubType,
                policyNo: this.selPolicy,
                refRecordId: this.recordId,
            };
            console.log('params:', params);
            await createSMSLog(params);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'SMS scheduled successfully',
                variant: 'success'
            }));

            this.reloadLogs();
        } catch (e) {
            console.error(e);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: e.message,
                variant: 'error'
            }));
        }
    }

}