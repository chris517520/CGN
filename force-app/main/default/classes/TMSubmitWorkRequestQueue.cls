/********************************************************************************
 * Apex Class Name - TMSubmitWorkRequestQueue
 * Created Date - Jun 28, 2018
 * @description use to send the document of the submitted policies to share folder
 * 
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Franco          28/06/2018              Original Version
 ********************************************************************************/
global without sharing class TMSubmitWorkRequestQueue implements Queueable, Database.AllowsCallouts{
    public String policyNumber;
    public Boolean postDeduplicationInd;
    public Boolean sideOrderInd;
    public Attachment att;
    public String appealComment;
    public String uwAppeal;
    public Person_Insured__c personInsured;/* add by Jack on 2021-12-03 for project: JR1829 */

    // add by minghua - 20190823 - [JR1760] E-fulfillment / CTM endorsement enhancement
    public String tmCases;
    
    public List<String> policyNumberList;
    public List<Boolean> postDeduplicationIndList;
    public List<Boolean> sideOrderIndList;
    public List<Attachment> attList;
    public List<String> appealCommentList;
    public List<String> uwAppealList;
    public List<Person_Insured__c> personInsuredList;/* add by Jack on 2021-12-03 for project: JR1829 */
    
    /********************************************************************************
     * Data initialization
     ********************************************************************************/
    public TMSubmitWorkRequestQueue(List<String> policyNumberList,List<Boolean> postDeduplicationIndList,List<Boolean> sideOrderIndList,List<Attachment> attList, List<String> appealCommentList,List<String> uwAppealList){
        this.policyNumberList = policyNumberList;
        this.postDeduplicationIndList = postDeduplicationIndList;
        this.sideOrderIndList = sideOrderIndList;
        this.attList = attList;
        this.appealCommentList = appealCommentList;//add by ken, pass appeal message to Appian through submitworkrequest
        this.uwAppealList = uwAppealList;

        this.policyNumber = policyNumberList[0];
        this.postDeduplicationInd = postDeduplicationIndList[0];
        this.sideOrderInd = sideOrderIndList[0];
        this.att = attList[0]; 
        this.appealComment = appealCommentList[0];//add by ken, pass appeal message to Appian through submitworkrequest
        this.uwAppeal = uwAppealList[0]; //add by Andy
    }

    /* add by Jack on 2021-12-03 for project: JR1829 */
    public TMSubmitWorkRequestQueue(List<String> policyNumberList,List<Boolean> postDeduplicationIndList,List<Boolean> sideOrderIndList,List<Attachment> attList, List<String> appealCommentList,List<String> uwAppealList,List<Person_Insured__c> personInsuredList){
        this(policyNumberList,postDeduplicationIndList,sideOrderIndList,attList,appealCommentList,uwAppealList);
        this.personInsuredList=personInsuredList;
        this.personInsured=personInsuredList[0];
    }

    // add by minghua - 20190823 - [JR1760] E-fulfillment / CTM endorsement enhancement
    public TMSubmitWorkRequestQueue(List<String> policyNumberList,List<Boolean> postDeduplicationIndList,List<Boolean> sideOrderIndList,List<Attachment> attList, List<String> appealCommentList,List<String> uwAppealList, String tmCases){
        this.policyNumberList = policyNumberList;
        this.postDeduplicationIndList = postDeduplicationIndList;
        this.sideOrderIndList = sideOrderIndList;
        this.attList = attList;
        this.appealCommentList = appealCommentList;
        this.uwAppealList = uwAppealList;
        this.tmCases = tmCases;

        this.policyNumber = policyNumberList[0];
        this.postDeduplicationInd = postDeduplicationIndList[0];
        this.sideOrderInd = sideOrderIndList[0];
        this.att = attList[0]; 
        this.appealComment = appealCommentList[0];
        this.uwAppeal = uwAppealList[0];
    }
    
    /********************************************************************************
     * Call submitWorkRequest WS
     ********************************************************************************/
    public void execute(QueueableContext context){
        system.debug('TMSubmitWorkRequestQueue >>>start');
        
        // build the request and call WS
        WorkCalloutHelper workHelper = new WorkCalloutHelper('TM'); 
        HttpCalloutVO.WorkRequest workRequest = new HttpCalloutVO.WorkRequest();            
        workRequest.fileBody = att.Body;
        workRequest.salesforceAttachmentId = att.Id;
        workRequest.salesForceWorkType = '';
        workRequest.policyNumberList = policyNumber;
        workRequest.requestType = WorkCalloutHelper.RT_NEW_BUSINESS_REQUEST;
        //add by jack for policy replacement
        List<policy_transaction__c> ptList = [select id,PolicyReplacement__c,status__c from policy_transaction__c where id in (select Policy_Transaction__c from new_policy__c where Policy_No__c =: policyNumber)];//SPS-667 jack add
        if(ptList.size() > 0){
            system.debug('[TMSubmitWorkRequestQueue] ptList[0].PolicyReplacement__c'+ptList[0].PolicyReplacement__c);
            if(String.isNotBlank(ptList[0].PolicyReplacement__c)){
                workRequest.customerDecisionPR = ptList[0].PolicyReplacement__c;
            }
        }
        //add by jack for policy replacement
        /* add by Jack on 2021-12-03 for project: JR1829 */
        if(personInsured != null){
            workRequest.ReasonForPIAgeOver18=String.isBlank(personInsured.Reason_for_PI_age_over_18__c)?'':personInsured.Reason_for_PI_age_over_18__c;
            workRequest.OtherReasonForPIAgeOver18=String.isBlank(personInsured.Other_Reason_for_PI_age_over_18__c)?'':personInsured.Other_Reason_for_PI_age_over_18__c;
        }
        /* add by Jack on 2021-12-03 for project: JR1829 */
        // update by minghua - 20190823 - [JR1760] E-fulfillment / CTM endorsement enhancement
        if(String.isNotBlank(this.tmCases)){
            workRequest.signal = 'TM cases';
            workRequest.underwritingDecision = 'Accepted';
        }else{
            workRequest.signal = 'ESales';
            workRequest.underwritingDecision = 'Referred';
        }

        workRequest.isBrokerSubmit = false;
        String fileType = att.ContentType;
        if(!String.isBlank(fileType)){
            fileType = fileType.substring(fileType.indexOf('/')+ 1, fileType.length());
        }else{
            fileType = 'pdf';
        }
        workRequest.mimeTypeCode = fileType;
        workRequest.fileName = att.name + '.' + fileType;
        workRequest.fileExtension = fileType;
        workRequest.postDeduplicationInd = postDeduplicationInd;
        workRequest.sideOrderInd = sideOrderInd;
        workRequest.sourcePortal = 'T';
        workRequest.appealComment = appealComment;//add by ken, pass appeal message to Appian through submitworkrequest
        if(uwAppeal == 'Appeal'){
            workRequest.appealRequest = 'Yes';
        }else{
            workRequest.appealRequest = 'No';
        }
        try{
            if(!test.isrunningtest()){
                List<HttpCalloutVO.WorkRequest> requestResult = workHelper.submitWorkRequest2(workRequest);
                System.debug('requestResult[0].resultCode:'+requestResult[0].resultCode);
                if(requestResult[0].resultCode == 'Failure'){
                    updateFailtran(ptList[0]);
                }
            }
        }catch(Exception e){
            system.debug('catch a exception :'+e.getMessage());
            updateFailTran(ptList[0]);//SPS-667 jack add
        }
        system.debug('TMSubmitPolicyToIpasWorkRequestQueue >>>end');
        
        // remove the first one and start to handle for the next policy in another queue
        if(policyNumberList.size() > 1){
            policyNumberList.remove(0);
            postDeduplicationIndList.remove(0);
            sideOrderIndList.remove(0);
            attList.remove(0);
            appealCommentList.remove(0);
            uwAppealList.remove(0);
            if(!test.isrunningtest()){
                // update by minghua - 20190823 - [JR1760] E-fulfillment / CTM endorsement enhancement
                if (String.isNotBlank(this.tmCases)){
                    String jobId = System.enqueueJob(new TMSubmitWorkRequestQueue(policyNumberList,postDeduplicationIndList,sideOrderIndList,attList,appealCommentList,uwAppealList,tmCases));
                }else{
                    String jobId = System.enqueueJob(new TMSubmitWorkRequestQueue(policyNumberList,postDeduplicationIndList,sideOrderIndList,attList,appealCommentList,uwAppealList));//change by ken, pass appeal message to Appian through submitworkrequest
                }
            }
        }
    }

    //SPS-667 jack add
    private void updateFailtran(policy_transaction__c tran){
        if(tran != null){
            tran = [select id, Status__c from Policy_Transaction__c where id =: tran.id]; // AH21323 - SPS-667 - Lawrence Wong
            //System.debug('[TMSubmitWorkRequestQueue.updateFailtran] - Policy Transaction Status (original): ' + tran.Status__c + '; (PTID: ' + tran.id + ')'); // AH21323 - SPS-667 - Lawrence Wong
            if(tran.Status__c == TMSubmitPolicyToIpasBatchable.TO_IPAS_FIALED){
                tran.Status__c = TMSubmitPolicyToIpasBatchable.TO_ILAS_AND_APPLIAN_FIALED;
            }else{
                tran.Status__c = TMSubmitPolicyToIpasBatchable.TO_APPLIAN_FIALED;
            }
            System.debug('tran.Status__c:'+tran.Status__c);
            update tran;
        }
    }
}