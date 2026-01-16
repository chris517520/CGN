/*********************************************************************************
 * Name: ServiceCalloutHelper
 *
 * Version History
 * Version           Author                 Date                      Description
 * ---------------  --------------------    -----------------------  ---------------------------------------------------------
 * V1.0             Franco                  2017-01-05               Provides functions for SendNotification from WS
 ********************************************************************************/
public class ServiceCalloutHelper extends HttpCalloutHelperAbstract{
    
    public static final String SendNotification = 'SendNotification';
    public static final String GetPolicyBranchCodeList = 'GetPolicyBranchCodeList';
    public static final String GetPolicyPlanNumberList = 'GetPolicyPlanNumberList';
    public static final String GetDiscountListBasic = 'GetDiscountListBasic';
    public static final String GetPlanInfoListBasic = 'GetPlanInfoListBasic';
    public static final String GetFilteredOFCAPhoneList = 'GetFilteredOFCAPhoneList';
    public static final String GetMasterList = 'GetMasterList';

    public HttpCalloutVO.Notification notification;
    public String policyNo;
    public String renewal;
    public String campaignCode;
    public String productCode;
    public List<String> phoneNumberList;
    //added for ClientPortal AccessLevel control
    private static User currentUser=[select id, Name, ProfileId, UserRoleId, UserName, LanguageLocaleKey, AccountId, Profile.UserLicense.Name,AccessLevel__c,Company_Code__c from User where id=:Userinfo.getUserId()];
    public String masterTypeId;
    //@param masterTypeId    1 for Country List, 2 for Nationality List, 3 for AML BLACKLIST, 4 for EMAIL OPTOUT LIST, 6 for  PHONE OPTOUT LIST
    
    public ServiceCalloutHelper(){
        this.TXName = 'TXService';
        notification = new HttpCalloutVO.Notification();
    }
    
    /**************************************************************************************
     * sendNotification
     * @param HttpCalloutVO.Notification
     * @return HttpCalloutVO.Notification
     * @decs:1.after call this function, 
     *     use HttpCalloutVO.Notification.isSuccess to see if successfully updated
     *       2.use helper.getResultInfo().resultInfoDesc to view the error message if fail to call
     **************************************************************************************/
    public HttpCalloutVO.Notification sendNotification(HttpCalloutVO.Notification notification){
        system.debug('>>>>> ServiceCalloutHelper.SendNotification >>>>>');
        this.functionName = SendNotification;
        this.notification = notification;
        List<HttpCalloutVO.Notification> nList = (List<HttpCalloutVO.Notification>)execute(new Map<String, String>());
        return nList[0];
    }

    /**************************************************************************************
     * processSendNotificationResult
     * @param Dom.document
     * @return List<HttpCalloutVO.Notification>
     * @decs:Handle the WS repsonse
     **************************************************************************************/
    public List<HttpCalloutVO.Notification> processSendNotificationResult(Dom.document doc){
        List<HttpCalloutVO.Notification> objList = new List<HttpCalloutVO.Notification>();
        this.notification.isSuccess = this.isCalloutSuccessfully && this.isResultSuccess;
        objList.add(this.notification);
        return objList;
    }

    /**************************************************************************************
     * getPolicyBranchCodeList
     * @param String
     * @return HttpCalloutVO.FullBranch
     * @decs:Call GetPolicyBranchCodeList WS
     **************************************************************************************/
    public HttpCalloutVO.FullBranch getPolicyBranchCodeList(String policyNo){
        system.debug('>>>>> ServiceCalloutHelper.GetPolicyBranchCodeList >>>>>');
        this.functionName = GetPolicyBranchCodeList;
        this.policyNo = policyNo;
        List<HttpCalloutVO.FullBranch> nList = (List<HttpCalloutVO.FullBranch>)execute(new Map<String, String>());
        return nList[0];
    }

    /**************************************************************************************
     * getPolicyBranchCodeList
     * @param String
     * @return HttpCalloutVO.FullBranch
     * @decs:Call GetPolicyBranchCodeList WS
     **************************************************************************************/
    public HttpCalloutVO.FullBranch getPolicyBranchCodeList(String policyNo,String renewal){
        system.debug('>>>>> ServiceCalloutHelper.GetPolicyBranchCodeList >>>>>');
        this.functionName = GetPolicyBranchCodeList;
        this.policyNo = policyNo;
        this.renewal = renewal;
        List<HttpCalloutVO.FullBranch> nList = (List<HttpCalloutVO.FullBranch>)execute(new Map<String, String>());
        return nList[0];
    }

    /**************************************************************************************
     * processPolicyBranchCodeListResult
     * @param Dom.document
     * @return List<HttpCalloutVO.FullBranch>
     * @decs:Handle the WS repsonse
     **************************************************************************************/
    public List<HttpCalloutVO.FullBranch> processPolicyBranchCodeListResult(Dom.document doc){
        
        system.debug('>>>>> PolicyCalloutHelper.processPolicyBranchCodeListResult >>>>>');
        List<HttpCalloutVO.FullBranch> objList = new List<HttpCalloutVO.FullBranch>();
        HttpCalloutVO.FullBranch obj = new HttpCalloutVO.FullBranch();
        obj.branchList = new List<HttpCalloutVO.Branch>();
        objList.add(obj);

        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXServiceResponse = getTXObjectResponseNode(doc);
        Dom.XmlNode oServiceNode = getChildNodeIfNotNull('OService', TXServiceResponse);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oServiceNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Policy'){
                obj.policyNumber = getChildNodeTextIfNotEmpty('PolNumber', childNode);
                List<Dom.XmlNode> branches = getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode branchNode : branches){
                    if(branchNode.getName() == 'BranchDef'){
                        HttpCalloutVO.Branch branchObj = new HttpCalloutVO.Branch();
                        branchObj.branchCode = getChildNodeTextIfNotEmpty('BranchCode', branchNode);
                        branchObj.branchDesc = getChildNodeTextIfNotEmpty('BranchDesc', branchNode);
                        obj.branchList.add(branchObj);
                    }
                }
            }
        }

        return objList;
    }

    /**************************************************************************************
     * getPolicyPlanNumberList
     * @param String
     * @return HttpCalloutVO.FullPlan
     * @decs:Call GetPolicyPlanNumberList WS to get all the policy plan number
     **************************************************************************************/
    public HttpCalloutVO.FullPlan getPolicyPlanNumberList(String policyNo){
        system.debug('>>>>> ServiceCalloutHelper.GetPolicyPlanNumberList >>>>>');
        this.functionName = GetPolicyPlanNumberList;
        this.policyNo = policyNo;
        List<HttpCalloutVO.FullPlan> nList = (List<HttpCalloutVO.FullPlan>)execute(new Map<String, String>());
        return nList[0];
    }

    /**************************************************************************************
     * getPolicyPlanNumberList
     * @param String
     * @return HttpCalloutVO.FullPlan
     * @decs:Call GetPolicyPlanNumberList WS to get all the policy plan number
     **************************************************************************************/
    public HttpCalloutVO.FullPlan getPolicyPlanNumberList(String policyNo,String renewal){
        system.debug('>>>>> ServiceCalloutHelper.GetPolicyPlanNumberList >>>>>');
        this.functionName = GetPolicyPlanNumberList;
        this.policyNo = policyNo;
        this.renewal = renewal;
        List<HttpCalloutVO.FullPlan> nList = (List<HttpCalloutVO.FullPlan>)execute(new Map<String, String>());
        return nList[0];
    }

    /**************************************************************************************
     * processPolicyPlanNumberList
     * @param Dom.document
     * @return List<HttpCalloutVO.FullPlan>
     * @decs:Handle the WS repsonse
     **************************************************************************************/
    public List<HttpCalloutVO.FullPlan> processPolicyPlanNumberList(Dom.document doc){
        
        system.debug('>>>>> PolicyCalloutHelper.processPolicyPlanNumberList >>>>>');
        List<HttpCalloutVO.FullPlan> objList = new List<HttpCalloutVO.FullPlan>();
        HttpCalloutVO.FullPlan obj = new HttpCalloutVO.FullPlan();
        obj.planList = new List<String>();
        obj.planDescList = new List<String>();  //added by Connor CP-143
        obj.planNoMap = new Map<String, String>();     // Added by Linus JR1904
        objList.add(obj);

        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXServiceResponse = getTXObjectResponseNode(doc);
        Dom.XmlNode oServiceNode = getChildNodeIfNotNull('OService', TXServiceResponse);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oServiceNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Policy'){
                obj.policyNumber = getChildNodeTextIfNotEmpty('PolNumber', childNode);
                List<Dom.XmlNode> plans = getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode planNode : plans){
                    if(planNode.getName() == 'CoverageDef'){
                        String planNo = getChildNodeTextIfNotEmpty('PlanNumber', planNode);
                        String planDesc = getChildNodeTextIfNotEmpty('PlanDesc', planNode);  //added by Connor 
                        obj.planList.add(planNo); 
                        obj.planNoMap.put(planNo, planDesc);      // Added by Linus JR1904
                        obj.planDescList.add(planDesc);  //added by Connor
                    }
                }
            }
        }

        return objList;
    }
    
    public List<HttpCalloutVO.Discount> getDiscountListBasic(String campaignCode){
        system.debug('>>>>> ServiceCalloutHelper.getDiscountListBasic >>>>>');
        this.functionName = GetDiscountListBasic;
        this.campaignCode = campaignCode;
        List<HttpCalloutVO.Discount> resultList = (List<HttpCalloutVO.Discount>)execute(new Map<String, String>());
        return resultList;
    }
    
    public List<HttpCalloutVO.Discount> processDiscountListBasic(Dom.document doc){
        system.debug('>>>>> PolicyCalloutHelper.processDiscountListBasic >>>>>');
        List<HttpCalloutVO.Discount> objList = new List<HttpCalloutVO.Discount>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXServiceResponse = getTXObjectResponseNode(doc);
        Dom.XmlNode oServiceNode = getChildNodeIfNotNull('OService', TXServiceResponse);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oServiceNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Discount'){
                HttpCalloutVO.Discount dis = new HttpCalloutVO.Discount();
                dis.discountCode = getChildNodeTextIfNotEmpty('DiscountCode', childNode);
                dis.discountStartYear = getChildNodeIntegerIfNotEmpty('DiscountStartYear', childNode);
                dis.discountDuration = getChildNodeIntegerIfNotEmpty('DiscountDuration', childNode);
                dis.discountPercentage = getChildNodeDecimalIfNotEmpty('DiscountPercentage', childNode);
                objList.add(dis);
            }
        }
        return objList;
    }
    
    public List<HttpCalloutVO.Product> getPlanInfoListBasic(String productCode){
        system.debug('>>>>> ServiceCalloutHelper.GetPlanInfoListBasic >>>>>');
        this.functionName = GetPlanInfoListBasic;
        this.productCode = productCode;
        List<HttpCalloutVO.Product> resultList = (List<HttpCalloutVO.Product>)execute(new Map<String, String>());
        return resultList;
    }
    
    public List<HttpCalloutVO.Product> processPlanInfoListBasic(Dom.document doc){
        system.debug('>>>>> PolicyCalloutHelper.processPlanInfoListBasic >>>>>');
        List<HttpCalloutVO.Product> objList = new List<HttpCalloutVO.Product>();
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXServiceResponse = getTXObjectResponseNode(doc);
        Dom.XmlNode oServiceNode = getChildNodeIfNotNull('OService', TXServiceResponse);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oServiceNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Product'){
                HttpCalloutVO.Product prod = new HttpCalloutVO.Product();
                prod.productCode = getChildNodeTextIfNotEmpty('ProductCode', childNode);
                List<Dom.XmlNode> productChildNodeList = getChildElementsIfNotNull(childNode);
                for(Dom.XmlNode productChildNode : productChildNodeList){
                    if(productChildNode.getName() == 'Benefit'){
                        HttpCalloutVO.Benefit bene = new HttpCalloutVO.Benefit();
                        bene.benefitLevelName = getChildNodeTextIfNotEmpty('BenefitLevelName', productChildNode);
                        bene.BenefitLevelCode = getChildNodeTextIfNotEmpty('BenefitLevelCode', productChildNode);
                        bene.planCode = getChildNodeTextIfNotEmpty('PlanCode', productChildNode);
                        bene.isAvailable = getChildNodeBooleanIfNotEmpty('AvailableInd', productChildNode);
                        
                        List<Dom.XmlNode> benefitChildNodeList = getChildElementsIfNotNull(productChildNode);
                        for(Dom.XmlNode benefitChildNode : benefitChildNodeList){
                            if(benefitChildNode.getName() == 'EligibleAge'){
                                HttpCalloutVO.EligibleAge eli = new HttpCalloutVO.EligibleAge();
                                eli.MinAgeYear = getChildNodeIntegerIfNotEmpty('MinAgeYear', benefitChildNode);
                                eli.MinAgeDay = getChildNodeIntegerIfNotEmpty('MinAgeDay', benefitChildNode);
                                eli.MaxAgeYear = getChildNodeIntegerIfNotEmpty('MaxAgeYear', benefitChildNode);
                                eli.MaxAgeDay = getChildNodeIntegerIfNotEmpty('MaxAgeDay', benefitChildNode);
                                eli.RelationRoleCode = getChildNodeTextIfNotEmpty('RelationRoleCode', benefitChildNode);
                                
                                bene.eligibleAgeList.add(eli);
                            }
                            if(benefitChildNode.getName() == 'BenefitDetail'){
                                HttpCalloutVO.BenefitDetail bd = new HttpCalloutVO.BenefitDetail();
                                bd.sequenceNumber = getChildNodeIntegerIfNotEmpty('SequenceNumber', benefitChildNode);
                                bd.description = getChildNodeTextIfNotEmpty('Description', benefitChildNode);
                                bd.amount = getChildNodeDecimalIfNotEmpty('Amount', benefitChildNode);
                                
                                bene.benefitDetailList.add(bd);
                            }
                        }
                        prod.benefitList.add(bene);
                    }
                    if(productChildNode.getName() == 'Rider'){
                        HttpCalloutVO.Rider rider = new HttpCalloutVO.Rider();
                        rider.riderName = getChildNodeTextIfNotEmpty('RiderName', productChildNode);
                        rider.riderCode = getChildNodeTextIfNotEmpty('RiderCode', productChildNode);
                        rider.benefitLevelCode = getChildNodeTextIfNotEmpty('BenefitLevelCode', productChildNode);
                        rider.isUWProduct = getChildNodeBooleanIfNotEmpty('UWProductInd', productChildNode);
                        rider.isAvailable = getChildNodeBooleanIfNotEmpty('AvailableInd', productChildNode);
                        rider.isSameLevel = getChildNodeBooleanIfNotEmpty('SameLevelInd', productChildNode);
                        
                        List<Dom.XmlNode> riderChildNodeList = getChildElementsIfNotNull(productChildNode);
                        for(Dom.XmlNode riderChildNode : riderChildNodeList){
                            if(riderChildNode.getName() == 'EligibleAge'){
                                HttpCalloutVO.EligibleAge eli = new HttpCalloutVO.EligibleAge();
                                eli.MinAgeYear = getChildNodeIntegerIfNotEmpty('MinAgeYear', riderChildNode);
                                eli.MinAgeDay = getChildNodeIntegerIfNotEmpty('MinAgeDay', riderChildNode);
                                eli.MaxAgeYear = getChildNodeIntegerIfNotEmpty('MaxAgeYear', riderChildNode);
                                eli.MaxAgeDay = getChildNodeIntegerIfNotEmpty('MaxAgeDay', riderChildNode);
                                eli.RelationRoleCode = getChildNodeTextIfNotEmpty('RelationRoleCode', riderChildNode);
                                
                                rider.eligibleAgeList.add(eli);
                            }
                            if(riderChildNode.getName() == 'BenefitDetail'){
                                HttpCalloutVO.BenefitDetail bd = new HttpCalloutVO.BenefitDetail();
                                bd.sequenceNumber = getChildNodeIntegerIfNotEmpty('SequenceNumber', riderChildNode);
                                bd.description = getChildNodeTextIfNotEmpty('Description', riderChildNode);
                                bd.amount = getChildNodeDecimalIfNotEmpty('Amount', riderChildNode);
                                
                                rider.benefitDetailList.add(bd);
                            }
                        }
                        prod.riderList.add(rider);
                    }
                }
                objList.add(prod);
            }
        }
        return objList;
    }
    
    public List<String> getFilteredOFCAPhoneList(List<String> phoneNumberList){
        system.debug('>>>>> ServiceCalloutHelper.GetFilteredOFCAPhoneList >>>>>');
        this.functionName = GetFilteredOFCAPhoneList;
        this.phoneNumberList = phoneNumberList;
        List<String> resultList = (List<String>)execute(new Map<String, String>());
        return resultList;
    }
    
    public List<String> processFilteredOFCAPhoneList(Dom.document doc){
        System.debug('>>>>> ServiceCalloutHelper.processFilteredOFCAPhoneList >>>>>');
        List<String> strList = new List<String>();
        if(!this.isCalloutSuccessfully){
            return strList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXServiceResponse = getTXObjectResponseNode(doc);
        Dom.XmlNode oServiceNode = getChildNodeIfNotNull('OService', TXServiceResponse);
        Dom.XmlNode SimplePhoneNumberNode = getChildNodeIfNotNull('SimplePhoneNumber', oServiceNode);
        System.debug('SimplePhoneNumberNode: ' + SimplePhoneNumberNode);
        List<Dom.XmlNode> valueNodes = getChildElementsIfNotNull(SimplePhoneNumberNode);        
        System.debug('valueNodes: ' + valueNodes);
        for(Dom.XmlNode valueNode : valueNodes){
            if(valueNode != null){
                String value = valueNode.getText();
                System.debug('value: ' + value);
                strList.add(value);
            }
        }
        System.debug('strList: ' + strList);
        return strList;
        
    }
    
    public List<HttpCalloutVO.MasterList> getMasterList(String masterTypeId){
        system.debug('>>>>> ServiceCalloutHelper.getMasterList >>>>>');
        this.functionName = GetMasterList;
        this.masterTypeId = masterTypeId;
        List<HttpCalloutVO.MasterList> resultList = (List<HttpCalloutVO.MasterList>)execute(new Map<String, String>());
        return resultList;
    }
    
    public List<HttpCalloutVO.MasterList> processMasterList(Dom.document doc){
        System.debug('>>>>> ServiceCalloutHelper.processMasterList >>>>>');
        List<HttpCalloutVO.MasterList> masterList = new List<HttpCalloutVO.MasterList>();
        if(!this.isCalloutSuccessfully){
            return masterList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXServiceResponse = getTXObjectResponseNode(doc);
        Dom.XmlNode oServiceNode = getChildNodeIfNotNull('OService', TXServiceResponse);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oServiceNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Master'){
                HttpCalloutVO.MasterList m = new HttpCalloutVO.MasterList();
                m.typeId = getChildNodeTextIfNotEmpty('MasterTypeId',childNode);
                m.code = getChildNodeTextIfNotEmpty('MasterCode',childNode);
                m.name = getChildNodeTextIfNotEmpty('MasterName',childNode);
                masterList.add(m);
            }
        }
        return masterList;
        
    }
    
    public String buildNotificationNode(){
        String result = '';
        if(this.notification != null){
            String userLoginName = Userinfo.getUserName();
            result = '<Notification id="notification001">'
                   + '    <SourceCode>' + processXMLEscape(this.notification.sourceCode, '') + '</SourceCode>'
                   + '    <TriggerId>' + processXMLEscape(this.notification.triggerId, '') + '</TriggerId>'
                   + '    <PolNumber>' + processXMLEscape(this.notification.polNumber, '') + '</PolNumber>'
                   + '    <GovtID>' + processXMLEscape(this.notification.ssn, '') + '</GovtID>'
                   + '    <UserLoginName>' + processXMLEscape(userLoginName, '') + '</UserLoginName>'
                   + '</Notification>';
        }
        return result;   
    }

    /**************************************************************************************
     * buildBranchCodeList
     * @return String
     * @decs:Build the policy node
     **************************************************************************************/
    public String buildBranchCodeList(){
        String result = '';
        if(this.policyNo != null){
            result = '<Policy id = "policy001">'
                   + '   <PolNumber>' + this.policyNo.escapeXML() + '</PolNumber>';
            if (this.renewal != null) {
                result += '   <RenewalPosition>' + this.renewal.escapeXML() + '</RenewalPosition>';
            }
            result+= '</Policy>';
        }
        return result; 
    }

    /**************************************************************************************
     * buildPolicyPlanNumberList
     * @return String
     * @decs:Build the policy node
     **************************************************************************************/
    public String buildPolicyPlanNumberList(){
        String result = '';
        if(this.policyNo != null){
            result = '<Policy id = "policy001">'
                   + '   <PolNumber>' + this.policyNo.escapeXML() + '</PolNumber>';
            if (this.renewal != null) {
                result += '   <RenewalPosition>' + this.renewal.escapeXML() + '</RenewalPosition>';
            }
            result+= '</Policy>';
        }
        return result; 
    }
    
    public String buildDiscountListBasic(){
        String result = '';
        if(this.campaignCode != null){
            result = '<Campaign id="campaign001">'
                   + '   <CampaignCode>' + this.campaignCode.escapeXML() + '</CampaignCode>'
                   + '</Campaign>';
        }
        return result; 
    }
    
    public String buildPlanInfoListBasic(){
        String result = '';
        if(this.productCode != null){
            result = '<Product id="product001">'
                   + '   <ProductCode>' + this.productCode.escapeXML() + '</ProductCode>'
                   + '</Product>';
        }
        return result; 
    }
    
    public String buildFilteredOFCAPhoneListBasic(){
        String result = '';
        if(this.phoneNumberList.size() > 0){
            result += '<SimplePhoneNumber numberOfValues="' + this.phoneNumberList.size() +'">';
            for(String value : phoneNumberList){
                result += '   <value>' + value.escapeXML() + '</value>';
            }
            result += '</SimplePhoneNumber>';
        }
        return result; 
    }
        
    public String buildMasterListBasic(){
        String result = '';
        if(this.masterTypeId != null){
                result += '<Master id="master001">';
                result += '   <MasterTypeId>' + this.masterTypeId.escapeXML() + '</MasterTypeId>';
                result += '</Master>';
        }
        return result; 
    }

    public String buildServiceRequestNode(){
        
        String result;

        if(this.functionName == SendNotification){
            result = this.buildNotificationNode();
        } else if (this.functionName == GetPolicyBranchCodeList){
            result = this.buildBranchCodeList();
        } else if (this.functionName == GetPolicyPlanNumberList){
            result = this.buildPolicyPlanNumberList();
        } else if (this.functionName == GetDiscountListBasic){
            result = this.buildDiscountListBasic();
        } else if (this.functionName == GetPlanInfoListBasic){
            result = this.buildPlanInfoListBasic();
        } else if (this.functionName == GetFilteredOFCAPhoneList){
            result = this.buildFilteredOFCAPhoneListBasic();
        } else if (this.functionName == GetMasterList){
            result = this.buildMasterListBasic();
        } 

        return result;
    }
    
    /**************************************************************************************
     * buildTXObjectRequestNode
     * @return String
     * @decs:Build the TXServiceRequest node
     **************************************************************************************/
    protected override String buildTXObjectRequestNode(){
        system.debug('>>>>> parameters : ' + this.notification);
        String datetimeStr = DateTime.now().formatGmt('yyyy-MM-dd HH:mm:ss');
        String TXObjectRequest = '';
        String strAccessLevel = '';
        
        String userAccess = '';
        userAccess = currentUser.AccessLevel__c;
        
        if (String.isNotBlank(userAccess)) {
            if (this.functionName == GetPolicyBranchCodeList||this.functionName == GetPolicyPlanNumberList) { //CTUI-220-20220622-Kirk
                strAccessLevel   = '    <AccessLevel>' + userAccess + '</AccessLevel>';
            }
        }
        TXObjectRequest = '<TXServiceRequest id="Request001">'
                        + '   <TransRefGUID>' + GuidUtil.NewGuid() + '</TransRefGUID>'
                        + '   <TransExeDate>' + datetimeStr.substring(0, 10) + '</TransExeDate>'
                        + '   <TransExeTime>' + datetimeStr.substring(11) + '</TransExeTime>'
                        + strAccessLevel
                        + '   <OService>'
                        +         this.currentLanguageNode
                        + '       <RoleId>' + this.roleID+ '</RoleId>' 
                        +         buildServiceRequestNode()
                        + '   </OService>'
                        + '</TXServiceRequest>';
        return TXObjectRequest;
    }
  
    /**************************************************************************************
     * Dom.document
     * @return List<Object>
     * @decs:According to the results to call different method
     **************************************************************************************/
    public override List<Object> processResultFromResponse(Dom.document doc) {
        if(this.functionName == SendNotification){
            return processSendNotificationResult(doc);
        } else if(this.functionName == GetPolicyBranchCodeList){
            return processPolicyBranchCodeListResult(doc);
        } else if(this.functionName == GetPolicyPlanNumberList){
            return processPolicyPlanNumberList(doc);
        } else if(this.functionName == GetDiscountListBasic){
            return processDiscountListBasic(doc);
        } else if(this.functionName == GetPlanInfoListBasic){
            return processPlanInfoListBasic(doc);
        } else if(this.functionName == GetFilteredOFCAPhoneList){
            return processFilteredOFCAPhoneList(doc);
        } else if(this.functionName == GetMasterList){
            return processMasterList(doc);
        } else {
            return new List<Object>();
        }
    }
}