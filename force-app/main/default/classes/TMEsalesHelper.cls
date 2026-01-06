/********************************************************************************
Apex Class Name - TMEsalesHelper
Version - 1.0
Created Date - Apr 24, 2018
@description TM Esales Helper

Modification Log : 
--------------------------------------------------------------------------------

*Version    Developer       Date                    Description
* ------    -----------     ------------            -----------------------
* 1.0       Franco          24/04/2018              Original Version
********************************************************************************/
public class TMEsalesHelper {
    
    public static final String WS_GET_QUOTE = 'GET_QUOTE';
    public static final String WS_PRESALES = 'preSales';
    public static final String WS_FULLUW = 'fullUnderwriting';
    public static TM_General_Setting__c generalSetting = TM_General_Setting__c.getValues('Default');
    public static ESales_Endpoint__c esalesSetting = ESales_Endpoint__c.getValues('Default');
    public static List<String> auwInboundChannels = new List<String> {'148','149','152'};
    private Map<String, String> insuredTypeMap;
    
    public static List<String> specialProductCodeList = new List<String> {'RSM', 'TMC50', 'TMCPU', 'RSPH', 'RSPU', 'RSPUS'};
    public static String PRODUCT_SP100 = '@SP100';
    public static Map<String,String> getQuoteProductCodeMap = new Map<String,String>{
        'RSM' => 'RSM','TMC50' => 'TMC50','TMCPU' => 'TMCPU','RSPH' => 'RSPH','RSPU' => 'RSPU','RSPUS' => 'RSPUS','@SP100' => 'SP100'
    };
    // 20210906 - minghua - eSalesHKWS API
    private static final String GetQuote='GetQuote';
    
    public TMEsalesHelper(){
        insuredTypeMap = new Map<String, String>();
        insuredTypeMap.put('PH = PI', 'MI');
        insuredTypeMap.put('Spouse', 'SP');
        insuredTypeMap.put('Dependent', 'DP');
    }
    
    /*
     * Get quote by plan Level
     * applicable to TM product: RSM, RSPH, RSPU, RSPUS, TMC50, TMCPU
     */
    public QuoteResult getQuote(QuoteParam param){
        //system.debug('>>>>> getQuote start: ' + param);
        Map<String, String> paramsMap = new Map<String, String>();
        paramsMap.put('action', 'quote');
        paramsMap.put('offercode', ''); // leave it blank
        paramsMap.put('si', '');        // leave it blank
        paramsMap.put('iqid', '');      // leave it blank
        paramsMap.put('lang', 'zh_HK');
        paramsMap.put('campaigncode', param.campaignCode);
        paramsMap.put('eligible', param.eligible);
        
        paramsMap.put('planLevel', param.planLevel);
        paramsMap.put('lastname', param.lastName);
        paramsMap.put('firstname', param.firstName);
        paramsMap.put('email', param.email);
        paramsMap.put('phone', param.phone);
        paramsMap.put('smoking', param.isSmoker == true ? '1' : '0');
        paramsMap.put('gender', param.isMale == true ? 'M' : 'F');
        paramsMap.put('dob-dates-min', '');
        paramsMap.put('dob-dates-max', '');
        String dob = '';
        if(param.dob != null){
            String year = String.valueOf(param.dob.year());
            String month = String.valueOf(param.dob.month());
            String day = String.valueOf(param.dob.day());
            dob = year + '/' + month.leftPad(2, '0') + '/' + day.leftPad(2, '0');
        }
        paramsMap.put('dob', dob);
        
        for(String key : paramsMap.keySet()){
            String value = paramsMap.get(key) == null ? '' : paramsMap.get(key);
            paramsMap.put(key, key + '=' + EncodingUtil.urlEncode(value, 'UTF-8'));
        }
        String paramString = String.join(paramsMap.values(), '&');
        
        String endpoint = esalesSetting.Get_Quote_Enhanced_Endpoint__c;

        // 20210906 - minghua - eSalesHKWS API, get ws log setting use function name and profile name
        Cigna_WS_Log_Setting__c cignaWSLogSetting=CignaUtil.getCignaWSLogSetting(GetQuote,ESalesUtility.currentUserProfileName);
        if (cignaWSLogSetting!=null&&cignaWSLogSetting.Reset_Endpoint__c) {
            System.debug('original endpoint='+endpoint);
            endpoint=cignaWSLogSetting.Endpoint_Domain__c+cignaWSLogSetting.Related_Path__c;
            System.debug('reset endpoint='+endpoint);
        }

        endpoint = endpoint + '?' + paramString;
        
        QuoteResult qr = new QuoteResult();
        try {
            HttpResponse res = getCalloutResponse(WS_GET_QUOTE, endpoint, 'GET', '');
            if(res != null){
                String body = res.getbody();
                qr = (QuoteResult)JSON.deserialize(body, QuoteResult.class);
            }
        } catch(Exception e){
            //system.debug('>>>>> getQuote end with exception: ' + e.getMessage());
            throw new GetQuoteException(e.getMessage());
        }
        
        //system.debug('>>>>> getQuoteByProduct end: ' + qr);
        return qr;
    }
    
    /*
     * Get quote by plan code and campaign code
     * @param TMEsalesHelper.QuoteProductParam
     *        - param.campaignCode
     *        - param.planCode
     */
    public List<ESalesUtility.rateTable> getQuoteProduct(QuoteProductParam param){
        //system.debug('>>>>> getQuoteByProduct start: ' + param);
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('action', 'Quotepremiumrate');
        paramMap.put('lang', 'en_US');
        paramMap.put('quotecampaign', param.campaignCode);
        paramMap.put('quoteplancode', param.planCode);
        // Rancho_HKITSFDC402_20250930 - add sum insured
        if(String.isNotBlank(param.quoteSumInsured)){
            paramMap.put('quotesuminsured', param.quoteSumInsured);
        }
        
        List<ESalesUtility.rateTable> rateList = new List<ESalesUtility.rateTable>();
        try {
            String resultdoc = (String)(ESalesUtility.WSGetQuote(WS_GET_QUOTE, paramMap));
            if(String.isNotBlank(resultdoc)){
                Set<String> planCodeSet = new Set<String>();
                planCodeSet.add(param.planCode);
                rateList = ESalesUtility.processJson(resultdoc, planCodeSet);
            }
        }catch (Exception e){
            system.debug('>>>>> getQuoteByProduct end with exception: ' + e.getMessage());
            throw new GetQuoteException(e.getMessage());
        }
        
        system.debug('>>>>> getQuoteByProduct end: ' + rateList);
        return rateList;
    }
    
    /*
     * Generate the pre sales attribute
     */
    public PreSalesAttribute getPreSalesAttribute(Boolean isInbound, List<TMEsalesHelper.ProductRecord> prdList, String productCode, TMCreatePolicyCtrl.PersonInsuredStructure pis, Boolean isParentHKIDHasInforcePolicy){
        String dob = '';
        //String height = '';
        //String weight = '';
        String issueAge = '';
        String channelCode = '';
        if(pis.pi.Date_of_Birth__c != null){
            String year = String.valueOf(pis.pi.Date_of_Birth__c.year());
            String month = String.valueOf(pis.pi.Date_of_Birth__c.month());
            String day = String.valueOf(pis.pi.Date_of_Birth__c.day());
            dob = year + month.leftPad(2, '0') + day.leftPad(2, '0');
            Integer totaldays = pis.pi.Date_Of_Birth__c.daysBetween(System.today());
            Integer age = (Integer)(Math.Floor(totaldays/365.2425));
            issueAge = String.valueOf(age);
        }
        TMEsalesHelper.PreSalesAttribute att = new TMEsalesHelper.PreSalesAttribute();
        att.applicationId = pis.applicationId;
        att.channel = ( isInbound ? generalSetting.Channel_Code_Inbound__c : generalSetting.Channel_Code_Outbound__c );
        att.piId = pis.pi.Personal_ID__c;
        att.locale = 'ZH'; //always disaply in Chinese
        //att.name = pis.pi.Person_Insured_Name__c;//comment by ken
        att.name = pis.pi.Insured_Last_Name__c + ' ' + pis.pi.Insured_First_Name__c;
        att.dob = dob;
        att.issueAge = issueAge;
        //system.debug('[TMEsalesHelper] getPreSalesAttribute().pis.pi.Height__c='+pis.pi.Height__c);
        //system.debug('[TMEsalesHelper] getPreSalesAttribute().pis.pi.Weight__c='+pis.pi.Weight__c);
        //att.height = pi.Height__c != null ? String.valueOf(pi.Height__c) : '';//comment by ken
        //att.weight = pi.Weight__c != null ? String.valueOf(pi.Weight__c) : '';//comment by ken
        Decimal height = String.isEmpty(pis.height)?null:Decimal.valueOf(pis.height);//added by ken
        Decimal weight = String.isEmpty(pis.weight)?null:Decimal.valueOf(pis.weight);//added by ken
        Decimal heightInch = String.isEmpty(pis.heightInch)?null:Decimal.valueOf(pis.heightInch);//added by ken
        att.height = ESalesUtility.calHeightValue(height,heightInch, pis.pi.Height_Unit__c);//added by ken, ticket DPSP-901        
        att.weight = TMPolicyUtil.calWeightValue(weight,pis.pi.Weight_Unit__c);//added by ken, ticket DPSP-901
        //system.debug('[TMEsalesHelper] getPreSalesAttribute().att.weight='+att.weight);
        //system.debug('[TMEsalesHelper] getPreSalesAttribute().att.height='+att.height);
        att.gender = '';
        if(pis.pi.Gender__c == 'Male'){
            att.gender = 'M';
        }else if(pis.pi.Gender__c == 'Female'){
            att.gender = 'F';
        }
        if(pis.pi.Smoker__c == 'yes'){
            att.smoker ='true';
        }else if(pis.pi.Smoker__c == 'no'){
            att.smoker ='false';
        }else{
            att.smoker = null;
        }
        /**
        if(pi.Relationship__c == 'Son' || pi.Relationship__c == 'Daughter'){
            att.masterIdJU = pi.Parent_PI_ID__c;
        }
        **/
        att.productRecordList = prdList;
        // Below are fixed value
        att.clientRole = 'UW';
        if(isParentHKIDHasInforcePolicy){
            att.masterIdJU = pis.pi.Parent_PI_ID__c;
            att.masterPlanIndicator = 'true';
        }else{
            att.masterIdJU = '';//default value
            att.masterPlanIndicator = 'false';//default value
        }

        // Rancho_HKITSFDC402_20250930 - add sumInsured in AUW request
        att.sumInsured = String.isNotBlank(pis.sumInsured) ? pis.sumInsured : '';
        
        //added by ken, for DPSP-628     
        //system.debug('[TMEsalesHelper] getPreSalesAttribute().productCode='+productCode); 
        //system.debug('[TMEsalesHelper] getPreSalesAttribute().pis.parentIDPolicylist='+pis.parentIDPolicylist);
        /**
        if(null != productCode && null != pis.parentIDPolicylist){
            for(HttpCalloutVO.Policy p : pis.parentIDPolicylist){
                //system.debug('[TMEsalesHelper] getPreSalesAttribute().p.productCode='+p.productCode);
                if((p.policyStatusDisplayName == 'Inforce' || p.policyStatusDisplayName == '生效') && productCode.contains(p.productCode)){
                    att.masterPlanIndicator = 'true';
                    att.masterIdJU = pis.pi.Parent_PI_ID__c;
                    break;
                }
            }
            //List<New_Policy__c> inforcePolicyInSFDC = [select id from new_policy__c 
            //                                                   where personal_id__c = :pis.pi.Parent_PI_ID__c
            //                                                   and (policy_status__c = 'Completed' or  policy_status__c = 'Submitted')
            //                                                   and Product_Code__c = :productCode
            //                                                   and UW_Overrall_Result__c = :TMCreatePolicyCtrl.PRESALES_UW_RESULT_ACCEPTED];
            
        }
        **/
        att.country = 'HK';
        att.triggerType = 'PRE_SALES';
        att.campaignCode = '';
        att.occCode = '';
        att.indCode = '';
        att.income = '';
        att.preSalesStatus = '';
        att.fullTriggerType = '';
        att.flag = '';
        //system.debug('>>> PreSalesAttribute: ' + att);
        return att;
    }
    
    /*
     * Get the pre sales result
     */
    public PreSalesResult preSales(PreSalesAttribute att){
        att.triggerType = 'PRE_SALES';
        String endpoint = esalesSetting.AUW_Endpoint__c;
        String body = getPreSalesRequestBody(att);
        HttpResponse res = getCalloutResponse(WS_PRESALES, endpoint, 'POST', body);
        PreSalesResult result = processXMLPreSales(res.getBodyDocument());
        //system.debug('caseid=' + result.caseId);
        //system.debug('result =' + result.result );
        return result;
    }
    
    /*
     * Get the full underwriting url
     */
    public String fullUnderwriting(PreSalesAttribute att){
        att.triggerType = 'FULL_UW';
        String endpoint = esalesSetting.AUW_Endpoint__c;
        String body = getFullUWRequestBody(att);
        HttpResponse res = getCalloutResponse(WS_FULLUW, endpoint, 'POST', body);
        String url = processFullUnderwritingResponse(res.getBodyDocument());
        //system.debug('url=' + url);
        return url;
    }
    
    /*
     *
     */
    public HttpResponse getCalloutResponse(String WSName, String endpoint, String method, String body){
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(120000);
        if('POST'.equalsIgnoreCase(method)){
            req.setBody(body);
        }
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();

        DateTime callTimeStart = null;
        DateTime callTimeEnd = null;
        try{
            //system.debug('>>>>> Callout Start >>>>>');
            //system.debug('>>>>> Request endpoint and method used : >>>>> ' + req.toString());
            //system.debug('>>>>> Request body if has : >>>>> ' + req.getBody());

            callTimeStart = DateTime.now();
            res = http.send(req);
            callTimeEnd = DateTime.now();

            //system.debug('>>>>> Response status and status code >>>>> ' + res.toString());
            //system.debug('>>>>> Response body >>>>> ' + res.getBody());
            
            Cigna_WS_Log_Setting__c wsLogSetting = Cigna_WS_Log_Setting__c.getValues(WSName);
            if(wsLogSetting != null && wsLogSetting.Enable_Logging__c && !Test.isRunningTest()){
                WSCalloutSettingHelper.insertLog(WSName, req, res, '', '', callTimeStart, callTimeEnd, TRUE);
            }
            return res;  
            
        } catch(System.CalloutException e){
            WSCalloutSettingHelper.insertLog(WSName, req, res, e.getMessage(), e.getStackTraceString(), callTimeStart, callTimeEnd, FALSE);
            return null;
        }
    }
    
    public String getPreSalesRequestBody(PreSalesAttribute att){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.uw.cigna.com/">'
                    + '  <soapenv:Header/>'
                    + '  <soapenv:Body>'
                    + '    <ws:preSales>'
                    + '      <arg0>'
                    + '        <applicationId>' + att.applicationId + '</applicationId>'
                    + '          <caseXML>'
                    + '            <![CDATA[<caseData>'
                    + '              <insured>'
                    + '                <attribute name="PIID" value="' + att.piId + '" />'
                    + '                <attribute name="LOCALE" value="' + att.locale + '" />'
                    + '                <attribute name="CLIENT_ROLE" value="' + att.clientRole + '" />'
                    + '                <attribute name="MASTER_ID_JU" value="' + att.masterIdJU + '" />'
                    + '                <attribute name="MASTER_PLAN_INDICATOR" value="' + att.masterPlanIndicator + '" />'
                    + '                <attribute name="NAME" value="' + att.name + '" />'
                    + '                <attribute name="COUNTRY" value="' + att.country + '" />'
                    + '                <attribute name="CHANNEL" value="' + att.channel + '" />'
                    + '                <attribute name="TRIGGER_TYPE" value="' + att.triggerType + '" />'
                    + '                <attribute name="DOB" value="' + att.dob + '" />'
                    + '                <attribute name="ISSUE_AGE" value="' + att.issueAge + '" />'
                    + '                <attribute name="HEIGHT" value="' + att.height + '" />'
                    + '                <attribute name="WEIGHT" value="' + att.weight + '" />'
                    + '                <attribute name="CAMPAIGN_CODE" value="' + att.campaignCode + '" />'
                    + '                <attribute name="OCC_CODE" value="' + att.occCode + '" />'
                    + '                <attribute name="IND_CODE" value="' + att.indCode + '" />'
                    + '                <attribute name="INCOME" value="' + att.income + '" />'
                    + '                <attribute name="GENDER" value="' + att.gender + '" />'
                    + '                <attribute name="SMOKER" value="' + att.smoker + '" />'
                    + '                <attribute name="CURRENT_CI_SUM_INSURED" value="' + att.sumInsured + '" />';// Rancho_HKITSFDC402_20250930 - add sumInsured in AUW request
        
        if(att.ProductRecordList != null && att.ProductRecordList.size() > 0){
            for(productRecord r : att.ProductRecordList){
                body += '<record>'
                      + '  <attribute name="PROPOSE_PLAN" value="' + r.proposePlan + '" />'
                      + '  <attribute name="PROPOSED_RATE_SCALE" value="' + r.proposeRateScale + '" />'
                      + '  <attribute name="RIDER_INDICATOR" value="' + r.isRider + '" />'
                      + '</record>';
            }
        } else {
            body += '<record>'
                  + '  <attribute name="PROPOSE_PLAN" value="" />'
                  + '  <attribute name="PROPOSED_RATE_SCALE" value="" />'
                  + '  <attribute name="RIDER_INDICATOR" value="" />'
                  + '</record>';
        }
        
        body += '            </insured>'
              + '          </caseData>]]>'
              + '        </caseXML>'
              + '      </arg0>'
              + '    </ws:preSales>'
              + '  </soapenv:Body>'
              + '</soapenv:Envelope>';
        
        return body;
    }
    
    public String getFullUWRequestBody(PreSalesAttribute att){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.uw.cigna.com/">'
                    + '  <soapenv:Header/>'
                    + '  <soapenv:Body>'
                    + '    <ws:fullUnderwriting>'
                    + '      <arg0>'
                    + '        <applicationId>' + att.applicationId + '</applicationId>'
                    + '        <caseXML>'
                    + '          <![CDATA[<caseData>'
                    + '            <insured>'
                    + '              <attribute name="PIID" value="' + att.piId + '" />'
                    + '              <attribute name="LOCALE" value="' + att.locale + '" />'
                    + '              <attribute name="CLIENT_ROLE" value="' + att.clientRole + '" />'
                    + '              <attribute name="COUNTRY" value="' + att.country + '" />'
                    + '              <attribute name="CHANNEL" value="' + att.channel + '" />'
                    + '              <attribute name="PRESALES_STATUS" value="' + att.preSalesStatus + '" />'
                    + '              <attribute name="TRIGGER" value="' + att.fullTriggerType + '" />'
                    + '              <attribute name="HEIGHT" value="' + att.height + '" />'
                    + '              <attribute name="WEIGHT" value="' + att.weight + '" />'
                    + '              <attribute name="DOB" value="' + att.dob + '" />'
                    + '              <attribute name="ISSUE_AGE" value="' + att.issueAge + '" />'
                    + '              <attribute name="GENDER" value="' + att.gender + '" />'
                    + '              <attribute name="SMOKER" value="' + att.smoker + '" />'
                    + '              <attribute name="CAMPAIGN_CODE" value="' + att.campaignCode + '" />'
                    + '              <attribute name="CURRENT_CI_SUM_INSURED" value="' + att.sumInsured + '" />'// Rancho_HKITSFDC402_20250930 - add sumInsured in AUW request
                    + '            </insured>'
                    + '          </caseData>]]>'
                    + '        </caseXML>'
                    + '      </arg0>'
                    + '    </ws:fullUnderwriting>'
                    + '  </soapenv:Body>'
                    + '</soapenv:Envelope>';
        
        return body;
    }
    
    public String processFullUnderwritingResponse(Dom.Document doc){
        String url = '';
        Dom.XMLNode nodeRoot = doc.getRootElement();
        Dom.XMLNode nodeBody = getFirstChildNodeIfNotNull(nodeRoot);
        Dom.XMLNode fullUnderwritingResponse = getFirstChildNodeIfNotNull(nodeBody);
        Dom.XMLNode returnNode = getChildNodeIfNotNull('return', fullUnderwritingResponse);
        Dom.XMLNode caseXMLNode = getChildNodeIfNotNull('caseXML', returnNode);
        if(caseXMLNode != null){
            for(Dom.XmlNode child : caseXMLNode.getChildren()){
                if(child.getText().startsWithIgnoreCase('Http')){
                    url = child.getText(); 
                }
            }
        }
        
        //replace the url private IP address
        String privateURL = esalesSetting.UAT_Private_URL__c;
        String prefixURL = esalesSetting.UW_URL_Prefix__c;
        
        if(url != null && url.startsWithIgnoreCase(privateURL)){
            url = url.replace(privateURL, prefixURL);
        }
        //system.debug('##processXMLresponse prefixURL ' + url);
        return url;
    }
    
    public PreSalesResult processXMLPreSales(Dom.Document doc){
    
        PreSalesResult resultTable = new PreSalesResult();
        String caseId = '';
        String preResult = '';
        
        String docXmlStr = doc.toXmlString();
        Integer startIdx = docXmlStr.indexOf('<caseXML>');
        Integer endIdx = docXmlStr.indexOf('</caseXML>');
        String caseXmlStr = docXmlStr.subString(startIdx + 9, endIdx).unescapeXml();
        //system.debug('caseXmlStr:' + caseXmlStr);
        
        Dom.Document caseXMLDoc = new Dom.Document();
        caseXMLDoc.load(caseXmlStr);
        Dom.XMLNode nodeRoot = caseXMLDoc.getRootElement();
        
        Dom.XMLNode casePropertiesNode = getChildNodeIfNotNull('caseProperties', nodeRoot);
        if(casePropertiesNode != null){
            for(Dom.XmlNode child : casePropertiesNode.getChildElements()){
                if(child.getAttributeValue('name', null) == 'CASEID'){
                    resultTable.caseId = child.getAttributeValue('value', null);
                }
            }
        }
        Dom.XMLNode insuredNode = getChildNodeIfNotNull('insured', nodeRoot);
        Dom.XMLNode insuredResultNode = getChildNodeIfNotNull('results', insuredNode);
        if(insuredResultNode != null){
            for(Dom.XmlNode child : insuredResultNode.getChildElements()){
                if(child.getName() == 'overallunderwritingResult'){
                    for(Dom.XmlNode attNode : child.getChildElements()){
                        if(attNode.getAttributeValue('name', null) == 'OVERALLRESULT'){
                            resultTable.result = attNode.getAttributeValue('value', null);
                        }
                    }
                }
                
                if(child.getName() == 'record'){
                    PreSalesResultMessage resultMsg = new PreSalesResultMessage();
                    Boolean isResultMessageNull = false;
                    for(Dom.XmlNode attNode : child.getChildElements()){
                        if(attNode.getAttributeValue('name', null) == 'PRODUCT_CODE_BASIC'){
                            resultMsg.productCode = attNode.getAttributeValue('value', null);
                        } else if(attNode.getName() == 'resultMessages'){
                            if(null == attNode.getChildElements() || attNode.getChildElements().size() == 0)
                                isResultMessageNull = true;
                            for(Dom.XmlNode msgNode : attNode.getChildElements()){
                                for(Dom.XmlNode att : msgNode.getChildElements()){
                                    if(att.getAttributeValue('name', null) == 'MESSAGE_DETAIL'){
                                        resultMsg.msgList.add(att.getAttributeValue('value', null));
                                    }
                                }
                            }
                        }
                    }
                    if(isResultMessageNull == false)
                        resultTable.resultMsgList.add(resultMsg);
                }
            }
        }
        
        //system.debug('##processXMLPreSales resultTable ' + resultTable);
        return resultTable;
    }
    
    public Dom.XmlNode getFirstChildNodeIfNotNull(Dom.XmlNode node){
        Dom.XmlNode result = null;
        List<Dom.XmlNode> childNodeList = getChildElementsIfNotNull(node);
        if(!childNodeList.isEmpty()){
            result = childNodeList[0];
        }
        return result;
    }

    public Dom.XmlNode getChildNodeIfNotNull(String elementName, Dom.XmlNode node){
        Dom.XmlNode result = null;
        if(node != null){
            return node.getChildElement(elementName, null);
        }
        return result;
    }
    
    public List<Dom.XmlNode> getChildElementsIfNotNull(Dom.XmlNode node){
        List<Dom.XmlNode> result = new List<Dom.XmlNode>();
        if(node != null){
            result = node.getChildElements();
        }
        return result;
    }
    
    /*
     * Parameter for preSales(PreSalesAttribute att)
     */
    public class PreSalesAttribute {
        public String applicationId { get; set; }
        public String piId { get; set; }
        public String locale { get; set; }
        public String clientRole { get; set; }
        public String masterIdJU { get; set; }
        public String masterPlanIndicator { get; set; }
        public String name { get; set; }
        public String country { get; set; }
        public String channel { get; set; }
        public String triggerType { get; set; }
        public String dob { get; set; }
        public String issueAge { get; set; }
        public String height { get; set; }
        public String weight { get; set; }
        public String campaignCode { get; set; }
        public String occCode { get; set; }
        public String indCode { get; set; }
        public String income { get; set; }
        public String gender { get; set; }
        public String smoker { get; set; }
        public String preSalesStatus { get; set; }
        public String fullTriggerType { get; set; }
        public String flag { get; set; }
        public List<ProductRecord> productRecordList { get; set; } { productRecordList = new List<ProductRecord>(); }
        public String sumInsured { get; set; }// Rancho_HKITSFDC402_20250930 - add sumInsured in AUW request
        
        public preSalesAttribute(){}
    }
    
    public class ProductRecord {
        public String proposePlan { get; set; } // Product code
        public String proposeRateScale { get; set; } // plan level
        public Boolean isRider { get; set; } { isRider = false; } // basic plan/rider
        
        private List<String> alphabet = new list<String> {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
            'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
        };
        
        public ProductRecord(){}
        
        public ProductRecord(String planCode, String rateScale, Boolean isRider){
            this.proposePlan = planCode;
            this.proposeRateScale = rateScale;
            this.isRider = isRider;
            
            // the rate scales from CITAS (GetPlanInfoListBasic) are in integers (i.e. 0,1,…,9,10,11,etc)
            // while those from IPAS are in 1 character (i.e. 0,1,…,9,A,B,etc). 
            // Hence, SFDC needs to convert the rate scales that are >9 to A,B,C,… before passing to AUW.
            try {
                Integer rscale = Integer.valueOf(this.proposeRateScale);
                if(rscale > 9){
                    this.proposeRateScale = alphabet[rscale-10];
                }
            } catch(Exception e){
                //system.debug('exception when convert rate scale: ' + this.proposeRateScale);
                //system.debug(e.getMessage());
            }
        }
    }
    
    /*
     * Result for preSales(PreSalesAttribute att)
     */
    public class PreSalesResult {
        public String caseId { get; set; }
        public String result { get; set; }
        public List<PreSalesResultMessage> resultMsgList { get; set; } { resultMsgList = new List<PreSalesResultMessage>(); }
        
        public PreSalesResult(){}
    }
    
    public class PreSalesResultMessage {
        public String ProductCode { get; set; }
        public List<String> msgList { get; set; } { msgList = new List<String>(); }
        public String message{get;set;}
        
        public void setMessage(){
            if(null != msgList){
                message = '';
                for(String msg : msgList){
                    message += msg + ';<br/>';
                }
            }
        }
    }
            
    /*
     * Parameter for getQuoteProduct(QuoteProductParam param)
     */
    public class QuoteProductParam {
        public String campaignCode { get; set; }
        public String planCode { get; set; }
        public String quoteSumInsured {get;set;}// Rancho_HKITSFDC402_20250930 - add sum insured
    }
    
    /*
     * Parameter for getQuoteByPlan(QuoteByPlanParam param)
     */
    public class QuoteParam {
        public String campaignCode { get; set; }
        public String planLevel { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public Date dob { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        public Boolean isSmoker { get; set; }
        public Boolean isMale { get; set; }
        public String eligible { get; set; } { eligible = 'MI'; } // Default value
    }
    
    /*
     * result for getQuote(QuoteParam param)
     */
    public class QuoteResult {
        public String quoteId { get; set; }
        public String status { get; set; }
        public String BPAnnualPrem { get; set; }
        public String BPMonthlyPrem { get; set; }
        public String ModalFactor {get;set;}
    }
    
    public class GetQuoteException extends Exception {
    }


    /*
     * Get quote result: person insured map
     */
    public class PersonInsured {
        public String key {get; set;}
        public String description {get; set;}
        public String gender {get; set;}
        public String planCode {get; set;}
        public Integer age {get; set;}
        public String smokingStatus {get; set;}
        public String riderPlanCode {get; set;}
        public String basicPlanCode {get; set;}
        public Map<String, String> planProductMap {get;set;} {planProductMap = new Map<String,String>();} //key=planCode, value=productCode
        public String benefitLevel{get;set;} // Plan Level
        public String policyId{get;set;} // PI Policy Id        
        public Map<String, Decimal> discountMap {get;set;} {discountMap = new Map<String,Decimal>();} //key=Discount1,Discount2,MandatoryDiscount,PaymentDiscount,DefaultDiscount, value=percentage
        public Date dateOfBirth {get;set;}//added by ken
        public String insuredType {get;set;}//added by ken
        public List<TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem> availableRiderBenefitlevelItemList;//added by ken
        public Decimal loading {get;set;} //added by Andy
        public String personName {get;set;}//added by ken
        public String quoteSumInsured {get;set;}// Rancho_HKITSFDC402_20250930 - add sum insured
        //public Map<String, Portalproduct> riderProductMap{get;set;}//added by ken , use to get portalproduct's offercode & si to call get quote ws
        //public Portalproduct basicPlanProduct{get;set;}//added by ken , use to get portalproduct's offercode & si to call get quote ws
    }

    /*
     * Call quotation WS to get premium table
     */
    public Map<String, List<ESalesUtility.rateTable>> getPremiumTable(Set<String> PlancodeSet, String campaignCode){        
        Map<String, List<ESalesUtility.rateTable>> premiumRateMap = new Map<String, List<ESalesUtility.rateTable>>();        
        List<ESalesUtility.rateTable> rateList = new List<ESalesUtility.rateTable>();
        String resultdoc;
        for(String s : PlancodeSet){                           
            //Rancho_HKITSFDC402_20250930 - add sum insured
            String planCode = s;
            String quoteSumInsured = null;
            if(s.contains('_')){
                planCode = s.split('_')[0];
                quoteSumInsured = s.split('_')[1];
            }
            //prepare the parameters mapping
            QuoteProductParam param = new QuoteProductParam();
            param.campaignCode  = campaignCode;
            param.planCode = planCode;
            param.quoteSumInsured = quoteSumInsured;
            rateList = getQuoteProduct(param);
            if(rateList != null && rateList.size() >0 ){
                premiumRateMap.put(s,rateList);
            }
            System.debug('[getPremiumTable] rateList '+rateList);
        }
        return premiumRateMap;
    }
    
    public static Decimal calWithDiscount(Decimal premium, Decimal discountPercentage, String discountCode, Decimal Loading){
        return TMEsalesHelper.calWithDiscount(premium,discountPercentage,discountCode,Loading,false,null);
    }
    
    /*
     * calculate the premium with discount and loading
     * Discount 1: multiple-rating-factor: 95 & 97
     * Discount 2: PO-DISCOUNT-TYPE: 06 / 08 / 09/ 10
     */
    public static Decimal calWithDiscount(Decimal premium, Decimal discountPercentage, String discountCode, Decimal Loading, Boolean isSpecialProduct, Decimal modelFactor){
        Decimal finalPremium = 0;
        Decimal Discount1 = 0;
        Decimal Discount2 = 0;
        
        if(discountPercentage == null){
            discountPercentage = 0;
        }
        if(Loading == null){
            Loading = 0;
        }
        if(discountCode == '95' || discountCode == '97'){
            Discount1 = discountPercentage/100;
        }else if(discountCode == '06' || discountCode == '08' || discountCode == '09' || discountCode == '10'){
            Discount2 = discountPercentage/100;
        }else{
            Discount1 = discountPercentage/100;
        }
        
        
        /*DPSP-742
        * 1.    No discount / No loading = annual premium
        * 2.    With discount = annual premium * ( 1 – total discount) + 0.00005 (Round to integer)
        * 3.    With loading = annual premium + (annual premium * (fact loading / 100)
        * 4.    With discount and with loading = (annual premium + (annual premium * (fact loading / 100)) * (1 – total discount) + 0.00005 (Round to integer)
        */
        if(null != premium){//add by ken
            //finalPremium = (((premium + (premium * Loading).Round(System.RoundingMode.HALF_UP)) - ((premium + (premium * Loading).Round(System.RoundingMode.HALF_UP)) * Discount1).Round(System.RoundingMode.HALF_UP))*(1-Discount2)).Round(System.RoundingMode.HALF_UP);
            
            //finalPremium = (((premium + (premium * Loading)) - ((premium + (premium * Loading)) * Discount1)) * (1-Discount2)).Round(System.RoundingMode.HALF_UP);//due to DPSP-756
            //system.debug('[TMEsalesHelper] calWithDiscount() premium >> ' + premium);
            
            Decimal finalPremiumWithoutRounding = 0;
            Decimal specialPre = 0;
            if(!isSpecialProduct){
                specialPre = 0.00005;
            }else{
                specialPre = 0;
            }
            system.debug('[TMEsalesHelper] calWithDiscount() Discount1 = '+Discount1);
            system.debug('[TMEsalesHelper] calWithDiscount() Loading = '+Loading);
            system.debug('[TMEsalesHelper] calWithDiscount() modelFactor = '+modelFactor);
            system.debug('[TMEsalesHelper] calWithDiscount() premium = '+premium);
            system.debug('[TMEsalesHelper] calWithDiscount() specialPre = '+specialPre);
            
            /*if(Discount1 > 0 && Loading == 0){
                //for DPSP-952, ((premium * discount).round * modelFactor).round
                if(null != modelFactor){
                    finalPremiumWithoutRounding = (premium * (1 - Discount1)).Round(System.RoundingMode.HALF_UP) * modelFactor + specialPre;
                }else{
                    finalPremiumWithoutRounding = premium * (1 - Discount1) + specialPre;
                }                
            }else if(Discount1 == 0 && Loading > 0){
                finalPremiumWithoutRounding = premium + (premium * Loading/100);
            }else if(Discount1 > 0 && Loading > 0){
                finalPremiumWithoutRounding = (premium + (premium * Loading/100)) * (1 - Discount1) + specialPre;
            }else{
                finalPremiumWithoutRounding = premium;
            }*/
            if(Discount1 > 0 && Loading == 0){
                //for DPSP-952, ((premium * discount).round * modelFactor).round
                if(null != modelFactor){
                    system.debug(' (premium * (1 - Discount1)).Round(System.RoundingMode.HALF_UP):'+ (premium * (1 - Discount1)).Round(System.RoundingMode.HALF_UP));
                    // finalPremiumWithoutRounding = (premium * (1 - Discount1)).Round(System.RoundingMode.HALF_UP) * modelFactor + specialPre;
                    finalPremiumWithoutRounding = (premium - (premium * Discount1).Round(System.RoundingMode.HALF_UP)).Round(System.RoundingMode.HALF_UP) * modelFactor + specialPre;/* add by Jack on 2022-04-21 for project: Premium mismatch with IPAS */
                    system.debug('3 finalPremiumWithoutRounding:'+finalPremiumWithoutRounding);
                }else{
                    finalPremiumWithoutRounding = premium - (premium * Discount1).Round(System.RoundingMode.HALF_UP) + specialPre;
                }                
            }else if(Discount1 == 0 && Loading > 0){
                if(null != modelFactor){
                    finalPremiumWithoutRounding = (premium + (premium * Loading/100)).Round(System.RoundingMode.HALF_UP)*modelFactor;
                }else{
                    finalPremiumWithoutRounding = premium + (premium * Loading/100);
                }
            }else if(Discount1 > 0 && Loading > 0){
                if(null != modelFactor){
                    //finalPremiumWithoutRounding = ((premium + (premium * Loading/100)) * (1 - Discount1)).Round(System.RoundingMode.HALF_UP)*modelFactor + specialPre;//jack add for SUQ project premiun loading discount calculation
                    // finalPremiumWithoutRounding = ((premium * (1 - Discount1)).Round(System.RoundingMode.HALF_UP) + (premium * Loading/100)) *modelFactor + specialPre;//jack add for SUQ project premiun loading discount calculation
                    finalPremiumWithoutRounding = ((premium - (premium * Discount1).Round(System.RoundingMode.HALF_UP)).Round(System.RoundingMode.HALF_UP) + (premium * Loading/100)) *modelFactor + specialPre;/* add by Jack on 2022-04-21 for project: Premium mismatch with IPAS */
                    system.debug('old value:'+String.valueOf(((premium + (premium * Loading/100)) * (1 - Discount1)).Round(System.RoundingMode.HALF_UP)*modelFactor + specialPre));
                    system.debug('new value:'+finalPremiumWithoutRounding);
                }else{
                    //finalPremiumWithoutRounding = (premium + (premium * Loading/100)) * (1 - Discount1) + specialPre;//jack add for SUQ project premiun loading discount calculation
                    // finalPremiumWithoutRounding = premium * (1 - Discount1) + (premium * Loading/100)  + specialPre;//jack add for SUQ project premiun loading discount calculation
                    finalPremiumWithoutRounding = premium - (premium * Discount1).Round(System.RoundingMode.HALF_UP) + (premium * Loading/100)  + specialPre;/* add by Jack on 2022-04-21 for project: Premium mismatch with IPAS */
                    system.debug('old value:'+String.valueOf((premium + (premium * Loading/100)) * (1 - Discount1) + specialPre));
                    system.debug('new value:'+finalPremiumWithoutRounding);
                }
            }else{
                if(null != modelFactor){
                    finalPremiumWithoutRounding = premium * modelFactor;
                }else{
                    finalPremiumWithoutRounding = premium;
                }
            }
            //system.debug('[TMEsalesHelper] calWithDiscount() finalPremiumWithoutRounding = ' + finalPremiumWithoutRounding);
            finalPremium = finalPremiumWithoutRounding.Round(System.RoundingMode.HALF_UP);
            //system.debug('[TMEsalesHelper] calWithDiscount() finalPremium = ' + finalPremium);
        }        
        
        return finalPremium;
    }

    public static Decimal getFinalDiscountPercentage(Map<String, Decimal> discountPercentageMap){
        Decimal finalDiscountPercentage = 0;
        List<Decimal> discountPercentageList = new List<Decimal>();
        //system.debug('[TMEsalesHelper] getFinalDiscountPercentage().discountPercentageMap'+discountPercentageMap);
        if(discountPercentageMap != null){
            Decimal tempFinalDiscount = 0;
            Decimal childDiscount = 0;
            for(String discountType : discountPercentageMap.keySet()){
                if(discountPercentageMap.get(discountType) != null && discountPercentageMap.get(discountType)  >0){
                    Decimal discount = discountPercentageMap.get(discountType)/100; 
                    
                    if(discountType.equalsIgnoreCase('Child Discount')){//special handling for child discount
                        childDiscount = 1 - discount;
                    }else{
                        //added by ken, due to UAT ticket DPSP-742
                        if(tempFinalDiscount > 0){
                            tempFinalDiscount += discount;
                        }else{
                            tempFinalDiscount = discount;
                        }
                    }
                }
            }

            //system.debug('[getFinalDiscountPercentage] tempFinalDiscount = '+tempFinalDiscount);
            //system.debug('[getFinalDiscountPercentage] childDiscount = '+childDiscount);
            if(tempFinalDiscount > 0){
                if(childDiscount >0){
                    //tempFinalDiscount = 1- ((1-tempFinalDiscount) + (1-childDiscount)); //comment by ken, due to UAT ticket DPSP-742
                    tempFinalDiscount = tempFinalDiscount + (1-childDiscount);//added by ken, due to UAT ticket DPSP-742
                }
                
                //finalDiscountPercentage = (1 - tempFinalDiscount)*100;//comment by ken, due to UAT ticket DPSP-742
                finalDiscountPercentage = tempFinalDiscount*100;//added by ken, due to UAT ticket DPSP-742
                
            }else if(childDiscount >0){
                finalDiscountPercentage = (1 - childDiscount)*100;
            }

        }
        
        //system.debug('[getFinalDiscountPercentage] finalDiscountPercentage = '+finalDiscountPercentage);
        return finalDiscountPercentage;
    }
    
    // it's temporary
    // just copy "getFinalDiscountPercentage(Map<String, Decimal> discountPercentageMap)", just want to fix DPSP-773
    public static Decimal getFinalDiscountPercentage(Map<String, Decimal> discountPercentageMap, PersonInsured pi, ESalesUtility.rateTable r){
        Decimal finalDiscountPercentage = 0;
        List<Decimal> discountPercentageList = new List<Decimal>();
        //system.debug('[TMEsalesHelper] getFinalDiscountPercentage().discountPercentageMap='+discountPercentageMap);
        if(discountPercentageMap != null){
            Decimal tempFinalDiscount = 0;
            Decimal childDiscount = 0;
            for(String discountType : discountPercentageMap.keySet()){
                if(discountPercentageMap.get(discountType) != null && discountPercentageMap.get(discountType)  >0){
                    
                    //DPSP-773: For this product for Child, only Dental (DETG) not apply Child Discount. 
                    //system.debug('[TMEsalesHelper] preparePremiumAmt().pi.planProductMap.get(r.planCode)='+pi.planProductMap.get(r.planCode));
                    if('DETG'.equals(pi.planProductMap.get(r.planCode)) && pi.age < 18 && discountType.equalsIgnoreCase('CHILD DISCOUNT*')){
                        continue;
                    }
                    //Add by Owen, 2024.1.12 add for elite360 for child DETG2.
                    //Rancho_JOBR378_20240717 - CHILD DISCOUNT (GROUP) not support dental rider
                    if('DETG2'.equals(pi.planProductMap.get(r.planCode)) && pi.age < 18 && (discountType.equalsIgnoreCase('CHILD DISCOUNT*') || discountType.equalsIgnoreCase('CHILD DISCOUNT (GROUP)'))){
                        continue;
                    }
                    Decimal discount = discountPercentageMap.get(discountType)/100; 
                    
                    if(discountType.equalsIgnoreCase('Child Discount')){//special handling for child discount
                        childDiscount = 1 - discount;
                    }else{
                        /** comment by ken, due to UAT ticket DPSP-742
                        if(tempFinalDiscount > 0){
                            tempFinalDiscount = tempFinalDiscount * (1 - discount);
                        }else{
                            tempFinalDiscount = 1 - discount;
                        }
                        **/
                        //added by ken, due to UAT ticket DPSP-742
                        if(tempFinalDiscount > 0){
                            tempFinalDiscount += discount;
                        }else{
                            tempFinalDiscount = discount;
                        }
                    }
                }
            }

            //system.debug('[getFinalDiscountPercentage] tempFinalDiscount = '+tempFinalDiscount);
            //system.debug('[getFinalDiscountPercentage] childDiscount = '+childDiscount);
            if(tempFinalDiscount > 0){
                if(childDiscount >0){
                    //tempFinalDiscount = 1- ((1-tempFinalDiscount) + (1-childDiscount)); //comment by ken, due to UAT ticket DPSP-742
                    tempFinalDiscount = tempFinalDiscount + (1-childDiscount);//added by ken, due to UAT ticket DPSP-742
                }
                
                //finalDiscountPercentage = (1 - tempFinalDiscount)*100;//comment by ken, due to UAT ticket DPSP-742
                finalDiscountPercentage = tempFinalDiscount*100;//added by ken, due to UAT ticket DPSP-742
                
            }else if(childDiscount >0){
                finalDiscountPercentage = (1 - childDiscount)*100;
            }

        }

        /*
        if(!discountPercentageList.isEmpty()){

            Decimal tempFinalDiscount = 0;           
            for(Decimal discountPercentage : discountPercentageList){
                if(discountPercentage != null && discountPercentage > 0){
                    Decimal discount = discountPercentage/100;                    
                    if(tempFinalDiscount > 0){
                        tempFinalDiscount = tempFinalDiscount * (1 - discount);
                    }else{
                        tempFinalDiscount = 1 - discount;
                    }
                }
            }
            //system.debug('[getFinalDiscountPercentage] tempFinalDiscount = '+tempFinalDiscount);
            if(tempFinalDiscount > 0){
                finalDiscountPercentage = (1 - tempFinalDiscount)*100;
            }
        } 
        */
        //system.debug('[getFinalDiscountPercentage] finalDiscountPercentage = '+finalDiscountPercentage);
        return finalDiscountPercentage;
    }

    /*
    get quotation amount for each person
    */
    public List<PremiumAmt> calculateQuotation(Map<String,PersonInsured> personMap,Set<String> plancodeList, String campaignCode){
        return calculateQuotation(personMap,plancodeList,campaignCode,'Annual');
    }

    public List<PremiumAmt> calculateQuotation(Map<String,PersonInsured> personMap,Set<String> plancodeList, String campaignCode, String paymentFrequency){
        if(String.isBlank(paymentFrequency)){
            //system.debug('[EsalesHelper] calculateQuotation() paymentFrequency empty');
            paymentFrequency = 'Annual';
        }
        //system.debug('[EsalesHelper] calculateQuotation() paymentFrequency >> ' + paymentFrequency);
        
        //system.debug('[calculateQuotation] plancodeList: ' + plancodeList);
        //system.debug('[calculateQuotation] personMap: ' + personMap);
        List<PremiumAmt> resultList = new List<PremiumAmt>();
        List<ESalesUtility.rateTable> tempRateList = new List<ESalesUtility.rateTable>();
        PremiumAmt amt = new PremiumAmt();
        PremiumAmt amtPI = new PremiumAmt();
        Map<String, List<ESalesUtility.rateTable>> premiumRateMap = getPremiumTable(plancodeList, campaignCode);  //get premium from WS        
        Set<String> personKeySet = personMap.keySet();  // personKeySet
        HttpCalloutVO.Discount discount = new HttpCalloutVO.Discount();
        //system.debug('[calculateQuotation] premiumRateMap: ' + premiumRateMap);
        //system.debug('[calculateQuotation] personKeySet: ' +personKeySet);

        Integer count = 0;
        Integer riderCnt = 0;
        List<String> tempPlanList = new List<String>();
        PersonInsured pi = new PersonInsured();
        Decimal subTotal = 0;
        Boolean basicDataMappedFlag = false;
        Boolean riderDataMappedFlag = false;
        
        for(String k : personKeySet){//person key set           
            //system.debug('[calculateQuotation] pi start========================'+K+'==============');
            count = count + 1; //person count
            riderCnt = 0; //rider count
            subTotal = 0;           
            pi = personMap.get(k);
            //system.debug('[TMEsalesHelper] calculateQuotation().pi = ' +pi);
            //system.debug('[TMEsalesHelper] calculateQuotation().pi.benefitlevel='+pi.benefitlevel);            
            if(pi != null && String.isNotBlank(pi.planCode)){               
                tempPlanList = pi.planCode.split(';'); 
                //system.debug('[TMEsalesHelper] calculateQuotation().tempPlanList='+tempPlanList);
                for(String p : tempPlanList){
                    //system.debug('[TMEsalesHelper] calculateQuotation().pi.planProductMap.get(p)='+pi.planProductMap.get(p));
                    //add by ken, for SP100 product's special riders, its riders' riderBenefitlevel should match the rider plan level in GET_QUOTE WS response
                    String riderBenefitlevel = null;
                    //system.debug('[TMEsalesHelper] calculateQuotation(). pi.availableRiderBenefitlevelItemList='+ pi.availableRiderBenefitlevelItemList);
                    for(TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem ai : pi.availableRiderBenefitlevelItemList){
                        if(ai.selectedRiderCode == p){
                            riderBenefitlevel = ai.benefitlevel;
                        }
                    }
                    //system.debug('[calculateQuotation] loop plan start p='+p);
                    //Rancho_HKITSFDC402_20250930 - add sum insured
                    String tempPlanCode = p;
                    if(String.isNotBlank(pi.quoteSumInsured) && p.equals(pi.basicPlanCode)){
                        tempPlanCode = p + '_' + pi.quoteSumInsured;
                    }
                    System.debug('tempPlanCode: '+tempPlanCode);
                    if(premiumRateMap.containskey(tempPlanCode)){
                        tempRateList = new List<ESalesUtility.rateTable>();
                        tempRateList = premiumRateMap.get(tempPlanCode);
                    } 
                    riderDataMappedFlag = false;
                    basicDataMappedFlag = false;
                    //system.debug('[TMEsalesHelper] calculateQuotation().tempRateList='+tempRateList);
                    for(ESalesUtility.rateTable r: tempRateList){                       
                        if(r.modalFactor != null){
                            //system.debug('[TMEsalesHelper] calculateQuotation().r.planCode='+r.planCode);
                            //system.debug('[TMEsalesHelper] calculateQuotation().r.planlevel='+r.planlevel);
                            //system.debug('[TMEsalesHelper] calculateQuotation().p='+p);
                            //system.debug('[TMEsalesHelper] pi.planProductMap.get(p)='+pi.planProductMap.get(p));
                            //Special solution for product SP100
                            if('SAHIP;SATPD;SPTIB;STP'.contains(pi.planProductMap.get(p)) || 'SAHIP;SATPD;SPTIB;STP'.contains(p)){
                                //system.debug('[TMEsalesHelper] calculateQuotation() SAHIP;SATPD;SPTIB;STP matched');
                                //for basic plan, pi.benefitlevel == r.planlevel &&
                                //system.debug('[TMEsalesHelper] calculateQuotation() pi.benefitlevel='+pi.benefitlevel);
                                //system.debug('[TMEsalesHelper] calculateQuotation() r.planlevel='+r.planlevel);
                                //system.debug('[TMEsalesHelper] calculateQuotation() pi.basicPlanCode='+pi.basicPlanCode);
                                //system.debug('[TMEsalesHelper] calculateQuotation() r.planCode='+r.planCode);
                                //system.debug('[TMEsalesHelper] calculateQuotation() r.age='+personMap.get(k).age);
                                //system.debug('[TMEsalesHelper] calculateQuotation() r.sex='+r.sex);
                                //system.debug('[TMEsalesHelper] calculateQuotation() personMap.get(k).gender='+personMap.get(k).gender);
                                //system.debug('[TMEsalesHelper] calculateQuotation() r.smokeStatus='+r.smokeStatus);
                                //system.debug('[TMEsalesHelper] calculateQuotation() personMap.get(k).smokingStatus='+personMap.get(k).smokingStatus);
                                //system.debug('[TMEsalesHelper] calculateQuotation() pi.riderPlanCode='+pi.riderPlanCode);
                                if(pi.benefitlevel == r.planlevel && pi.basicPlanCode == r.planCode && r.age == personMap.get(k).age && r.sex == personMap.get(k).gender && r.smokeStatus == personMap.get(k).smokingStatus){
                                    //system.debug('[TMEsalesHelper] calculateQuotation().r='+r);
                                    //system.debug('[calculateQuotation] Basic Plan Matched [start] 1');
                                    basicDataMappedFlag = true;
                                    amtPI = preparePremiumAmt(k,false,pi,r,discount,count,riderCnt,paymentFrequency);
                                    if(amtPI.actualPremium != null){
                                        subTotal = subTotal + amtPI.actualPremium;
                                    }
                                    break;
                                    //system.debug('[calculateQuotation] Basic Plan Matched [end] ');
                                }
                                //for riders, riderBenefitlevel == r.planlevel &&
                                //system.debug('[TMEsalesHelper] calculateQuotation() riderBenefitlevel='+riderBenefitlevel);
                                //system.debug('[TMEsalesHelper] calculateQuotation() r.planlevel='+r.planlevel);
                                if(riderBenefitlevel == r.planlevel && String.isNotBlank(pi.riderPlanCode) && pi.riderPlanCode.contains(r.planCode) && r.age == personMap.get(k).age && r.sex == personMap.get(k).gender && r.smokeStatus == personMap.get(k).smokingStatus){
                                    //system.debug('[TMEsalesHelper] calculateQuotation().r='+r);
                                    //system.debug('[calculateQuotation] Rider Matched [start] ');                                      
                                    riderDataMappedFlag = true;
                                    riderCnt = riderCnt + 1;
                                    amt = preparePremiumAmt(k,true,pi,r,discount,count,riderCnt,paymentFrequency);
                                    if(amt.actualPremium != null){
                                        subTotal = subTotal + amt.actualPremium;
                                    }
                                    resultList.add(amt);
                                    break;
                                    //system.debug('[calculateQuotation] Rider Matched [end] ');
                                }
                            //Special solution for product PMGH , use sex:male to match the price whatever what pi's sex is
                            }else if('@PMGH;DENGH;HIPGH;OPGH;SMMGH'.contains(pi.planProductMap.get(p))){
                                //system.debug('[TMEsalesHelper] calculateQuotation() DENGH;HIPGH;OPGH;SMMGH matched');
                                //for basic plan
                                if(pi.basicPlanCode == r.planCode && r.age == personMap.get(k).age && r.sex == 'M' && r.smokeStatus == personMap.get(k).smokingStatus){
                                    //system.debug('[calculateQuotation] Basic Plan Matched [start] 2');
                                    basicDataMappedFlag = true;
                                    amtPI = preparePremiumAmt(k,false,pi,r,discount,count,riderCnt,paymentFrequency);
                                    if(amtPI.actualPremium != null){
                                        subTotal = subTotal + amtPI.actualPremium;
                                    }
                                    break;
                                    //system.debug('[calculateQuotation] Basic Plan Matched [end] ');
                                }                                
                                //for riders
                                if(String.isNotBlank(pi.riderPlanCode) && pi.riderPlanCode.contains(r.planCode) && r.age == personMap.get(k).age && r.sex == 'M' && r.smokeStatus == personMap.get(k).smokingStatus){
                                    //system.debug('[calculateQuotation] Rider Matched [start] ');  
                                    riderDataMappedFlag = true;
                                    riderCnt = riderCnt + 1;
                                    amt = preparePremiumAmt(k,true,pi,r,discount,count,riderCnt,paymentFrequency);
                                    if(amt.actualPremium != null){
                                        subTotal = subTotal + amt.actualPremium;
                                    }
                                    resultList.add(amt);
                                    break;
                                    //system.debug('[calculateQuotation] Rider Matched [end] ');
                                }
                            //solution for normal product     
                            }else{
                                
                                //for basic plan
                                if(pi.basicPlanCode == r.planCode && r.age == personMap.get(k).age && r.sex == personMap.get(k).gender && r.smokeStatus == personMap.get(k).smokingStatus){
                                    //system.debug('[calculateQuotation] Basic Plan Matched [start] 3');
                                    basicDataMappedFlag = true;
                                    amtPI = preparePremiumAmt(k,false,pi,r,discount,count,riderCnt,paymentFrequency);
                                    if(amtPI.actualPremium != null){
                                        subTotal = subTotal + amtPI.actualPremium;
                                    }
                                    break;
                                    //system.debug('[calculateQuotation] Basic Plan Matched [end] ');
                                }                                
                                //for riders
                                if(String.isNotBlank(pi.riderPlanCode) && pi.riderPlanCode.contains(r.planCode) && r.age == personMap.get(k).age && r.sex == personMap.get(k).gender && r.smokeStatus == personMap.get(k).smokingStatus){
                                    //system.debug('[calculateQuotation] Rider Matched [start] ');  
                                    riderDataMappedFlag = true;
                                    riderCnt = riderCnt + 1;
                                    amt = preparePremiumAmt(k,true,pi,r,discount,count,riderCnt,paymentFrequency);
                                    if(amt.actualPremium != null){
                                        subTotal = subTotal + amt.actualPremium;
                                    }
                                    resultList.add(amt);
                                    break;
                                    //system.debug('[calculateQuotation] Rider Matched [end] ');
                                }                                
                            }                            
                        }
                    }//end for tempRateList
                    //system.debug('[TMEsalesHelper] calculateQuotation().subTotal='+subTotal);
                    //system.debug('[TMEsalesHelper] calculateQuotation().amt.actualPremium='+amt.actualPremium);
                    //system.debug('[calculateQuotation] basicDataMappedFlag='+basicDataMappedFlag+',riderDataMappedFlag='+riderDataMappedFlag);
                    
                    // if no data was mapped, New null for premium table
                    if(!basicDataMappedFlag && p == pi.basicPlanCode){
                        amtPI = preparePremiumAmt(k,false,pi,null,discount,count,riderCnt,paymentFrequency);
                    }
                    if(!riderDataMappedFlag && String.isNotBlank(pi.riderPlanCode) && p != pi.basicPlanCode){
                        //system.debug('[TMEsalesHelper] calculateQuotation().pi.riderPlanCode='+pi.riderPlanCode+' pi.basicPlanCode='+pi.basicPlanCode+' p='+p);
                        riderCnt = riderCnt + 1; 
                        amt = preparePremiumAmt(k,true,pi,null,discount,count,riderCnt,paymentFrequency);
                        amt.productCode = p;
                        amt.premiumDescription = p;
                        resultList.add(amt);                        
                    }
                    //system.debug('[calculateQuotation] loop plan end p='+p);
                }//end for tempPlanList
                
                if(amtPI.premiumPerson != null && amtPI.premiumPerson == k){   
                    //system.debug('[TMEsalesHelper] calculateQuotation().subTotal='+subTotal);
                    //system.debug('[TMEsalesHelper] calculateQuotation().amt.actualPremium='+amt.actualPremium);
                    amtPI.subTotal = subTotal;
                    resultList.add(amtPI);                
                }                  
            }//end if pi
            
            
            //system.debug('[calculateQuotation] pi end========================'+K+'==============');
        }//end for personkeyset

        if(resultList != null){
            resultList.sort();
        }
        //system.debug('[calculateQuotation] end, resultList.size: ' +resultList.size());
        return resultList;
    }
    
    public PremiumAmt preparePremiumAmt(String k, Boolean isRider, PersonInsured pi, ESalesUtility.rateTable r, HttpCalloutVO.Discount discount,Integer piIndex,Integer riderIndex,String paymentFrequency){
        //system.debug('[TMEsalesHelper] preparePremiumAmt() piIndex >> ' + piIndex);
        //system.debug('[TMEsalesHelper] preparePremiumAmt() isRider >> ' + isRider);
        //system.debug('[TMEsalesHelper] preparePremiumAmt() riderIndex >> ' + riderIndex);
        //system.debug('[TMEsalesHelper] preparePremiumAmt() paymentFrequency >> ' + paymentFrequency);
        //system.debug('[TMEsalesHelper] preparePremiumAmt() k >> ' + k);
        //system.debug('[TMEsalesHelper] preparePremiumAmt() pi >> ' + pi);
        system.debug('[TMEsalesHelper] preparePremiumAmt() r >> ' + r);
        system.debug('[TMEsalesHelper] preparePremiumAmt() discount >> ' + discount);
        
        //List<Decimal> discountList = new List<Decimal>();       
        //discountList.addAll(pi.discountMap.values());
        Map<String, Decimal> tempdiscountMap = new Map<String, Decimal>();
        tempdiscountMap = pi.discountMap;
        //added by ken
        Decimal annualrate;
        Decimal originalPremiumMonth;
        Decimal modalFactor = null;
        String planCode = pi.planProductMap.get(pi.basicPlanCode);
        Boolean isSpecialProductCode = specialProductCodeList.contains(planCode);
        
        if(isSpecialProductCode){
            QuoteParam param = new QuoteParam();
            param.campaignCode = getQuoteProductCodeMap.get(planCode);// product code            
            param.planLevel = pi.benefitLevel;
            param.isMale = (pi.gender == 'M');
            param.isSmoker = (pi.smokingStatus == 'true');
            param.lastname = '';
            param.firstname = '';
            param.dob = pi.dateOfBirth;
            param.email = '';
            param.phone = '';
            param.eligible = insuredTypeMap.get(pi.insuredType);
            QuoteResult qr = getQuote(param);
            //system.debug('>>>> ' + qr.BPAnnualPrem);
            //system.debug('>>>> ' + qr.BPMonthlyPrem);
            annualrate = Decimal.valueOf(qr.BPAnnualPrem);
            originalPremiumMonth = annualrate * Decimal.valueOf(qr.ModalFactor);
            //annualrate = originalPremiumMonth * 12 ; // changed by Andy for these product annual premium use monthly * 12 (related DPSP-827)
            
        //for DPSP-755 SP100 use new WS to get annual premium. But not use special calcualte function   
        }else if('@SP100' == planCode){
            QuoteParam param = new QuoteParam();
            param.campaignCode = getQuoteProductCodeMap.get(planCode);// product code
            param.planLevel = pi.benefitLevel;
            //system.debug('[TMEsalesHelper] r='+r);
            //system.debug('[TMEsalesHelper] param='+param);
            if(isRider){
                param.campaignCode = r.planCode;
                param.planLevel = r.planlevel;
            }
            param.isMale = (pi.gender == 'M');
            param.isSmoker = (pi.smokingStatus == 'true');
            param.lastname = '';
            param.firstname = '';
            param.dob = pi.dateOfBirth;
            param.email = '';
            param.phone = '';
            param.eligible = insuredTypeMap.get(pi.insuredType);
            QuoteResult qr = getQuote(param);
            //system.debug('>>>> ' + qr.BPAnnualPrem);
            //system.debug('>>>> ' + qr.BPMonthlyPrem);
            annualrate = Decimal.valueOf(qr.BPAnnualPrem);
            //originalPremiumMonth = annualrate * Decimal.valueOf(qr.ModalFactor);
            modalFactor = Decimal.valueOf(qr.ModalFactor);
        } else {
            if(r != null){
                annualrate = r.annualrate;
                modalFactor = r.modalFactor;
            }
        }

        PremiumAmt amt = new PremiumAmt();
        amt.premiumPerson = k;
        amt.isRider = isRider; 
        amt.productcode = r == null ? null : pi.planProductMap.get(r.planCode);
        // Rancho_HKITSFDC402_20250930 - add sum insured
        if(String.isNotBlank(pi.quoteSumInsured)){
            amt.sumInsured = Decimal.valueOf(pi.quoteSumInsured);
        }
        Integer displayOrderNum = Integer.valueOf(piIndex + '00'); 
        if(isRider){ //rider
            amt.premiumDescription = amt.productcode;
            amt.displayOrder = displayOrderNum + riderIndex;
        }else{ //basic plan
            //amt.premiumDescription = 'Person Insured No.' + piIndex;
            amt.premiumDescription = amt.productcode;
            amt.displayOrder = displayOrderNum;
            //amt.personInsuredIndex = 'Person Insured No.' + piIndex;
            amt.personInsuredIndex = pi.personName;
        }       
        if(r != null){
            amt.originalPremiumMonth = (null != modalFactor)? annualrate*modalFactor  : originalPremiumMonth;//changed by ken
            amt.annualPremium = annualrate;
            //system.debug('[TMEsalesHelper] amt.annualPremium + '+amt.annualPremium+'r.annualrate'+r.annualrate);
            amt.discountPercent = discount.discountPercentage;        
            if(discount.discountPercentage != null && discount.discountPercentage > 0){
                amt.discountPremium = (annualrate * (discount.discountPercentage/100)).Round(System.RoundingMode.HALF_UP);
                //discountList.add(amt.discountPercent);
            }else{
                amt.discountPremium = 0;
            }
            amt.medicalLoadingPercent = (pi.loading == null ? 0 : pi.loading);
            amt.medicalLoadingAmount = (annualrate * amt.medicalLoadingPercent / 100).Round(System.RoundingMode.HALF_UP); 
            //system.debug('[TMEsalesHelper] preparePremiumAmt().tempdiscountMap='+tempdiscountMap);
            //origin: Decimal finalDiscountPercentage = TMEsalesHelper.getFinalDiscountPercentage(tempdiscountMap);
            // temporary
            Decimal finalDiscountPercentage = TMEsalesHelper.getFinalDiscountPercentage(tempdiscountMap, pi, r);
            //system.debug('[TMEsalesHelper] preparePremiumAmt().finalDiscountPercentage='+finalDiscountPercentage);            
            if(finalDiscountPercentage != null && finalDiscountPercentage > 0){
                amt.totalDiscountPercent = finalDiscountPercentage;
                amt.totalDiscountPremium = (annualrate * (finalDiscountPercentage/100)).Round(System.RoundingMode.HALF_UP);  
            }else{
                amt.totalDiscountPercent = 0;
                amt.totalDiscountPremium = 0;
            }
            
            if(paymentFrequency.equalsIgnoreCase('Monthly')){
                amt.originalPremium = amt.originalPremiumMonth.Round(System.RoundingMode.HALF_UP);
                amt.loadingPremium = (amt.originalPremium * amt.medicalLoadingPercent/100).Round(System.RoundingMode.HALF_UP); 
                // if(null != pi.planProductMap.get(pi.basicPlanCode) && pi.planProductMap.get(pi.basicPlanCode).contains('PMGH')){
                //     amt.actualPremium = calWithDiscount(amt.annualPremium, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, modalFactor);
                // }else{
                    // amt.actualPremium = calWithDiscount(amt.originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, null);/* add by Jack on 2022-03-25 for project: Premium mismatch with IPAS */
                // amt.annualPremium=83;
                amt.actualPremium = calWithDiscount(amt.annualPremium, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, modalFactor);/* add by Jack on 2022-03-25 for project: Premium mismatch with IPAS */
                system.debug('amt.actualPremium:'+amt.actualPremium);
                // }                
                //amt.actualPremium = calWithDiscount(amt.originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode);
            }else if(paymentFrequency.equalsIgnoreCase('Quarterly')){
                amt.originalPremium = amt.originalPremiumMonth.Round(System.RoundingMode.HALF_UP) * 3;
                amt.loadingPremium = (amt.originalPremium * amt.medicalLoadingPercent/100).Round(System.RoundingMode.HALF_UP); 
                if(null != pi.planProductMap.get(pi.basicPlanCode) && pi.planProductMap.get(pi.basicPlanCode).contains('PMGH')){
                    amt.actualPremium = calWithDiscount(amt.annualPremium, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, modalFactor) * 3;
                }else if(null != pi.planProductMap.get(pi.basicPlanCode) && pi.planProductMap.get(pi.basicPlanCode).contains('SP100')){//DPSP-1078
                    //amt.actualPremium = calWithDiscount(amt.annualPremium, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, modalFactor) * 3;
                    if(null == amt.totalDiscountPercent)
                        amt.totalDiscountPercent = 0;
                    amt.actualPremium = (amt.annualPremium * (1-amt.totalDiscountPercent/100) * modalFactor * 3).Round(System.RoundingMode.HALF_UP);
                    
                }else{
                    amt.actualPremium = calWithDiscount(amt.originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, null) * 3;
                }
                //amt.actualPremium = calWithDiscount(amt.originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode) * 3;
            }else if(paymentFrequency.equalsIgnoreCase('Semi Annually')){
                amt.originalPremium = amt.originalPremiumMonth.Round(System.RoundingMode.HALF_UP) * 6;
                amt.loadingPremium = (amt.originalPremium * amt.medicalLoadingPercent/100).Round(System.RoundingMode.HALF_UP); 
                if(null != pi.planProductMap.get(pi.basicPlanCode) && pi.planProductMap.get(pi.basicPlanCode).contains('PMGH')){
                    amt.actualPremium = calWithDiscount(amt.annualPremium, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, modalFactor) * 6;
                }else if(null != pi.planProductMap.get(pi.basicPlanCode) && pi.planProductMap.get(pi.basicPlanCode).contains('SP100')){
                    if(null == amt.totalDiscountPercent)
                        amt.totalDiscountPercent = 0;
                    amt.actualPremium = (amt.annualPremium * (1-amt.totalDiscountPercent/100) * 0.5).Round(System.RoundingMode.HALF_UP);
                }else{
                    amt.actualPremium = calWithDiscount(amt.originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, null) * 6;
                }
                //amt.actualPremium = calWithDiscount(amt.originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode) * 6;
            }else{
                if(null == modalFactor){
                    amt.originalPremium = amt.originalPremiumMonth.Round(System.RoundingMode.HALF_UP) * 12;
                    amt.loadingPremium = (amt.originalPremium * amt.medicalLoadingPercent/100).Round(System.RoundingMode.HALF_UP); 
                    
                    amt.actualPremium = calWithDiscount(amt.originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, null) * 12;
                }else{
                    amt.originalPremium = amt.annualPremium;
                    amt.loadingPremium = (amt.originalPremium * amt.medicalLoadingPercent/100).Round(System.RoundingMode.HALF_UP); 
                    
                    amt.actualPremium = calWithDiscount(amt.annualPremium, amt.totalDiscountPercent, null, pi.loading, isSpecialProductCode, null);
                }
                
            }
            
            //amt.actualPremium = (null != modalFactor) ? calWithDiscount(annualrate, amt.totalDiscountPercent, null, pi.loading) : (calWithDiscount(originalPremiumMonth, amt.totalDiscountPercent, null, pi.loading, true) * 12) ;
        }
        amt.policyId = pi.policyId;
        amt.benefitLevel = pi.benefitLevel; 
        //for PMGH
        /* add by Jack on 2022-03-25 for project: Premium mismatch with IPAS */
        // if(null != pi.planProductMap.get(pi.basicPlanCode) && (pi.planProductMap.get(pi.basicPlanCode).contains('PMGH') || pi.planProductMap.get(pi.basicPlanCode).contains('SP100'))){
        amt.modalFactor = modalFactor;
        // }        
        return amt;
    }

    /*
     * Get quote result: premium amount
     */
    public class PremiumAmt implements Comparable{
        public String premiumPerson {get; set;}
        public String premiumDescription {get; set;}
        public Decimal originalPremiumMonth {get; set;}
        public Decimal annualPremium {get; set;}
        public Decimal discountPercent {get; set;} // initialized discount: from WS
        public Decimal discountPremium {get; set;} // initialized discount Premium: from WS
        public Decimal medicalLoadingPercent {get; set;}
        public Decimal medicalLoadingAmount {get; set;}
        public Decimal actualPremium {get; set;}
        public Decimal subTotal {get; set;}
        public Integer displayOrder {get; set;}
        public Boolean isRider{get; set;}
        public Decimal totalDiscountPercent {get; set;} // total Percentage : totalDiscountPercent = discountPercent * discount1Percent * discount2Percent * paymentDiscountPercent * mandatoryDiscountPercent
        public Decimal totalDiscountPremium {get; set;} // total Premium
        public String productCode {get;set;} // Rider Code or Product Code
        public String policyId{get;set;} // PI Policy ID
        public String benefitLevel{get;set;} // PI Benefit Level
        public String campaignCode {get;set;}  // campaign code  - base on plan code
        
        //New display premium table
        public Decimal originalPremium {get;set;} //Based on selected payment frequency to display Annual/Monthly Premium
        public Decimal loadingPremium {get;set;} //Based on selected payment frequency to display Annual/Monthly Premium
        public String personInsuredIndex {get;set;} //e.g.  Person Insured No.1
        
        public Decimal modalFactor {get;set;}//for PMGH
        
        public Decimal totalCoupon{get;set;}//AM project coupon jack add total coupon
        
        public Decimal sumInsured {get;set;}// Rancho_HKITSFDC402_20250930 - add sum insured
        
        public Integer compareTo(Object amt){
            PremiumAmt amt2 = (PremiumAmt)amt;            
            
            if(this.displayOrder != null && amt2.displayOrder != null){
                if(this.displayOrder > amt2.displayOrder){
                    return 1;
                } else if(this.displayOrder < amt2.displayOrder){
                    return -1;
                } else {
                    return 0;
                }
            } else {
                if(this.displayOrder != null){
                    return -1;
                } else if (amt2.displayOrder != null){
                    return 1;
                } else {
                    return 0;
                }
            }
        }
    }
    
    /*
     * Get product information for basic plan from Customer Portal by product code list
     * @param product code list
     * @return map
     *         - key: product code + rate scale
     *         - value: product
     */
    public static Map<String, Portalproduct> getProductMappingByBasicPlan(Set<String> selectedPlanList){
        Map<String, Portalproduct> productMap = new Map<String, Portalproduct>();
        String key;
        Portalproduct prd = new Portalproduct();
        //Get corresponding information from portal product
        For(Product__c p : [Select id, Plan_Code__c, Campaign_Code__c, Rate_Scale__c, Offer_Code__c, Product_Code__c,
                            Area_of_Coverage__c, Deductible__c, Plan_Level__c, Plan_Option__c
                            From Product__c 
                            Where RecordType.DeveloperName = 'Plan' and Product_Code__c IN :selectedPlanList]){
            key = p.Product_Code__c + '_' + p.Rate_Scale__c;
            prd = new Portalproduct();
            if(!productMap.containsKey(key)){
                prd.productCode = p.Product_Code__c;
                prd.campaignCode = p.Campaign_Code__c;
                prd.planCode = p.Plan_Code__c;
                prd.deductible = p.Deductible__c;
                prd.areaOfCoverage = p.Area_of_Coverage__c;
                prd.planLevel = p.Plan_Level__c;
                prd.planOption = p.Plan_Option__c;
                prd.offerCode = p.Offer_Code__c;
                if(p.Rate_Scale__c != null){
                    prd.rateScale = String.valueOf(p.Rate_Scale__c);
                }
                productMap.put(key, prd);
            }
        }
        //system.debug('[getProductMappingByBasicPlan] productMap.size='+productMap.size());
        return productMap;
    }
    
    /*
     * Get product information for rider from Customer Portal by product code list and basic plan
     * @param product code list
     * @return map
     *         - key: product code + rate scale
     *         - value: product
     */
    public static Map<String, Portalproduct> getProductMappingByRiders(Set<String> selectedPlanList, Portalproduct basicPlan){
        //system.debug('[getProductMappingByRiders] selectedPlanList = '+selectedPlanList+': Portalproduct='+basicPlan);
        Map<String, Portalproduct> productMap = new Map<String, Portalproduct>();
        String key;
        Portalproduct prd = new Portalproduct();
        //Get corresponding information from portal product
        List<Product__c> productList = new List<Product__c>();
        // Elite Product need specific filter Parent_Product_Code__c
        /*if('NELG;NESG'.contains(basicPlan.productCode))
            productList = [Select id, Plan_Code__c, Campaign_Code__c, Rate_Scale__c, Offer_Code__c, Product_Code__c,
                            Area_of_Coverage__c, Deductible__c, Plan_Level__c, Plan_Option__c
                            From Product__c 
                            Where RecordType.DeveloperName = 'Plan' and Product_Code__c IN :selectedPlanList
                            And (Area_of_Coverage__c = :basicPlan.areaOfCoverage OR Area_of_Coverage__c = null)
                            And (Deductible__c = :basicPlan.deductible OR Deductible__c = null)
                            And (Plan_Level__c = :basicPlan.planLevel OR Plan_Level__c = null)
                            And (Plan_Option__c = :basicPlan.planOption OR Plan_Option__c = null)
                            And (Parent_Product_Code__c = :basicPlan.productCode OR Parent_Product_Code__c = null)
                            And Child_Raid_Up_Plan__c = false];
        else*/
            productList = [Select id, Plan_Code__c, Campaign_Code__c, Rate_Scale__c, Offer_Code__c, Product_Code__c,
                            Area_of_Coverage__c, Deductible__c, Plan_Level__c, Plan_Option__c
                            From Product__c 
                            Where RecordType.DeveloperName = 'Plan' and Product_Code__c IN :selectedPlanList
                            And (Area_of_Coverage__c = :basicPlan.areaOfCoverage OR Area_of_Coverage__c = null)
                            And (Deductible__c = :basicPlan.deductible OR Deductible__c = null)
                            And (Plan_Level__c = :basicPlan.planLevel OR Plan_Level__c = null)
                            And (Plan_Option__c = :basicPlan.planOption OR Plan_Option__c = null)
                            And Child_Raid_Up_Plan__c = false
                            And Removed_From_TM__c = false];
        
        For(Product__c p : productList){
            key = p.Product_Code__c + '_' + p.Rate_Scale__c;
            prd = new Portalproduct();
            if(!productMap.containsKey(key)){
                prd.productCode = p.Product_Code__c;
                prd.campaignCode = p.Campaign_Code__c;
                prd.planCode = p.Plan_Code__c;
                prd.deductible = p.Deductible__c;
                prd.areaOfCoverage = p.Area_of_Coverage__c;
                prd.planLevel = p.Plan_Level__c;
                prd.planOption = p.Plan_Option__c;
                prd.offerCode = p.Offer_Code__c;
                if(p.Rate_Scale__c != null){
                    prd.rateScale = String.valueOf(p.Rate_Scale__c);
                }
                productMap.put(key, prd);
            }
        }        
        //system.debug('[getProductMappingByRiders] productMap.size='+productMap.size());
        return productMap;
    }
    
    
    
    public static Map<String, Portalproduct> getProductMappingByRidersAndBenefit(Set<String> selectedPlanList, List<TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem> availableRiderBenefitlevelItemList, Portalproduct basicPlan){
        
        //system.debug('[getProductMappingByRiders] selectedPlanList = '+selectedPlanList+': Portalproduct='+basicPlan+ ' availableRiderBenefitlevelItemList : ' + availableRiderBenefitlevelItemList);
        Map<String, Portalproduct> productMap = new Map<String, Portalproduct>();
        String key;
        Portalproduct prd = new Portalproduct();
        
        //convert availableRiderBenefitlevelItemList to Map<RiderCode,BenefitLevel>
        Map<String,String> riderCodeBenefitLevelMap = new Map<String,String>();
        if(!availableRiderBenefitlevelItemList.isEmpty()){
            for(TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem item : availableRiderBenefitlevelItemList){
                riderCodeBenefitLevelMap.put(item.selectedRiderCode, item.benefitlevel);
            }
        }
        
        //Get corresponding information from portal product
        String param1 = basicPlan.areaOfCoverage;
        String param2 = basicPlan.deductible;
        String param3 = basicPlan.planLevel;
        String param4 = basicPlan.planOption;
        String param5 = basicPlan.offerCode;
        String sql = 'Select id, Plan_Code__c, Campaign_Code__c, Rate_Scale__c, Offer_Code__c, Product_Code__c, '
                        +'Area_of_Coverage__c, Deductible__c, Plan_Level__c, Plan_Option__c '
                        +'From Product__c '
                        +'Where RecordType.DeveloperName = \'Plan\' and Product_Code__c IN :selectedPlanList '
                        +'And (Area_of_Coverage__c = :param1 OR Area_of_Coverage__c = null) '
                        +'And (Deductible__c = :param2 OR Deductible__c = null) '
                        +'And (Plan_Level__c = :param3 OR Plan_Level__c = null) '
                        +'And (Plan_Option__c = :param4 OR Plan_Option__c = null) '
                        +'And Child_Raid_Up_Plan__c = false '
                        +'AND (Offer_code__c = :param5 OR  Offer_code__c = null) ';
        
        List<Product__c> riderList = Database.query(sql);
        
        for(Product__c p : riderList){
            if(riderCodeBenefitLevelMap.get(p.Product_Code__c) == String.valueOf(p.Rate_Scale__c)){
                key = p.Product_Code__c + '_' + p.Rate_Scale__c;
                prd = new Portalproduct();
                prd.productCode = p.Product_Code__c;
                prd.campaignCode = p.Campaign_Code__c;
                prd.planCode = p.Plan_Code__c;
                prd.deductible = p.Deductible__c;
                prd.areaOfCoverage = p.Area_of_Coverage__c;
                prd.planLevel = p.Plan_Level__c;
                prd.planOption = p.Plan_Option__c;
                prd.offerCode = p.Offer_Code__c;
                if(p.Rate_Scale__c != null){
                    prd.rateScale = String.valueOf(p.Rate_Scale__c);
                }
                productMap.put(key, prd);
            }
        }        
        //system.debug('[getProductMappingByRiders] productMap.size='+productMap.size());
        return productMap;
    }
    
    public static Map<String, Portalproduct> getProductMappingByRidersAndBenefit(Map<String, List<String>> benefitLevelRiderCode, Map<String, Portalproduct> basicProductMap, String productCode){
        
        Map<String, Portalproduct> resultProductMap = new Map<String, Portalproduct>();
        Integer i = 0;
        for(String benefitLevel : benefitLevelRiderCode.keySet()){
            Portalproduct basicPlan = basicProductMap.get(productCode + '_'+ benefitLevel);//benefitl level of selected rider
            Set<String> riderCodeSet = new Set<String>();
            riderCodeSet.addAll(benefitLevelRiderCode.get(benefitLevel));//the same benefit level rider code list
            Map<String, Portalproduct> riderPortalProduct = getProductMappingByRiders(riderCodeSet, basicPlan);
            for(Portalproduct pp : riderPortalProduct.values()){
                resultProductMap.put(i+'', pp);//the map key is Meaningless, just for return the same result type as getProductMappingByRiders()
                ++i;
            }
            ++i;
        }
        return resultProductMap;
    }

    /**
    * for Combo product: only has a dummy benifity level. riders has mutiple level
    **/
    public static Map<String, Portalproduct> getProductMappingByRidersAndBenefit(Set<String> selectedPlanList, List<TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem> availableRiderBenefitlevelItemList, Portalproduct basicPlan, Boolean dummyBenefit){
        
        //system.debug('[getProductMappingByRiders] selectedPlanList = '+selectedPlanList+': Portalproduct='+basicPlan+ ' availableRiderBenefitlevelItemList : ' + availableRiderBenefitlevelItemList);
        Map<String, Portalproduct> productMap = new Map<String, Portalproduct>();
        String key;
        Portalproduct prd = new Portalproduct();
        
        //convert availableRiderBenefitlevelItemList to Map<RiderCode,BenefitLevel>
        Map<String,String> riderCodeBenefitLevelMap = new Map<String,String>();
        if(!availableRiderBenefitlevelItemList.isEmpty()){
            for(TMCreatePolicyCtrl.AvailableRiderBenefitlevelItem item : availableRiderBenefitlevelItemList){
                riderCodeBenefitLevelMap.put(item.selectedRiderCode, item.benefitlevel);
            }
        }
        
        //Get corresponding information from portal product
        String param1 = basicPlan.areaOfCoverage;
        String param2 = basicPlan.deductible;
        String param3 = basicPlan.planLevel;
        String param4 = basicPlan.planOption;
        String param5 = basicPlan.offerCode;
        String sql = 'Select id, Plan_Code__c, Campaign_Code__c, Rate_Scale__c, Offer_Code__c, Product_Code__c, '
                        +'Area_of_Coverage__c, Deductible__c, Plan_Level__c, Plan_Option__c '
                        +'From Product__c '
                        +'Where RecordType.DeveloperName = \'Plan\' and Product_Code__c IN :selectedPlanList '
                        +'And (Area_of_Coverage__c = :param1 OR Area_of_Coverage__c = null) '
                        +'And (Deductible__c = :param2 OR Deductible__c = null) '
                        +'And (Plan_Level__c = :param3 OR Plan_Level__c = null) '
                        +'And (Plan_Option__c = :param4 OR Plan_Option__c = null) '
                        +'And Child_Raid_Up_Plan__c = false ';
        
        List<Product__c> riderList = Database.query(sql);
        
        for(Product__c p : riderList){
            if(riderCodeBenefitLevelMap.get(p.Product_Code__c) == String.valueOf(p.Rate_Scale__c)){
                key = p.Product_Code__c + '_' + p.Rate_Scale__c;
                prd = new Portalproduct();
                prd.productCode = p.Product_Code__c;
                prd.campaignCode = p.Campaign_Code__c;
                prd.planCode = p.Plan_Code__c;
                prd.deductible = p.Deductible__c;
                prd.areaOfCoverage = p.Area_of_Coverage__c;
                prd.planLevel = p.Plan_Level__c;
                prd.planOption = p.Plan_Option__c;
                prd.offerCode = p.Offer_Code__c;
                if(p.Rate_Scale__c != null){
                    prd.rateScale = String.valueOf(p.Rate_Scale__c);
                }
                productMap.put(key, prd);
            }
        }        
        //system.debug('[getProductMappingByRiders] productMap.size='+productMap.size());
        return productMap;
    }

    /*
     *  Portal product: get campaign code, plan code from portal products
     */
    public class Portalproduct{
        public String productCode {get; set;}
        public String campaignCode {get; set;}
        public String planCode {get; set;}
        public String rateScale {get; set;}
        public String areaOfCoverage {get; set;}
        public String deductible {get; set;}
        public String planLevel {get; set;}
        public String planOption {get; set;}   
        public String offerCode {get;set;}
    }
    
    
    /*
    * For Handling special product (e.g. DMBG / PBTG)
    * input para : riderCodeList - List of rider code of respective basic plan
    * output : Map<riderCode, Map< basic plan rate scale , Set<rate_scale>>>
    */
    public static Map<String, Map<String, Set<String>>> getRiderCodeBenefitListMap(List<String> riderCodeList, String basicPlanProductCode){
        
        //system.debug('[TMEsalesHelper] getRiderCodeBenefitListMap basicPlanProductCode >>> ' + basicPlanProductCode);
        //system.debug('[TMEsalesHelper] getRiderCodeBenefitListMap riderCodeList >>> ' + riderCodeList);
        
        Map<String,String> basicPlan_OfferCodePlanLevel_rateScaleMap = new Map<String,String>();
        for(Product__c p : [Select id, Plan_Code__c, Campaign_Code__c, Rate_Scale__c, Offer_Code__c, 
                            Product_Code__c, Area_of_Coverage__c, Deductible__c, Plan_Level__c, Plan_Option__c 
                            From Product__c 
                            Where RecordType.DeveloperName = 'Plan' 
                            and Product_Code__c = :basicPlanProductCode ]){
            
            String offerCodePlanLevel = p.Offer_Code__c + '_' + p.Plan_Level__c;
            
            basicPlan_OfferCodePlanLevel_rateScaleMap.put(offerCodePlanLevel, String.valueOf(p.Rate_Scale__c)); 
                                
        }
        //system.debug('[TMEsalesHelper] getRiderCodeBenefitListMap basicPlan_OfferCodePlanLevel_rateScaleMap >>> ' + basicPlan_OfferCodePlanLevel_rateScaleMap);
        
        Map<String, Map<String, Set<String>>> riderCodeBenefitListMap = new Map<String, Map<String, Set<String>>>();
        
        for(Product__c p : [Select id, Plan_Code__c, Campaign_Code__c, Rate_Scale__c, Offer_Code__c, Product_Code__c,
                            Area_of_Coverage__c, Deductible__c, Plan_Level__c, Plan_Option__c
                            From Product__c 
                            Where RecordType.DeveloperName = 'Plan' and Product_Code__c IN :riderCodeList 
                            And Child_Raid_Up_Plan__c = false]){
            
            /*
            * If key exist, get respective offerCodePlanLevel_rateScaleMap to handle:
            */
            if(riderCodeBenefitListMap.containsKey(p.Product_Code__c)){ 
                Map<String, Set<String>> basicPlanRateScale_rateScaleMap = riderCodeBenefitListMap.get(p.Product_Code__c);
                String offerCodePlanLevel = p.Offer_Code__c + '_' + p.Plan_Level__c;
                //system.debug('[TMEsalesHelper], offerCodePlanLevel='+offerCodePlanLevel);
                //system.debug('[TMEsalesHelper], basicPlan_OfferCodePlanLevel_rateScaleMap.get(offerCodePlanLevel)='+basicPlan_OfferCodePlanLevel_rateScaleMap.get(offerCodePlanLevel));
                if(basicPlanRateScale_rateScaleMap.containsKey(basicPlan_OfferCodePlanLevel_rateScaleMap.get(offerCodePlanLevel))){
                    //Map ->                        Map ->                  Set ->          .add(xxx) 
                    riderCodeBenefitListMap.get(p.Product_Code__c).get(basicPlan_OfferCodePlanLevel_rateScaleMap.get(offerCodePlanLevel)).add(String.valueOf(p.Rate_Scale__c));
                }else{
                    Set<String> rateScaleList = new Set<String>();
                    rateScaleList.add(String.valueOf(p.Rate_Scale__c));
                    riderCodeBenefitListMap.get(p.Product_Code__c).put(basicPlan_OfferCodePlanLevel_rateScaleMap.get(offerCodePlanLevel), rateScaleList);
                }
            }else{
                Map<String, Set<String>> basicPlanRateScale_rateScaleMap = new Map<String, Set<String>>();
                String offerCodePlanLevel = p.Offer_Code__c + '_' + p.Plan_Level__c;
                String rateScale = String.valueOf(p.Rate_Scale__c);
                basicPlanRateScale_rateScaleMap.put(basicPlan_OfferCodePlanLevel_rateScaleMap.get(offerCodePlanLevel) ,new Set<String>{rateScale});
                
                riderCodeBenefitListMap.put(p.Product_Code__c, basicPlanRateScale_rateScaleMap);
            }
            //system.debug('[TMEsalesHelper] getRiderCodeBenefitListMap riderCodeBenefitListMap >>> ' + riderCodeBenefitListMap);
        }
        //system.debug('[TMEsalesHelper] getRiderCodeBenefitListMap return riderCodeBenefitListMap >>> ' + riderCodeBenefitListMap);
        return riderCodeBenefitListMap;
    } 
    
    
    
    /*
    public static String getMandatoryRidersByProductCode(String productCode){
        String mandatoryRiders = null;        
        for(TM_Product_Mandatory_Riders_Setting__c result : [Select Mandatory_Riders__c from TM_Product_Mandatory_Riders_Setting__c where product_code__c = :productCode]){
            mandatoryRiders = result.Mandatory_Riders__c;
        }
        //system.debug('[getMandatoryRidersByProductCode] mandatoryRiders='+mandatoryRiders);
        return mandatoryRiders;
    }*/
}