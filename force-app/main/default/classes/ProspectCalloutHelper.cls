/********************************************************************************
Apex Class Name - ProspectCalloutHelper
Version - 1.0
Created Date - December 25, 2017
@description Controlloer for prospect WS

Modification Log : 
--------------------------------------------------------------------------------

*Version    Developer        Date                    Description
* ------    -----------     ------------            -----------------------
* 1.0       ZaiHong Qing     2017/12/25              Original Version
 ********************************************************************************/ 

public class ProspectCalloutHelper extends HttpCalloutHelperAbstract {

    public static final String GetProspectListBasicByCriteria = 'GetProspectListBasicByCriteria';
    public static final String GetProspectBasic = 'GetProspectBasic';

    public Map<String, String> paramsMap {get;set;}
    public String userLanguage = '';
    public String TXLifeRequest = '';

    public ProspectCalloutHelper(){
        this.TXName = 'TXLife';
        this.paramsMap = new Map<String, String>();
        this.userLanguage = UserInfo.getLanguage();
    }
    
    public ProspectCalloutHelper(String roleId){
        this();
        this.roleId = roleId;
    }
    
    /***************************************************************
     * getProspectBasic
     * @decs:Call GetProspectBasic WS to get prospect basic info
     * @param String,@param String
     * @return List<HttpCalloutVO.ProspectDetail>
     ***************************************************************/
    public List<HttpCalloutVO.ProspectDetail> getProspectBasic(String activityId,String activityType){ 
        //system.debug('>>>>> ProspectCalloutHelper.getProspectBasic >>>>>');
        this.functionName = ProspectCalloutHelper.GetProspectBasic;
        paramsMap = new Map<String, String>();
        paramsMap.put('activityId', activityId);
        paramsMap.put('activityType', activityType);
        return (List<HttpCalloutVO.ProspectDetail>)execute(new Map<String, String>());
    }

    /***************************************************************
     * getProspectListBasicByCriteria
     * @decs:Call GetProspectListBasicByCriteria WS to get prospect list
     * @param HttpCalloutVO.PolicyRequest
     * @return List<HttpCalloutVO.Prospect>
     ***************************************************************/
    public List<HttpCalloutVO.Prospect> getProspectListBasicByCriteria(HttpCalloutVO.PolicyRequest request){ 
        //system.debug('>>>>> ProspectCalloutHelper.getProspectListBasicByCriteria >>>>>');
        this.functionName = ProspectCalloutHelper.GetProspectListBasicByCriteria;
        paramsMap = new Map<String, String>();
        paramsMap.put('PolicyHolderName', String.isNotBlank(request.holderName) ? request.holderName : '');
        paramsMap.put('PersonInsuredName', String.isNotBlank(request.insuredName) ? request.insuredName : '');
        paramsMap.put('PersonInsuredHKID', String.isNotBlank(request.insuredId) ? request.insuredId : '');
        paramsMap.put('PolicyHolderHKID', String.isNotBlank(request.holderId) ? request.holderId: '');
        
        paramsMap.put('SubmissionDateTimeFrom', String.isNotBlank(request.submissionDateTimeFrom) ? request.submissionDateTimeFrom: '');
        paramsMap.put('SubmissionDateTimeTo', String.isNotBlank(request.submissionDateTimeTo) ? request.submissionDateTimeTo: '');
        paramsMap.put('SortOrder', String.isNotBlank(request.SortOrder) ? request.SortOrder: '');
        return (List<HttpCalloutVO.Prospect>)execute(new Map<String, String>());
    }
    
    /***************************************************************
     * getProspectListBasicByCriteria
     * @decs:Build WS request node
     * @return String
     ***************************************************************/
    protected override String buildTXObjectRequestNode(){
        //system.debug('>>>>> parameters : ' + paramsMap);
        if(paramsMap != null && paramsMap.size() > 0){
            for(String key : paramsMap.keySet()){
                if(String.isNotBlank(paramsMap.get(key))){
                    paramsMap.put(key, paramsMap.get(key).escapeXML());
                }
            }
        }
        //system.debug('>>>>> parameters after escapeXML : ' + paramsMap);
        String datetimeStr = DateTime.now().formatGmt('yyyy-MM-dd HH:mm:ss');
        
        String  TXLifeRequest = '';
        
        if(this.functionName == ProspectCalloutHelper.GetProspectListBasicByCriteria){
            TXLifeRequest   = '<TXLifeRequest id="Request001">'
                            + '    <TransRefGUID>' + GuidUtil.NewGuid() + '</TransRefGUID>'
                            + '    <TransType tc="302">Holding Search</TransType>'
                            + '    <TransSubType tc="30200">Holding Search</TransSubType>'
                            + '    <TransExeDate>' + datetimeStr.substring(0, 10) + '</TransExeDate>'
                            + '    <TransExeTime>' + datetimeStr.substring(11) + '</TransExeTime>'
                            + '    <InquiryLevel tc="3">Target Object, all relations, and all related objects</InquiryLevel>'
                            + '    <MaxRecords>' + this.maxRecords + '</MaxRecords>'
                            + '    <StartRecord>' + this.startRecord + '</StartRecord>'                      
                            +      buildCriteriaExpressionNode(paramsMap)                       
                            + '</TXLifeRequest>';
        }
        
        if(this.functionName == ProspectCalloutHelper.GetProspectBasic){
            TXLifeRequest   = '<TXLifeRequest id="Request001">'
                            + '    <TransRefGUID>' + GuidUtil.NewGuid() + '</TransRefGUID>'
                            + '    <TransType tc="203">Holding Inquiry</TransType>'
                            + '    <TransSubType tc="20300">Holding Inquiry</TransSubType>'
                            + '    <TransExeDate>' + datetimeStr.substring(0, 10) + '</TransExeDate>'
                            + '    <TransExeTime>' + datetimeStr.substring(11) + '</TransExeTime>'
                            + '    <InquiryLevel tc="3">Target Object, all relations, and all related objects</InquiryLevel>'
                            +      buildCriteriaExpressionNode(paramsMap)                       
                            + '</TXLifeRequest>';
        }
        return TXLifeRequest;
    }

    /***************************************************************
     * buildCriteriaExpressionNode
     * @param Map<String, String>
     * @decs:Build criteria expression node
     * @return String
     ***************************************************************/
    public String buildCriteriaExpressionNode(Map<String, String> paramsMap){      
        String criterias = '';
        String holderFullName = paramsMap.get('PolicyHolderName') == null ? '' : paramsMap.get('PolicyHolderName');
        String insuredFullName = paramsMap.get('PersonInsuredName') == null ? '' : paramsMap.get('PersonInsuredName');
        String insuredGovtID = paramsMap.get('PersonInsuredHKID') == null ? '' : paramsMap.get('PersonInsuredHKID');
        String holderGovtID = paramsMap.get('PolicyHolderHKID') == null ? '' : paramsMap.get('PolicyHolderHKID');
        
        String submissionDateTimeFrom = paramsMap.get('SubmissionDateTimeFrom') == null ? '' : paramsMap.get('SubmissionDateTimeFrom');
        String submissionDateTimeTo = paramsMap.get('SubmissionDateTimeTo') == null ? '' : paramsMap.get('SubmissionDateTimeTo');

        String activityId = paramsMap.get('activityId') == null ? '' : paramsMap.get('activityId');
        String activity = paramsMap.get('activityType') == null ? '' : paramsMap.get('activityType');
        
        
        String relationRoleCode = paramsMap.get('RelationRoleCode') == null ? '' : paramsMap.get('RelationRoleCode'); 
        String sortOrder = paramsMap.get('SortOrder') == null ? 'A' : paramsMap.get('SortOrder');
        
        String holderGovtIDCriteria = '';
        if(String.isNotBlank(holderGovtID)){
            holderGovtIDCriteria = '<Criteria>'
                                 + '    <ObjectType tc="6">Party</ObjectType>'
                                 + '    <PropertyName>HolderGovtID</PropertyName>'
                                 + '    <PropertyValue>' + holderGovtID + '</PropertyValue>'
                                 + '    <Operation tc="1">Equal</Operation>'
                                 + '</Criteria>';
        }
        
        String holderFullNameCriteria = '';
        if(String.isNotBlank(holderFullName)){
            holderFullNameCriteria = '<Criteria>'
                                   + '    <ObjectType tc="6">Party</ObjectType>'
                                   + '    <PropertyName>HolderName</PropertyName>'
                                   + '    <PropertyValue>' + holderFullName + '</PropertyValue>'
                                   + '    <Operation tc="9">Wildcard match</Operation>'
                                   + '</Criteria>';
        }

        String insuredGovtIDCriteria = '';
        if(String.isNotBlank(insuredGovtID)){
            insuredGovtIDCriteria = '<Criteria>'
                                  + '    <ObjectType tc="6">Party</ObjectType>'
                                  + '    <PropertyName>GovtID</PropertyName>'
                                  + '    <PropertyValue>' + insuredGovtID + '</PropertyValue>'
                                  + '    <Operation tc="1">Equal</Operation>'
                                  + '</Criteria>';
        }
        
        String insuredFullNameCriteria = '';
        if(String.isNotBlank(insuredFullName)){
            insuredFullNameCriteria = '<Criteria>'
                                    + '    <ObjectType tc="6">Party</ObjectType>'
                                    + '    <PropertyName>FullName</PropertyName>'
                                    + '    <PropertyValue>' + insuredFullName + '</PropertyValue>'
                                    + '    <Operation tc="9">Wildcard match</Operation>'
                                    + '</Criteria>';
        }
    
    
        String relationRoleCodeCriteria = '';
        if(String.isNotBlank(relationRoleCode)){
            relationRoleCodeCriteria = '<Criteria>'
                                    + '    <ObjectType tc="8">Relation</ObjectType>'
                                    + '    <PropertyName>RelationRoleCode</PropertyName>'
                                    + '    <PropertyValue tc="' + relationRoleCode + '">' + PersonCalloutHelper.RelationShipMap.get(paramsMap.get('RelationRole')) + '</PropertyValue>'
                                    + '    <Operation tc="1">equal to</Operation>'
                                    + '</Criteria>';
        }
        
        String submissionDateTimeFromCriteria = '';
        if(String.isNotBlank(submissionDateTimeFrom)){
            submissionDateTimeFromCriteria = '<Criteria>'
                                            + '    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                            + '    <PropertyName>SubmissionDateTime</PropertyName>'
                                            + '    <PropertyValue>' + submissionDateTimeFrom + '</PropertyValue>'
                                            + '    <Operation tc="6">Greater than or equal to</Operation>'
                                            + '</Criteria>';
        }
        
        String submissionDateTimeToCriteria = '';
        if(String.isNotBlank(submissionDateTimeTo)){
            submissionDateTimeToCriteria = '<Criteria>'
                                            + '    <ObjectType tc="252">OLifEExtension</ObjectType>'
                                            + '    <PropertyName>SubmissionDateTime</PropertyName>'
                                            + '    <PropertyValue>' + submissionDateTimeTo + '</PropertyValue>'
                                            + '    <Operation tc="5">Less than or equal to</Operation>'
                                            + '</Criteria>';
        }
        
        String insuredCriteriaExpression = '';
        if(String.isNotBlank(insuredGovtIDCriteria) || String.isNotBlank(insuredFullNameCriteria) 
            || String.isNotBlank(submissionDateTimeFromCriteria) || String.isNotBlank(submissionDateTimeToCriteria)){
            insuredCriteriaExpression = '<CriteriaOperator tc="2">And</CriteriaOperator>'
                                      +      insuredGovtIDCriteria
                                      +      insuredFullNameCriteria
                                      +      submissionDateTimeFromCriteria
                                      +      submissionDateTimeToCriteria;
        }

        String sortOrderCriteria = '';              
        if(String.isNotBlank(sortOrder)){
            if(sortOrder.equalsIgnoreCase('a')){
                sortOrder ='A';
            }
            if(sortOrder.equalsIgnoreCase('d')){
                sortOrder ='D';
            }
            sortOrderCriteria = '<SortOrder>'+sortOrder+'</SortOrder>';
        }
        
        if(this.functionName == ProspectCalloutHelper.GetProspectListBasicByCriteria){
            criterias  += '<CriteriaExpression>'
                        + '    <CriteriaOperator tc="2">And</CriteriaOperator>'
                        +      holderGovtIDCriteria
                        +      holderFullNameCriteria 
                        +      insuredGovtIDCriteria 
                        +      insuredFullNameCriteria
                        +      submissionDateTimeFromCriteria 
                        +      submissionDateTimeToCriteria 
                        + '</CriteriaExpression>'
                        + '<OLifE>'
                        +      this.currentLanguageNode
                        + '    <OLifEExtension VendorCode="525">'
                        + '        <RoleId>' + this.roleID + '</RoleId>'
                        +          sortOrderCriteria 
                        + '        <StreamSource>' + this.roleID + '</StreamSource>'
                        + '    </OLifEExtension>'                                           
                        + '</OLifE>';     
        }
        if(this.functionName == ProspectCalloutHelper.GetProspectBasic){
            criterias  += '<OLifE>'
                        +      this.currentLanguageNode
                        + '    <Holding id="Holding001">'
                        + '        <OLifEExtension VendorCode="525">'
                        + '            <ActivityId>' + activityId + '</ActivityId>'
                        + '            <ActivityType>' + activity + '</ActivityType>'
                        + '        </OLifEExtension>'
                        + '    </Holding>'
                        + '    <OLifEExtension VendorCode="525">'
                        + '        <RoleId>' + this.roleID + '</RoleId>'                        
                        + '    </OLifEExtension>'                                           
                        + '</OLifE>'; 
        }
        return criterias;
    }
    
    public String getProspectIDCriteria(Map<String, String> paramsMap){
        if(this.functionName == ProspectCalloutHelper.GetProspectBasic){
           String prospectId = paramsMap.get('ProspectId') == null ? '' : paramsMap.get('ProspectId');             
           String prospectIdCriteria = '';
           if(String.isNotBlank(prospectId)){
                prospectIdCriteria = '<CriteriaExpression>'
                                      + '<CriteriaOperator tc="2">And</CriteriaOperator>'
                                      + '<Criteria>'
                                      + '    <ObjectType tc="6">Party</ObjectType>'
                                      + '    <PropertyName>ProspectID</PropertyName>'
                                      + '    <PropertyValue>' + prospectId + '</PropertyValue>'
                                      + '    <Operation tc="1">Equal</Operation>'
                                      + '</Criteria>';
           }
            return prospectIdCriteria;
        }else{
            return '';
        }
    }
    
    /***************************************************************
     * processResultFromResponse
     * @param Dom.document
     * @decs:Handle the WS repsonse
     * @return List<Object>
     ***************************************************************/
    public override List<Object> processResultFromResponse(Dom.document doc){
        if(this.functionName == ProspectCalloutHelper.GetProspectListBasicByCriteria){
            return processProspectListBasicByCriteriaResult(doc);
        } else if(this.functionName == ProspectCalloutHelper.GetProspectBasic){
            return processProspectBasicResult(doc);
        }else {
            return new List<Object>();
        }
    }

    /***************************************************************
     * processProspectListBasicByCriteriaResult
     * @param Dom.document
     * @decs:Handle the getProspectListBasicByCriteria WS repsonse
     * @return List<HttpCalloutVO.Prospect>
     ***************************************************************/
    public List<HttpCalloutVO.Prospect> processProspectListBasicByCriteriaResult(Dom.document doc){
        //system.debug('>>>>> ProspectCalloutHelper.processProspectListBasicByCriteriaResult >>>>>');
        List<HttpCalloutVO.Prospect> objList = new List<HttpCalloutVO.Prospect>();        
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode = getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode = getChildNodeIfNotNull('OLifE', TXLifeResponseNode);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oLifeNode);
        Map<String,HttpCalloutVO.Prospect> holdingMap = new Map<String,HttpCalloutVO.Prospect>();
        Map<String,HttpCalloutVO.Person> partyMap = new Map<String,HttpCalloutVO.Person>();
        List<HttpCalloutVO.Relation> relationList = new List<HttpCalloutVO.Relation>();
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Holding'){
                String holdingId = childNode.getAttributeValue('id', null);
                String holdingTypeCode = getChildNodeAttributeIfNotEmpty('HoldingTypeCode', 'tc', childNode);
                if(String.isNotBlank(holdingTypeCode) && holdingTypeCode == '2'){
                    HttpCalloutVO.Prospect prospect = new HttpCalloutVO.Prospect();
                    Dom.XmlNode policyNode = getChildNodeIfNotNull('Policy', childNode);
                    if(policyNode != null){
                        prospect.policyId = policyNode.getAttributeValue('id', null);
                        prospect.planName = getChildNodeTextIfNotEmpty('PlanName', policyNode);
                        prospect.productCode = getChildNodeTextIfNotEmpty('ProductCode', policyNode);
                        prospect.polNumber = getChildNodeTextIfNotEmpty('PolNumber', policyNode); // added for DPSP-118;
                    }
                    
                    Dom.XmlNode OLifEExtensionNode = getChildNodeIfNotNull('OLifEExtension', childNode);
                    if(OLifEExtensionNode != null){
                        prospect.activityId = Integer.Valueof(getChildNodeDecimalIfNotEmpty('ActivityId', OLifEExtensionNode));
                        prospect.activityType = getChildNodeTextIfNotEmpty('ActivityType', OLifEExtensionNode);
                        prospect.submissionDate = getChildNodeDateIfNotEmpty('SubmissionDate', OLifEExtensionNode,'yyyy-MM-dd');
                        String submissionTime = getChildNodeTextIfNotEmpty('SubmissionTime', OLifEExtensionNode);
                        if(submissionTime!=null){
                            List<String> timeList = submissionTime.split(':');
                            if(timeList.size()>2){
                                prospect.submissionTime = Time.newInstance(Integer.Valueof(timeList[0]), Integer.Valueof(timeList[1]), Integer.Valueof(timeList[2]), 0);
                            }
                        }
                    }
                    
                    holdingMap.put(holdingId,prospect);
                }
            }else if(childNode.getName() == 'Party'){
                HttpCalloutVO.Person person = new HttpCalloutVO.Person();
                String partyId = childNode.getAttributeValue('id', null);
                String partyTypeCode= getChildNodeAttributeIfNotEmpty('PartyTypeCode', 'tc', childNode);
                if(partyTypeCode == '1'){ //Person                    
                    person.fullName = getChildNodeTextIfNotEmpty('FullName', childNode);                   
                    person.ssnNumber = getChildNodeTextIfNotEmpty('GovtID', childNode);
                    Dom.XmlNode personNode = getChildNodeIfNotNull('Person', childNode);
                    person.personId = personNode.getAttributeValue('id', null);
                    person.firstName = getChildNodeTextIfNotEmpty('FirstName', personNode);
                    person.lastName = getChildNodeTextIfNotEmpty('LastName', personNode);
                    person.gender = getChildNodeTextIfNotEmpty('Gender', personNode);
                    person.genderCode = getChildNodeAttributeIfNotEmpty('Gender', 'tc', personNode);
                    person.birthDate = getChildNodeTextIfNotEmpty('BirthDate', personNode);                    
                    person.birthDateInDate = getChildNodeDateIfNotEmpty('BirthDate', personNode, 'yyyy-MM-dd');  
                    partyMap.put(partyId,person);
                }
            }else if(childNode.getName() == 'Relation'){
                HttpCalloutVO.Relation relation = new HttpCalloutVO.Relation();
                relation.id = childNode.getAttributeValue('id', null);
                relation.OriginatingObjectID = childNode.getAttributeValue('OriginatingObjectID', null);
                relation.RelatedObjectID = childNode.getAttributeValue('RelatedObjectID', null);
                relation.OriginatingObjectType = getChildNodeTextIfNotEmpty('OriginatingObjectType', childNode);
                relation.OriginatingObjectCode = getChildNodeAttributeIfNotEmpty('OriginatingObjectType', 'tc', childNode);
                relation.RelatedObjectType = getChildNodeTextIfNotEmpty('RelatedObjectType', childNode);
                relation.RelatedObjectCode = getChildNodeAttributeIfNotEmpty('RelatedObjectType', 'tc', childNode);
                relation.RelationRoleCode = getChildNodeAttributeIfNotEmpty('RelationRoleCode', 'tc', childNode);
                relation.RelationRoleType = getChildNodeTextIfNotEmpty('RelationRoleCode', childNode);
                relationList.add(relation);
            }
        }
        for(HttpCalloutVO.Relation relation : relationList){
            HttpCalloutVO.Prospect prospect = holdingMap.get(relation.OriginatingObjectID);
            HttpCalloutVO.Person party = partyMap.get(relation.RelatedObjectID);
            if(relation.RelationRoleCode == '8'){ // Holder                    
                prospect.holderDetail = party;
            }else if (relation.RelationRoleCode == '32'){ // insured
                prospect.insuredDetail = party;
            }else if (relation.RelationRoleCode == '34'){ // beneficiary
                prospect.beneficiaryDetail = party;
            }
            holdingMap.put(relation.OriginatingObjectID,prospect);
        }
        
        for(HttpCalloutVO.Prospect p : holdingMap.values()){
            objList.add(p);
        }
        //system.debug('>>>>> List<HttpCalloutVO.Prospect> >>>>> ' + objList.size());
        return objList;
    }   

    /***************************************************************
     * processProspectBasicResult
     * @param Dom.document
     * @decs:Handle the getProspectBasic WS repsonse
     * @return List<HttpCalloutVO.ProspectDetail>
     ***************************************************************/
    public List<HttpCalloutVO.ProspectDetail> processProspectBasicResult(Dom.document doc){
        //system.debug('>>>>> ProspectCalloutHelper.processProspectBasicResult >>>>>');        
        
        Map<String,HttpCalloutVO.Person> partyMap = new Map<String,HttpCalloutVO.Person>();
        List<HttpCalloutVO.Relation> relationList = new List<HttpCalloutVO.Relation>();
        
        HttpCalloutVO.ProspectDetail prospectDetail = new HttpCalloutVO.ProspectDetail();   
        List<HttpCalloutVO.ProspectDetail> objList = new List<HttpCalloutVO.ProspectDetail>();        
        if(!this.isCalloutSuccessfully){
            return objList;
        }
        
        Dom.XmlNode root = doc.getRootElement();
        Dom.XmlNode TXLifeResponseNode = getTXObjectResponseNode(doc);
        Dom.XmlNode oLifeNode = getChildNodeIfNotNull('OLifE', TXLifeResponseNode);
        List<Dom.XmlNode> childNodes = getChildElementsIfNotNull(oLifeNode);
        for(Dom.XmlNode childNode : childNodes){
            if(childNode.getName() == 'Holding'){                              
                String holdingTypeCode = getChildNodeAttributeIfNotEmpty('HoldingTypeCode', 'tc', childNode);
                
                if(String.isNotBlank(holdingTypeCode) && holdingTypeCode == '2'){
                    Dom.XmlNode policyNode = getChildNodeIfNotNull('Policy', childNode);
                    if(policyNode != null){
                        HttpCalloutVO.Policy policy = new HttpCalloutVO.Policy();                                          
                        policy.policyNumber = getChildNodeTextIfNotEmpty('PolNumber', policyNode);                       
                        policy.productCode = getChildNodeTextIfNotEmpty('ProductCode', policyNode);
                        policy.planName = getChildNodeTextIfNotEmpty('PlanName', policyNode);
                        policy.policyStatus = getChildNodeTextIfNotEmpty('PolicyStatus', policyNode);
                        policy.policyStatusCode = getChildNodeAttributeIfNotEmpty('PolicyStatus', 'tc', policyNode);
                        policy.paymentAmt = getChildNodeDecimalIfNotEmpty('PaymentAmt', policyNode);
                        policy.policyValue  = getChildNodeTextIfNotEmpty('PolicyValue', policyNode);                        
                        Dom.XmlNode policyOLifEExtensionNode = getChildNodeIfNotNull('OLifEExtension', policyNode);
                        if(policyOLifEExtensionNode != null){
                            policy.monthlyPaymentAmt = getChildNodeTextIfNotEmpty('MonthlyPaymentAmt', policyOLifEExtensionNode);
                        }
                        //AM project coupon jack add
                        /* List<Coupon> couponList=new List<Coupon>();
                        List<Dom.XmlNode> policyChildNodes = getChildElementsIfNotNull(policyNode);
                        for(Dom.XmlNode policyChildNode :policyChildNodes){
                            if(policyChildNode.getName() == 'Coupon'){
                                String couponCode = getChildNodeTextIfNotEmpty('CouponCode', policyChildNode);
                                Coupon coupon=new Coupon(couponCode);
                                couponList.add(coupon);
                            }
                        }
                        policy.couponList=couponList; */
                        
                        prospectDetail.policy = policy;                       
                    }
                    
                    Dom.XmlNode OLifEExtensionNode = getChildNodeIfNotNull('OLifEExtension', childNode);
                    if(OLifEExtensionNode != null){
                        prospectDetail.ActivityId = getChildNodeTextIfNotEmpty('ActivityId', OLifEExtensionNode);
                        prospectDetail.ActivityType = getChildNodeTextIfNotEmpty('ActivityType', OLifEExtensionNode);
                        prospectDetail.SubmissionDate = getChildNodeTextIfNotEmpty('SubmissionDate', OLifEExtensionNode);
                        prospectDetail.SubmissionTime = getChildNodeTextIfNotEmpty('SubmissionTime', OLifEExtensionNode);
                        prospectDetail.SubmissionDateInTime = DateTime.valueOfGmt(prospectDetail.SubmissionDate + ' ' + prospectDetail.SubmissionTime );
                        Dom.XmlNode prospectNode = getChildNodeIfNotNull('Prospect', OLifEExtensionNode);
                        if(prospectNode != null){
                            prospectDetail.prospectId = prospectNode.getAttributeValue('id', null);
                            prospectDetail.RunningNumber = getChildNodeTextIfNotEmpty('RunningNumber', prospectNode);
                            prospectDetail.PolicyStatus = getChildNodeTextIfNotEmpty('PolicyStatus', prospectNode);
                            prospectDetail.IQID = getChildNodeTextIfNotEmpty('IQID', prospectNode);
                            prospectDetail.transactionStatus = getChildNodeTextIfNotEmpty('TransactionStatus',prospectNode);//Add by Ken
                            String smokeInd = getChildNodeAttributeIfNotEmpty('SmokeInd', 'tc', prospectNode);//Add by Ken
                            if(String.isNotBlank(smokeInd) && smokeInd == '1'){
                                prospectDetail.smokeInd = true;
                            }else{
                                prospectDetail.smokeInd = false;
                            }
                            prospectDetail.preferContactTime = getChildNodeTextIfNotEmpty('PreferContactTime',prospectNode);//Add by Ken
                            prospectDetail.howToKnow = getChildNodeTextIfNotEmpty('HowToKnow',prospectNode);//Add by Ken
                            prospectDetail.planLevel = getChildNodeTextIfNotEmpty('PlanLevel',prospectNode);//Add by Ken
                            prospectDetail.rateScale = getChildNodeTextIfNotEmpty('RateScale',prospectNode);//Add by Ken
                            prospectDetail.RiderPlanLevel1 = getChildNodeTextIfNotEmpty('RiderPlanLevel1',prospectNode);//Add by Ken
                            prospectDetail.Rider1 = getChildNodeTextIfNotEmpty('Rider1',prospectNode);//Add by Ken
                            prospectDetail.RiderPlanLevel2 = getChildNodeTextIfNotEmpty('RiderPlanLevel2',prospectNode);//Add by Ken
                            prospectDetail.Rider2 = getChildNodeTextIfNotEmpty('Rider2',prospectNode);//Add by Ken
                            prospectDetail.RiderPlanLevel3 = getChildNodeTextIfNotEmpty('RiderPlanLevel3',prospectNode);//Add by Ken
                            prospectDetail.Rider3 = getChildNodeTextIfNotEmpty('Rider3',prospectNode);//Add by Ken
                            prospectDetail.RiderPlanLevel4 = getChildNodeTextIfNotEmpty('RiderPlanLevel4',prospectNode);//Add by Ken
                            prospectDetail.Rider4 = getChildNodeTextIfNotEmpty('Rider4',prospectNode);//Add by Ken
                            prospectDetail.RiderPlanLevel5 = getChildNodeTextIfNotEmpty('RiderPlanLevel5',prospectNode);//Add by Kermit
                            prospectDetail.Rider5 = getChildNodeTextIfNotEmpty('Rider5',prospectNode);//Add by Kermit
                            prospectDetail.RiderPlanLevel6 = getChildNodeTextIfNotEmpty('RiderPlanLevel6',prospectNode);//Add by Kermit
                            prospectDetail.Rider6 = getChildNodeTextIfNotEmpty('Rider6',prospectNode);
                            //Combo: maybe has 7 rider -20201209
                            prospectDetail.RiderPlanLevel7 = getChildNodeTextIfNotEmpty('RiderPlanLevel7',prospectNode);
                            prospectDetail.Rider7 = getChildNodeTextIfNotEmpty('Rider7',prospectNode);
                            
                            prospectDetail.ProductCode = getChildNodeTextIfNotEmpty('ProductCode', prospectNode);
                            prospectDetail.PromoCode = getChildNodeTextIfNotEmpty('PromoCode',prospectNode); // Add by Owen,20230523, For JOBR-312 to get promote code
                            prospectDetail.CampaignCode = getChildNodeTextIfNotEmpty('CampaignCode', prospectNode);
                            prospectDetail.DiscountCode1 = getChildNodeTextIfNotEmpty('DiscountCode1', prospectNode); //Add by Manuel
                            prospectDetail.DiscountCode2 = getChildNodeTextIfNotEmpty('DiscountCode2', prospectNode); //Add by Manuel
                            prospectDetail.OptOutInd = getChildNodeBooleanIfNotEmpty('OptOutInd', prospectNode); //Add by Andy 20180716
                            prospectDetail.language = getChildNodeTextIfNotEmpty('Language', prospectNode);
                            prospectDetail.Enquiry = getChildNodeTextIfNotEmpty('Enquiry', prospectNode);
                            String jointIndCode = getChildNodeAttributeIfNotEmpty('JointInd', 'tc', prospectNode);
                            if(String.isNotBlank(jointIndCode) && jointIndCode == '1'){
                                prospectDetail.JointInd = true;
                            }else{
                                prospectDetail.JointInd = false;
                            }
                            String getQuoteCompleteIndCode = getChildNodeAttributeIfNotEmpty('GetQuoteCompleteInd', 'tc', prospectNode);
                            if(String.isNotBlank(getQuoteCompleteIndCode) && getQuoteCompleteIndCode == '1'){
                                prospectDetail.GetQuoteCompleteInd = true;
                            }else{
                                prospectDetail.GetQuoteCompleteInd = false;
                            }
                            String holderInfoCompleteIndCode = getChildNodeAttributeIfNotEmpty('HolderInfoCompleteInd', 'tc', prospectNode);
                            if(String.isNotBlank(holderInfoCompleteIndCode) && holderInfoCompleteIndCode == '1'){
                                prospectDetail.HolderInfoCompleteInd = true;
                            }else{
                                prospectDetail.HolderInfoCompleteInd = false;
                            }
                            String PreSalesCompleteIndCode = getChildNodeAttributeIfNotEmpty('PreSalesCompleteInd', 'tc', prospectNode);
                            if(String.isNotBlank(PreSalesCompleteIndCode) && PreSalesCompleteIndCode == '1'){
                                prospectDetail.PreSalesCompleteInd = true;
                            }else{
                                prospectDetail.PreSalesCompleteInd = false;
                            }
                            String UWQuestionaireCompleteIndCode = getChildNodeAttributeIfNotEmpty('UWQuestionaireCompleteInd', 'tc', prospectNode);
                            if(String.isNotBlank(UWQuestionaireCompleteIndCode) && UWQuestionaireCompleteIndCode == '1'){
                                prospectDetail.UWQuestionaireCompleteInd = true;
                            }else{
                                prospectDetail.UWQuestionaireCompleteInd = false;
                            }
                            String UWReviewCompleteIndCode = getChildNodeAttributeIfNotEmpty('UWReviewCompleteInd', 'tc', prospectNode);
                            if(String.isNotBlank(UWReviewCompleteIndCode) && UWReviewCompleteIndCode == '1'){
                                prospectDetail.UWReviewCompleteInd = true;
                            }else{
                                prospectDetail.UWReviewCompleteInd = false;
                            }
                            String ApplicationCompleteIndCode = getChildNodeAttributeIfNotEmpty('ApplicationCompleteInd', 'tc', prospectNode);
                            if(String.isNotBlank(ApplicationCompleteIndCode) && ApplicationCompleteIndCode == '1'){
                                prospectDetail.ApplicationCompleteInd = true;
                            }else{
                                prospectDetail.ApplicationCompleteInd = false;
                            }
                            String PaymentRequestSubmitIndCode = getChildNodeAttributeIfNotEmpty('PaymentRequestSubmitInd', 'tc', prospectNode);
                            if(String.isNotBlank(PaymentRequestSubmitIndCode) && PaymentRequestSubmitIndCode == '1'){
                                prospectDetail.PaymentRequestSubmitInd = true;
                            }else{
                                prospectDetail.PaymentRequestSubmitInd = false;
                            }
                            String PaymentAcceptIndCode = getChildNodeAttributeIfNotEmpty('PaymentAcceptInd', 'tc', prospectNode);
                            if(String.isNotBlank(PaymentAcceptIndCode) && PaymentAcceptIndCode == '1'){
                                prospectDetail.PaymentAcceptInd = true;
                            }else{
                                prospectDetail.PaymentAcceptInd = false;
                            }
                            prospectDetail.PresalesResult = getChildNodeTextIfNotEmpty('PresalesResult', prospectNode);
                            prospectDetail.FinalUWResult = getChildNodeTextIfNotEmpty('FinalUWResult', prospectNode);
                            prospectDetail.FinalResult = getChildNodeTextIfNotEmpty('FinalResult', prospectNode);   
                            prospectDetail.LoadingPremiumRate=getChildNodeTextIfNotEmpty('LoadingPremiumRate', prospectNode);/* add by Jack on 2021-10-28 for project: SUQ loading for drop-off */ 
                            
                            //add for JR-GA by kermit
                            prospectDetail.GAClientID = getChildNodeTextIfNotEmpty('GAClientID',prospectNode);
                            prospectDetail.GATrackID = getChildNodeTextIfNotEmpty('GATrackID',prospectNode);
                            prospectDetail.GAUserId = getChildNodeTextIfNotEmpty('GAUserId',prospectNode);
                            prospectDetail.GASource = getChildNodeTextIfNotEmpty('GASource',prospectNode);
                            prospectDetail.GAMedium = getChildNodeTextIfNotEmpty('GAMedium',prospectNode);
                            prospectDetail.GACampaign = getChildNodeTextIfNotEmpty('GACampaign',prospectNode);
                            //add for JR-GA by kermit
                            
                            //JR-1846
                            prospectDetail.GAKeyword = getChildNodeTextIfNotEmpty('GAKeyword',prospectNode);
                            //JR-1846
                            
                            //add for Covid19 by Andy Li start
                            prospectDetail.QuestionAns1 = getChildNodeTextIfNotEmpty('QuestionAns1',prospectNode);
                            prospectDetail.QuestionAns2 = getChildNodeTextIfNotEmpty('QuestionAns2',prospectNode);
                            //add for Covid19 by Andy Li end

                            //add for Combo Product by Rancho
                            prospectDetail.QuestionAns3 = getChildNodeTextIfNotEmpty('QuestionAns3', prospectNode);
                            prospectDetail.QuestionAns4 = getChildNodeTextIfNotEmpty('QuestionAns4', prospectNode);
                            prospectDetail.QuestionAns5 = getChildNodeTextIfNotEmpty('QuestionAns5', prospectNode);
                            //Combo TM
                            prospectDetail.planDeclaration = getChildNodeTextIfNotEmpty('PlanDeclaration', prospectNode);

                            //for get AUW URL
                            prospectDetail.UWApplicationId = getChildNodeTextIfNotEmpty('UWApplicationId',prospectNode);
                            
                            // for SPS-97 missing exclusion message
                            prospectDetail.exclusionDetails = new List<HttpCalloutVO.UWExclusionDetail>();
                            prospectDetail.remarkDetailsList = new List<HttpCalloutVO.UWExclusionDetail>();
                            List<String> remarksList = new List<String>();
                            
                            //duplicate remark/exclusion handling
                            Set<String> remarkCodeSet = new Set<String>();
                            //end
                            
                            List<Dom.XmlNode> prospectChildNodeList = prospectNode.getChildElements();
                            for(Dom.XmlNode prospectChildNode : prospectChildNodeList){
                                if('UWFullUWProductTypeResult'.equals(prospectChildNode.getName())){
                                    String fullUWType = getChildNodeTextIfNotEmpty('UWFullUWType',prospectChildNode);
                                    if('Exclusion'.equals(fullUWType)){
                                        HttpCalloutVO.UWExclusionDetail exclusion = new HttpCalloutVO.UWExclusionDetail();
                                        String code = getChildNodeTextIfNotEmpty('UWFullUWCode',prospectChildNode);
                                        String description = getChildNodeTextIfNotEmpty('UWFullUWDesc',prospectChildNode);
                                        if(!remarkCodeSet.contains(code)){
                                            exclusion.description = description;
                                            exclusion.detail = code + ' : ' + description;
                                            prospectDetail.exclusionDetails.add(exclusion);
                                            remarksList.add(description);
                                            remarkCodeSet.add(code);
                                            //system.debug('[ProspectCalloutHelper] processProspectBasicResult exclusion.description: '+exclusion.description);
                                            //system.debug('[ProspectCalloutHelper] processProspectBasicResult exclusion.detail: '+exclusion.detail);
                                        }
                                    }else if('Remark'.equals(fullUWType)){
                                        HttpCalloutVO.UWExclusionDetail exclusion = new HttpCalloutVO.UWExclusionDetail();
                                        String code = getChildNodeTextIfNotEmpty('UWFullUWCode',prospectChildNode);
                                        String remark = getChildNodeTextIfNotEmpty('UWFullUWDesc',prospectChildNode);
                                        if(!remarkCodeSet.contains(code)){
                                            exclusion.detail = code + ' : ' + remark;
                                            prospectDetail.remarkDetailsList.add(exclusion);
                                            remarksList.add(remark);
                                            remarkCodeSet.add(code);
                                        }
                                    }
                                }
                            }
                            prospectDetail.remarkDetails = String.join(remarksList,';');
                            //system.debug('[ProspectCalloutHelper] processProspectBasicResult prospectDetail.remarkDetails: '+prospectDetail.remarkDetails);
                            //system.debug('[ProspectCalloutHelper] processProspectBasicResult prospectDetail.exclusionDetails.size(): '+prospectDetail.exclusionDetails.size());
                            //system.debug('[ProspectCalloutHelper] processProspectBasicResult exclusionDetailList.size(): '+exclusionDetailList.size());
                            // for SPS-97 end
                        }
                    }
                }
            }else if(childNode.getName() == 'Party'){
                HttpCalloutVO.Person person = new HttpCalloutVO.Person();                
                String partyTypeCode= getChildNodeAttributeIfNotEmpty('PartyTypeCode', 'tc', childNode);
                String partyId = childNode.getAttributeValue('id', null);
                if(partyTypeCode == '1'){ //Person                    
                    person.fullName = getChildNodeTextIfNotEmpty('FullName', childNode);                   
                    person.ssnNumber = getChildNodeTextIfNotEmpty('GovtID', childNode);
                    
                    Dom.XmlNode personNode = getChildNodeIfNotNull('Person', childNode);
                    person.personId = personNode.getAttributeValue('id', null);
                    person.firstName = getChildNodeTextIfNotEmpty('FirstName', personNode);
                    person.lastName = getChildNodeTextIfNotEmpty('LastName', personNode);
                    person.middleName = getChildNodeTextIfNotEmpty('MiddleName', personNode);                    
                    person.title = getChildNodeTextIfNotEmpty('Title', personNode);
                    person.gender = getChildNodeTextIfNotEmpty('Gender', personNode);
                    person.genderCode = getChildNodeAttributeIfNotEmpty('Gender', 'tc', personNode);
                    person.birthDate = getChildNodeTextIfNotEmpty('BirthDate', personNode);                    
                    person.birthDateInDate = getChildNodeDateIfNotEmpty('BirthDate', personNode, 'yyyy-MM-dd');  
                    
                    //Add by Manuel start
                    person.height = getChildNodeTextIfNotEmpty('Height', personNode);
                    person.weight = getChildNodeTextIfNotEmpty('Weight', personNode);
                    person.placeOfResCode = getChildNodeTextIfNotEmpty('PlaceOfResCode', personNode);
                    //Add by Manuel stop

                    /* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
                    person.Nationality = getChildNodeTextIfNotEmpty('Nationality', personNode);
                    person.NationalityCode = getChildNodeTextIfNotEmpty('NationalityCode', personNode);
                    person.PlaceOfBirth = getChildNodeTextIfNotEmpty('PlaceOfBirth', personNode);
                    person.PlaceOfBirthCode = getChildNodeTextIfNotEmpty('PlaceOfBirthCode', personNode);
                    /* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
                    
                    //AM project jack add 
                    Dom.XmlNode membershipNode = getChildNodeIfNotNull('Membership', childNode);
                    HttpcalloutVO.Membership membership=new HttpcalloutVO.Membership();
                    membership.channel = getChildNodeTextIfNotEmpty('Channel', membershipNode);
                    membership.membershipId = getChildNodeTextIfNotEmpty('MembershipId', membershipNode);
                    membership.membershipFirstName = getChildNodeTextIfNotEmpty('MembershipFirstName', membershipNode);
                    membership.membershipLastName = getChildNodeTextIfNotEmpty('MembershipLastName', membershipNode);
                    person.membership=membership;
                    //AM project jack add
                    List<Dom.XmlNode> partyChildNodes = getChildElementsIfNotNull(childNode);
                    for(Dom.XmlNode n : partyChildNodes){
                        if(n.getName() == 'Address'){
                            String addressTypeCode = getChildNodeAttributeIfNotEmpty('AddressTypeCode', 'tc', n);
                            if(addressTypeCode == '17'){ // Mailing Address
                                person.addressLine1 = getChildNodeTextIfNotEmpty('Line1', n);
                                person.addressLine2 = getChildNodeTextIfNotEmpty('Line2', n);
                                person.addressLine3 = getChildNodeTextIfNotEmpty('Line3', n);
                                person.addressLine4 = getChildNodeTextIfNotEmpty('Line4', n);
                                person.city = getChildNodeTextIfNotEmpty('City', n);
                                person.addressState = getChildNodeTextIfNotEmpty('AddressState', n);
                                person.zip = getChildNodeTextIfNotEmpty('Zip', n);
                                person.addressCountry = getChildNodeTextIfNotEmpty('AddressCountry', n);                                
                                person.addressCountryCode = getChildNodeTextIfNotEmpty('AddressCountryCode', n);/* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */                                
                            }else if(addressTypeCode == '1'){
                                person.ResidenceaddressLine1 = getChildNodeTextIfNotEmpty('Line1', n);
                                person.ResidenceaddressLine2 = getChildNodeTextIfNotEmpty('Line2', n);
                                person.ResidenceaddressLine3 = getChildNodeTextIfNotEmpty('Line3', n);
                                person.ResidenceaddressLine4 = getChildNodeTextIfNotEmpty('Line4', n);
                                person.ResidenceaddressConutry = getChildNodeTextIfNotEmpty('AddressCountry', n);
                                person.ResidenceaddressConutryCode = getChildNodeTextIfNotEmpty('AddressCountryCode', n);/* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
                                person.ResidenceaddressSourceSystem = getChildNodeTextIfNotEmpty('SourceSystem', n);
                            } 
                        }else if(n.getName() == 'EMailAddress'){
                            person.emailAddress = getChildNodeTextIfNotEmpty('AddrLine', n);
                        }else if(n.getName() == 'Phone'){
                            String phoneTypeCode = getChildNodeAttributeIfNotEmpty('PhoneTypeCode', 'tc', n);
                            if(phoneTypeCode == '1'){ // Home
                                person.homePhoneNo = getChildNodeTextIfNotEmpty('DialNumber', n);
                                person.homePhoneCountryCode = getChildNodeTextIfNotEmpty('CountryCode', n);
                                person.homePhoneAreaCode = getChildNodeTextIfNotEmpty('AreaCode', n);
                            }else if(phoneTypeCode == '2'){ // Business
                                person.businessPhoneNo = getChildNodeTextIfNotEmpty('DialNumber', n);
                                person.businessPhoneCountryCode = getChildNodeTextIfNotEmpty('CountryCode', n);
                                person.businessPhoneAreaCode = getChildNodeTextIfNotEmpty('AreaCode', n);   
                                person.businessPhoneExt = getChildNodeTextIfNotEmpty('Ext', n);                             
                            }else if(phoneTypeCode == '12'){ // Mobile
                                person.mobilePhoneNo = getChildNodeTextIfNotEmpty('DialNumber', n);
                                person.mobileCountryCode = getChildNodeTextIfNotEmpty('CountryCode', n);
                                person.mobileAreaCode = getChildNodeTextIfNotEmpty('AreaCode', n);                                
                            }
                        }
                    }
                    partyMap.put(partyId,person);
                }
            }else if(childNode.getName() == 'Relation'){
                HttpCalloutVO.Relation relation = new HttpCalloutVO.Relation();
                relation.id = childNode.getAttributeValue('id', null);
                relation.OriginatingObjectID = childNode.getAttributeValue('OriginatingObjectID', null);
                relation.RelatedObjectID = childNode.getAttributeValue('RelatedObjectID', null);
                relation.OriginatingObjectType = getChildNodeTextIfNotEmpty('OriginatingObjectType', childNode);
                relation.OriginatingObjectCode = getChildNodeAttributeIfNotEmpty('OriginatingObjectType', 'tc', childNode);
                relation.RelatedObjectType = getChildNodeTextIfNotEmpty('RelatedObjectType', childNode);
                relation.RelatedObjectCode = getChildNodeAttributeIfNotEmpty('RelatedObjectType', 'tc', childNode);
                relation.RelationRoleCode = getChildNodeAttributeIfNotEmpty('RelationRoleCode', 'tc', childNode);
                relation.RelationRoleType = getChildNodeTextIfNotEmpty('RelationRoleCode', childNode);
                relation.InsurableInterestReason = getChildNodeTextIfNotEmpty('InsurableInterestReason', childNode);
                
                relationList.add(relation);
            }
        }
        for(HttpCalloutVO.Relation relation : relationList){
            HttpCalloutVO.Person party = partyMap.get(relation.RelatedObjectID);
            HttpCalloutVO.PersonRelation pr = new HttpCalloutVO.PersonRelation();
            pr.relation = relation;
            pr.person = party;
            if(relation.RelationRoleCode == '8'){ // Holder                    
                prospectDetail.holderDetail = pr;
            }else if (relation.RelationRoleCode == '32'){ // insured
                prospectDetail.insuredDetailList.add(pr);
            }else if (relation.RelationRoleCode == '34'){ // beneficiary
                prospectDetail.beneficiaryDetailList.add(pr);
            }
        }
        //system.debug('>>>>> List<HttpCalloutVO.ProspectDetail> >>>>> ' + prospectDetail);
        objList.add(prospectDetail);
        return objList;
    }
    
    public void setIsCalloutSuccessfullyTrue(){
        this.isCalloutSuccessfully = true;
    }
}