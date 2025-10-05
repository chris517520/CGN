/*********************************************************************************
 * Name: HttpCalloutHelperAbstract
 *
 * Version History
 * Version           Author                 Date                      Description
 * ---------------  --------------------    -----------------------  ---------------------------------------------------------
 * V1.0             Franco                  2016-10-24               Instantiates the Custom Settings, Common methods used in concrete classes for WS
 * ......           
 * JR1774           Lawrence BP Wong        2019-11                  JR1774
 * AH18454          Lawrence BP Wong        2020-01                  AH18454
 ********************************************************************************/
public without sharing abstract class HttpCalloutHelperAbstract{
    public static final String RESULT_CODE_SUCCESS='1';
    public static final String RESULT_CODE_FAILURE='5';
    public static final String CUSTOM_PERMISSION_BROKER_USER='Broker_User';
    public static final String CUSTOM_PERMISSION_BROKER_ADMIN_USER='Broker_Admin_User';
    public static final String CUSTOM_PERMISSION_BROKER_SUPER_ADMIN_USER='Broker_Supur_Admin';
    public static final String CUSTOM_PERMISSION_CUSTOMER_USER='Customer_User';
    public static final String CUSTOM_PERMISSION_CUSTOMER_SERVICE_USER='Customer_Service_User';
    public static final String CUSTOM_PERMISSION_BD_USER='BD_Users';
    public static final String CUSTOM_PERMISSION_TM_USER='TM_User';
    public static final String CUSTOM_PERMISSION_CVM_USER='CVM_User';
    public static final String CUSTOM_PERMISSION_UW_USER='UW_User';
    // Rancho_CP46_20210210
    public static final String SERVICING_ACCOUNT_CM='HK_CM_WS_SRV';
    public static final String SERVICING_ACCOUNT_SU='testAccount';
    public static final String GUEST_USER='Guest_User';
    public static final String ROLE_ID_PH='PH';
    public static final String ROLE_ID_PCS='PCS';
    public static final String ROLE_ID_BCS='BCS';
    public static final String ROLE_ID_FC='FC';
    public static final String ROLE_ID_BK='BK';
    public static final String ROLE_ID_CM='CM';
    public static final String ROLE_ID_SU='SU';
    protected String servicingAcc;

    public static final String DEFAULT_PAGE_SIZE='5';
    private static Map<Id, CustomPermission> customPermissionNamesById=new Map<Id, CustomPermission>([SELECT Id, DeveloperName FROM CustomPermission]);
    private static List<SetupEntityAccess> setupEntities=[SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId in :customPermissionNamesById.keySet() AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId())];
    private static User currentUser=[select id, Name, ProfileId, UserRoleId, UserName, LanguageLocaleKey, AccountId, Profile.UserLicense.Name from User where id=:Userinfo.getUserId()];
    private static Account currentAccount = new Account();
    protected String currentUserLoginName;
    protected String sslCertificateName;
    protected String endpoint;
    protected String httpMethod;
    protected Integer timeout;
    protected WS_Callout_Setting__c calloutSetting;
    protected String functionName;
    protected String TXName;
    protected String roleID;
    protected String currentLanguageNode;
    protected Boolean isCalloutSuccessfully;    // true means the response status code is 200
    protected Boolean isResultSuccess;          // true means the ResultCode is SUCCESS : <ResultCode tc="1">Success</ResultCode>
    protected Boolean isSOAPFault;              // true means the response body include the '<soapenv:Fault>'
    protected Boolean isGuestUser;
    protected Boolean isForceToUseSU;
    public Integer startRecord; // will pass to WS
    public Integer maxRecords;  // will pass to WS
    protected Integer recordsFound; // receive from WS, use this field as the total record count
    protected DateTime callTimeStart;
    protected DateTime callTimeEnd;
    public Integer totalRecordCount;
    protected Integer pageSize;
    protected Integer currentPageNum;
    public Boolean isPagingExecute;  
    protected Boolean isReplaceFileBodyToAttachmentId;
    protected String attachmentIds;
    protected Boolean asyn;  // set to true to use Continuation, default is false
    protected HttpRequest asynRequest; // only for Continuation call.
    protected String requestBodyAsyn; // for Continuation only
    protected String appName; //add by kermit
    // protected String hashcode; //add by minghua 20190910 use cache to store WS response
    //add by minghua 20190910 use cache to store WS response
    public static Boolean useCache{
        get{if(currentUser!=null&&String.isNotBlank(currentUser.profileId)){
                if(useCache==null){
                    useCache=false;
                    List<Profile> profiles=[select Id, Name from Profile where Id=:currentUser.profileId];
                    if(profiles!=null && !profiles.isEmpty()){
                        WS_Callout_Setting__c cachesetting = WS_Callout_Setting__c.getValues(profiles[0].Name);
                        if(cachesetting!=null && cachesetting.Enable_Cache__c){
                            useCache = true;
                        }
                    }
                }
            }else{
                useCache = false;
            }
            return useCache;
        }set;
    }
    //Nicole_SOQL Enhancement_20200507
    // 20230921 - minghua - PI-129 Vulnerability follow up request - Pentest (FND-61951) High
    public static String currentUserProfile=[select id,Name from Profile where id=:Userinfo.getProfileId()].Name;       
    Profile personalChoiceProfile = [SELECT Id FROM Profile WHERE Name='PersonalChoice Profile'];                      
    // after the WS calling, access this class to view the detail result from WS(resultInfoDesc, recordsFound etc.)
    protected HttpCalloutVO.TransResult result;
    static{
        if(currentUser!=null&&String.isNotBlank(currentUser.AccountId)){
            // 20240226 - minghua - JOBR-363 Add logging / indicator to show usage between web and app
            // currentAccount = [select SSN__c, Is_Altruist_User__c from Account where Id=:currentUser.AccountId];
            currentAccount = [select SSN__c, Is_Altruist_User__c,Group_Policy_Number__pc, Individual_Policy_Number__pc from Account where Id=:currentUser.AccountId];
        }
    }
    // 20240226 - minghua - JOBR-363 Add logging / indicator to show usage between web and app
    protected String callerPlatform;
    protected String policyUser;

    public HttpCalloutHelperAbstract(){
        system.debug('Current Login User: ' + currentUser);
        // 20240226 - minghua - JOBR-363 Add logging / indicator to show usage between web and app
        policyUser='';
        if (currentAccount!=null) {
            if (String.isNotBlank(currentAccount.Group_Policy_Number__pc)&&String.isNotBlank(currentAccount.Individual_Policy_Number__pc)) {
                policyUser='Both Policy User';
            }else if (String.isNotBlank(currentAccount.Individual_Policy_Number__pc)) {
                policyUser='Individual Policy User';
            }else if (String.isNotBlank(currentAccount.Group_Policy_Number__pc)) {
                policyUser='Group Policy User';
            }
        }
        callerPlatform='Web';
        List<AuthSession> sessionList=[SELECT Id,LoginHistory.Application From AuthSession Where UsersId=:userinfo.getUserId() and IsCurrent=true];
        if (!sessionList.isEmpty()&&'MycignaReactApp'.equalsIgnoreCase(sessionList[0].LoginHistory.Application)) {
            callerPlatform='App';
            System.debug('HttpCalloutHelperAbstract sessionList:'+sessionList);
        }
        if(Test.isRunningTest()){
            calloutSetting = WS_Callout_Setting__c.getValues('Default');
        }else{
            //Nicole_SOQL Enhancement_20200507
            //calloutSetting = WSCalloutSettingHelper.getSetting(currentUser.profileId);
            if(String.IsNotBlank(currentUserProfile)){
                calloutSetting=WSCalloutSettingHelper.getSettingbyName(currentUserProfile);
            }else{
                calloutSetting=WSCalloutSettingHelper.getSetting(currentUser.profileId);
            }
        }
        if(calloutSetting==null){
            calloutSetting=new WS_Callout_Setting__c();
        }
        //system.debug('>>>>> WS Callout Setting infomation : >>>>> ' + calloutSetting);
        this.endpoint=calloutSetting.Endpoint__c;  // http://uat.cigna.com.hk/CignaFW/CignaDigitalWSService
        this.currentUserLoginName=Userinfo.getUserName();
        this.httpMethod='POST';
        this.timeout=120000;
        this.sslCertificateName='';
        this.isCalloutSuccessfully=false;
        this.isResultSuccess=false;
        this.isSOAPFault=false;
        this.asyn=false;
        this.isForceToUseSU=false;
        this.isReplaceFileBodyToAttachmentId=false;
        this.attachmentIds='';
        this.isGuestUser=currentUser.Profile.UserLicense.Name=='Guest User License';
        initRoleID();
        initCurrentLanguage();
        // pagination parameters
        this.totalRecordCount=0;
        this.currentPageNum=1;
        this.pageSize=Integer.valueOf(DEFAULT_PAGE_SIZE);
        this.startRecord=1;
        this.maxRecords=Integer.valueOf(calloutSetting.Request_Max_Records__c);
        this.isPagingExecute=false;
    }

    // Rancho_HKITSFDC393_20250827 - allow to set start record as some WS need to return more than 500 records
    public void resetStartRecord(Integer startRecord){
        this.startRecord = startRecord;
        this.isPagingExecute = true;
    }

    public void initRoleID(){
        // Rancho_CP46_20210210: add role id into WS Callout Setting, and use profile name to get role id and servicing account
        WS_Callout_Setting__c setting = new WS_Callout_Setting__c();
        if(String.isNotBlank(currentUserProfile)){
            setting = WS_Callout_Setting__c.getValues(currentUserProfile);
        }
        this.roleID=setting?.Role_ID__c;
        this.servicingAcc=setting?.Srv_Account_Name__c;
        if(this.isGuestUser){this.roleID=ROLE_ID_SU;}// avoid missing guest user profile
        if(String.isBlank(this.roleID)){this.servicingAcc=SERVICING_ACCOUNT_SU;}
        
        // Set<String> customPermissions=new Set<String>();        
        // for(SetupEntityAccess setupEntity:setupEntities){
        //     customPermissions.add(customPermissionNamesById.get(setupEntity.SetupEntityId).DeveloperName);
        // }
        // // Rancho_CP46_20210210
        // // Rancho_RoleIdUpdate_20210901: add sort order to avoid wrong role id when a profile owns multiple custom permissions
        // List<API_Permission_Mapping__mdt> cusPermissionList = new List<API_Permission_Mapping__mdt>([SELECT Label, DeveloperName, Role_ID__c, Is_Altruist__c, Servicing_Account__c, Sort_Order__c FROM API_Permission_Mapping__mdt ORDER BY Sort_Order__c]);
        // //cusPermissionList = API_Permission_Mapping__mdt.getAll().values();
        // System.debug('cusPermissionList: '+cusPermissionList);
        // System.debug('customPermissions: '+customPermissions);
        // System.debug('currentAccount.Is_Altruist_User__c: '+currentAccount.Is_Altruist_User__c);
        // for(API_Permission_Mapping__mdt cpm : cusPermissionList){
        //     if(this.isGuestUser && cpm.Label==GUEST_USER){
        //         this.roleID=cpm.Role_ID__c;
        //         this.servicingAcc=cpm.Servicing_Account__c;
        //     }else if(customPermissions.contains(cpm.Label) && (currentAccount.Is_Altruist_User__c==cpm.Is_Altruist__c)){
        //         this.roleID=cpm.Role_ID__c;
        //         this.servicingAcc=cpm.Servicing_Account__c;
        //     }
        //     // Rancho_RoleIdUpdate_20210901: break the loop to avoid reseting value
        //     if(String.isNotBlank(this.roleID)){break;}
        // }
        // if(String.isBlank(this.roleID)){
        //     this.servicingAcc=SERVICING_ACCOUNT_SU;
        // }
        system.debug('initRoleID: '+this.roleID+' servicingAcc: '+this.servicingAcc);
        // if(this.isGuestUser){
        //     this.roleID='SU';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_BROKER_SUPER_ADMIN_USER)){
        //     this.roleID='SU';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_BROKER_ADMIN_USER)){
        //     this.roleID=currentAccount.Is_Altruist_User__c ? 'PCS' : 'BCS';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_BROKER_USER)){
        //     this.roleID=currentAccount.Is_Altruist_User__c ? 'FC' : 'BK';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_CUSTOMER_USER)){
        //     this.roleID='PH';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_CUSTOMER_SERVICE_USER)){
        //     this.roleID='CS'; // 20170109 Hi team - Please suspend using role id = CS temporarily, as it's found that there is issue for this role.
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_BD_USER)){
        //     this.roleID='BD';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_TM_USER)){
        //     this.roleID='TM';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_CVM_USER)){
        //     this.roleID='TM';
        // }else if(customPermissions.contains(CUSTOM_PERMISSION_UW_USER)){
        //     this.roleID='UW';
        // }else{
        //     this.roleID=''; 
        // }
        // system.debug('>>initRoleID:>>>'+this.roleID);
    }
    public void initCurrentLanguage(){
        currentLanguageNode = '<CurrentLanguage tc="9">English</CurrentLanguage>';
        if('zh_HK'.equalsIgnoreCase(currentUser.LanguageLocaleKey)|| 'zh_CN'.equalsIgnoreCase(currentUser.LanguageLocaleKey)|| 'zh_TW'.equalsIgnoreCase(currentUser.LanguageLocaleKey)){
            currentLanguageNode = '<CurrentLanguage tc="523">Chinese (Cantonese)</CurrentLanguage>';
        }
    }
    public List<Object> execute(Map<String, String> paramsMap){
        List<Object> resultList = new List<Object>();
        if(!isPagingExecute){
            this.currentPageNum = 1;
            this.startRecord = 1;
        }
        result = new HttpCalloutVO.TransResult();
        if(asyn){
            return resultList;
        }
        System.debug('Callout helper Abstract: Current Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        // prepare the WS request body XML
        Long beginTime = Datetime.now().gettime();
        HttpRequest request = buildRequest(paramsMap, buildRequestBody());
        //add by minghua 20190910 use cache to store WS response
        Cigna_WS_Log_Setting__c wsLogSetting = Cigna_WS_Log_Setting__c.getValues(this.functionName);
        //CR-55 enhance performance: whether enable platforma cache  2021-12-16 zane
        WS_Callout_Setting__c profileWSCallSetting = WS_Callout_Setting__c.getValues(currentUserProfile);
   
       //CR-55 enhance performance: get data from platform cache  2021-12-16 Zane
        String platCacheHashcode = '';
        String objCacheHashcode = '';
        CacheManager cacheManager = null;
        if(wsLogSetting != null && profileWSCallSetting != null && String.isNotBlank(profileWSCallSetting.Cache_Partition__c) && ((wsLogSetting.Session_Cache__c && !CignaUtil.isAsynchronous()) || wsLogSetting.Org_Cache__c)){
            //cache name limits 50 length
            platCacheHashcode = PlatformCacheManager.getShortKey(request.getBody(), this.functionName); 
            List<Object> platCacheResult = (List<Object>)PlatformCacheManager.getCache(platCacheHashcode, profileWSCallSetting, wsLogSetting);
            if(platCacheResult != null){
                System.debug(LoggingLevel.INFO, '***execute platCacheResult: ' + platCacheResult);
                return platCacheResult;
            }
        //CR-55 End
        }

        //CR-55 merge two if logic
        if(useCache && wsLogSetting != null && wsLogSetting.Enable_cache__c){
            cacheManager = new DatabaseCacheManager(wsLogSetting);
            objCacheHashcode = cacheManager.getKey(request.getBody());
            System.debug('Generate cache objCacheHashcode:'+objCacheHashcode);
            if(String.isNotBlank(objCacheHashcode)){
                try{
                    String resultStr = (String)cacheManager.getCache(objCacheHashcode);
                    Dom.document resultDoc = null;
                    Dom.Document domLoad = new Dom.Document();
                    if(String.isNotBlank(resultStr)){
                        domLoad.load(resultStr);
                        resultDoc = domLoad;
                    }
                    if(resultDoc != null){
                        this.isCalloutSuccessfully = true;
                        processErrorFromResponse(resultDoc); //add by minghua - 20191108 - SPS-317
                        processSoapenvFault(resultDoc); //add by minghua - 20191108 - SPS-317
                        resultList = processResultFromResponse(resultDoc);
                        System.debug('Get cache resultList:'+resultList);
                        //CR-55 enhance performance: store into platform cache if the cache was stored in asynchronous context 2022-01-05
                        if(String.isNotBlank(platCacheHashcode)){
                            Boolean putCacheResult = PlatformCacheManager.putCache(platCacheHashcode,resultList, profileWSCallSetting, wsLogSetting);
                            System.debug(LoggingLevel.INFO, '***execute object cache putCacheResult: ' + putCacheResult);
                        }
                        return resultList;
                    }
                }catch(Exception e){ }
            }
        }
        Long endTime = Datetime.now().getTime();
        System.debug('Time spent to prepare the WS request body XML: ' + String.valueOf((endTime - beginTime)) + ' millisecond');
        // get the response from WS
        beginTime = Datetime.now().gettime();
        HttpResponse response = getCalloutResponse(request);
        endTime = Datetime.now().getTime();
        System.debug('Time spent to get the response from WS: ' + String.valueOf((endTime - beginTime)) + ' millisecond');
        // parse the WS response body XML, include error handling and the result
        beginTime = Datetime.now().gettime();
        Dom.document resultDoc = response != null ? response.getBodyDocument() : null;
        try{
            processErrorFromResponse(resultDoc); // First check if there were any errors
        }catch(CignaWSResultTooLargeException e){
            // sync log
            insertLog(request, response, e.getMessage(), e.getStackTraceString(), callTimeStart, callTimeEnd, FALSE);
            throw new CignaWSResultTooLargeException(e.getMessage());
        }
        processSoapenvFault(resultDoc);
        // Log the successful request and response if the setting is enable
        if(isCalloutSuccessfully && isResultSuccess && !isSOAPFault){
            if(wsLogSetting != null && wsLogSetting.Enable_Logging__c){
                if(this.functionName == PolicyCalloutHelper.GetPolicyDoc||this.functionName == WorkCalloutHelper.GetWorkDoc){   //Added by Nicole for Efulfillent Large document download
                     response.setBody('');
                }
                insertLog(request, response, '', '', callTimeStart, callTimeEnd, TRUE);
            }
        }
        // Log the error request/response/error message/etc.
        if(isCalloutSuccessfully && (isSOAPFault || !isResultSuccess)){
            try{
                // AH18454 - [[
                String szRequestBody = request.getBody();
                Boolean bIsVerifyPolicyInfoWSCall = szRequestBody.containsIgnoreCase('q0:VerifyPolicyInfo');
                if(True == bIsVerifyPolicyInfoWSCall){
                    System.debug('[HttpCalloutHelperAbstract][execute] - Belonging to VerifyPolicyInfo web service call.');
                }else{
                // ]] - AH18454
                    if(String.isNotBlank(result.resultLoginId)){
                        throw new CignaWSException(Label.Error_Message_User_Existed+result.resultLoginId);
                    }else{
                        throw new CignaWSException(result.resultInfoDesc);
                    }
                }    // AH18454
            }catch(CignaWSException e){
                insertLog(request, response, result.resultInfoDesc, e.getStackTraceString(), callTimeStart, callTimeEnd, FALSE);
                if(String.isNotBlank(result.resultLoginId)){
                    throw new CignaWSException(Label.Error_Message_User_Existed+result.resultLoginId);
                }else{
                    throw new CignaWSException(result.resultInfoDesc);
                }
            }
        }
        resultList = processResultFromResponse(resultDoc);
        endTime = Datetime.now().getTime();
        System.debug('>>>>> Time spent to parse the WS response body XML : >>>>> ' + String.valueOf((endTime - beginTime)) + ' millisecond');
        isPagingExecute = false;
        if(Test.isRunningTest()){
            // build exception case for test
            String testparam = ApexPages.currentPage().getParameters().get('testparam');
            if('CignaWSResultTooLargeException'.equalsIgnoreCase(testparam)){
                throw new CignaWSResultTooLargeException('test CignaWSResultTooLargeException case');
            }
            if('CignaWSTimeoutException'.equalsIgnoreCase(testparam)){
                throw new CignaWSTimeoutException('test CignaWSTimeoutException case');
            }
            if('CignaWSException'.equalsIgnoreCase(testparam)){
                throw new CignaWSException('test CignaWSException case');
            }
        }

        //CR-55 enhance performance: get data from platform cache  2021-12-16 Zane
        if(String.isNotBlank(platCacheHashcode)){
            Boolean putCacheResult = PlatformCacheManager.putCache(platCacheHashcode,resultList, profileWSCallSetting, wsLogSetting);
            System.debug(LoggingLevel.INFO, '***execute putCacheResult: ' + putCacheResult);
        
        //add by minghua 20190910 use cache to store WS response
        }else if(String.isNotBlank(objCacheHashcode)){
            cacheManager.putCache(objCacheHashcode,resultDoc.toXmlString(),currentUserProfile);
            System.debug('put list to DB, objCacheHashcode: '+objCacheHashcode);
        }
        //CR-55 End
        return resultList;
    }
    /*
     * asynExecute
     *     @callbackFunctionName: your customize function in your controller
     */
    
    // Zoe commented on 0515 for deployment rehearsal, these are not covered by test class 
    /**
    public AsynCalloutInfo asynExecute(String callbackFunctionName){
        Continuation con = new Continuation(120);
        con.continuationMethod = callbackFunctionName;
        HttpRequest request = buildRequest(new Map<String, String>(), buildRequestBody());
        system.debug('>>>>> asynExecute Request endpoint and method used : >>>>> ' + request.toString());
        system.debug('>>>>> asynExecute Request body if has : >>>>> ' + request.getBody());
        callTimeStart = DateTime.now();
        String requestLabel = con.addHttpRequest(request);
        AsynCalloutInfo aci = new AsynCalloutInfo(con, requestLabel, request.getEndpoint(), callTimeStart);
        system.debug('>>>>> Continuation info ' + aci);
        return aci;
    }*/
    public List<Object> processResponse(HttpResponse response){
        List<Object> resultList = new List<Object>();
        result = new HttpCalloutVO.TransResult();
        Exception exceptions;
        this.isCalloutSuccessfully = false;
        System.debug('Response status and status code: ' + response.toString());
        System.debug('Response body: ' + response.getBody());
        Integer statusCode = response.getStatusCode();
        if(statusCode != 200){
            result.resultInfoDesc = response.getStatus() + '. Please contact the administrator.';
            exceptions = new CignaWSException(response.getStatus());
        }else{
            this.isCalloutSuccessfully = true;
        }
        if(exceptions != null){
            system.debug('Exception: ' + exceptions.getMessage());
            if(exceptions.getMessage().contains('Read timed out') || exceptions.getMessage().contains('Exceeded maximum time allotted for callout')){
                result.resultInfoDesc = Label.WS_Connection_Timeout;
                throw new CignaWSTimeoutException(Label.WS_Connection_Timeout);
            }else{
                throw exceptions;
            }
        }
        // parse the WS response body XML, include error handling and the result
        Long beginTime = Datetime.now().gettime();
        Dom.document resultDoc = response != null ? response.getBodyDocument() : null;
        try{
            processErrorFromResponse(resultDoc); // First check if there were any errors
        }catch(CignaWSResultTooLargeException e){
            insertLog(requestBodyAsyn, response, e.getMessage(), e.getStackTraceString(), Datetime.now(), Datetime.now(), FALSE);
            throw new CignaWSResultTooLargeException(e.getMessage());
        }
        processSoapenvFault(resultDoc);
        // Log the successful request and response if the setting is enable
        if(isCalloutSuccessfully && isResultSuccess && !isSOAPFault){
            Cigna_WS_Log_Setting__c wsLogSetting = Cigna_WS_Log_Setting__c.getValues(this.functionName);
            if(wsLogSetting != null && wsLogSetting.Enable_Logging__c){
                insertLog(requestBodyAsyn, response, '', '', Datetime.now(), Datetime.now(), TRUE);
            }
        }
        // Log the error request/response/error message/etc.
        if(isCalloutSuccessfully && (isSOAPFault || !isResultSuccess)){
            try{
                throw new CignaWSException(result.resultInfoDesc);
            }catch(CignaWSException e){
                insertLog(requestBodyAsyn, response, e.getMessage(), e.getStackTraceString(), Datetime.now(), Datetime.now(), FALSE);
                throw new CignaWSException(result.resultInfoDesc);
            }
        }
        resultList = processResultFromResponse(resultDoc);
        Long endTime = Datetime.now().getTime();
        system.debug('>>>>> Time spent to parse the WS response body XML : >>>>> ' + String.valueOf((endTime - beginTime)) + ' millisecond');
        system.debug('### result list size ' + resultList.size());
        return resultList;
    }
    public HttpRequest getRequest(){
        HttpRequest req = null;
        try{
            req = buildRequest(new Map<String, String>(), buildRequestBody());
            requestBodyAsyn = req.getBody();
            system.debug('>>>>> Request endpoint and method used : >>>>> ' + req.toString());
            system.debug('>>>>> Request body if has : >>>>> ' + req.getBody());
        }catch(Exception e){
            system.debug('>>>>> getRequest error: ' + e.getMessage());
        }
        return req;
    }
    private HttpRequest buildRequest(Map<String, String> paramsMap, String body){
        // Set parameters
        String queryString = '';
        String endpointWithParam = this.endpoint; 
        System.debug(this.endpoint);  
        if(paramsMap != null && paramsMap.size() > 0){
            for(String key : paramsMap.keySet()){
                if(String.isBlank(paramsMap.get(key))){
                    paramsMap.remove(key);
                }else{
                    paramsMap.put(key, key + '=' + EncodingUtil.urlEncode(paramsMap.get(key), 'UTF-8'));
                }
            }
            queryString = String.join(paramsMap.values(), '&');

            if(String.isNotBlank(endpointWithParam)){
                endpointWithParam += '?' + queryString;
            }
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointWithParam);
        req.setMethod(this.httpMethod);
        req.setTimeout(this.timeout);
        if(String.isNotBlank(body)){
            req.setBody(body);
        }
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
        if(String.isNotBlank(this.sslCertificateName)){
            req.setClientCertificateName(this.sslCertificateName);
        }
        return req;
    }
    // implement this method in the child class
    // TXObjectRequest : eg. TXLifeRequest/TXAccountRequest/TXFundRequest/TXNBRequest
    protected abstract String buildTXObjectRequestNode();
    protected String buildRequestBody(){
        String userLoginName = Userinfo.getUserName();
        if(this.isGuestUser){
            userLoginName = calloutSetting.SU_Login_Name__c;
        }
        //add Bob 20201208 CMUser
        if(!Test.isRunningTest()){
            // Rancho_CP46_20210210
            if(!this.isGuestUser&&CignaUtil.isCMLoginAsUser()&&(this.roleID==ROLE_ID_PH||this.roleID==ROLE_ID_PCS||this.roleID==ROLE_ID_BCS||this.roleID==ROLE_ID_FC||this.roleID==ROLE_ID_BK)){
                this.roleID=ROLE_ID_CM;
                this.servicingAcc=SERVICING_ACCOUNT_CM;
            }
        }
        //end
        // force to use SU
        if(isForceToUseSU||this.functionName == UserCalloutHelper.ValidateUser||this.functionName == CompanyCalloutHelper.GetCompanyList
            || this.functionName == CompanyCalloutHelper.SetCompanyLink){
                // Rancho_CP46_20210210
                this.roleID = ROLE_ID_SU;
                this.servicingAcc = SERVICING_ACCOUNT_SU; 
                userLoginName = calloutSetting.SU_Login_Name__c;
        }
        //add by lihao
         //Profile p = [SELECT Id FROM Profile WHERE Name='PersonalChoice Profile'];//SPS-693 jack add
          if(UserInfo.getProfileId()==personalChoiceProfile.Id){
            userLoginName='';
          }  

        // PI-114 20230731, commented by Owen to remove chubb
        // minghua - 20220511 - login flow for Chubb
        // if (this.functionName==UserCalloutHelper.ChubbValidateUser) {
        //     this.functionName=UserCalloutHelper.ValidateUser;
        //     this.servicingAcc=SERVICING_ACCOUNT_SU;
        //     userLoginName=calloutSetting.Chubb_Login_Name__c;
        // }
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:q0="http://webservice.digital.cigna.com/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                    + '    <soapenv:Header>';
                    //add Bob CM User 20201221
                    // Rancho_CP46_20210210
                    body+=          '<q0:SrvAccountName>' + servicingAcc + '</q0:SrvAccountName>';
                    // if(this.roleID=='CM'){
                    //     body+=          '<q0:SrvAccountName>' + calloutSetting.CM_Login_Srv_Account_Name__c + '</q0:SrvAccountName>';
                    // }else{
                    //     body+=          '<q0:SrvAccountName>' + calloutSetting.Srv_Account_Name__c + '</q0:SrvAccountName>';
                    // }
                    body+= '    </soapenv:Header>'
                    + '     <soapenv:Body>'    
                    //+ '         <q0:' + this.functionName + '>'       // Commented by JR1774
                    //+ '             <q0:' + this.TXName + ' Version="1.00">'    // Commented by JR1774
                    // JR1774 - [[
                    + '         <q0:' + this.functionName + '>';
                    if(this.functionName != PolicyCalloutHelper.VerifyPolicyInfo){
                        body += '             <q0:' + this.TXName + ' Version="1.00">';
                    }else{
                        body += '             <q0:TXService Version="1.00">';
                    }
                    body += ''
                    // ]] - JR1774 
                    + '                 <UserAuthRequest>'
                    + '                     <UserLoginName>' + userLoginName + '</UserLoginName>'
                    + '                     <VendorApp>'
                    + '                         <VendorName VendorCode="' + calloutSetting.Vendor_Code__c + '">' + calloutSetting.Vendor_Name__c + '</VendorName>'
                    //+ '                         <AppName>' + calloutSetting.App_Name__c + '</AppName>'
                    // 20240226 - minghua - JOBR-363 Add logging / indicator to show usage between web and app
                    +'                          <AppName>' + (String.isBlank(appName)?calloutSetting.App_Name__c:appName) + '</AppName>';
                    // + '                         <AppVer>' + calloutSetting.App_Version__c + '</AppVer>'
                    if ('Web'.equalsIgnoreCase(this.callerPlatform)) {
                        body += '                         <AppVer>1.00</AppVer>';
                    }else{
                        body += '                         <AppVer>2.00</AppVer>';
                    }
                    body += ''
                    + '                     </VendorApp>'
                    + '                </UserAuthRequest>'
                    //+                  buildTXObjectRequestNode()    // Commented by JR1774
                    //+ '            </q0:' + this.TXName + '>'    // Commented by JR1774
                    // JR1774 - [[
                    +                  buildTXObjectRequestNode()                    
                    //if(this.functionName != PolicyCalloutHelper.VerifyPolicyInfo){
                    //    body += '            </q0:' + this.TXName + '>';
                    //}else{
                    //    body += '            </q0:TXService>';
                    //}
                    //body += ''
                    
                    // ]] - JR1774
                    
                    //Nicole_20200318_SPS-408
                    + (this.functionName == PolicyCalloutHelper.VerifyPolicyInfo?'            </q0:TXService>':'            </q0:' + this.TXName + '>')                   
                    + ''
                    + '        </q0:' + functionName + '>'
                    + '    </soapenv:Body>'
                    + '</soapenv:Envelope>';
        System.debug(LoggingLevel.INFO,'>>>>> body:' + body);                                
        return body;
    }
    protected String buildRequestBody4Attachment(){
        this.isReplaceFileBodyToAttachmentId = true;
        String requestBody = buildRequestBody();
        this.isReplaceFileBodyToAttachmentId = false;
        return requestBody;
    }
    protected HttpResponse getCalloutResponse(HttpRequest req){
        HttpResponse res = null;
        Http http = new Http();
        Exception exceptions;
        this.isCalloutSuccessfully = false;
        this.callTimeStart = null;
        this.callTimeEnd = null;
        try{
            System.debug('>>>>> Callout Start >>>>>');
            system.debug('>>>>> Request endpoint and method used : >>>>> ' + req.toString());
            system.debug('>>>>> Request body if has : >>>>> ' + req.getBody());
            
            callTimeStart = DateTime.now();
            res = http.send(req);
            callTimeEnd = DateTime.now();
            HttpCalloutInfo.add(this.functionName, callTimeStart, callTimeEnd);
            
            System.debug('>>>>> Response status and status code >>>>> ' + res.toString());
            System.debug('>>>>> Response body >>>>> ' + res.getBody());
            
            Integer statusCode = res.getStatusCode();
            if(statusCode != 200){
                result.resultInfoDesc = res.getStatus() + '. Please contact the administrator.';
                exceptions = new CignaWSException(res.getStatus());
            }else{
                this.isCalloutSuccessfully = true;
            }
            if(Test.isRunningTest()){
                // build exception case for test
                String testparam = ApexPages.currentPage().getParameters().get('testparam');
                if('CignaWSResultTooLargeException'.equalsIgnoreCase(testparam)){
                    this.isCalloutSuccessfully = false;
                    throw new CignaWSResultTooLargeException('test CignaWSResultTooLargeException case');
                }
                if('CignaWSTimeoutException'.equalsIgnoreCase(testparam)){
                    this.isCalloutSuccessfully = false;
                    throw new CignaWSTimeoutException('test CignaWSTimeoutException case Read timed out');
                }
                if('CignaWSException'.equalsIgnoreCase(testparam)){
                    this.isCalloutSuccessfully = false;
                    throw new CignaWSException('test CignaWSException case');
                }
            }
        }catch(Exception e){
            exceptions = e;
            system.debug('>>>>> Exception : >>>>> ' + e.getMessage());
            if(e.getMessage().contains('Read timed out')
                    || e.getMessage().contains('Exceeded maximum time allotted for callout')){
                result.resultInfoDesc = Label.WS_Connection_Timeout;
                exceptions = new CignaWSTimeoutException(Label.WS_Connection_Timeout);
            }else{
                result.resultInfoDesc = 'Failed retrieving data. Please contact the administrator. [Error Message: ' + e.getmessage() + ']';
                exceptions = new CignaWSException(e.getMessage());
            }
        }finally{
            System.debug('>>>>> Callout End >>>>> isCalloutSuccessfully : ' + this.isCalloutSuccessfully);
            if(!this.isCalloutSuccessfully){
                if(exceptions != null){
                    String errorMsg = exceptions.getMessage();
                    String errorDetail = exceptions.getStackTraceString();
                    // use DML to log the timeout exception
                    if(exceptions instanceOf CignaWSTimeoutException){
                        errorMsg = errorMsg + ' | ALL the previous calls in this transaction : ' + HttpCalloutInfo.getCalloutInfoList();
                        if(Limits.getDMLRows() < Limits.getLimitDMLRows() && Limits.getDMLStatements() < Limits.getLimitDMLStatements()){
                            System.PageReference pageRef = ApexPages.currentPage();
                            String currentPage = pageRef != null ? EncodingUtil.urlEncode(pageRef.getUrl(), 'UTF-8') : '';
                            currentPage = System.isFuture() ? 'FutureHandler' : currentPage;
                            String endpoint = req != null ? req.getEndpoint() : '';
                            String requestBody = '';
                            if(String.isNotBlank(this.attachmentIds) && (this.functionName == EmailCalloutHelper.SendEmail || this.functionName == ClaimCalloutHelper.SubmitClaimRequest|| this.functionName == ClaimCalloutHelper.ReplyClaimPendingMemo || this.functionName == WorkCalloutHelper.ReplyWorkPendingMemo|| this.functionName == WorkCalloutHelper.SubmitWorkRequest || this.functionName == WorkCalloutHelper.GetWorkDoc)){
                                requestBody = buildRequestBody4Attachment();
                            }else{
                                requestBody = req != null ? req.getBody() : '';
                            }
                            String responseStatus = res != null ? res.getStatus() : '';
                            String responseBody = res != null ? res.getBody() : '';
                            CignaWSErrorLogQueue wslogQueue = new CignaWSErrorLogQueue(endpoint, requestBody, responseBody, responseStatus, errorMsg, Userinfo.getUserId(), callTimeStart, this.functionName, currentPage, errorDetail, attachmentIds);
                            ID jobID = System.enqueueJob(wslogQueue);
                        }
                        system.debug('>>>>> Insert Log Timeout Exception >>>>>' + errorMsg);
                    }else{
                        // sync log
                        insertLog(req, res, errorMsg, errorDetail, callTimeStart, callTimeEnd, FALSE);
                    }
                    throw exceptions;
                }
            }
        }
        return res;
    }
    // implement this method in the child class
    protected abstract List<Object> processResultFromResponse(Dom.document doc);
    /*
     * Process TransResult node from the response file
     *
     * <TransResult>
     *     <ResultCode tc="5">RESULT_FAILURE</ResultCode>
     *     <ResultInfo>
     *         <ResultInfoCode tc="100">General</ResultInfoCode>
     *         <ResultInfoDesc>This company already has company mapping. The company code is testCompany2</ResultInfoDesc>
     *     </ResultInfo>
     * </TransResult>
     *
     * ResultCode : 1 = RESULT_SUCCESS ; 5 = RESULT_FAILURE
     * ResultInfoCode : 100 = RESULTINFO_GENERAL ; 200 = RESULTINFO_DATA ; 1420 = RESULTINFO_INVALIDUSER ; 3026 = RESULTINFO_UNKNOWNPOLNUM ; 300 = RESULTINFO_NOTAVAILSYS ; 201 = RESULTINFO_XMLPARSE
     */
    protected void processErrorFromResponse(Dom.document doc){
        isResultSuccess = false;
        result.isSuccess = false;
        if(isCalloutSuccessfully){
            Dom.XmlNode TXObjectResponseNode = getTXObjectResponseNode(doc);
            Dom.XmlNode TransResultNode = getChildNodeIfNotNull('TransResult', TXObjectResponseNode);
            Dom.XmlNode ResultInfoNode = getChildNodeIfNotNull('ResultInfo', TransResultNode);
            result.resultCode = getChildNodeAttributeIfNotEmpty('ResultCode', 'tc', TransResultNode);
            result.recordsFound = getChildNodeTextIfNotEmpty('RecordsFound', TransResultNode);
            result.recordsFound = String.isBlank(result.recordsFound) ? '0' : result.recordsFound;
            this.totalRecordCount = Integer.valueOf(result.recordsFound);
            result.nextRecord = getChildNodeTextIfNotEmpty('NextRecord', TXObjectResponseNode);// Rancho_HKITSFDC393_20250827 - get next record
            result.resultInfoCode = getChildNodeAttributeIfNotEmpty('ResultInfoCode', 'tc', ResultInfoNode);
            result.resultInfoDesc = getChildNodeTextIfNotEmpty('ResultInfoDesc', ResultInfoNode);
            Dom.XmlNode OAccountNode = getChildNodeIfNotNull('OAccount', TXObjectResponseNode);
            result.resultLoginId = getChildNodeTextIfNotEmpty('LoginId', OAccountNode);
            String resultInfoCodeText = getChildNodeTextIfNotEmpty('ResultInfoCode', ResultInfoNode);
            if(TransResultNode != null && RESULT_CODE_SUCCESS != result.resultCode){
                String resultInfoDesc = result.resultInfoDesc;
                if(result.resultInfoCode == '710'){
                    result.resultInfoDesc = Label.WS_result_set_size_is_over_1000; // further will updated.
                    throw new CignaWSResultTooLargeException(Label.WS_result_set_size_is_over_1000);
                }
                if(result.resultInfoCode == 'P003'){//Added by In-gage for SendSMS errors
                    result.resultInfoDesc = Label.WS_insufficient_credit_limit_to_send_message; // further will updated.
                    throw new CignaWSResultTooLargeException(Label.WS_insufficient_credit_limit_to_send_message);
                }
                //Add by kermit for SendSMS result
                if(this.functionName.equalsIgnoreCase('SendSMS') && resultInfoCodeText == 'A000' && result.resultInfoDesc == 'OK'){
                    isResultSuccess = true;
                    result.isSuccess = true;                    
                }
                //End add
            }else{
                isResultSuccess = true;
                result.isSuccess = true;
            }
        }
        system.debug('isResultSuccess: ' + isResultSuccess  + ' helper.getResultInfo(): ' + this.result+' resultLoginId: '+result.resultLoginId);
    }
    /*
     * insertLog
     *     -- call SFDC WS to insert Cigna WS Log
     */
    public void insertLog(String requestBody, HttpResponse response, String errorMsg, String errorDetail, DateTime callTime, DateTime callTimeEnd, Boolean isSuccessfulCalling){
         try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String sfdcEndpoint= calloutSetting.CignaWSErrorLogRest_Endpoint__c;
            req.setEndpoint(sfdcEndpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/xml;charset=UTF-8');
            req.setTimeout(120000);
            String callTimeStr = '';
            if(callTime != null){
                callTimeStr = callTime.formatGmt('yyyy-MM-dd HH:mm:ss.SSS');
            }
            String timeRequiredStr = '';
            if(callTime != null && callTimeEnd != null){
                timeRequiredStr = String.valueOf(callTimeEnd.getTime() - callTime.getTime());
            }
            System.PageReference pageRef = ApexPages.currentPage();
            String currentPage = (pageRef != null && pageRef.getUrl() != null ) ? EncodingUtil.urlEncode(pageRef.getUrl(), 'UTF-8') : '';
            currentPage = System.isFuture() ? 'FutureHandler' : currentPage;
            currentPage = currentPage.length() > 4000 ? currentPage.subString(0, 3999) : currentPage;
            String body = '<request>'
                        + '<endpoint>' + calloutSetting.Endpoint__c + '</endpoint>'
                        + '<requestBody>' + requestBody.escapeXML() + '</requestBody>'
                        + '<responseBody>' + response.getBody().escapeXML() + '</responseBody>'
                        + '<responseStat>' + response.getStatus() + '</responseStat>'
                        + '<errorMsg>' + errorMsg + '</errorMsg>'
                        + '<errorDetail>' + errorDetail + '</errorDetail>'
                        + '<WSFunctionName>' + this.functionName + '</WSFunctionName>'
                        + '<callerId>' + userinfo.getUserId() + '</callerId>'
                        + '<callTime>' + callTimeStr + '</callTime>'
                        + '<timeRequired>' + timeRequiredStr + '</timeRequired>'
                        + '<currentPage>' + currentPage + '</currentPage>'
                        + '<successfulCalling>' + isSuccessfulCalling + '</successfulCalling>'
                        + '<attachmentIds>' + this.attachmentIds + '</attachmentIds>'
                        // 20240226 - minghua - JOBR-363 Add logging / indicator to show usage between web and app
                        + '<callerPlatform>' + this.callerPlatform + '</callerPlatform>'
                        + '<policyUser>' + this.policyUser + '</policyUser>'
                        + '<RTypeName>WS_Log</RTypeName>'
                        + '</request>';
            req.setBody(body);
            HttpResponse res = h.send(req);
            System.debug('>>>>> insertLog status and status code >>>>> ' + res.toString());
            System.debug('>>>>> insertLog request body >>>>> ' + req.getBody());
            System.debug('>>>>> insertLog response body >>>>> ' + res.getBody());
        }catch(Exception e){
            System.debug('>>>>> insertLog failed >>>>> ' + e.getLineNumber() + ' ' + e.getMessage() + '\r\n' + e.getStackTraceString());
        }
    }
    /*
     * insertLog
     *     -- call SFDC WS to insert Cigna WS Log
     */
    public void insertLog(HttpRequest request, HttpResponse response, String errorMsg, String errorDetail, DateTime callTime, DateTime callTimeEnd, Boolean isSuccessfulCalling){
         try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String sfdcEndpoint= calloutSetting.CignaWSErrorLogRest_Endpoint__c;
            req.setEndpoint(sfdcEndpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/xml;charset=UTF-8');
            req.setTimeout(120000);
            String callTimeStr = '';
            if(callTime != null){
                callTimeStr = callTime.formatGmt('yyyy-MM-dd HH:mm:ss.SSS');
            }
            String timeRequiredStr = '';
            if(callTime != null && callTimeEnd != null){
                timeRequiredStr = String.valueOf(callTimeEnd.getTime() - callTime.getTime());
            }
            System.PageReference pageRef = ApexPages.currentPage();
            String currentPage = (pageRef != null && pageRef.getUrl() != null ) ? EncodingUtil.urlEncode(pageRef.getUrl(), 'UTF-8') : '';
            currentPage = System.isFuture() ? 'FutureHandler' : currentPage;
            currentPage = currentPage.length() > 4000 ? currentPage.subString(0, 3999) : currentPage;
            // String requestBody = request == null ? '' : request.getBody().escapeXML();
            String requestBody = '';
            if(String.isNotBlank(this.attachmentIds) && (this.functionName == EmailCalloutHelper.SendEmail
                    || this.functionName == ClaimCalloutHelper.SubmitClaimRequest
                    || this.functionName == ClaimCalloutHelper.ReplyClaimPendingMemo
                    || this.functionName == WorkCalloutHelper.ReplyWorkPendingMemo
                    || this.functionName == WorkCalloutHelper.SubmitWorkRequest
                    || this.functionName == WorkCalloutHelper.GetWorkDoc)){
                requestBody = buildRequestBody4Attachment().escapeXML();
            }else{
                requestBody = request == null ? '' : request.getBody().escapeXML();
            }
            String body = '<request>'
                        + '<endpoint>' + (request == null ? '' : request.getEndpoint()) + '</endpoint>'
                        + '<requestBody>' + requestBody + '</requestBody>'
                        + '<responseBody>' + (response == null ? '' : response.getBody().escapeXML()) + '</responseBody>'
                        + '<responseStat>' + (response == null ? '' : response.getStatus()) + '</responseStat>'
                        + '<errorMsg>' + errorMsg + '</errorMsg>'
                        + '<errorDetail>' + errorDetail + '</errorDetail>'
                        + '<WSFunctionName>' + this.functionName + '</WSFunctionName>'
                        + '<callerId>' + userinfo.getUserId() + '</callerId>'
                        + '<callTime>' + callTimeStr + '</callTime>'
                        + '<timeRequired>' + timeRequiredStr + '</timeRequired>'
                        + '<currentPage>' + currentPage + '</currentPage>'
                        + '<successfulCalling>' + isSuccessfulCalling + '</successfulCalling>'
                        + '<attachmentIds>' + this.attachmentIds + '</attachmentIds>'
                        // 20240226 - minghua - JOBR-363 Add logging / indicator to show usage between web and app
                        + '<callerPlatform>' + this.callerPlatform + '</callerPlatform>'
                        + '<policyUser>' + this.policyUser + '</policyUser>'
                        + '<RTypeName>WS_Log</RTypeName>'
                        + '</request>';
            req.setBody(body);
            HttpResponse res = h.send(req);
            System.debug('>>>>> insertLog status and status code >>>>> ' + res.toString());
            System.debug('>>>>> insertLog request body >>>>> ' + req.getBody());
            System.debug('>>>>> insertLog response body >>>>> ' + res.getBody());
        }catch(Exception e){
            System.debug('>>>>> insertLog failed >>>>> ' + e.getLineNumber() + ' ' + e.getMessage() + '\r\n' + e.getStackTraceString());
        }
    }
    /*
     * insertLog
     *     -- call SFDC WS to insert SFDC Log
     */
    public void insertSFDCLog(String errorMsg, String errorDetail){
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String sfdcEndpoint= calloutSetting.CignaWSErrorLogRest_Endpoint__c;
            req.setEndpoint(sfdcEndpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/xml;charset=UTF-8');
            req.setTimeout(120000);
            System.PageReference pageRef = ApexPages.currentPage();
            String currentPage = (pageRef != null && pageRef.getUrl() != null ) ? EncodingUtil.urlEncode(pageRef.getUrl(), 'UTF-8') : '';
            currentPage = System.isFuture() ? 'FutureHandler' : currentPage;
            currentPage = currentPage.length() > 4000 ? currentPage.subString(0, 3999) : currentPage;
            String body = '<request>'
                        + '<endpoint></endpoint>'
                        + '<requestBody></requestBody>'
                        + '<responseBody></responseBody>'
                        + '<responseStat></responseStat>'
                        + '<errorMsg>' + errorMsg.escapeXML()+ '</errorMsg>'
                        + '<errorDetail>' + errorDetail.escapeXML() + '</errorDetail>'
                        + '<WSFunctionName></WSFunctionName>'
                        + '<callerId>' + userinfo.getUserId() + '</callerId>'
                        + '<callTime>' + DateTime.now().formatGmt('yyyy-MM-dd HH:mm:ss') + '</callTime>'
                        + '<currentPage>' + currentPage + '</currentPage>'
                        + '<successfulCalling></successfulCalling>'
                        + '<attachmentIds>' + this.attachmentIds + '</attachmentIds>'
                        // 20240226 - minghua - JOBR-363 Add logging / indicator to show usage between web and app
                        + '<callerPlatform>' + this.callerPlatform + '</callerPlatform>'
                        + '<policyUser>' + this.policyUser + '</policyUser>'
                        + '<RTypeName>SFDC_Log</RTypeName>'
                        + '</request>';
            req.setBody(body);
            HttpResponse res = h.send(req);
            System.debug('>>>>> insertLog status and status code >>>>> ' + res.toString());
            System.debug('>>>>> insertLog Response body >>>>> ' + res.getBody());
        }catch(Exception e){
            System.debug('>>>>> insertLog failed >>>>> ' + e.getLineNumber() + ' ' + e.getMessage() + '\r\n' + e.getStackTraceString());
        }
    }
    /*
     * getResultInfo
     *     use helper.getResultInfo().isSuccess to see if the calling is successful
     *     if helper.getResultInfo().isSuccess == false,  then can use helper.getResultInfo().resultInfoDesc to view the error message
     */
    public HttpCalloutVO.TransResult getResultInfo(){
        return this.result;
    }
    public User getCurrentUser(){
        return currentUser;
    }
    public Integer getTotalPage(){
        return totalRecordCount == 0 ? 1 : (totalRecordCount + pageSize - 1) / pageSize;
    }
    public Integer getCurrentPageNumber(){
        return this.currentPageNum;
    }
    public Boolean hasNext(){
        System.debug('HttpCalloutHelperAbstract.hasNext: ' + (getCurrentPageNumber() < getTotalPage()));
        return getCurrentPageNumber() < getTotalPage();
    }
    public Boolean hasPrev(){
        System.debug('HttpCalloutHelperAbstract.hasPrev: ' + (getCurrentPageNumber() > 1));
        return getCurrentPageNumber() > 1;
    }
    public List<Object> prevPage(){
        // if hasPrev() is false, will return the data of current page
        if(hasPrev()){
            System.debug('HttpCalloutHelperAbstract.prevPage');
            this.startRecord = this.startRecord - this.pageSize;
            this.maxRecords = this.pageSize;
            this.currentPageNum = this.currentPageNum - 1;
            this.isPagingExecute = true;
        }
        return execute(new Map<String, String>());
    }
    public List<Object> nextPage(){
        // if hasNext() is false, will return the data of current page
        if(hasNext()){
            System.debug('HttpCalloutHelperAbstract.nextPage');
            this.startRecord = this.startRecord + this.pageSize;
            this.maxRecords = this.pageSize;
            this.currentPageNum = this.currentPageNum + 1;
            this.isPagingExecute = true;
        }
        return execute(new Map<String, String>());
    }
    public List<Object> firstPage(){
        System.debug('HttpCalloutHelperAbstract.firstPage');
        this.startRecord = 1;
        this.maxRecords = this.pageSize;
        this.currentPageNum = 1;
        this.isPagingExecute = true;
        return execute(new Map<String, String>());
    }
    public List<Object> lastPage(){
        System.debug('HttpCalloutHelperAbstract.lastPage');
        this.startRecord = this.pageSize * (getTotalPage() - 1);
        this.maxRecords = this.pageSize;
        this.currentPageNum = getTotalPage();
        this.isPagingExecute = true;
        return execute(new Map<String, String>());
    }
    public String getChildNodeTextIfNotEmpty(String elementName, Dom.XmlNode node){
        String result = '';
        if(node != null){
            Dom.XmlNode childNode = node.getChildElement(elementName, null);
            if(childNode != null){
                result = childNode.getText();
                if(result != null){
                    result = result.trim();
                }
            }
        }
        return result;
    }
    public Blob getChildNodeBlobIfNotEmpty(String elementName, Dom.XmlNode node){
        Blob result = null;
        if(node != null){
            Dom.XmlNode childNode = node.getChildElement(elementName, null);
            if(childNode != null){
                return EncodingUtil.base64Decode(childNode.getText());
            }
        }
        return result;
    }
    public String getChildNodeAttributeIfNotEmpty(String elementName, String attributeName, Dom.XmlNode node){
        String result = '';
        if(node != null){
            Dom.XmlNode childNode = node.getChildElement(elementName, null);
            if(childNode != null){
                result = childNode.getAttributeValue(attributeName, null);
            }
            
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
    public Dom.XmlNode getFirstChildNodeIfNotNull(Dom.XmlNode node){
        Dom.XmlNode result = null;
        List<Dom.XmlNode> childNodeList = getChildElementsIfNotNull(node);
        if(!childNodeList.isEmpty()){
            result = childNodeList[0];
        }
        return result;
    }
    /*
     * Expected date time format is "yyyy-MM-dd HH:mm:ss.sss"
     */
    public DateTime getChildNodeDateTimeIfNotEmpty(String elementName, Dom.XmlNode node, Boolean isGMT){
        DateTime dt = null;
        String dtStr = getChildNodeTextIfNotEmpty(elementName, node);
        try{
            if(String.isNotBlank(dtStr)){
                dt = isGMT ? DateTime.valueOfGmt(dtStr) : DateTime.valueOf(dtStr);
            }
        }catch(Exception e){
            system.debug('String Data convert to DateTime error : [original data:' + dtStr + ']');
        }
        return dt;
    }
    //added by Connor for CP-156(Client Portal)
    public Date getChildNodeDateFromSpecialDateTimeIfNotEmpty(String elementName, Dom.XmlNode node){
         Map<String, Integer> monthMap = new Map<String, Integer>{'Jan'=>1, 'Feb'=>2
         , 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9
         , 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
         Date d = null;
         String dtStr = getChildNodeTextIfNotEmpty(elementName, node);         
         List<String> dateParts;
         try{
            if(String.isNotBlank(dtStr)){
             dateParts = dtStr.replace('  ',' ').split(' ');
             Integer month = monthMap.get(dateParts[0]);
             Integer day = Integer.valueOf(dateParts[1]);
             Integer year = Integer.valueOf(dateParts[2]);
             d = Date.newInstance(year,month,day);
            }
        }catch(Exception e){
            system.debug('String Data convert to Date error : [original data:' + dtStr + ']'+'error is:'+dateParts);
        }
        return d;
    }
    /*
     * Expected date format is "yyyy-MM-dd", or "yyyy/MM/dd", or "dd/MM/yyyy"
     */
    public Date getChildNodeDateIfNotEmpty(String elementName, Dom.XmlNode node, String format){
        Date d = null;
        String dStr = getChildNodeTextIfNotEmpty(elementName, node);
        try{
            if(String.isNotBlank(dStr)){
                if('yyyy-MM-dd'.equalsIgnoreCase(format)){
                    d = Date.valueOf(dStr);
                }else if('yyyy/MM/dd'.equalsIgnoreCase(format)){
                    List<String> dlist = dStr.split('/');
                    d = Date.newInstance(Integer.valueOf(dlist[0]), Integer.valueOf(dlist[1]), Integer.valueOf(dlist[2]));
                }else if('dd/MM/yyyy'.equalsIgnoreCase(format)){
                    List<String> dlist = dStr.split('/');
                    d = Date.newInstance(Integer.valueOf(dlist[2]), Integer.valueOf(dlist[1]), Integer.valueOf(dlist[0]));
                }
            }
        }catch(Exception e){
            system.debug('String Data convert to Date error : [original data:' + dStr + ']');
        }
        return d;
    }
    public Decimal getChildNodeDecimalIfNotEmpty(String elementName, Dom.XmlNode node){
        Decimal d = null;
        String dStr = getChildNodeTextIfNotEmpty(elementName, node);
        try{
            if(String.isNotBlank(dStr)){
                d = Decimal.valueof(dStr);
            }
        }catch(Exception e){
            system.debug('String Data convert to Decimal error : [original data:' + dStr + ']');
        }
        return d;
    }
    public Integer getChildNodeIntegerIfNotEmpty(String elementName, Dom.XmlNode node){
        Integer d = null;
        String dStr = getChildNodeTextIfNotEmpty(elementName, node);
        try{
            if(String.isNotBlank(dStr)){
                d = Integer.valueof(dStr);
            }
        }catch(Exception e){
            system.debug('String Data convert to Decimal error : [original data:' + dStr + ']');
        }
        return d;
    }
    public Boolean getChildNodeBooleanIfNotEmpty(String elementName, Dom.XmlNode node){
        Boolean b = null;
        String bStr = getChildNodeTextIfNotEmpty(elementName, node);
        try{
            if(String.isNotBlank(bStr)){
                b = Boolean.valueof(bStr);
            }
        }catch(Exception e){
            system.debug('String Data convert to Boolean error : [original data:' + bStr + ']');
        }
        return b;
    }
    /*
     * Special for Cigna WS
     * 
     *<?xml version="1.0" encoding="UTF-8"?>
     *<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
     *  <soapenv:Body>
     *      <ns2:GetPolicyPersonListBasicResponse xmlns:ns2="http://webservice.digital.cigna.com/">
     *          <return Version="1.0">
     *              <TXLifeResponse PrimaryObjectID="Holding001" id="Response001">
     *                  Child Node
     *              </TXLifeResponse>
     *          </return>
     *      </ns2:GetPolicyPersonListBasicResponse>
     *  </soapenv:Body>
     *</soapenv:Envelope>
     *
     * TXObjectResponse : eg. TXLifeRequest/TXAccountRequest/TXFundRequest/TXNBRequest
     */
    public Dom.XmlNode getTXObjectResponseNode(Dom.Document doc){
        Dom.XmlNode result = null;
        if(doc != null){
            Dom.XmlNode root = doc.getRootElement();
            Dom.XmlNode bodyNode = getFirstChildNodeIfNotNull(root);
            Dom.XmlNode responseNode = getFirstChildNodeIfNotNull(bodyNode);
            Dom.XmlNode returnNode = getFirstChildNodeIfNotNull(responseNode);
            result = getFirstChildNodeIfNotNull(returnNode);
        }
        return result;
    }
    /*
     * Special for Cigna WS
     * 
     *<?xml version="1.0" encoding="UTF-8"?>
     *<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:q0="http://webservice.digital.cigna.com/">
     *  <soapenv:Header>
     *      <q0:SrvAccountName>testAccount</q0:SrvAccountName>
     *  </soapenv:Header>
     *  <soapenv:Body>
     *      <q0:SetNBDropOff>
     *          <q0:TXNB Version="1.00">
     *              <UserAuthRequest>
     *                  XXXXXX
     *              </UserAuthRequest>
     *              <TXNBRequest id="request001">
     *                  XXXXXX
     *              </TXNBRequest>
     *          </q0:TXNB>
     *      </q0:SetNBDropOff>
     *      <soapenv:Fault>
     *          <faultcode>soapenv:Server</faultcode>
     *          <faultstring>XXXXXX</faultstring>
     *      </soapenv:Fault>
     *  </soapenv:Body>
     *</soapenv:Envelope>
     * 
     */
    public void processSoapenvFault(Dom.Document doc){
        this.isSOAPFault = false;
        if(doc != null){
            Dom.XmlNode root = doc.getRootElement();
            if(root != null){
                Dom.XmlNode bodyNode = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                if(bodyNode != null){
                    Dom.XmlNode faultNode = bodyNode.getChildElement('Fault', 'http://schemas.xmlsoap.org/soap/envelope/');
                    if(faultNode != null){
                        result.resultInfoCode = getChildNodeTextIfNotEmpty('faultcode', faultNode);
                        result.resultInfoDesc = getChildNodeTextIfNotEmpty('faultstring', faultNode);
                        result.isSuccess = false;
                        this.isSOAPFault = true;
                    }
                }
            }
        }
    }
    public String processXMLEscape(String originValue, String defaultValueIfBlank){
        if(String.isNotBlank(originValue)){return originValue.escapeXML();}
        else if(String.isNotBlank(defaultValueIfBlank)){return defaultValueIfBlank.escapeXML();}
        else{return '';}
    }
    public String processXMLEscape(Decimal originValue, String defaultValueIfBlank){
        if(originValue != null){
            return originValue.toPlainString();
        }else if(String.isNotBlank(defaultValueIfBlank)){
            return defaultValueIfBlank.escapeXML();
        }else{
            return '';
        }
    }
    public String processXMLEscape(Date originValue, String defaultValueIfBlank){
        if(originValue != null){
            return originValue.year() + '-' + String.valueOf(originValue.month()).leftPad(2, '0') + '-' + String.valueOf(originValue.day()).leftPad(2, '0');
        }else if(String.isNotBlank(defaultValueIfBlank)){
            return defaultValueIfBlank.escapeXML();
        }else{
            return '';
        }
    }
    public String processXMLEscape(Time originValue, String defaultValueIfBlank){
        if(originValue != null){
            return originValue.hour() + ':' + originValue.minute() + ':' + originValue.second();
        }else if(String.isNotBlank(defaultValueIfBlank)){
            return defaultValueIfBlank.escapeXML();
        }else{
            return '';
        }
    }
    public String processXMLEscape(Boolean originValue, String defaultValueIfBlank){
        if(originValue != null){return originValue ? 'Y' : 'N';}
        else if(String.isNotBlank(defaultValueIfBlank)){return defaultValueIfBlank.escapeXML();}
        else{return '';}
    }
}