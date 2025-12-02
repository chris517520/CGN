/********************************************************************************
 * Apex Class Name - CignaUtil
 * Version - 1.0
 * Created Date - January 24, 2017
 * @description A Queue job to update case
 * 
 * Modification Log : 
 * -------------------------------------------------------------------------
 * Version   Developer          Date                    Description
 * ------    --------------     ------------            -----------------------
 * 1.0       Deloitte Admin     2017-1-24               Original Version
 ********************************************************************************/
global without sharing class CignaUtil{    
    private static Portal_Settings__c portalSettings = Portal_Settings__c.getInstance();
    //Nicole_SMT_20210310
    public static string cusFuncTD=Custom_Value__c.getValues('Customer_Function_TD')!=null?Custom_Value__c.getValues('Customer_Function_TD').Value__c:'';
    public static string cusPartCX=Custom_Value__c.getValues('Customer_Partner_CX')!=null?Custom_Value__c.getValues('Customer_Partner_CX').Value__c:'';
    public static string cusPartSMT=Custom_Value__c.getValues('Customer_Partner_SMT')!=null?Custom_Value__c.getValues('Customer_Partner_SMT').Value__c:'';
    public static string cusPartBSPK=Custom_Value__c.getValues('Customer_Partner_BSPK')!=null?Custom_Value__c.getValues('Customer_Partner_BSPK').Value__c:'';//PI Register - Tovid 20210924
    public static string virtualHeaProfile = Portal_Settings__c.getInstance().Customer_Virtual_User_Profile__c;
    // CTUI-220-20220622-Kirk
    public static Blob clientKey{
        get{
            if(clientKey == null){
                clientKey=EncodingUtil.base64Decode(Client_Portal_Setting__c.getValues('Key').Client_Portal_Key__c);
            }
            return clientKey;
        }
        set;
    }
    
    /**********************************************************************
     * isCMLoginAsUser
     * @description:Determine if the current user is CMLoginAsUser
     * Created - add Bob 20201208 CMUser
     * @return PageReference
     **********************************************************************/
    public static PageReference stopSubmittionforCMUser(){
        if(!System.isFuture()&&!System.isBatch()&&!System.isQueueable()&&!System.isScheduled()&&portalSettings.Enable_Login_As__c){
            Map<String,String> currentSessionAttributes=Auth.SessionManagement.getCurrentSession();
            String sessionType=currentSessionAttributes.get('SessionType');
            if(currentSessionAttributes.get('UserType')=='Standard'&&portalSettings.Enable_Login_As__c&&'Oauth2'!=sessionType){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,Label.CM_Login_As));
                return null;
            }
            return null;
        }
        return null;
    }

    /**********************************************************************
     * isCMLoginAsUser
     * @description:Determine if the current user is CMLoginAsUser
     * Created - add Bob 20201208 CMUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isCMLoginAsUser(){
        // System.debug('System.isFuture():' + System.isFuture());
        // System.debug('System.isQueueable():' + System.isQueueable());
        // System.debug('System.isScheduled():' + System.isScheduled());
        // System.debug('portalSettings.Enable_Login_As__c:' + portalSettings.Enable_Login_As__c);
        if (!System.isFuture()&&!System.isBatch()&&!System.isQueueable()&&!System.isScheduled()&portalSettings.Enable_Login_As__c) {
            // System.debug('System.isFuture():' + System.isFuture());
            // System.debug('System.isQueueable():' + System.isQueueable());
            // System.debug('System.isScheduled():' + System.isScheduled());
            // System.debug('portalSettings.Enable_Login_As__c:' + portalSettings.Enable_Login_As__c);
            Map<String,String> currentSessionAttributes=Auth.SessionManagement.getCurrentSession();
            String sessionType=currentSessionAttributes.get('SessionType');
            // System.debug('currentSessionAttributes:' + currentSessionAttributes);
            if(currentSessionAttributes.get('UserType')=='Standard'&&portalSettings.Enable_Login_As__c&&'Oauth2'!=sessionType){
                return true;
            }
            return false;
        }
        return false;
    }
    
    /**********************************************************************
     * isBrokerPortal
     * @description:Determine if the current environment is broker portal
     * @return Boolean
     **********************************************************************/
    public static Boolean isBrokerPortal(){
        return (Site.getName() != null && Site.getName().toLowerCase().contains('broker')) || CignaUtil.isBDUser();
    }
    
    public static Boolean isMyCignaRN(){
        return (Site.getName() != null && Site.getName().equals('My_Cigna'));
    }

    /**********************************************************************
     * isCustomerPortal
     * @description:Determine if the current environment is customer portal
     * @return Boolean
     **********************************************************************/
    public static Boolean isCustomerPortal(){      
        return portalSettings != null && portalSettings.Customer_Portal_Site_Name__c != null && portalSettings.Customer_Portal_Site_Name__c.equalsIgnoreCase(Site.getName());
    }
    
    /**********************************************************************
     * isCSUser
     * @description:Determine if the current user is CSUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isCSUser(){  
        //BEGIN HKITSFDC-129      
        // List<CustomPermission> customPermissions = [SELECT Id, DeveloperName FROM CustomPermission where DeveloperName = 'Customer_Service_User'];     
        // List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId = :customPermissions[0].id AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId())];        
        // return setupEntities.size()>0;
        return FeatureManagement.checkPermission('Customer_Service_User');
        //END HKITSFDC-129      
    }
    
    /**********************************************************************
     * isBDUser
     * @description:Determine if the current user is BDUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isBDUser(){
        //BEGIN HKITSFDC-129
        // return hasPermission(UserInfo.getUserId(), 'BD_Users');
        return FeatureManagement.checkPermission('BD_Users');
        //END HKITSFDC-129
    }
    
    /**********************************************************************
     * isTMUser
     * @description:Determine if the current user is TMUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isTMUser(String userId){
        return hasPermission(userId, 'TM_User');
    }
    
    /**********************************************************************
     * isCVMUser
     * @description:Determine if the current user is CVMUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isCVMUser(String userId){
        return hasPermission(userId, 'CVM_User');
    }
    
    /**********************************************************************
     * isTMRUser
     * @description:Determine if the current user is TMRUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isTMRUser(String userId){
        return hasPermission(userId, 'TM_TMR');
    }
    
    /**********************************************************************
     * isTMBuildTeamUser
     * @description:Determine if the current user is TMBuildTeamUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isTMBuildTeamUser(String userId){
        return hasPermission(userId, 'TM_Build_Team_User');
    }
    
    /**********************************************************************
     * isTMDTCUser
     * @description:Determine if the current user is TMDTCUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isTMDTCUser(String userId){
        return hasPermission(userId, 'TM_DTC_User');
    }
    
    /**********************************************************************
     * isTMLeader
     * @description:Determine if the current user is TMLeader
     * @return Boolean
     **********************************************************************/
    public static Boolean isTMLeader(String userId){
        return hasPermission(userId, 'TM_Leader');
    }
    
    /**********************************************************************
     * isAllowChangeCustomerRecordType
     * @description:Determine if the current user is Allow Change Customer Record Type
     * @return Boolean
     **********************************************************************/
    public static Boolean isAllowChangeCustomerRecordType(String userId){
        return hasPermission(userId, 'Allow_Change_Customer_Record_Type');
    }
    
    /**********************************************************************
     * hasPermission
     * @description:Determine if the specified user has the custom permission
     * @return Boolean
     **********************************************************************/
    public static Boolean hasPermission(String userId, String permissionName){
        //BEGIN HKITSFDC-129
        // List<CustomPermission> customPermissions = [SELECT Id, DeveloperName FROM CustomPermission where DeveloperName = :permissionName];     
        // List<SetupEntityAccess> setupEntities = new List<SetupEntityAccess>();
        // if(customPermissions.size() > 0){
        //     setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId = :customPermissions[0].id AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId)];
        // }        
        // return setupEntities.size()>0;
        return FeatureManagement.checkPermission(permissionName);
        //END HKITSFDC-129
    }
    
    /**********************************************************************
     * isEsalesCSUser
     * @description:Determine if the current user is EsalesCSUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isEsalesCSUser(){     
        //BEGIN HKITSFDC-129  
        // List<CustomPermission> customPermissions = [SELECT Id, DeveloperName FROM CustomPermission where DeveloperName = 'CS_User'];     
        // List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId = :customPermissions[0].id AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId())];        
        // return setupEntities.size()>0;
        return FeatureManagement.checkPermission('CS_User');
        //END HKITSFDC-129  
    }
    
    /**********************************************************************
     * isEsalesRMUser
     * @description:Determine if the current user is EsalesRMUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isEsalesRMUser(){   
        //BEGIN HKITSFDC-129     
        // List<CustomPermission> customPermissions = [SELECT Id, DeveloperName FROM CustomPermission where DeveloperName = 'RM_User'];     
        // List<SetupEntityAccess> setupEntities = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId = :customPermissions[0].id AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId())];       
        // return setupEntities.size()>0;
        return FeatureManagement.checkPermission('RM_User');
        //END HKITSFDC-129     
    }

    /**********************************************************************
     * isEnableBuyNowForCustomer
     * @description:Determine if the current user is EnableBuyNowForCustomer
     * @return Boolean
     **********************************************************************/
    public static Boolean isEnableBuyNowForCustomer(){
        return portalSettings != null && portalSettings.Enable_Buy_Now__c;
    }
    
    /**********************************************************************
     * isEnableBuyNowForBroker
     * @description:Determine if the current user is EnableBuyNowForBroker
     * @return Boolean
     **********************************************************************/
    public static Boolean isEnableBuyNowForBroker(){
        return portalSettings != null && portalSettings.Broker_Enable_Buy_Now__c;
    }
    
    /**********************************************************************
     * isAltruistUser
     * @description:Determine if the current user is AltruistUser
     * @return Boolean
     **********************************************************************/
    public static Boolean isAltruistUser(){
        List<Account> accList = new List<Account>();
        List<User> userList = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(!userList.isEmpty() && userList[0].AccountId != null){
            accList = [select id, Is_Altruist_User__c from Account where Id = :userList[0].AccountId and Is_Altruist_User__c = true];
        }        
        return !accList.isEmpty();
    }
    
    /**********************************************************************
     * generateOneTimeToken
     * @description:Encoding the token
     * @return String
     **********************************************************************/
    public static String generateOneTimeToken(){
        return EncodingUtil.convertToHex(Crypto.generateAesKey(256));
    }
    
    /**********************************************************************
     * generateOneTimeToken
     * @description: Rancho_CTUI226_20220706 - add user info into the token and encode it
     * @param String username
     * @return String
     * @author ranzhao@deloitte.com.cn
     **********************************************************************/
    public static String generateOneTimeToken(String username){
        Blob iv = Blob.valueOf('CignaEsignatureG');
        Blob data = Blob.valueOf(username+System.now().millisecond());
        Blob encrypted=Crypto.encrypt('AES256',clientKey,iv,data);
        System.debug('cigna util token: '+EncodingUtil.urlEncode(EncodingUtil.base64Encode(encrypted),'UTF-8'));
        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(encrypted),'UTF-8');
    }

    /**********************************************************************
     * decryptOneTimeToken
     * @description: Rancho_CTUI226_20220706 - decode the token and compare with username
     * @param String token - external data one time token
     * @return String
     * @author ranzhao@deloitte.com.cn
     **********************************************************************/
    public static Boolean decryptOneTimeToken(String token){
        Boolean result=false;
        if(String.isNotBlank(token)){
            Blob iv = Blob.valueOf('CignaEsignatureG');
            Blob data = EncodingUtil.base64Decode(EncodingUtil.urlDecode(token, 'UTF-8'));
            Blob decrypted = Crypto.decrypt('AES256', clientKey, iv, data);
            System.debug('decrypted:'+decrypted.toString());
            if(decrypted.toString().containsIgnoreCase(UserInfo.getUserName())){
                result = true;
            }
        }
        return result;
    }

    /**********************************************************************
     * getFolderId
     * @description:Get Custom_Portal_Documents's Folder
     * @return Id
     **********************************************************************/
    public static Id getFolderId(){
        Folder fol = [Select Id,Name,DeveloperName From Folder Where DeveloperName = 'Custom_Portal_Documents'];
        return fol.Id;
    }
    
    /**********************************************************************
     * getBrkFolderId
     * @description:Get Broker_Portal_Documents's Folder
     * @return Id
     **********************************************************************/
    public static Id getBrkFolderId(){
        Folder fol = [Select Id,Name,DeveloperName From Folder Where DeveloperName = 'Broker_Portal_Documents'];
        return fol.Id;
    }
    
    /**********************************************************************
     * getPersonalInformationCollectionStatement_eng
     * @description: Get personal information collection statement
     * @return String
     **********************************************************************/
    public static String getPersonalInformationCollectionStatement_eng(){
        // Rancho_update PICS in website_20211020: replace production url
        // return 'https://www.cigna.com.hk/iwov-resources/docs/en/PersonalInformationCollectionStatement_eng.pdf';
        //JOBR-184: updated by Kermit
        if(isCustomerPortal()){
            return Label.PersonalInformationCollectionStatementURL;
        }else{
            return Label.BrokerPersonalInformationCollectionStatementURL;
        }
    }
    
    /**********************************************************************
     * getPrivacy_statement_eng
     * @description: Get personal information collection statement
     * @return String
     **********************************************************************/
    public static String getPersonalInformationCollectionStatement_chi(){
        // Rancho_update PICS in website_20211020: replace production url
        // return 'https://www.cigna.com.hk/iwov-resources/docs/zh-hant/PersonalInformationCollectionStatement_chi.pdf';
        //JOBR-184: updated by Kermit
        if(isCustomerPortal()){
            return Label.PersonalInformationCollectionStatementURL;
        }else{
            return Label.BrokerPersonalInformationCollectionStatementURL;
        }
    }
    
    /**********************************************************************
     * getPrivacy_statement_eng
     * @description: Get Privacy statement
     * @return String
     **********************************************************************/
    public static String getPrivacy_statement_eng(){
        // Comment by Shengt for JOBR-235
        return Label.PrivacyStatementURL;
        // Id folderId = getFolderId();
        // String docId='';
        // if(folderId!=null){
        //     List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = 'Privacy_statement_eng_20170224' and folderId = :folderId];
        //     if(docList.size()>0){
        //         docId = docList[0].Id;
        //     }
        // }
        // return docId;
    }
    
     /**********************************************************************
     * getPrivacy_statement_chi
     * @description: Get Privacy statement
     * @return String
     **********************************************************************/
    public static String getPrivacy_statement_chi(){
        // Comment by Shengt for JOBR-235
        return Label.PrivacyStatementURL;
        // Id folderId = getFolderId();
        // String docId='';
        // if(folderId!=null){
        //     List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = 'Privacy_statement_chi_20170224' and folderId = :folderId];
        //     if(docList.size()>0){ 
        //         docId = docList[0].Id;
        //     }
        // }
        // return docId;
    }
    
    /**********************************************************************
     * getBrokerPrivacyStatement_eng
     * @description: Get Broker's privacy statement
     * @return String
     **********************************************************************/
    public static String getBrokerPrivacyStatement_eng(){
        // Comment by Shengt for JOBR-235
        return Label.BrokerPrivacyStatementURL;
        // Id folderId = getBrkFolderId();
        // String docId='';
        // if(folderId!=null){
        //     List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = 'Brk_privacy_statement_eng_20170223' and folderId = :folderId];
        //     if(docList.size()>0){
        //         docId = docList[0].Id;
        //     }
        // }
        // return docId;
    }
    
    /**********************************************************************
     * getBrokerPrivacyStatement_chi
     * @description: Get Broker's privacy statement
     * @return String
     **********************************************************************/
    public static String getBrokerPrivacyStatement_chi(){
        // Comment by Shengt for JOBR-235
        return Label.BrokerPrivacyStatementURL;
        // Id folderId = getBrkFolderId();
        // String docId='';
        // if(folderId!=null){
        //     List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = 'Brk_privacy_statement_chi_20170223' and folderId = :folderId];
        //     if(docList.size()>0){
        //         docId = docList[0].Id;
        //     }
        // }
        // return docId;
    }
    
    /**********************************************************************
     * getBrokerPersonalInformationCollectionStatement_eng
     * @description: Get broker personal information collection statement
     * @return String
     **********************************************************************/
    public static String getBrokerPersonalInformationCollectionStatement_eng(){
        // Comment by Shengt for JOBR-235
        return Label.BrokerPersonalInformationCollectionStatementURL;
        // Id folderId = getBrkFolderId();
        // String docId='';
        // if(folderId!=null){
        //     List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = 'Brk_personal_information_collection_statement_eng' and folderId = :folderId];
        //     if(docList.size()>0){
        //         docId = docList[0].Id;
        //     }
        // }
        // return docId;
    }
    
    /**********************************************************************
     * getBrokerPersonalInformationCollectionStatement_chi
     * @description: Get broker personal information collection statement
     * @return String
     **********************************************************************/
    public static String getBrokerPersonalInformationCollectionStatement_chi(){
        // Comment by Shengt for JOBR-235
        return Label.BrokerPersonalInformationCollectionStatementURL;
        // Id folderId = getBrkFolderId();
        // String docId='';
        // if(folderId!=null){
        //     List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = 'Brk_personal_information_collection_statement_chi' and folderId = :folderId];
        //     if(docList.size()>0){
        //         docId = docList[0].Id;
        //     }
        // }
        // return docId;
    }

    // add by David 07/11/2017 for ThirdPartyPayment CR start
    public static String getBrokerPortalURL(){
        return portalSettings.Broker_Portal_URL__c;
    }
    // add by David 07/11/2017 for ThirdPartyPayment CR start

    /**********************************************************************
     * calculateAge
     * @description: Calculate the age
     * @param Date
     * @return Integer
     * @author:Nicole
     **********************************************************************/
    public static Integer calculateAge(Date d){
           if(d == null){return null;}          
           Datetime nowDT = Datetime.now();
           Integer nowYear = Integer.valueOf(nowDT.format('yyyy'));
           Integer nowMonth = Integer.valueOf(nowDT.format('MM'));
           Integer nowDay = Integer.valueOf(nowDT.format('dd'));
           Integer age=nowYear-Integer.valueOf(d.year());

           if(nowMonth <= Integer.valueOf(d.month())){
                if(nowMonth == Integer.valueOf(d.month())){
                    if(nowDay < Integer.valueOf(d.Day())){age--;}
                }else{age--;}
            }
            return age;
    }
        
    /**********************************************************************
     * isPIGreaterThan18
     * @description: To Decide is older than 18
     * @param Boolean,@param Date
     * @return Boolean
     * @author:Nicole
     **********************************************************************/    
    public static Boolean isPIGreaterThan18(Boolean isPI,Date d){
           if(!isPI || d == null){return false;}           
           Datetime nowDT = Datetime.now();
           Integer nowYear = Integer.valueOf(nowDT.format('yyyy'));
           Integer nowMonth = Integer.valueOf(nowDT.format('MM'));
           Integer nowDay = Integer.valueOf(nowDT.format('dd'));
           Integer age=nowYear-Integer.valueOf(d.year());
           if(nowMonth <= Integer.valueOf(d.month())){
                if(nowMonth == Integer.valueOf(d.month())){
                    if(nowDay < Integer.valueOf(d.Day())){age--;}
                }else{age--;}
            }
            
            if(age>18){return true;}
            else{return false;}           
    }
    //Added by Nicole for Encryption in 2018.04.27 end      
    
    /*************************************************************
     *方法名: getQueryStringByFieldMap
     *功能说明: 根据对象字段Map返回SQL查询语句
     *参数说明: Map<String,Schema.SObjectField> objLoopMap 
     *返回值: String queryString
     *************************************************************/
    public Static String getQueryStringByFieldMap(Map<String,Schema.SObjectField> objLoopMap){
        String queryString = '';
        for(String fieldApi : objLoopMap.keySet()){
            if(queryString <> ''){queryString += ',';}
            queryString += fieldApi;
        }
        return queryString;
    } 
    
    //GL31 jack add
    /*************************************************************
     *方法名: getAvailableProductScope
     *功能说明: 根据所选答案返回可选product和rider的Map
     *参数说明: List<Assessment_Questions_Product_Mapping__c> mappingList,String Q1Answer,String Q2Answer
     *返回值: Map<String,Set<String>> key->ProdCode value->rider set
     *************************************************************/
    public static Map<String,Set<String>> getAvailableProductScope(List<Assessment_Questions_Product_Mapping__c> mappingList,String Q1Answer,String Q2Answer){
        Map<String,Set<String>> resultMap = new Map<String,Set<String>>();
        Set<String> productCodeScope = new Set<String>();
        system.debug('Q1Answer:'+Q1Answer+'Q2Answer'+Q2Answer);
        for(Assessment_Questions_Product_Mapping__c mapping : mappingList){
            if(Q1Answer.containsIgnoreCase(mapping.Answer_of_Q1__c) && Q2Answer.containsIgnoreCase(mapping.Answer_of_Q2__c) && String.isNotBlank(mapping.Available_Product_Code__c) ){
               List<String> productCodeList = mapping.Available_Product_Code__c.split(';');
               for(String codeRider : productCodeList){
                   String code;
                   String rider;
                   if(codeRider.contains('[')){
                       code = codeRider.substringBefore('[').deleteWhitespace();
                       rider = codeRider.substringBetween('[', ']');
                   }else{
                       code = codeRider.deleteWhitespace();
                   }
                   Set<String> riderSet;
                    if(resultMap.containsKey(code)){
                        riderSet = resultMap.get(code);
                    }else{
                        riderSet = new Set<String>();
                    }
                    if(String.isNotBlank(rider)){
                        riderSet.addAll(rider.split(','));
                    }
                    // if(String.isNotBlank(mapping.Product_Code_for_All_Rider_Available__c) && mapping.Product_Code_for_All_Rider_Available__c.containsIgnoreCase(code)){
                    //         riderSet.add(ALL_RIDER_IS_AVAILABLE);
                    // }else{
                    //     if( String.isNotBlank(mapping.Available_Rider__c) ){
                    //         Pattern pat = Pattern.compile(code+':(\\w+,*)+');
                    //         Matcher matcher = pat.matcher(mapping.Available_Rider__c);
                    //         if(matcher.find()){
                    //             system.debug('matcher.group(0):'+matcher.group(0));
                    //             String riderString = matcher.group(0).substringAfter(code+':');
                    //             riderSet.addAll(riderString.split(','));
                    //         }
                    //     }
                    // }
                    resultMap.put(code,riderSet);
               }
            }
        }
        system.debug('resultMap:'+resultMap);
        return resultMap;
    }
    /*************************************************************
     *方法名: getTMProductCode
     *功能说明: 根据Map的数据返回相应TM Product Code
     *参数说明: List<TM_Product_Category__c> prodCatList,Map<String,Set<String>> productRiderMap
     *返回值: String
     *************************************************************/
    public static String getTMProductCode(List<TM_Product_Category__c> prodCatList,Map<String,Set<String>> productRiderMap){
        Map<String,String> tmProductMap = new Map<String,String>();
        String result = '';
        for(TM_Product_Category__c proCat : prodCatList){
            tmProductMap.put(proCat.Parent_Product__c,proCat.Product_Code__c);
        }
        for(String key : productRiderMap.keySet()){
            if(productRiderMap.get(key).contains(ALL_RIDER) || TM_PRO_SCOPE.containsIgnoreCase(key)){
                if(tmProductMap.containsKey(key)){
                    result = result + tmProductMap.get(key) + ',';
                }else{
                    result = result + key + ',';
                }
            }
        }
        if(result.endsWith(',')){
            result = result.substringBeforeLast(',');
        }
        return result;
    }
    /*************************************************************
     *方法名: getAvailableRider
     *功能说明: 根据Map和选择的product code返回相应rider数据
     *参数说明: List<TM_Product_Category__c> prodCatList,Map<String,Set<String>> productRiderMap,String code
     *返回值: Set<String> rider set
     *************************************************************/
    public static Set<String> getAvailableRider(List<TM_Product_Category__c> prodCatList,Map<String,Set<String>> productRiderMap,String code){
        for(TM_Product_Category__c proCat : prodCatList){
            if(code != null && proCat.Product_Code__c.containsIgnoreCase(code)){
                code = proCat.Parent_Product__c;
            }
        }
        System.debug('code'+code);
        System.debug('productRiderMap'+productRiderMap);
        System.debug('contains key'+productRiderMap.containsKey(Code));
        return productRiderMap.get(Code);
    }

    public static Boolean assessRiderValide(Set<String> selectedRiders,Set<String> availableRider){
        if((availableRider != null && availableRider.contains(ALL_RIDER)) || selectedRiders == null || selectedRiders.size() == 0){return true;}
        else if(availableRider == null){return false;}
        
        Boolean result = false;
        for(String rider : selectedRiders){
            system.debug('rider:'+rider);   
            for(String riderKey : availableRider){
                System.debug('riderKey:'+riderKey);
                if(rider.startsWithIgnoreCase(riderKey)){
                    result = true;
                    break;
                }
            }
            if(result){return result;}
        }
        System.debug('assessRiderValide result：'+result);
        return result;
    } 

    public static final String EMPTY_ASSESSMENT_ANSWER = 'Answer of Assessment Question is empty';
    public static final String PRO_CODE_FAIL = 'Product Code Fail';
    public static final String RIDER_FAIL = 'Rider Fail';
    public static final String FINE_RESULT = 'Fine Result';
    public static final String TM_PRO_SCOPE = '@CBOG, @SP100';
    public static final String ALL_RIDER = 'ALL';
    public static String checkAssessResult( String Q1Answer,String Q2Answer,String proRiderMapS,String selectedProductCode,Set<String> selectedRider,Boolean isTM,Boolean isEsales){
        //answer checking
        if(String.isEmpty(Q1Answer) || String.isEmpty(Q2Answer)){
            if(String.isEmpty(proRiderMapS)){
                return EMPTY_ASSESSMENT_ANSWER;
            }
        }

        //product code validation
        Map<String,Set<String>> assessProRiderMap;
        if(string.isNotBlank(proRiderMapS)){
            assessProRiderMap = (Map<String,Set<String>>)JSON.deserialize(proRiderMapS, Map<String,Set<String>>.class);
        }else{
            List<Assessment_Questions_Product_Mapping__c> mappingList = Assessment_Questions_Product_Mapping__c.getAll().values();
            assessProRiderMap = getAvailableProductScope(mappingList,Q1Answer,Q2Answer);
        }
        // List<TM_Product_Category__c> prodCatList=TM_Product_Category__c.getAll().values();//jack add for friend and family discount in SFDC
        List<TM_Product_Category__c> prodCatList=[Select Product_Code__c,Parent_Product__c,Name from TM_Product_Category__c where Module__c='Assessment Question'];//jack add for friend and family discount in SFDC
        System.debug('assessProRiderMap:'+assessProRiderMap);
        if(!TM_PRO_SCOPE.containsIgnoreCase(selectedProductCode)){
            if(isTM){
                String tmProS = getTMProductCode(prodCatList,assessProRiderMap);
                if(!tmProS.containsIgnoreCase(selectedProductCode)){
                    return PRO_CODE_FAIL;
                }
            }else{
                if(!assessProRiderMap.containsKey(selectedProductCode) || !assessProRiderMap.get(selectedProductCode).contains(ALL_RIDER)){
                    return PRO_CODE_FAIL;
                }
            }
        }
        
        //rider validation
        Set<String> assessRiderSet;
        if(isEsales){
            if(isTM){
                assessRiderSet = getAvailableRider(prodCatList,assessProRiderMap,selectedProductCode);
                if(TM_PRO_SCOPE.containsIgnoreCase(selectedProductCode) && !assessRiderValide(selectedRider,assessRiderSet)){
                    return RIDER_FAIL;
                }
            }
        }else{
            assessRiderSet = assessProRiderMap.get(selectedProductCode);
            if(!assessRiderValide(selectedRider,assessRiderSet)){
                return RIDER_FAIL;
            }
        }
        return FINE_RESULT;
    }
    
    //SPS-699 jack add
    public static void createCheckingLog(String functionName,  String LineNumber, String StackTrace, String ErrorMessage,String policyNo){
        Checking_Log__c clog = new Checking_Log__c();
            //clog.Function_Name__c = 'TMWebsitCallListGenerateQueue.createOpportunity';
            clog.Function_Name__c = functionName;
            clog.Policy_No_in_the_Batch__c = policyNo?.length()>254?policyNo.substring(0,254):policyNo;
            clog.ErrorMessage_Long__c = ErrorMessage;
            clog.TmpString1__c = LineNumber;
            clog.TmpString2__c = StackTrace;
            clog.UserInfo_String__c = userInfo.getUserId();
            insert clog;
    }
    
    //added by Connor 24/02/21
    public static Map<String, Map<String, String>> getTranslationByCategory(String ctgy){
        Map<String, Map<String, String>> transField = new Map<String, Map<String, String>>();
         //ctgy = '%' + ctgy + '%';      [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c like :ctgy]
        //String sql = select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c like '\'%'+ctgy+'%\'';    // like '%ctgy%'
        for(Translate__mdt t : [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c = :ctgy]){
            transField.put(t.DeveloperName, new Map<String, String>{'zh_TW' => t.zh_TW__c, 'en_US' => t.en_US__c });
        }
        return transField ;
    }
    //added by jack MR
    public static Map<String, Map<String, String>> getTranslationByCategory(Set<String> ctgys){
        Map<String, Map<String, String>> transField = new Map<String, Map<String, String>>();
         //ctgy = '%' + ctgy + '%';      [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c like :ctgy]
        //String sql = select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c like '\'%'+ctgy+'%\'';    // like '%ctgy%'
        for(Translate__mdt t : [select DeveloperName,zh_TW__c, en_US__c from Translate__mdt where Category__c in :ctgys]){
            transField.put(t.DeveloperName, new Map<String, String>{'zh_TW' => t.zh_TW__c, 'en_US' => t.en_US__c });
        }
        return transField ;
    }
    //added by Connor 26/03/21
    public static String buildCriteriaNode(String objectTypeTc,String objectTypeValue, String propertyName, String propertyValue, String operationTC, String operationValue){
        String result = '';
        if(String.isBlank(propertyValue)){
            return result;
        }
        result =  '<Criteria>'
            +'    <ObjectType tc="'+objectTypeTc+'">'+objectTypeValue+'</ObjectType>'
            +'    <PropertyName>'+propertyName+'</PropertyName>'
            + '    <PropertyValue>' +propertyValue+'</PropertyValue>'
            + '    <Operation tc="'+operationTC+'">'+operationValue+'</Operation>'
            + '</Criteria>';
        return result;
    }
    
    //Nicole_SMT_20210310
    //To covert a string to List<String>
    public static List<String> listCoverter(String input){
        List<String> result=new List<String>();
        if(input!=null){
            for(Integer i=0;i<input.length();i++){
                result.add(input.Substring(i,i+1));
            }
        }
        return result;
    }
    //To covert a binary number to decimal number
    public static String binaryConverter(String binary){
        Integer result=0;
        if(String.IsNotBlank(binary)){
            List<String> binaryList=listCoverter(binary);           
            if(binaryList!=null&&binaryList.size()>0){
                Integer tolSize=binaryList.size();
                for(Integer i=0;i<tolSize;i++){
                    if(binaryList[i]!=null){
                        Integer unit=1;
                        for(Integer j=tolSize-i-1;j>0;j--){
                            unit=unit*2;
                        }
                        result+=Integer.Valueof(binaryList[i])*unit;
                    }
                }
            }
        }
        return String.Valueof(result);
    }

    /********************************************************************
    * caculate claim TAT, invoke from flow Commercial Assessment Screen
    * @param   List<FlowDataWrapper> wrapperList
    * @return  Decimal
    * @author  Rancho_JOBR313_20230809
    ********************************************************************/
    @InvocableMethod
    public static List<Decimal> getTATByDatetime(List<FlowDataWrapper> wrapperList){
        System.debug('get TAT param: '+wrapperList);
        List<Decimal> resultList = new List<Decimal>();
        for(FlowDataWrapper wrapper : wrapperList){
            Decimal result = calcuBusinessHours(getBusiHours('HWC Team Business Hours'), wrapper.startTime, wrapper.endTime, 'daysWithScale1');
            resultList.add(result);
        }
        return resultList;
    }

    public class FlowDataWrapper{
        @InvocableVariable(label='Start Datetime' description='claim team start working' required=true)
        public Datetime startTime;
        @InvocableVariable(label='End Datetime' description='claim team finish working' required=true)
        public Datetime endTime;
    }

    /**
     * calculate business hours between two date/time excluding holiday and weekends
     * @param businessHoursName: used Business Hours configuration from setup; startDate: start datetime; endDate: end datetime
     *                             unitType: return milliseconds  value or hours
     * @return 
     * @author Zane Zhang
     * @version V1.0  2021-06-28  init this method
     * 
     * ***/

    public static BusinessHours getBusiHours(String businessHoursName){
        BusinessHours busiHour = [SELECT Id, Name,MondayStartTime, MondayEndTime,TimeZoneSidKey FROM BusinessHours WHERE Name =:businessHoursName LIMIT 1 ];

        return busiHour;
    }
    // pass date
    public static Decimal calcuBusinessHours(BusinessHours busiHours, Date startDate, Date endDate, String unitType){
        //Constructs a Datetime from Integer representations of the specified year, month (1=Jan), and day at midnight in the local time zone.
        // 2021-07-15 == 2021-07-14 16:00:00
        return calcuBusinessHours(busiHours, DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()), DateTime.newInstance(endDate.year(), endDate.month(), endDate.day()), unitType);

    }
    //pass date time
    public static Decimal calcuBusinessHours(BusinessHours busiHours, DateTime startDate, DateTime endDate, String unitType){

        Decimal resultLength = 0;

        BusinessHours busiHour = busiHours;

        if(startDate != null && endDate != null && String.isNotBlank(unitType)){
            resultLength = BusinessHours.diff(busiHour.Id, startDate, endDate);

            //covert to different unit
            if(String.isNotBlank(unitType) && unitType == 'hoursWithScale2'){
                Decimal unitResult = resultLength/(60*60*1000);
                resultLength = unitResult.setScale(2);
            }else if(String.isNotBlank(unitType) && unitType == 'hours'){
                resultLength = resultLength/(60*60*1000);
            }else if(String.isNotBlank(unitType) && unitType == 'daysWithScale1'){
                if(busiHour.MondayStartTime!= null && busiHour.MondayEndTime!= null){
                    Decimal oneDayMilli = (busiHour.MondayEndTime.hour()*60+busiHour.MondayEndTime.minute())*60*1000 - (busiHour.MondayStartTime.hour()*60+busiHour.MondayStartTime.minute())*60*1000;
                    System.debug(LoggingLevel.INFO, '***onaDayMilli : ' + oneDayMilli);
                    Decimal unitResult = resultLength/oneDayMilli;
                    resultLength = unitResult.setScale(1);
                }
            }
        }

        return resultLength;
    }
    
    // Rancho_SMT144_20220411 - deploy to production in advance for getting the doc
    public static String getSMT_TC_Outpatient_Discount(){
        Id folderId = getFolderId();
        String docId='';
        if(folderId!=null){
            List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = 'SMT_TC_Outpatient_Discount' and folderId = :folderId];
            if(docList.size()>0){
                docId = docList[0].Id;
            }
        }
        return docId;
    }

    //SMT-109 Tovid Add  Data_Privacy_Notice doc -start    
    public static String getTelaDoc(String fileName){
        Id folderId = getFolderId();
        String docId='';
        if(folderId!=null){
            List<Document> docList = [Select Id,Name,DeveloperName From Document Where DeveloperName = :fileName and folderId = :folderId];
            if(docList.size()>0){
                docId = docList[0].Id;
            }
        }
        return docId;
    }
    //SMT-109 Tovid Add  Data_Privacy_Notice doc -end

    /**
     * @Description: use function name to get Cigna WS log Setting
     * if Cigna WS log Setting field parent is not null, will get domain endpoint from WS_Callout_Setting__c according to profile name
     * 20210906 - minghua - eSalesHKWS API
     * @return Cigna_WS_Log_Setting__c
     * @author Minghua Gong
     * @version v1.0  init this method  2021-09-06 minghua
     *          v1.1  add getting endpoint from profile level 2021-09-13 Zane
     */
    public static Cigna_WS_Log_Setting__c getCignaWSLogSetting(String functionName,String profileName){
        // use function name to get Cigna WS log Setting
        Cigna_WS_Log_Setting__c wsLogSetting =Cigna_WS_Log_Setting__c.getValues(functionName);
        if(wsLogSetting!=null&&String.isNotBlank(wsLogSetting.Parent__c)&&String.isNotBlank(profileName)){
            String endpoint='';
            // get WS_Callout_Setting__c according to profile name
            WS_Callout_Setting__c wsSetting = WS_Callout_Setting__c.getValues(profileName);
            if(wsSetting!=null){
                // get endpoint from WS Callout Setting
                endpoint=getParentEndPoint(wsLogSetting.Parent__c, wsSetting);
                if(String.isBlank(endpoint)&&String.isNotBlank(wsSetting.Parent__c)){
                    // get endpoint from this WS Callout Setting's parent Setting
                    wsSetting = WS_Callout_Setting__c.getValues(wsSetting.Parent__c);
                    if(wsSetting!=null){
                        endpoint=getParentEndPoint(wsLogSetting.Parent__c,wsSetting);
                    }
                }
                wsLogSetting.Endpoint_Domain__c=endpoint;
            }
        }
        return wsLogSetting;
    }
 
    // get profile level endpoint if the parent value of ws log custom setting 2021-09-13 Zane
    private static String getParentEndPoint(String parentField, WS_Callout_Setting__c wsCallSetting){
        String parentEndpoint = '';

        switch on parentField{
            when 'Endpoint'{
                parentEndpoint = wsCallSetting.Endpoint__c;
            }
            when 'CB_Endpoint'{
                parentEndpoint = wsCallSetting.CB_Endpoint__c;
            }
            when 'eSales_Endpoint' {
                parentEndpoint = wsCallSetting.eSales_Endpoint__c;
            }

        }
        return parentEndpoint;
    }

    /*detect whether apex is asynchronous  2021-01-05 Zane*/
    public static Boolean isAsynchronous(){
        return System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled();
    }

    
    //CR-63_Link_20220520:isSafeObject
    public static Boolean isSafeObject(String objName){
        Map <String, Schema.SObjectType> schemaMap=Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);
        if (myObj!=null) { 
            return true; 
        }else{
            return false;
        }
    }

    //CR-63_Link_20220520:isSafeField
    public static Boolean isSafeField(String fieldName, String objName){
        if(String.isBlank(fieldName) || String.isBlank(objName)){
            return false;
        }
        List<String> fieidNameList;
        if(fieldName.contains(',')){
            fieidNameList=fieldName.split(',');
        }else{
            fieidNameList=new List<String>();
            fieidNameList.add(fieldName);
        }
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);
        if (myObj!=null) { 
            for(String fieldStr : fieidNameList){
                SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldStr);
                if(myField==null){
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    //CR-63_Link_20220520:isSafeId
    public static Boolean isSafeId(Id objId){
        SObjectType myObj = objId.getSobjectType();
        if(myObj != null){
            return true;
        }else{
            return false;
        }
    }

    /**
    * @description escapt script tag for XSS
    * @author jackshao@deloitte.com.cn | 06-22-2022 | Checkmarx SOQL injection
    * @param String input 
    * @return String 
    **/
    public static String escapeScriptTag(String input){
        return input==null?null:input.replaceAll('<\\s*\\/*\\s*[Ss][Cc][Rr][Ii][Pp][Tt]\\s*>', ' ');
    }

    private static final String[] JS_DECODED = new String[] { '\\', '\'', '\n', '\r', '"', '!--', '/', '<', '>' };
    private static final String[] JS_ENCODED = new String[] { '\\\\', '\\\'', '\\n', '\\r', '\\"', '\\!--', '\\/', '\\u003C', '\\u003E' };

    public static String SFDC_JSENCODE(String input) {
		return ENCODE(input, JS_DECODED, JS_ENCODED);
	}

    private static String ENCODE(String input, String[] fromArr, String[] toArr) {
		if (input == null || input.length() == 0)
			return input;

		for (Integer i = 0; i < fromArr.size(); ++i) {
			input = input.replace(fromArr[i], toArr[i]);
		}
		
		return input;
	}

    // Rancho_HKITSFDC378_20251105 - remove '&', '\\&amp;'
    private static final String[] JSINHTML_DECODED = new String[] { '\\', '\'', '"', '\r', '\n', '<', '>' };
	private static final String[] JSINHTML_ENCODED = new String[] { '\\\\', '\\&#39;', '\\&quot;', '\\r', '\\n', '&lt;', '&gt;' };

    public static String SFDC_JSINHTMLENCODE(String input) {
		return ENCODE(input, JSINHTML_DECODED, JSINHTML_ENCODED);
	}

    /**
    * @description escapt script tag for XSS, and exclude \n for app textarea field
    * @author ranzhao@deloitte.com.cn
    * @param String input 
    * @return String 
    **/
    private static final String[] JSTEXTAREA_DECODED = new String[] { '\\', '\'', '"', '\r', '<', '>' };
    private static final String[] JSTEXTAREA_ENCODED = new String[] { '\\\\', '\\&#39;', '\\&quot;', '\\r', '&lt;', '&gt;' };

    public static String SFDC_JSTEXTAREAENCODE(String input) {
        return ENCODE(input, JSTEXTAREA_DECODED, JSTEXTAREA_ENCODED);
    }

    /**
     * CTUI-220-20220622-Kirk
     * @Author   minghua
     * @DateTime 2022-07-12T14:05:31+0800
     * @param    dataStr
     * @return   String base64 encrypt
     */
    public static String generateToken(String dataStr){
        Blob data=Blob.valueOf(dataStr);
        Blob encrypted=Crypto.encryptWithManagedIV('AES256',clientKey,data);
        return EncodingUtil.base64Encode(encrypted);
    }
    /**
     * CTUI-220-20220622-Kirk
     * @Author   minghua
     * @DateTime 2022-07-12T14:05:31+0800
     * @param    dataStr
     * @return   String base64 encrypt url
     */
    public static String generateURLToken(String dataStr){
        return EncodingUtil.urlEncode(generateToken(dataStr),'UTF-8');
    }
    /**
     * CTUI-220-20220622-Kirk
     * @Author   minghua
     * @DateTime 2022-07-12T14:06:26+0800
     * @param    token
     * @return    String
     */
    public static String decryptToken(String token){
        Blob data=EncodingUtil.base64Decode(token);
        Blob decrypted=Crypto.decryptWithManagedIV('AES256',clientKey,data);
        return decrypted.toString();
    }
    /**
     * CTUI-220-20220622-Kirk
     * @Author   minghua
     * @DateTime 2022-07-12T14:06:26+0800
     * @param    token
     * @return    String
     */
    public static String decryptUTLToken(String token){
        return decryptToken(EncodingUtil.urlDecode(token,'UTF-8'));
    }

    /**
     * Save log to Checking_Log__c TmpString1__c/TmpString2__c/TmpString3__c
     * @Author   Gong,Minghua
     * @DateTime 2022-11-01
     * @param    funName
     * @param    reqBody
     */
    @future
    public static void createSaveLog(String funName,String reqBody) {
        Integer maxLimit=32700;
        try {
            Checking_Log__c clog=new Checking_Log__c();
            if (String.isNotBlank(funName)) {
                clog.Function_Name__c = funName;
            }
            if (String.isNotBlank(reqBody)) {
                reqBody = reqBody.trim();
                if (reqBody.length()/maxLimit==0) {
                    clog.TmpString1__c=reqBody;
                }else if (reqBody.length()/maxLimit==1) {
                    clog.TmpString1__c=reqBody.substring(0,maxLimit);
                    clog.TmpString2__c=reqBody.substring(maxLimit,reqBody.length());
                }else if (reqBody.length()/maxLimit>=2) {
                    clog.TmpString1__c=reqBody.substring(0,maxLimit);
                    clog.TmpString2__c=reqBody.substring(maxLimit,2*maxLimit);
                    clog.TmpString3__c=reqBody.substring(2*maxLimit,reqBody.length()>3*maxLimit?3*maxLimit:reqBody.length());
                }
            }
            clog.UserInfo_String__c = userInfo.getUserId();

            insert clog;
        }
        catch (Exception e) {
            createCheckingLog('CignaUtil.createSaveLog', String.valueOf(e.getLineNumber()) , e.getStackTraceString(), e.getMessage(), '');
        }
    }


    /**
     * check policy is inforce
     * 
     * @param    statuscode: policy status code
     * @Author   Zane  2022-11-15
     */ 
    public static Boolean checkIsInforce(string statusCode){
        List<Policy_Status_Mapping__c> psmList = new List<Policy_Status_Mapping__c>();
        Map<String, String> psmMap = new Map<String,String>();
        Boolean retStatus = false;
        if(statusCode==null || statusCode==''){return false;}

        psmList = Policy_Status_Mapping__c.getAll().values();
        for(Policy_Status_Mapping__c p : psmList){
            psmMap.put(p.PolicyCode__c, p.PolicyStatus__c);
        }

        if(psmMap.get(statusCode) =='Inforce'){
            retStatus=true;  
        }
        return retStatus;
    }

    /**
     * get settings data from a custom metadata object:common metadata object. it can be used to store settings data
     * get 
     * @param    category: category field value
     * @param    subCategory: sub-category field value
     * @param    isLongText: whether add long text field in soql. it wil count soql limit if true
     * @return Map<String, Map<String, String>> return more records
     * @Author   Zane  2022-12-03
     */
    public static Map<String, Map<String, String>> getMetadataByCategory(String category, String subCategory, Boolean isLongText){

        Map<String, Map<String, String>> cateGoryMetadataMap = new Map<String, Map<String, String>>();
        String metaQryStr = 'SELECT Id,MasterLabel, DeveloperName,App__c,Category__c, Sub_Category__c, Field_Key1__c, Field_Key2__c, Field_Key3__c, Field_Key4__c, Field_Key5__c, Field_Key6__c, Field_Key7__c,'
                            +' Field_Key8__c, Field_Key9__c, Field_Key10__c, Field_Key11__c,Field_Key12__c, Field_Key13__c, Field_Key14__c, Field_Value1__c, Field_Value2__c, Field_Value3__c, Field_Value4__c, Field_Value5__c,'
                            +'Field_Value6__c, Field_Value7__c, Field_Value8__c, Field_Value9__c, Field_Value10__c, Field_Value11__c';
        //Count toward Apex governor limits, if SOQL queries containing long text area fields. Number of SOQL queries: 0 out of 100
        if(isLongText){
            metaQryStr+=', Field_Value12__c, Field_Value13__c, Field_Value14__c FROM Common_Metadata__mdt WHERE Id!=null ';   
        }else{
            metaQryStr+=' FROM Common_Metadata__mdt WHERE Id!=null ';
        }

        //where filter, use category and subcategory
        if(String.isNotBlank(category)){
            metaQryStr += ' AND Category__c =:category';
        }
        if(String.isNotBlank(subCategory)){
            metaQryStr += ' AND Sub_Category__c =:subCategory';
        }

        //return empty map. avoid query all records
        if(String.isNotBlank(category) && String.isNotBlank(subCategory)){
            return cateGoryMetadataMap;
        }
        List<Common_metadata__mdt> commonMetaList = Database.query(metaQryStr);
        for(Common_metadata__mdt tempCommonMeta: commonMetaList){
            //get key and value from a record
            Map<String, String> metaKeyValueMap = new Map<String, String>();
            if(String.isNotBlank(tempCommonMeta.App__c)){
                metaKeyValueMap.put('App__c', tempCommonMeta.App__c);
            }
            if(String.isNotBlank(tempCommonMeta.Category__c)){
                metaKeyValueMap.put('Category__c', tempCommonMeta.Category__c);
            }
            if(String.isNotBlank(tempCommonMeta.Sub_Category__c)){
                metaKeyValueMap.put('Sub_Category__c', tempCommonMeta.Sub_Category__c);
            }

            if(String.isNotBlank(tempCommonMeta.Field_Key1__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key1__c, tempCommonMeta.Field_Value1__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key2__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key2__c, tempCommonMeta.Field_Value2__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key3__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key3__c, tempCommonMeta.Field_Value3__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key4__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key4__c, tempCommonMeta.Field_Value4__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key5__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key5__c, tempCommonMeta.Field_Value5__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key6__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key6__c, tempCommonMeta.Field_Value6__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key7__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key7__c, tempCommonMeta.Field_Value7__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key8__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key8__c, tempCommonMeta.Field_Value8__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key9__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key9__c, tempCommonMeta.Field_Value9__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key10__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key10__c, tempCommonMeta.Field_Value10__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key11__c)){
                metaKeyValueMap.put(tempCommonMeta.Field_Key11__c, tempCommonMeta.Field_Value11__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key12__c) && isLongText){
                metaKeyValueMap.put(tempCommonMeta.Field_Key12__c, tempCommonMeta.Field_Value12__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key13__c) && isLongText){
                metaKeyValueMap.put(tempCommonMeta.Field_Key13__c, tempCommonMeta.Field_Value13__c);
            }
            if(String.isNotBlank(tempCommonMeta.Field_Key14__c) && isLongText){
                metaKeyValueMap.put(tempCommonMeta.Field_Key14__c, tempCommonMeta.Field_Value14__c);
            }
            //put the current record into map by metadat label
            cateGoryMetadataMap.put(tempCommonMeta.MasterLabel, metaKeyValueMap);
        }

        System.debug(LoggingLevel.INFO, '***getMetadataByCategory cateGoryMetadataMap : ' + cateGoryMetadataMap);
        return cateGoryMetadataMap;
    }

    /**
     * get settings data from a custom metadata object:common metadata object. it can be used to store settings data
     * get 
     * @param    metaName: developer name of custom metadata
     * @return  Map<String, String> return map record by developer name
     * @Author   Zane  2022-12-03
     */
    public static Map<String, String> getMetadataByName(String metaName){
        Map<String, String> metadataMap = new Map<String, String>();
        Common_metadata__mdt commonMeta = Common_metadata__mdt.getInstance(metaName);

        if(commonMeta != null){
            //get key and value from a record
            if(String.isNotBlank(commonMeta.App__c)){
                metadataMap.put('App__c', commonMeta.App__c);
            }
            if(String.isNotBlank(commonMeta.Category__c)){
                metadataMap.put('Category__c', commonMeta.Category__c);
            }
            if(String.isNotBlank(commonMeta.Sub_Category__c)){
                metadataMap.put('Sub_Category__c', commonMeta.Sub_Category__c);
            }
            
            if(String.isNotBlank(commonMeta.Field_Key1__c)){
                metadataMap.put(commonMeta.Field_Key1__c, commonMeta.Field_Value1__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key2__c)){
                metadataMap.put(commonMeta.Field_Key2__c, commonMeta.Field_Value2__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key3__c)){
                metadataMap.put(commonMeta.Field_Key3__c, commonMeta.Field_Value3__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key4__c)){
                metadataMap.put(commonMeta.Field_Key4__c, commonMeta.Field_Value4__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key5__c)){
                metadataMap.put(commonMeta.Field_Key5__c, commonMeta.Field_Value5__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key6__c)){
                metadataMap.put(commonMeta.Field_Key6__c, commonMeta.Field_Value6__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key7__c)){
                metadataMap.put(commonMeta.Field_Key7__c, commonMeta.Field_Value7__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key8__c)){
                metadataMap.put(commonMeta.Field_Key8__c, commonMeta.Field_Value8__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key9__c)){
                metadataMap.put(commonMeta.Field_Key9__c, commonMeta.Field_Value9__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key10__c)){
                metadataMap.put(commonMeta.Field_Key10__c, commonMeta.Field_Value10__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key11__c)){
                metadataMap.put(commonMeta.Field_Key11__c, commonMeta.Field_Value11__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key12__c)){
                metadataMap.put(commonMeta.Field_Key12__c, commonMeta.Field_Value12__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key13__c)){
                metadataMap.put(commonMeta.Field_Key13__c, commonMeta.Field_Value13__c);
            }
            if(String.isNotBlank(commonMeta.Field_Key14__c)){
                metadataMap.put(commonMeta.Field_Key14__c, commonMeta.Field_Value14__c);
            }
            
        }

        System.debug(LoggingLevel.INFO, '***getMetadataByName metadataMap : ' + metadataMap);
        return metadataMap;

    }

    /********************************************************************
    * check if is valid hkid
    *@param   String hkid - hkid with check digit
    *@return  Booleam
    *@author  Rancho_PI146_20240118 - allow hkid start with 2 engligh character
    ********************************************************************/
    public static Boolean validateHKID(String hkid){
        String HKIDRegex = '^[a-zA-Z]{1,2}[0-9]{6}[0-9A-Z]{1}$';
        if(checkRegularExp(hkid, HKIDRegex)){
            String enChar = hkid.substring(0, hkid.length() - 7).toUpperCase();
            Integer total = 0;
            // hkid may start with 1 or 2 engligh character
            Map<String, Integer> weightMap = new Map<String, Integer>();
            for(HKID_Char_Weight__c weight : [Select id,Chars__c,Weight__c FROM HKID_Char_Weight__c]){
                weightMap.put(weight.Chars__c, Integer.valueOf(weight.Weight__c));
            }
            if(enChar.length() == 1){
                total = 36*9+weightMap.get(enChar)*8;
            }else{
                List<String> tempList = enChar.split('');
                total = weightMap.get(tempList[0])*9+weightMap.get(tempList[1])*8;
            }
            // calculate total weight
            Integer numberWeight = 7;
            for(Integer i = hkid.length()-7; i<hkid.length()-1; i++){
                String numberId = hkid.substring(i,i+1);
                System.debug('current char: '+numberId);
                total = total + numberWeight * Integer.valueOf(numberId);
                numberWeight--;
            }
            // validate check digit
            Integer code = 11 - remainder(total,11);
            String checkDigit = hkid.substring(hkid.length() - 1);
            if(code == 10){
                return checkDigit == 'A';
            }else if(code == 11){
                return checkDigit == '0';
            }else{
                return checkDigit == String.valueOf(code);
            }
        }else{
            return false;
        }
    }

    /**
     * check and return hkId
     * 
     * @param    hkid
     * @Author   Owen 2023-11-13
     */ 
    public static String checkHkId(String hkid){
        String finalHkId = '';
        String validateNumber = '';
        String HKIDRegex='^[a-zA-Z]{1,2}[0-9]{6}$';
        if(checkRegularExp(hkid, HKIDRegex)){
            String enChar = hkid.substring(0, hkid.length() - 6).toUpperCase();
            Integer total = 0;
            // hkid may start with 1 or 2 engligh character
            Map<String, Integer> weightMap = new Map<String, Integer>();
            for(HKID_Char_Weight__c weight : [Select id,Chars__c,Weight__c FROM HKID_Char_Weight__c]){
                weightMap.put(weight.Chars__c, Integer.valueOf(weight.Weight__c));
            }
            if(enChar.length() == 1){
                total = 36*9+weightMap.get(enChar)*8;
            }else{
                List<String> tempList = enChar.split('');
                total = weightMap.get(tempList[0])*9+weightMap.get(tempList[1])*8;
            }
            Integer numberWeight = 7;
            for(Integer i = hkid.length()-6; i<hkid.length(); i++){
                String numberId = hkid.substring(i,i+1);
                total = total + numberWeight * Integer.valueOf(numberId);
                numberWeight--;
            }
            Integer code = 11 - remainder(total,11);
            if(code == 10){
                validateNumber ='A';
            }else if(code == 11){
                validateNumber ='0';
            }else{
                validateNumber =String.valueOf(code);
            }
            return finalHkId = hkid+validateNumber;
        }else{
            return hkid;
        }
    }

    private static boolean checkRegularExp(String stringToCheck, String regExp){
        if(stringToCheck==null){
            return false;
        }
        Boolean result=true;
        Pattern MyPattern=Pattern.compile(regExp);
        Matcher MyMatcher=MyPattern.matcher(stringToCheck);
    
        if(!MyMatcher.matches()){ 
            result=false;
        }
        
        return result; 
    }

    private static Integer remainder(Integer dividend, Integer divider){
        Decimal resultDecimal = Decimal.valueOf(dividend) / divider;
        Integer resultDown = Integer.valueOf(resultDecimal.round(System.RoundingMode.DOWN));
        return dividend - resultDown * divider;
    }

    /**
    * @description get record type by object name and recordtype name
    * @author jackshao@deloitte.com.cn | 07-07-2023 
    * @param string objAPIName 
    * @param string recTypeName 
    * @return Id 
    **/
    public static Id getRecordTypeIdByName(string objAPIName, string recTypeName){
        Id recTypeId;
        if(String.isNotBlank(objAPIName) && String.isNotBlank(recTypeName)){
            system.debug(objAPIName+' recType:'+recTypeName);
            system.debug(Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByName().get(recTypeName));
            recTypeId= Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        }  
        return recTypeId;  
    }
    /**
    * @description get record type id by object name and recordtype developer name
    * @author jackshao@deloitte.com.cn | 09-26-2023 
    * @param string objAPIName 
    * @param string recTypeName 
    * @return Id 
    **/
    public static Id getRecordTypeIdByDevName(string objAPIName, string recTypeName){
        Id recTypeId;
        if(String.isNotBlank(objAPIName) && String.isNotBlank(recTypeName)){
            system.debug(objAPIName+' recType:'+recTypeName);
            system.debug(Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeName));
            recTypeId= Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
        }  
        return recTypeId;  
    }

    public static String CHINA='86';
    public static String HONGKONG='852';
    public static String MACAU='853';
    public class MasterList{
        public String key;
        public String value;
        MasterList(String code,String name){
            this.key=code;
            this.value=name;
        }
    }
    /**
    * @description get country code list by api
    * @author jackshao@deloitte.com.cn | 09-26-2023 
    * @param String lang 
    * @return List<MasterList> 
    **/
    public static List<MasterList> getCountryCodeList(String lang){
        MasterListCalloutHelper mLHelper=new MasterListCalloutHelper(14,'en');
        if (lang!='en_US') {
            mLHelper=new MasterListCalloutHelper(14,'zh');
        }
        List<MasterList> mlList=new List<MasterList>();
        List<HttpCalloutVO.MasterList> masterList=(List<HttpCalloutVO.MasterList>)mLHelper.RequestMasterList();
        List<HttpCalloutVO.MasterList> otherList=new List<HttpCalloutVO.MasterList>();
        HttpCalloutVO.MasterList chinaMaster=new HttpCalloutVO.MasterList();
        HttpCalloutVO.MasterList hongkongMaster=new HttpCalloutVO.MasterList();
        HttpCalloutVO.MasterList macauMaster=new HttpCalloutVO.MasterList();
        if(!masterList.isEmpty()){
            for(HttpCalloutVO.MasterList m: masterList){
                if(m.code!=null){
                    if(m.code==CHINA){
                        chinaMaster=m;
                    }else if(m.code==HONGKONG){
                        hongkongMaster=m;
                    }else if(m.code==MACAU){
                        macauMaster=m;
                    }else{
                        otherList.add(m);
                    }
                }
            }
            otherList.sort();
            System.debug('otherList: '+otherList);
            if (macauMaster!=null) {
                otherList.add(0,macauMaster);
            }
            if (hongkongMaster!=null) {
                otherList.add(0,hongkongMaster);
            }
            if (chinaMaster!=null) {
                otherList.add(0,chinaMaster);
            }
            System.debug('otherList: '+otherList);
            for(HttpCalloutVO.MasterList other:otherList){
                // String.isBlank(other.countryISOCode)
                if(String.isBlank(other.code)){
                    continue;
                }
                // masterMaps.put(other.countryISOCode,other.name);
                mlList.add(new MasterList(other.code,other.name+' (+'+other.code+')'));
            }
            
            System.debug('master list: '+mlList);
        }
        return mlList;
    }

    /********************************************************************
    * get field set History Tracking fields depend on object api name
    *@param   String objName - object api name
    *@return  List<Schema.FieldSetMember>
    *@author  Rancho_JOBR348_20231221 - HC audit logging
    ********************************************************************/
    public static List<Schema.FieldSetMember> getTrackField(String objName){
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType obj = schemaMap.get(objName);
        List<Schema.FieldSetMember> trackedFields = obj.getDescribe().FieldSets.getMap().get('HistoryTracking').getFields();
        return trackedFields;
    }

    /********************************************************************
    * get all the fields api name and label depend on object api name
    *@param   String objName - object api name
    *@return  List<Schema.FieldSetMember>
    *@author  Rancho_JOBR348_20231221 - HC audit logging
    ********************************************************************/
    public static Map<String, String> getFieldMap(String objName){
        Map<String, String> resultMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType myObj = schemaMap.get(objName);
        Map<String, Schema.SobjectField> fieldMap = myObj.getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()){
            resultMap.put(fieldMap.get(fieldName).getDescribe().getName(), fieldMap.get(fieldName).getDescribe().getLabel());
        }
        return resultMap;
    }

    /********************************************************************
    * get health cloud case's record type
    *@return  List<Id>
    *@author  Rancho_JOBR348_20231221 - HC audit logging
    ********************************************************************/
    public static List<Id> getHCCaseRecdType(){
        List<Id> tempList = new List<Id>();
        tempList.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Care_Manager_Service').getRecordTypeId());
        tempList.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Medical_Claim').getRecordTypeId());
        tempList.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Medical_Classification').getRecordTypeId());
        tempList.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pre_authorization').getRecordTypeId());
        tempList.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ServiceRequest').getRecordTypeId());
        return tempList;
    }

    /**
     * @description update broker hierarchy - Rancho_HKITSFDC97_20241003
     * @param List<User> agentList
     * @param User agentLeader
     * @author ranzhao@deloitte.com.cn
     **/
    public static void updateAgentHierarchy(List<User> agentList, User agentLeader){
        Set<String> agentCombineSet = new Set<String>();
        String agentCombine = '';
        List<HttpCalloutVO.AgentHierarchy> agentHierarchyList = new List<HttpCalloutVO.AgentHierarchy>();

        // higher-level agent should have the hierarchy of her/his own and lower-level agent
        // 1. agentLeader should have her/his own hierarchy
        // 2. agentLeader should have her/his own subAgent hierarchy
        // 3. agentLeader should have agent hierarchy
        // 4. agent should have have her/his own hierarchy
        // 5. agent should have her/his own subAgent hierarchy
        for(User agent : agentList){
            HttpCalloutVO.AgentHierarchy agentHierarchy = new HttpCalloutVO.AgentHierarchy();
            agentHierarchy.companyCode = agentLeader.Company_Code__c;
            agentHierarchy.agentCode = agentLeader.Agent_Code__c;
            agentHierarchy.subCompanyCode = agent.Company_Code__c;
            agentHierarchy.subAgentCode = agent.Agent_Code__c;
            // agentHierarchy.isAltruist = isAltruist;
            agentCombine = agentHierarchy.agentCode + agentHierarchy.subAgentCode;
            if(!agentCombineSet.contains(agentCombine)){
                agentCombineSet.add(agentCombine);
                agentHierarchyList.add(agentHierarchy);
            }
            String sacEach = agent.Sub_Agent_Code__c;
            if(String.isNotBlank(sacEach)){
                List<String> subAgentCodeList = sacEach.split(';');
                if(subAgentCodeList.size() > 0){
                    HttpCalloutVO.AgentHierarchy agentHierarchySelf = new HttpCalloutVO.AgentHierarchy();
                    agentHierarchySelf.companyCode = agent.Company_Code__c;
                    agentHierarchySelf.agentCode = agent.Agent_Code__c;
                    agentHierarchySelf.subCompanyCode = agent.Company_Code__c;
                    agentHierarchySelf.subAgentCode = agent.Agent_Code__c;
                    // agentHierarchySelf.isAltruist = isAltruist;
                    agentCombine = agentHierarchySelf.agentCode + agentHierarchySelf.subAgentCode;
                    if(!agentCombineSet.contains(agentCombine)){
                        agentCombineSet.add(agentCombine);
                        agentHierarchyList.add(agentHierarchySelf);
                    }
                    for(String subAgentCodeTmp : subAgentCodeList){
                        HttpCalloutVO.AgentHierarchy agentHierarchyEach = new HttpCalloutVO.AgentHierarchy();
                        agentHierarchyEach.companyCode = agent.Company_Code__c;
                        agentHierarchyEach.agentCode = agent.Agent_Code__c;
                        agentHierarchyEach.subCompanyCode = agent.Company_Code__c;
                        agentHierarchyEach.subAgentCode = subAgentCodeTmp;
                        // agentHierarchyEach.isAltruist = isAltruist;
                        agentCombine = agentHierarchyEach.agentCode + agentHierarchyEach.subAgentCode;
                        if(!agentCombineSet.contains(agentCombine)){
                            agentCombineSet.add(agentCombine);
                            agentHierarchyList.add(agentHierarchyEach);
                        }
                    }
                }
            }
        }
        System.debug('updateAgentHierarchy: '+agentHierarchyList);
        AgentCalloutHelper aHelper = new AgentCalloutHelper(true);
        try{
            agentHierarchyList = aHelper.updateAgentHierarchy(agentHierarchyList);
        }catch(Exception e){
            System.debug('UpdateAgentHierarchyFailed: '+e.getMessage());
        }
    }
    //BEGIN HKITSFDC-56
    public static final String L1 = '1';
    public static final String L2 = '2';
    public static final String L3 = '3';
    
    public static void handleUpdateWorkingDateCalc(Complaint_Setting__c setting, Set<Date> holidayDates, Complaint__c newComp , Map<id, Complaint__c> oldCompMap){
        system.debug('handleUpdateWorkingDateCalc called');
        Complaint__c oldComp = oldCompMap.get(newComp.Id);
        if(oldComp != null){
            if(oldComp.Complaint_Level__c != newComp.Complaint_Level__c || oldComp.Case_escalation_date__c != newComp.Case_escalation_date__c 
               || (newComp.Due_Working_Date__c == null && newComp.Complaint_Level__c != null)){
                system.debug('A handleUpdateWorkingDateCalc changes detected: Level Before: '+oldComp.Complaint_Level__c+' Level After: '+newComp.Complaint_Level__c);
                system.debug('B handleUpdateWorkingDateCalc changes detected: EsDate Before: '+oldComp.Case_escalation_date__c+' EsDate After: '+newComp.Case_escalation_date__c);
                handleWorkingDateCalc(setting, holidayDates, newComp);
            }
        }
    }
    
    public static void handleWorkingDateCalc(Complaint_Setting__c setting, Set<Date> holidayDates, Complaint__c comp){
        Date fromDate = comp.Case_escalation_date__c == null ? comp.Complaint_Date__c : comp.Case_escalation_date__c;
        
        //newly created level 1
        if(comp.Complaint_Level__c == L1){
            comp.Due_Working_Date__c = getWorkingDate(holidayDates, fromDate, setting.Due_Date_Lv1__c.intValue());
        }
        
        //newly created level 2
        if(comp.Complaint_Level__c == L2){
            comp.TAT_1_Working_Date__c = getWorkingDate(holidayDates, fromDate, setting.TAT_1_Lv2__c.intValue());
        	comp.TAT_2_Working_Date__c = getWorkingDate(holidayDates, fromDate, setting.TAT_2_Lv2__c.intValue());
        	comp.Due_Working_Date__c = getWorkingDate(holidayDates, fromDate, setting.Due_Date_Lv2__c.intValue());
        }
        
        //newly created level 3
        if(comp.Complaint_Level__c == L3){
            comp.TAT_1_Working_Date__c = getWorkingDate(holidayDates, fromDate, setting.TAT_1_Lv3__c.intValue());
        	comp.TAT_2_Working_Date__c = getWorkingDate(holidayDates, fromDate, setting.TAT_2_Lv3__c.intValue());
        	comp.Due_Working_Date__c = getWorkingDate(holidayDates, fromDate, setting.Due_Date_Lv3__c.intValue());
        }
    }
    
    public static Complaint_Setting__c getComplaintSetting(){
        return [SELECT Id, Due_Date_Lv1__c,Due_Date_Lv2__c,Due_Date_Lv3__c,TAT_1_Lv2__c,TAT_1_Lv3__c,TAT_2_Lv2__c,TAT_2_Lv3__c
				FROM Complaint_Setting__c LIMIT 1];
    } 
    
    public static Date retrieveEarliestDate(List<Complaint__c> compList){
        Date earliestDate = null;
		for(Complaint__c comp : compList){
            Date dateToComp = comp.case_escalation_date__c != null ? comp.case_escalation_date__c : comp.Complaint_Date__c;
            system.debug('dateToComp: '+dateToComp);
            if(dateToComp != null){
                if(earliestDate == null || dateToComp < earliestDate){
                    earliestDate = dateToComp;
                }
            }
        }
        return earliestDate;
    }
    
    public static Set<Date> getHolidayDateSet(Date fromDate){
        String dynQuery = 'SELECT ActivityDate FROM Holiday ';
        if(fromDate != null){
            dynQuery += ' WHERE ActivityDate >= :fromDate';
        }
        
        List<Holiday> holidays = Database.query(dynQuery);
        Set<Date> holidayDates = new Set<Date>();
        for(Holiday h : holidays){
            holidayDates.add(h.ActivityDate);
        }
        return holidayDates;
    }
    
	public static Date getWorkingDate(Set<Date> holidayDates, Date fromDate, Integer workingDays){
        if(workingDays <= 0){
            return fromDate;
        }

        System.debug('Holidays dates in Set: '+holidayDates);
        if(holidayDates == null){
            holidayDates = getHolidayDateSet(null);
        }
        
		Date currentDate = fromDate;
		Integer daysToAdd = workingDays;

        while(daysToAdd > 0){
        	currentDate = currentDate.addDays(1);
            
            DateTime dt = DateTime.newInstance(currentDate, Time.newInstance(0,0,0,0));
            Integer dayOfWeek = dt.format('u').indexOf('7') == 0 ? 0 : Integer.valueOf(dt.format('u'));
            
            System.debug('CurrentDate: ' + currentDate + ',Day of Week: '+ dayOfWeek + ',Is Holiday: '+holidayDates.contains(currentDate) + ',Days Remaining: '+daysToAdd);
            
            //If not weekend and not holiday, decrease the counter
            if(dayOfWeek != 0 && dayOfWeek != 6 && !holidayDates.contains(currentDate)){
                daysToAdd--;
            }
        }   
        
        return currentDate;
    }
    
    public static Date getWorkingDate(Date fromDate, Integer workingDays){
        Set<Date> holidayDates = getHolidayDateSet(fromDate);
        return getWorkingDate(holidayDates, fromDate, workingDays);
    }
    
    //END HKITSFDC-56
    
    //BEGIN HKITSFDC-111
    public static Set<Id> collectOwnerIdWithVerintPermission(Set<Id> caseOwnerIdSet, Set<String> permissionSetName){
        Set<Id> result = new Set<Id>();
        List<PermissionSetAssignment> assignments = [SELECT Id,AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :caseOwnerIdSet AND PermissionSet.Name IN :permissionSetName];
		
        for(PermissionSetAssignment psa : assignments){
            result.add(psa.AssigneeId);
        }
        
        return result;
    }
    //END HKITSFDC-111
   
}