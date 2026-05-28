/**********************************************************************
 * 
 * @url: /services/apexrest/rest
 * 1. register cigna normal user
 * 
*************************************************************************/
@RestResource(urlMapping='/myCgnRegisterUser/*')
global class MyCgnRegisterUser {
    public static Map<String,Map<String,String>> transField=CignaUtil.getTranslationByCategory('registerOktaUser');
    public static Map<String,Country_List_Settings__c> countryMap=Country_List_Settings__c.getAll();
    public static String CHINA='86';
    public static String HONGKONG='852';
    public static String MACAU='853';
    public static String SUCCESS='success';
    global class RegisterData{
        String hKId,ddDOB,mmDOB,yyyyDOB,firstName,lastName,lang,oldAccId; // used for user check
        String isTDUser,signature,mobile,countryCode,regDate,isNew,sHA256Key,cusFuncTD,cusKey,placeOfRecidency,smtCountry,gender; // TD user
        String dOBStr,registrationEmail,phoneNumber;
        String factorType,emailFactorId,smsFactorId,oktaUserId,passCode; // used for OTP verify
        String pw,confirmPW,userName,indivPoliyNum,groupPoliyNum,userId; // used for user register
        String eSign,isBSPK,isHKID;
        Boolean marketingOptOut,showOptout,isPH,invalidEmail;
        String oldPassword, newPassword; // HKITSFDC-183 (use for update password)
        List<MasterList> cCodeLs;
    }

    public class Response{
        public String status{get;set;}{status='error';}
        public RegisterData data; // RegisterData
        public String message;
        public String eSign;
    }

    class MasterList{
        String key;
        String value;
        MasterList(String code,String name){
            this.key=code;
            this.value=name;
        }
    }


    @HttpPost
    global static void doPost(RegisterData req) {
        System.debug('req:'+req);
        
        if (String.isBlank(req.lang)||!(req.lang.equals('zh_TW')||req.lang.equals('en_US'))) {
            req.lang=userInfo.getLanguage();
        }
        RestResponse res=RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String reqUrl=RestContext.request.requestURI;

        Response result=new Response();
        try{
            if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/checkUser')) {
                result=checkUser(req);
            }else if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/activateFactor')) {
                result=activateFactor(req);
            }else if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/reSendOTP')) {
                result=reSendOTP(req);
            }else if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/registerUser')) {
                result=registerUser(req);
            }else if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/registerUserWS')) {
                result=registerUserWS(req);
            }else if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/updateUserPW')) {
                result=updateUserProfile(req);//for first time register , no old password
            }else if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/sendOTP')) {
                result=sendOTP(req,false);
            }else if (reqUrl.equalsIgnoreCase('/myCgnRegisterUser/updatePassword')) {   // HKITSFDC-183
                result=updatePassword(req);
            }
            res.statusCode=200;
        } catch (Exception e){
            result.message=e.getMessage();
            res.statusCode=500;
        }
        res.responseBody=Blob.valueOf(JSON.serialize(result));
    }

    /**
     * Normal user HKID and DOB check
     * @Author   Gong,Minghua
     * @DateTime 2023-04-19
     * @param    req          [description]
     * @return                [description]
     */
    public static Response checkUser(RegisterData req){
        Response result=new Response();
        Boolean isTDUser=String.isNotBlank(req.isTDUser)?true:false;
        String lang=req.lang;
        if (String.isBlank(req.hKId)) {
            result.message=transField.get('Error_Message_Input_Passport').get(lang);
            return result;
        }
        if (String.isBlank(req.ddDOB)) {
            result.message=transField.get('Error_Message_Input_Birth_Date').get(lang);
            return result;
        }
        if (String.isBlank(req.mmDOB)) {
            result.message=transField.get('Error_Message_Input_Birth_Month').get(lang);
            return result;
        }
        if (String.isBlank(req.yyyyDOB)) {
            result.message=transField.get('Error_Message_Input_Birth_Year').get(lang);
            return result;
        }
        
        String finalHKId='';
        if (isTDUser) {
            if (CignaValidateUtil.isValidID(req.hKId)) {
                finalHKId=req.hKId;
            }else{
                result.message=transField.get('Error_Message_Invalid_Passport').get(lang);
                return result;
            }
        }else{
            finalHKId=req.hKId;
        }

        // Check HKID or memberId is PH or dependent/Spouse
        req.isPH=true;
        System.debug('checkuser:'+req.isHKID);
        if (finalHKId.contains('-')) {
            if (!finalHKId.endsWith('-00')) {
                req.isPH=false;
            }
        }

        //HKITSFDC-453 Begin , fix of exsting bugs
        String formattedMonth = req.mmDOB.length() == 1 ? '0' + req.mmDOB : req.mmDOB;
        String formattedDay = req.ddDOB.length() == 1 ? '0' + req.ddDOB : req.ddDOB;
        String theDOBString = formattedMonth + '/' + formattedDay + '/' + req.yyyyDOB;

        //String theDOBString=req.mmDOB+'/'+req.ddDOB+'/'+req.yyyyDOB;
        //HKTISFDC-438 Ended
        if (!CignaValidateUtil.isValidDOB(theDOBString)) {
            result.message=transField.get('Error_Message_Invalid_Birth_Date').get(lang);
            return result;
        }

        req.dOBStr=req.yyyyDOB+'-'+req.mmDOB+'-'+req.ddDOB;
        if (!CignaValidateUtil.isAbove18(req.dOBStr)) {
            result.message=transField.get('Error_Message_Below_18').get(lang);
            return result;
        }

        UserCalloutHelper helper=new UserCalloutHelper();
        List<HttpCalloutVO.User> wsResult=new List<HttpCalloutVO.User>();
        try{
            HttpCalloutVO.User wsUser=new HttpCalloutVO.User();
            wsUser.hkid=finalHKId;
            wsUser.dob=req.dOBStr;
            wsUser.isHKID=req.isHKID;
            wsResult=helper.RegisterValidateUser(wsUser);

            req.indivPoliyNum='';
            req.groupPoliyNum='';
            if(!wsResult.isEmpty()&&wsResult[0].isSuccess){
                finalHKId=wsResult[0].hkid;
                req.hKId=finalHKId;
                // Get customer policy number and update the value to contact policy number field
                for(HttpCalloutVO.Policy  tempPoli :wsResult[0].policyList){
                    if('I'==tempPoli.policyType){
                        req.indivPoliyNum+=tempPoli.policyNumber+',';
                    }else if('G'==tempPoli.policyType){
                        req.groupPoliyNum+=tempPoli.policyNumber+',';
                    }
                }

                req.indivPoliyNum=req.indivPoliyNum.removeEnd(',');
                req.groupPoliyNum=req.groupPoliyNum.removeEnd(',');
                req.showOptout=false;
                req.marketingOptOut=false;
                if(String.isNotBlank(req.groupPoliyNum)){
                    List<String> grpPlcyList=req.groupPoliyNum.split(',');
                    Date currentDate=Date.today();
                    Integer grpSize=[SELECT Count() FROM Policy__c WHERE Policy_Number__c IN :grpPlcyList AND Marketing_Opt_Out__c='Y' AND Coverage_Period_From__c<=:currentDate AND Coverage_Period_To__c>=:currentDate];
                    if(grpSize>0){
                        req.showOptout=false;
                        // group policies listing in persinal choice template map default opt out marketting service
                        req.marketingOptOut=true;
                    }
                }
            }
            PersonCalloutHelper personHelper=new PersonCalloutHelper();
            List<HttpCalloutVO.Person> personList=personHelper.getPersonBasic(finalHKId);
            if(String.isBlank(req.countryCode)){
                req.countryCode=Label.Default_Country_Code;
            }
            req.registrationEmail='';
            req.phoneNumber='';
            if(!personList.isEmpty()){
                req.firstName='null';
                req.lastName='null';
                if(String.isNotBlank(personList[0].firstName)){
                    req.firstName=personList[0].firstName;
                }
                if(String.isNotBlank(personList[0].lastName)){
                    req.lastName=personList[0].lastName;
                }
                if (String.isNotBlank(personList[0].personalEMailAddress)) {
                    req.registrationEmail=personList[0].personalEMailAddress;
                }
                
                if (String.isNotBlank(personList[0].mobilePhoneNo)) {
                    req.phoneNumber=handlePhone(personList[0].mobilePhoneNo);
                }
                if (String.isNotBlank(personList[0].mobileCountryCode)) {
                    req.countryCode=personList[0].mobileCountryCode;
                }else if (req.phoneNumber.length()==11) {
                    req.countryCode='86';
                }
            }
            System.debug('registrationEmail:'+req.registrationEmail);
            if (req.isPH&&String.isBlank(req.registrationEmail)) {
                result.message=transField.get('Error_Message_No_Personal_Email').get(lang);//HKITSFDC-316 Ivan
                return result;
            }
        }catch(CignaWSResultTooLargeException e1){
            result.message=transField.get('WS_result_set_size_is_over_1000').get(lang);
            return result;
        }catch(CignaWSTimeoutException e2){
            result.message=transField.get('WS_Connection_Timeout').get(lang);
            return result;
        }catch(CignaWSException e3){
            String resultCode=helper.getResultInfo().resultInfoCode;
            result.message=processErrorMsg(resultCode, e3.getMessage(),lang);
            return result;
        }catch(Exception e4){
            result.message=e4.getMessage();
            return result;
        }

        List<User> uList=[SELECT Id,AccountId,Account.IsCustomerPortal,isActive FROM User Where Account.SSN__c =:finalHKId];
        req.oldAccId='';
        Boolean isExistUser=false;
        Boolean isCustomerPortal=false;
        if (!uList.isEmpty()) {
            if (uList[0].isActive) {
                // existing Salesforce user
                isCustomerPortal=uList[0].Account.IsCustomerPortal;
            }else{
                // existing inactive user,will disable the account
                req.oldAccId=uList[0].AccountId;
                isExistUser=true;
            }
        }

        try {
            List<Account> fetchList=fetchAccount(req,finalHKId,isExistUser,false,lang);
            System.debug('fetchList:'+fetchList);
            if(finalHKId==''){
                //invalid user
                result.message=transField.get('Error_Message_Invalid_User').get(lang);
            }else if(!fetchList.isEmpty()){
                if(isCustomerPortal){
                    //existing Salesforce user
                    result.message=transField.get('Error_Message_User_Existed').get(lang);
                }else if (req.isPH) {
                    //is PH, first create Okta user
                    result=sendOTP(req,true);
                }else{
                    // Get Country Code List for mobile country code
                    MasterListCalloutHelper mLHelper=new MasterListCalloutHelper(14,'en');
                    if (req.lang!='en_US') {
                        mLHelper=new MasterListCalloutHelper(14,'zh');
                    }
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
                        List<MasterList> mlList=new List<MasterList>();
                        for(HttpCalloutVO.MasterList other:otherList){
                            // String.isBlank(other.countryISOCode)
                            if(String.isBlank(other.code)){
                                continue;
                            }
                            // masterMaps.put(other.countryISOCode,other.name);
                            mlList.add(new MasterList(other.code,other.name+' (+'+other.code+')'));
                        }
                        req.cCodeLs=mlList;
                        System.debug('master list: '+mlList);
                    }
                    result.status=SUCCESS; 
                }
            }else{
                //account not found
                result.message=transField.get('Error_Message_Account_Not_Found').get(lang);
            }
            
            if (result.status==SUCCESS) {
                // encrypt data
                Map<String,Object> eSignMap=new Map<String,Object>();
                eSignMap.put('hKId', req.hKId);
                if (String.isNotBlank(req.oktaUserId)) {
                    eSignMap.put('oktaUserId', req.oktaUserId);
                }
                if (String.isNotBlank(req.smsFactorId)) {
                    eSignMap.put('smsFactorId', req.smsFactorId);
                }
                if (String.isNotBlank(req.emailFactorId)) {
                    eSignMap.put('emailFactorId', req.emailFactorId);
                }

                result.eSign=CignaCryptoUtil.encryptSign(JSON.serialize(eSignMap));
                req.eSign=result.eSign;
                result.data=req;
                if (!fetchList.isEmpty()) {
                    try {
                        for (Account item : fetchList) {
                            upsert item;
                        }
                    }
                    catch (Exception e) {
                        System.debug('fetchList Exception:'+e.getMessage());
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('Exception:'+e.getMessage());
            result.message=e.getMessage();
        }
        return result;
    }

    /**
     * ReSend SMS/Email OTP
     * @Author   Gong,Minghua
     * @DateTime 2023-04-27
     * @param    req          [oktaUserId,factorId]
     * @return   Response     [only check status]
     */
    public static Response reSendOTP(RegisterData req){
        Response result=new Response();
        String decryStr=CignaCryptoUtil.decryptSign(req.eSign);
        if (String.isBlank(decryStr)) {
            result.message=transField.get('Error_Message_Data_Tampered').get(req.lang);
        }else{
            Map<String,Object> eSignMap=(Map<String,Object>)JSON.deserializeUntyped(decryStr);
            if (!req.hKId.equals(eSignMap.get('hKId'))) {
                result.message=transField.get('Error_Message_Data_Tampered').get(req.lang);
                return result;
            }
            OktaMFACalloutHelper oktaHelper=new OktaMFACalloutHelper();
            Map<String,String> paramsMap=new Map<String,String>();
            HttpCalloutJsonVO.OktaMFAResult oktaResult=new HttpCalloutJsonVO.OktaMFAResult();

            paramsMap.put('userId',(String)eSignMap.get('oktaUserId'));
            paramsMap.put('factorType',req.factorType);
            if (req.factorType=='email') {
                if (String.isNotBlank(req.emailFactorId)) {
                    paramsMap.put('factorId',(String)eSignMap.get('emailFactorId'));
                    oktaResult=oktaHelper.verifyOTP(paramsMap);
                }else{
                    paramsMap.put('email',req.registrationEmail);
                    oktaResult=oktaHelper.enrollFactor(paramsMap);
                    req.emailFactorId=oktaResult.factorRes?.id;
                    if (eSignMap.containsKey('emailFactorId')) {
                        eSignMap.remove('emailFactorId');
                    }
                    eSignMap.put('emailFactorId', req.emailFactorId);
                }
            }else if(req.factorType=='sms') {
                if (String.isNotBlank(req.smsFactorId)) {
                    paramsMap.put('factorId',(String)eSignMap.get('smsFactorId'));
                    oktaResult=oktaHelper.resendFactor(paramsMap);
                }else{
                    paramsMap.put('phoneNumber',req.countryCode+req.phoneNumber);
                    oktaResult=oktaHelper.enrollFactor(paramsMap);
                    req.smsFactorId=oktaResult.factorRes?.id;
                    if (eSignMap.containsKey('smsFactorId')) {
                        eSignMap.remove('smsFactorId');
                    }
                    eSignMap.put('smsFactorId', req.smsFactorId);
                }
            }
            
            System.debug('OktaMFACalloutHelper enrollFactor:'+oktaResult);

            if (oktaResult.isResultSuccess) {
                result.eSign=CignaCryptoUtil.encryptSign(JSON.serialize(eSignMap));
                req.eSign=result.eSign;
                result.data=req;
                result.status=SUCCESS;
            }else{
                result.message=handErrMsg(oktaResult.errorRes);
                //HKITSFDC-329 Ivan start
                if(oktaResult.errorRes.errorCode=='E0000109'){
                    result.message=transField.get('SMS_Recently_Sent').get(req.lang);
                }
                //HKITSFDC-329 Ivan end
            }
        }
        return result;
    }

    /**
     * Activate Enroll Factor
     * @Author   Gong,Minghua
     * @DateTime 2023-04-27
     * @param    req          [passCode,oktaUserId,factorId]
     * @return   Response     [description]
     */
    public static Response activateFactor(RegisterData req){
        String lang=req.lang;
        Response result=new Response();
        String decryStr=CignaCryptoUtil.decryptSign(req.eSign);
        if (String.isBlank(decryStr)) {
            result.message=transField.get('Error_Message_Data_Tampered').get(req.lang);
        }else{
            Map<String,Object> eSignMap=(Map<String,Object>)JSON.deserializeUntyped(decryStr);
            OktaMFACalloutHelper oktaHelper=new OktaMFACalloutHelper();
            HttpCalloutJsonVO.OktaMFAResult oktaResult=new HttpCalloutJsonVO.OktaMFAResult();
            Map<String,String> paramsMap=new Map<String,String>();
            paramsMap.put('passCode',req.passCode);
            paramsMap.put('userId',(String)eSignMap.get('oktaUserId'));
            boolean activeEmail=false;
            if (req.factorType=='email') {
                activeEmail=true;
                if (String.isBlank((String)eSignMap.get('emailFactorId'))) {
                    paramsMap.put('factorId',req.emailFactorId);
                }else{
                    paramsMap.put('factorId',(String)eSignMap.get('emailFactorId'));
                }
                oktaResult=oktaHelper.verifyOTP(paramsMap);
            }else{
                if (String.isBlank((String)eSignMap.get('smsFactorId'))) {
                    paramsMap.put('factorId',req.smsFactorId);
                }else{
                    paramsMap.put('factorId',(String)eSignMap.get('smsFactorId'));
                }
                oktaResult=oktaHelper.activateFactor(paramsMap);
            }

            System.debug('OktaMFACalloutHelper activateFactor:'+oktaResult);
            if(oktaResult.isResultSuccess) {
                if (activeEmail) {
                    req.smsFactorId='';
                }else{
                    if (String.isNotBlank(oktaResult.factorRes?.id)) {
                        req.smsFactorId=oktaResult.factorRes.id;
                    }
                }
                result.data=req;
                result.status=SUCCESS;
            }else if (oktaResult.errorRes?.errorCode=='E0000068') {
                // E0000068 Invalid Passcode/Answer
                result.message=transField.get('Error_Message_Wrong_OTP').get(lang);
            }else{
                result.message=handErrMsg(oktaResult.errorRes);
            }
        }
        return result;
    }

    /**
     * Register User in SFDC
     * @Author   Gong,Minghua
     * @DateTime 2023-05-12
     * @param    req          [description]
     * @return                [description]
     */
    public static Response registerUser(RegisterData req){
        Response result=new Response();
        String lang=req.lang;
        req.invalidEmail=false;
        String decryStr=CignaCryptoUtil.decryptSign(req.eSign);
        if (String.isBlank(decryStr)) {
            result.message=transField.get('Error_Message_Data_Tampered').get(req.lang);
        }else{
            Map<String,Object> eSignMap=(Map<String,Object>)JSON.deserializeUntyped(decryStr);
            String userName=req.userName;
            Boolean isTDUser=String.isNotBlank(req.isTDUser)?true:false;
            if(!CignaValidateUtil.isValidEmail(userName)){
                req.invalidEmail=true;
                result.data=req;
                result.message=transField.get('Error_Message_Email_Not_Valid').get(lang);
                return result;
            }
               
            if(!CignaValidateUtil.isValidPassword(req.pw)){
                result.message=transField.get('Error_Message_Invalid_Password').get(lang);
                return result;
            }  
            
            if (req.pw!=req.confirmPW) {
                result.message=transField.get('Error_Message_Passwords_did_not_match').get(lang);
                return result;
            }

            String accountId='';
            String finalHKId=req.hKId;
            List<Account> accList=[Select Id From Account Where SSN__c=:finalHKId.toUpperCase() Limit 1];
            if(!accList.isEmpty()){
                accountId=accList[0].Id;
            }
            // get customer profile
            String profile=Portal_Settings__c.getInstance().Customer_User_Profile__c;
            String profileTD=Portal_Settings__c.getInstance().Customer_Virtual_User_Profile__c;
            String profileId='';
            String profileTDId='';
            for(Profile pro:[SELECT Id,Name FROM Profile WHERE NAME =:new List<String>{profile,profileTD}]){
                if(pro.Name==profile){profileId=pro.Id;}
                if(pro.Name==profileTD){profileTDId=pro.Id;}
            }
            
            String countryCode=req.countryCode;
            if(String.isBlank(countryCode)){
                countryCode=Label.Default_Country_Code;
            }
            countryCode=countryCode.startsWith('+')?countryCode:'+'+countryCode;

            User u=new User();
            u.Username=userName;
            u.Email=userName;
            u.FirstName=req.firstName;
            u.LastName=req.lastName;
            u.CommunityNickname=EncodingUtil.convertToHex(Crypto.generateAesKey(128));
            u.ProfileId=isTDUser?profileTDId:profileId;
            u.Contact_No_Country_Code__c=countryCode;
            if (String.isNotBlank(req.phoneNumber)) {
                u.MobilePhone=countryCode+req.phoneNumber;
                u.Contact_No__c=req.phoneNumber;
            }
            u.languagelocalekey=Label.Header_Language_Code_Current;
            u.timezonesidkey='Asia/Hong_Kong';
            u.User_Type__c='SIT User';
            if (eSignMap.containsKey('oktaUserId')) {
                u.OktaExternalId__c=(String)eSignMap.get('oktaUserId');
            }
            if (eSignMap.containsKey('emailFactorId')) {
                u.OktaEmailFactorId__c=(String)eSignMap.get('emailFactorId');
            }
            if (eSignMap.containsKey('smsFactorId')) {
                u.OktaSMSFactorId__c=(String)eSignMap.get('smsFactorId');
            }
            
            if(isTDUser){
                u.Nationality__c=req.smtCountry;
                u.Place_Of_Recidency__c=req.placeOfRecidency;
                u.Is_New_Registred_SMT_User__c='Y';       
                u.Features__c=CignaUtil.cusFuncTD;
                u.Customer_Key__c=String.IsNotBlank(req.cusKey)?req.cusKey:'';       
                u.TD_Reg_Date__c=String.IsNotBlank(req.regDate)?Date.ValueOf(req.regDate):null;
            }
            
            u.Notification_Language__c=Label.Header_Language_Code=='en_US'?'zh_TW':'en_US';
            u.Notification_Email_Address__c=req.registrationEmail;

            if (String.isNotBlank(req.lang)){
                u.Notification_Language__c=req.lang;
                u.LanguageLocaleKey=req.lang;
            }

            String userId=null;
            UserCalloutHelper helper;
            try{
                List<User> existUserList=[select id from User where username=:userName and isActive=true];
                if(!existUserList.isEmpty()){
                    req.invalidEmail=true;
                    result.data=req;
                    result.message=transField.get('Error_Message_The_email_has_been_registe').get(lang);
                    return result;
                }

                // 20240314 - minghua - MRP-353 Urgent Production Issue - Cannot register
                try {
                    if (!Test.isRunningTest()) {
                        Site.validatePassword(u,req.pw,req.pw);
                    }
                }
                catch (Exception e) {
                    String errorMsg=e.getMessage();
                    result.message=errorMsg;
                    if (lang.equalsIgnoreCase('zh_TW')) {
                        if (errorMsg.containsIgnoreCase('Your password cannot equal your first name')) {
                            result.message=transField.get('Error_Message_Password_Firstname').get(lang);
                        }else if (errorMsg.containsIgnoreCase('Your password cannot equal your last name')) {
                            result.message=transField.get('Error_Message_Password_Lastname').get(lang);
                        }else if (errorMsg.containsIgnoreCase('Your Password cannot equal or contain your user name')) {
                            result.message=transField.get('Error_Message_Password_Username').get(lang);
                        }
                    }
                    result.data=req;
                    return result;
                }

                helper=new UserCalloutHelper();
                System.debug('registerUser [20260317] username:'+ u.username);
                System.debug('registerUser:'+accountId+' '+req.pw);
                System.debug('registerUser [20260317] u:'+ u);
                if (Test.isRunningTest()) {
                    userId='ahsj12344';
                }else{
                    userId=Site.createExternalUser(u,accountId,req.pw);
                }
                if(userId!=null){
                    req.userId=userId;
                    result.status=SUCCESS;
                    result.data=req;
                    try {
                        // GS user
                        MemberManagementHelper mHelper=new MemberManagementHelper();
                        if(mHelper.isGSUser(finalHKId,null)){
                            mHelper.updateMemberRegistrationEmail(finalHKId,userName);
                        }
                        updateContOpt(req);
                        if(String.IsNotBlank(req.cusKey)){
                            for(Event_Tracking_History__c history:[select Id,Customer_Register_Status__c from Event_Tracking_History__c where Customer_Key__c=:req.cusKey]){
                                history.Customer_Register_Status__c='REGISTER';
                                update history;
                            }
                            // if the customer has high risk record,update the status 
                            List<High_Risk_Register__c> hrrList=[Select id,Status__c from High_Risk_Register__c where Customer_Key__c=:req.cusKey];
                            if(!hrrList.isEmpty()){
                                for(High_Risk_Register__c hrr:hrrList){
                                    hrr.Status__c='REGISTERED';
                                }
                                update hrrList;
                            }
                        }
                    }
                    catch (Exception e) {
                        System.debug('Exception:'+e.getMessage());
                    }
                }else{
                    result.message=transField.get('Error_Message_Create_User_Failed').get(lang);
                    return result;
                }
            }catch(Site.ExternalUserCreateException ex){
                // List<String> errors=ex.getDisplayMessages();
                // for (String error:errors){
                // }
                result.message=ex.getMessage();
                String errorDetail='Line Number: '+ex.getLineNumber()+'\r\n'+'Message: '+ex.getMessage()+'\r\n'+'Display Message: '+ex.getDisplayMessages()+'\r\n'+'Case: '+ex.getCause()+'\r\n'+'StackTraceString: '+ex.getStackTraceString();
                helper.insertSFDCLog(ex.getMessage(), errorDetail);
                System.debug('ExternalUserCreate=>Exception:'+ex.getMessage()+' '+ex.getDisplayMessages());
                return result;
            }catch(Exception e){
                result.message=e.getMessage();
                String errorDetail='Line Number: '+e.getLineNumber()+'\r\n'+'Message: '+e.getMessage()+'\r\n'+'Case: '+e.getCause()+'\r\n'+'StackTraceString: '+e.getStackTraceString();
                helper.insertSFDCLog(e.getMessage(), errorDetail);
                System.debug('CreateExternalUser=>Exception:'+e.getMessage());
                return result;
            }
        }
        return result;
    }
    
    /**
     * Register User to Cigna
     * @Author   Gong,Minghua
     * @DateTime 2023-05-12
     * @param    req          [description]
     * @return                [description]
     */
    public static Response registerUserWS(RegisterData req){
        Response result=new Response();
        Boolean isTDUser=String.isNotBlank(req.isTDUser)?true:false;
        
        String countryCode=req.countryCode;
        if(String.isBlank(countryCode)){
            countryCode=Label.Default_Country_Code;
        }
        countryCode=countryCode.startsWith('+')?countryCode:'+'+countryCode;
        
        HttpCalloutVO.User wsUser=new HttpCalloutVO.User();
        wsUser.hkid=req.hKId;
        // wsUser.dob=req.yyyyDOB+'-'+req.mmDOB+'-'+req.ddDOB;
        wsUser.dob=req.dOBStr;
        wsUser.roleId='PH';
        wsUser.loginId=req.userName;
        wsUser.firstName=req.firstName;
        wsUser.lastName=req.lastName;
        if (String.isNotBlank(req.phoneNumber)) {
            wsUser.phoneNumber=countryCode+req.phoneNumber;
        }
        wsUser.emailAddress=req.userName;
        wsUser.personalEMailAddress=req.registrationEmail;
        wsUser.NoticeLanguage=Label.Header_Language_Code=='en_US'?'zh_TW':'en_US';
        if(String.isNotBlank(req.lang)){
            wsUser.NoticeLanguage=req.lang;
        }
        
        UserCalloutHelper helper;
        Boolean isWSSuccessful=false;
        try{
            System.debug('call webservice to register user:'+wsUser);
            helper=new UserCalloutHelper();
            if(isTDUser){
                wsUser.partner=CignaUtil.cusPartSMT;
                wsUser.function=CignaUtil.cusFuncTD;
                wsUser.customerKey=req.cusKey;
                wsUser.isNew='Y';
                wsUser.partnerOTPNumber=req.phoneNumber;
                wsUser.gender=String.IsNotBlank(req.gender)?(req.gender.equalsIgnoreCase('Male')?'M':'F'):'';
                wsUser.marketingOpt='N';
                Map<String,Country_List_Settings__c> countryMap=Country_List_Settings__c.getAll();
                for(Country_List_Settings__c country:countryMap.values()){
                    if(country.Chi_Desc__c==req.smtCountry||country.Eng_Desc__c==req.smtCountry){
                        wsUser.nationality=country.Country_Id__c;
                    }
                    if(country.Chi_Desc__c==req.placeOfRecidency||country.Eng_Desc__c==req.placeOfRecidency){
                        wsUser.residency=country.Country_Id__c;
                    }
                }
                List<HttpCalloutVO.User> resultList=helper.RegisterPartnerUser(wsUser);
                if(!resultList.isEmpty()){
                    isWSSuccessful=true;
                    HttpCalloutVO.User user=resultList.get(0);
                    req.indivPoliyNum='';
                    for(HttpCalloutVO.Policy tempPoli:user.policyList){
                        if(CignaUtil.cusFuncTD==tempPoli.policyType){req.indivPoliyNum+=tempPoli.policyNumber+',';}
                        req.indivPoliyNum=req.indivPoliyNum.removeEnd(',');
                    }
                }
                updateContOpt(req);
            }else{
                if(String.isNotBlank(req.isBSPK)){ // PI Register
                    wsUser.partner=CignaUtil.cusPartBSPK;
                    wsUser.function=CignaUtil.cusFuncTD;
                }
                isWSSuccessful=helper.registerUser(wsUser);
            }
            if(isWSSuccessful){
                result.status=SUCCESS;
                // if (String.isNotBlank(req.oldAccountId)&&String.isNotBlank(personAccount.Id)) {
                //     transferRelatedListToNewAccount(oldAccountId,personAccount.Id);
                // }
                // if (piRegisterStep2) {
                //     piRegisterStep1=false;
                //     piRegisterStep2=false;
                //     piRegisterStep3=false;
                //     piRegisterStep4=true;
                // }else{
                    
                // }
            }else{
                result.message=helper.getResultInfo().resultInfoDesc;
                return result;
            }
        }catch(CignaWSTimeoutException e2){
            result.message=e2.getMessage();
            return result;
        }catch(CignaWSException e3){
            result.message=e3.getMessage();
            return result;
        }catch(Exception e4){
            result.message=e4.getMessage();
            return result;
        }finally{
            System.debug('isWSSuccessful: '+isWSSuccessful );
            if(!isWSSuccessful){
                // overwrite the ssn and hence user can register again
                inactivateUser(req.userId);
            }else{
                // helper=new UserCalloutHelper();
                // try{
                //     HttpCalloutVO.User u=new HttpCalloutVO.User();
                //     u.emailAddress=req.userName;
                //     Boolean isExisting=helper.validateUser(u);
                // }catch(Exception e){
                //     result.message=e.getMessage();
                //     inactivateUser(req.userId);
                //     return result;
                // }
            }
        }
        return result;
    }

    /**
     * [update okta User password description]
     * @Author   Gong,Minghua
     * @DateTime 2023-05-02
     * @param    req          [password,userId]
     * @return                [description]
     */
    public static Response updateUserProfile(RegisterData req){
        Response result=new Response();
        String decryStr=CignaCryptoUtil.decryptSign(req.eSign);
        if (String.isBlank(decryStr)) {
            result.message=transField.get('Error_Message_Data_Tampered').get(req.lang);
        }else{
            Map<String,Object> eSignMap=(Map<String,Object>)JSON.deserializeUntyped(decryStr);
            OktaMFACalloutHelper oktaHelper=new OktaMFACalloutHelper();
            Map<String,String> paramsMap=new Map<String,String>();
            paramsMap.put('password',req.pw);
            paramsMap.put('userId',(String)eSignMap.get('oktaUserId'));
            // if (req.registrationEmail!=req.userName) {
                paramsMap.put('loginEmail',req.userName);
            // }

            HttpCalloutJsonVO.OktaMFAResult oktaResult=oktaHelper.updateUserProfile(paramsMap);
            System.debug('OktaMFACalloutHelper updateUserProfile:'+oktaResult);
            if(oktaResult.isResultSuccess) {
                oktaResult=oktaHelper.addUserToGroup(paramsMap);
                System.debug('OktaMFACalloutHelper addUserToGroup:'+oktaResult);
                if (oktaResult.isResultSuccess) {
                    result.status=SUCCESS;
                }else{
                    result.message=handErrMsg(oktaResult.errorRes);
                }
            }else{
                result.message=handErrMsg(oktaResult.errorRes);
            }
        }
        return result;
    }

    // HKITSFDC-183 START
    /**
     * [update okta User password description new]
     * @Author   mshah10
     * @DateTime 2026-01-02
     */
    public static Response updatePassword(RegisterData req) {
        Response result = new Response();
        
        try {
            String decryStr = CignaCryptoUtil.decryptSign(req.eSign);
            if (String.isBlank(decryStr)) {
                result.message = transField.get('Error_Message_Data_Tampered').get(req.lang);
                return result;
            }
            
            Map<String, Object> eSignMap = (Map<String, Object>)JSON.deserializeUntyped(decryStr);
            String oktaUserId = (String)eSignMap.get('oktaUserId');
            
            if (String.isBlank(oktaUserId)) {
                result.message = 'Invalid user identification';
                return result;
            }
            
            OktaMFACalloutHelper oktaHelper = new OktaMFACalloutHelper();
            
            // Prepare password update request
            Map<String, String> paramsMap = new Map<String, String>();
            paramsMap.put('userId', oktaUserId);
            paramsMap.put('oldPassword', req.oldPassword);
            paramsMap.put('newPassword', req.newPassword);
            
            // Make the callout to update password
            HttpCalloutJsonVO.OktaMFAResult oktaResult = oktaHelper.updatePassword(paramsMap);
            
            System.debug('OktaMFACalloutHelper updatePassword:' + oktaResult);
            
            if (oktaResult.isResultSuccess) {
                result.status = SUCCESS;
                result.message = 'Password updated successfully';
            } else {
                result.message = handErrMsg(oktaResult.errorRes);
            }
            
        } catch (Exception e) {
            System.debug('Error in updatePassword: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            result.message = 'An error occurred while updating password';
        }
        
        return result;
    }
    // HKITSFDC-183 END


    /**
     * 1.Create Okta user
     * 2.If existing Okta user, get Okta user Id
     * 3.Reset all factor use Id
     * 4.Get email factor Id
     * 5.Verify OTP use email factor Id
     * 6.If not existing email factor Id, call enroll email factor send OTP
     * @Author   Gong,Minghua
     * @DateTime 2023-06-21
     * @param    req          [description]
     * @param    isCall       [equal true, indicator inner function call it]
     * @return                [description]
     */
    public static Response sendOTP(RegisterData req, Boolean isCall){
        Response result=new Response();
        String decryStr='';
        if (!isCall) {
            decryStr=CignaCryptoUtil.decryptSign(req.eSign);
            if (String.isBlank(decryStr)) {
                result.message=transField.get('Error_Message_Data_Tampered').get(req.lang);
                return result;
            }
        }
        OktaMFACalloutHelper oktaHelper=new OktaMFACalloutHelper();
        Map<String,String> paramsMap=new Map<String,String>();
        paramsMap.put('lastName',req.firstName);
        paramsMap.put('firstName',req.lastName);
        // 20240422 - minghua - PI-150 Unable to register new okta user if personal email is the same
        paramsMap.put('email',req.registrationEmail);
        paramsMap.put('login',req.registrationEmail+'_tmp_'+DateTime.now().formatGmt('yyyyMMddHHmmss'));

        HttpCalloutJsonVO.OktaMFAResult oktaResult=oktaHelper.createUser(paramsMap);
        System.debug('OktaMFACalloutHelper createUser:'+oktaResult);

        req.oktaUserId='';
        if(oktaResult.isResultSuccess){
            req.oktaUserId=oktaResult.userRes?.id;
        }else if(oktaResult.errorRes?.errorCode=='E0000001'&&oktaResult.errorRes?.errorSummary.equalsIgnoreCase('Api validation failed: login')){
            // existing Okta user, will call ws to get userId
            paramsMap.put('userName',req.registrationEmail);
            oktaResult=oktaHelper.getUserByLogin(paramsMap);
            System.debug('OktaMFACalloutHelper getUserByLogin:'+oktaResult);
            if(oktaResult.isResultSuccess){
                req.oktaUserId=oktaResult.userRes?.id;
            }
        }

        if (String.isNotBlank(req.oktaUserId)) {
            // if user active other factor, but not continue to regiestion, so will reset factor
            paramsMap.put('userId',req.oktaUserId);
            try {
                oktaResult=oktaHelper.resetAllFactor(paramsMap);
                System.debug('OktaMFACalloutHelper resetAllFactor:'+oktaResult);
            }
            catch (Exception e) {}
            
            // Get Okta factor Id
            req.smsFactorId='';
            req.emailFactorId='';
            oktaResult=oktaHelper.getFactorByUserId(paramsMap);
            System.debug('OktaMFACalloutHelper getFactorByUserId:'+oktaResult);
            if(oktaResult.isResultSuccess){
                if (oktaResult.factorArray?.size()>0) {
                    for (HttpCalloutJsonVO.OktaFactorResponse item:oktaResult.factorArray) {
                        // only check email factor, because reset all factor, only email factor
                        if (item.factorType=='email') {
                            req.emailFactorId=item.id;
                            paramsMap.put('factorId',req.emailFactorId);
                            // send OTP use factorId
                            oktaResult=oktaHelper.verifyOTP(paramsMap);
                            System.debug('OktaMFACalloutHelper verifyOTP:'+oktaResult);
                            if(oktaResult.isResultSuccess){
                                result.status=SUCCESS;
                            }else{
                                result.message=handErrMsg(oktaResult.errorRes);
                            }
                        }
                    }
                }else{
                    result.message=transField.get('Error_Message_No_Factor').get(req.lang);
                }

                // if not get email factor, will call enroll factor
                // if (String.isBlank(req.emailFactorId)) {
                //     paramsMap.put('userId',req.oktaUserId);
                //     paramsMap.put('factorType','email');
                //     paramsMap.put('email',req.registrationEmail);

                //     oktaResult=oktaHelper.enrollFactor(paramsMap);
                //     System.debug('OktaMFACalloutHelper enrollFactor:'+oktaResult);
                //     if (oktaResult.isResultSuccess) {
                //         req.emailFactorId=oktaResult.factorRes?.id;
                //         result.status=SUCCESS;
                //     }else{
                //         result.message=handErrMsg(oktaResult.errorRes);
                //     }
                // }
            }else{
                result.message=handErrMsg(oktaResult.errorRes);
            }
        }else{
            result.message=handErrMsg(oktaResult.errorRes);
        }
        if (!isCall&&result.status==SUCCESS){
            Map<String,Object> eSignMap=(Map<String,Object>)JSON.deserializeUntyped(decryStr);
            if (String.isNotBlank(req.oktaUserId)) {
                eSignMap.put('oktaUserId', req.oktaUserId);
            }
            if (String.isNotBlank(req.smsFactorId)) {
                eSignMap.put('smsFactorId', req.smsFactorId);
            }
            if (String.isNotBlank(req.emailFactorId)) {
                eSignMap.put('emailFactorId', req.emailFactorId);
            }
            result.eSign=CignaCryptoUtil.encryptSign(JSON.serialize(eSignMap));
            req.eSign=result.eSign;
            result.data=req;
        }

        return result;
    }

    // public static Response checkSMTUser(RegisterData req){
    //     boolean isTDUser=false;
    //     Response result=new Response();
    //     if(String.isNotBlank(req.cusFuncTD)&&req.cusFuncTD==CignaUtil.cusFuncTD&String.isNotBlank(req.cusKey)&&CignaCryptoUtil.generate(req.countryCode+req.mobile+req.cusFuncTD+req.cusKey+req.regDate+req.isNew)==req.sHA256Key){
    //         isTDUser=true;
    //     }
    //     String lang='en_US';
    //     if (String.isNotBlank(req.lang)&&(req.lang.equalsIgnoreCase('zh_TW')||req.lang.equalsIgnoreCase('en_US'))) {
    //         lang=req.lang;
    //     }
    //     Map<String,Map<String,String>> transFieldSMT=CignaUtil.getTranslationByCategory('SMT Registration');

    //     if (String.isBlank(req.hKId)) {
    //         if (isTDUser) {
    //             result.message=transFieldSMT.get('SMT_Input_HKID').get(lang);
    //         }else{
    //             result.message=Label.Error_Message_Input_Passport;
    //         }
    //         return result;
    //     }
    //     if (String.isBlank(req.ddDOB)) {
    //         result.message=Label.Error_Message_Invalid_Passport;
    //         return result;
    //     }
    //     if (String.isBlank(req.mmDOB)) {
    //         result.message=Label.Error_Message_Input_Birth_Month;
    //         return result;
    //     }
    //     if (String.isBlank(req.yyyyDOB)) {
    //         result.message=Label.Error_Message_Input_Birth_Year;
    //         return result;
    //     }
        
    //     String finalHKId='';
        
    //     if (isValidID(req.hKId)) {
    //         if(isTDUser){
    //             finalHKId=req.hKId.substring(0,7); 
    //         }else{
    //             finalHKId=req.hKId;
    //         }
    //     }else{
    //         if(isTDUser){
    //             result.message=transFieldSMT.get('SMT_Invalid_HKID').get(lang);
    //             return result;
    //         }else{
    //             result.message=Label.Error_Message_Invalid_Passport;
    //             return result;
    //         }
    //     }

    //     String theDOBString=req.ddDOB+'/'+req.mmDOB+'/'+req.yyyyDOB;

    //     if (!isValidDOB(theDOBString)) {
    //         result.message=Label.Error_Message_Invalid_Birth_Date;
    //         return result;
    //     }

    //     if (!isAbove18(req.ddDOB,req.mmDOB,req.yyyyDOB)) {
    //         result.message=Label.Error_Message_Below_18;
    //         return result;
    //     }

    //     if(isTDUser){
    //         if(String.IsBlank(req.firstName)||String.IsBlank(req.lastName)){
    //             result.message=transFieldSMT.get('SMT_Input_Name').get(lang);
    //             return result;
    //         }
    //         if(String.isBlank(req.placeOfRecidency)){
    //             result.message=transFieldSMT.get('SMT_Place_Of_Recidency').get(lang);
    //             return result;
    //         }
            
    //         if(String.isBlank(req.smtCountry)){
    //             result.message=transFieldSMT.get('SMT_Nationality').get(lang);
    //             return result;
    //         }
    //         if(!CignaValidateUtil.isCountry(req.placeOfRecidency,'',req.smtCountry,req.placeOfRecidency,req.cusKey)){
    //             result.message=transFieldSMT.get('SMT_Place_Of_Recidency_Error').get(lang);
    //             return result;
    //         }
    //         if(!CignaValidateUtil.isCountry(req.smtCountry,'',req.smtCountry,req.placeOfRecidency,req.cusKey)){
    //             result.message=transFieldSMT.get('SMT_Nationality_Error').get(lang);
    //             return result;
    //         }
    //     }
    //     RegisterData res=new RegisterData();
    //     //Skip validateUser for TD user,since the validation already done in SMT verify page
    //     if(!isTDUser){
    //         UserCalloutHelper helper=new UserCalloutHelper();
    //         List<HttpCalloutVO.User> wsResult=new List<HttpCalloutVO.User>();
    //         try{
    //             HttpCalloutVO.User wsUser=new HttpCalloutVO.User();
    //             wsUser.hkid=finalHKId;
    //             wsUser.dob=req.yyyyDOB+'-'+req.mmDOB+'-'+req.ddDOB;
    //             wsResult=helper.RegisterValidateUser(wsUser);

    //             String indivPoliyNum='';
    //             String groupPoliyNum='';
    //             if(!wsResult.isEmpty()&&wsResult[0].isSuccess){
    //                 // HttpCalloutVO.TransResult result=helper.getResultInfo();
    //                 // Get customer policy number and update the value to contact policy number field
    //                 for(HttpCalloutVO.Policy  tempPoli :wsResult[0].policyList){
    //                     if('I'==tempPoli.policyType){
    //                         indivPoliyNum+=tempPoli.policyNumber+',';
    //                     }else if('G'==tempPoli.policyType){
    //                         groupPoliyNum+=tempPoli.policyNumber+',';
    //                     }
    //                 }
    
    //                 indivPoliyNum=indivPoliyNum.removeEnd(',');
    //                 groupPoliyNum=groupPoliyNum.removeEnd(',');
    //                 if(String.isNotBlank(groupPoliyNum)){
    //                     List<String> grpPlcyList=groupPoliyNum.split(',');
    //                     Date currentDate=Date.today();
    //                     Integer grpSize=[SELECT Count() FROM Policy__c WHERE Policy_Number__c IN :grpPlcyList AND Marketing_Opt_Out__c='Y' AND Coverage_Period_From__c<=:currentDate AND Coverage_Period_To__c>=:currentDate];
    //                     if(grpSize>0){
    //                         // showOptout=false;
    //                         // marketingOptOut=true;
    //                     }
    //                 }
    //             }
    //             PersonCalloutHelper personHelper=new PersonCalloutHelper();
    //             List<HttpCalloutVO.Person> personList=personHelper.getPersonBasic(finalHKId);
    //             if(!personList.isEmpty()){
    //                 if(String.isNotBlank(personList[0].firstName)){
    //                     req.firstName=personList[0].firstName;
    //                 }
    //                 if(String.isNotBlank(personList[0].lastName)){
    //                     req.lastName=personList[0].lastName;
    //                 }
                    
    //             }
    //         }catch(CignaWSResultTooLargeException e1){
    //             result.message=Label.WS_result_set_size_is_over_1000;
    //             return result;
    //         }catch(CignaWSTimeoutException e2){
    //             result.message=Label.WS_Connection_Timeout;
    //             return result;
    //         }catch(CignaWSException e3){
    //             // Registration flow for Chubb,when call WS fail,will call Chubb validateUser
    //             RegisterData chubbRes=chubbCheck(req,lang);
    //             Map<String,Map<String,String>> transField=CignaUtil.getTranslationByCategory('CustomerRegistrationController');
    //             if (String.isNotBlank(chubbRes.message)){
    //                 // update user not found error message,can be commented when chubb code removed
    //                 if(chubbRes.message.startsWithIgnoreCase('User record is not found')){
    //                     result.message=transField.get('RegisterReminder4').get(lang)+transField.get('RegisterReminder2').get(lang);
    //                 }else{
    //                     result.message=chubbRes.message;
    //                 }
    //                 return result;
    //             }else{
    //                 // if mobile will jump to login page to login
    //                 // if (req.isMobile) {
    //                 //     loginSuccessPR=new PageReference(Site.getPathPrefix()+'/CustomerLoginVFP');
    //                 //     showValidate=false;
    //                 //     if (loginSuccessPR!=null) {
    //                 //         return null;
    //                 //     }
    //                 // }else{
    //                 //     return null;
    //                 // }
    //             }
                
    //             // update user not found error message
    //             if(e3.getMessage().startsWithIgnoreCase('User record is not found') || e3.getMessage().startsWithIgnoreCase('Please input a valid HK id') || e3.getMessage().startsWithIgnoreCase('Please input full HK id')){ 
    //                 result.message=transField.get('RegisterReminder4').get(lang)+transField.get('RegisterReminder2').get(lang);
    //                 return result;
    //             }
    
    //             // ValidateUser WS return a new error message when the user status is 'I'
    //             String resultCode=helper.getResultInfo().resultInfoCode;
    //             if (Test.isRunningTest()){
    //                 resultCode='212';
    //             }

    //             if(String.isNotBlank(resultCode)&&resultCode.equals('212')){
    //                 result.message=transField.get('ErrorMessageInvalidRegistrationStatusI').get(lang);
    //                 return result;
    //             }
                
    //             result.message=e3.getMessage();
    //             return result;
    //         }catch(Exception e4){
    //             result.message=e4.getMessage();
    //             return result;
    //         }
    //     }

    //     // if existing inactive user,will disable the account
    //     List<User> uList=[SELECT Id,AccountId,Account.IsCustomerPortal FROM User Where Account.SSN__c =:finalHKId and isActive=false];
    //     res.oldAccId='';
    //     Boolean isExistUser=false;
    //     Boolean isCustomerPortal=false;
    //     if (!uList.isEmpty()) {
    //         res.oldAccId=uList[0].AccountId;
    //         isCustomerPortal=uList[0].Account.IsCustomerPortal;
    //         isExistUser=true;
    //     }

    //     List<Account> fetchList=fetchAccount(req,finalHKId,isExistUser,false,lang);
    //     Integer returnStatus=1;
    //     if(finalHKId==''){
    //         returnStatus=0;    //invalid user
    //     }else if(!fetchList.isEmpty()){
    //         if(isCustomerPortal){
    //             returnStatus=2;    //existing Salesforce user
    //         }else{
    //             returnStatus=1;    //OK to proceed
    //         }
    //     }else{
    //         returnStatus=3;    //account not found
    //     }
         
    //     if(returnStatus==0){
    //         result.message=Label.Error_Message_Invalid_User;
    //     }else if(returnStatus==2){
    //         if(isTDUser){
    //             // beenRegistered=true;
    //         }else{
    //             result.message=Label.Error_Message_User_Existed;
    //         }
    //     }else if(returnStatus==3){
    //         result.message=Label.Error_Message_Account_Not_Found;
    //     }else if(returnStatus==1){

    //     }
    //     result.eSign=CignaCryptoUtil.encryptSign('true');
    //     return result;
    // }


    /**
     * @Description: Discards the SSN and Customer id of account
     * @param ssn
     * @return String
     * @author Minghua Gong
     * @date 2023-04-18
     */
    private static String inactivateAccount(String ssn){
        String oldAccountId='';
        List<Account> accList=[Select Id,SSN__c,Customer_ID__c from Account Where SSN__c=:ssn];
        if(!accList.isEmpty()){
            oldAccountId=accList[0].Id;
            Integer seqNum=SequenceNumberGenerator.getNext('WSL_ERR');
            update new Account(Id=accList[0].Id,ssn__c='WSL_ERR'+seqNum,Customer_ID__c='WSL_ERR'+seqNum);
        }
        return oldAccountId;
    }

    /**
     * 1.Existing inactive user,will inactivate account and create new account
     * 2.Not existing inactive user, need check existing account
     *     Yes,existing account,need update it
     *     No,create new account
     * @Author   Gong,Minghua
     * @DateTime 2023-04-27
     * @param    req          [description]
     * @param    hKId         [description]
     * @param    isExistUser  [description]
     * @param    isTDUser     [description]
     * @param    lang         [description]
     * @return                [description]
     */
    private static List<Account> fetchAccount(RegisterData req,String hKId,Boolean isExistUser,Boolean isTDUser,String lang){
        List<Account> resList=new List<Account>();
        List<Account> accList=[Select Id,SSN__c,Customer_ID__c,firstName,lastName,isCustomerPortal,gender__c,PersonBirthdate__c From Account Where SSN__c=:hKId.toUpperCase() Limit 1];
        Boolean existAcc=false;
        if (isExistUser) {
            // existing inactive user,need inactivate account
            // then create new account,set existAcc=false
            // Integer seqNum=SequenceNumberGenerator.getNext('WSL_ERR');
            resList.add(new Account(Id=accList[0].Id,ssn__c='WSL_ERR'+accList[0].ssn__c,Customer_ID__c='WSL_ERR'+accList[0].Customer_ID__c));
        }else{
            // has no existing inactive user,need check existing account
            // Yes,existing account,need update it,set existAcc=true
            // No,create new account,set existAcc=false
            if (!accList.isEmpty()) {
                existAcc=true;
            }
        }
        
        Account personAccount=null;
        Portal_Settings__c portalSetting=Portal_Settings__c.getOrgDefaults();
        String customerAdminId;
        if(portalSetting!=null){
            customerAdminId=portalSetting.Customer_Admin_ID__c;
        }

        String ownerId=Portal_Settings__c.getInstance().Account_OwnerId__c;
        if(Test.isRunningTest()){
            ownerId='0050K000008MZte';
        }
        // existing account,update it
        if(existAcc){
            System.debug('Account existed in SFDC.');
            personAccount=accList[0];
            if(String.isNotBlank(req.firstName)){
                personAccount.firstName=req.firstName;
            }
            if(String.isNotBlank(req.lastName)){
                personAccount.lastName=req.lastName;
            }
            if(customerAdminId!=null){
                personAccount.Customer_Admin__c=customerAdminId;
            }
            if(String.isNotBlank(ownerId)){
                personAccount.OwnerId=ownerId;
            }
            if(String.isNotBlank(req.gender)){
                personAccount.gender__c=req.gender;
            }           
            if(String.isNotBlank(req.yyyyDOB)&&String.isNotBlank(req.mmDOB)&&String.isNotBlank(req.ddDOB)){
                personAccount.PersonBirthdate__c=Date.newInstance(Integer.Valueof(req.yyyyDOB),Integer.Valueof(req.mmDOB),Integer.Valueof(req.ddDOB));
            }
            if (isTDUser) {
                personAccount.Notification_Language__pc=lang;
            }
        }else{
            if(String.isNotBlank(ownerId)){
                RecordType customerRT;
                for(RecordType rt:[SELECT Id,Name,developerName FROM RecordType WHERE (developerName='Customer' OR developerName='Customer_Admin') AND SObjectType='Account' AND IsActive=true]){
                    if(rt.developerName=='Customer'){
                        customerRT=rt;
                    }
                }
                String attFirstName=String.isNotBlank(req.firstName)?req.firstName:'';
                String attLastName=String.isNotBlank(req.lastName)?req.lastName:'Visitor';
                personAccount=new Account(firstName=attFirstName,lastName=attLastName,SSN__c=hKId,
                    OwnerId=ownerId,recordTypeId=customerRT.id);
                if(customerAdminId!=null){
                    personAccount.Customer_Admin__c=customerAdminId;
                }
                if(String.isNotBlank(req.gender)){
                    personAccount.gender__c=req.gender;
                }
                if(String.isNotBlank(req.yyyyDOB)&&String.isNotBlank(req.mmDOB)&&String.isNotBlank(req.ddDOB)){
                    personAccount.PersonBirthdate__c=Date.newInstance(Integer.Valueof(req.yyyyDOB),Integer.Valueof(req.mmDOB),Integer.Valueof(req.ddDOB));
                }
                if (isTDUser) {
                    personAccount.Notification_Language__pc=lang;
                }
            }
        }
        if (personAccount!=null) {
            resList.add(personAccount);
        }
        return resList;
    }

    /**
     * update contact values which will be synchronized to MC;
     * @Author   Gong,Minghua
     * @DateTime 2023-04-28
     * @param    isTDUser     [TD user]
     * @param    req          [RegisterData]
     */
    public static void updateContOpt(RegisterData req){
        User regisUser=[SELECT Id,ContactId,MobilePhone,Email FROM User WHERE Id=:req.userId];
        Contact cont=new Contact();
        Boolean isTDUser=String.isNotBlank(req.isTDUser)?true:false;
        if(String.isNotBlank(regisUser.ContactId)){
            cont.Id=regisUser.ContactId;
            cont.Overall_Opt_Out__c=isTDUser?true:req.marketingOptOut; // HKITSFDC-563 Update Overall Opt Out instead of Marketing Opt Out
            cont.Individual_Policy_Number__c=req.indivPoliyNum?.length()>255?req.indivPoliyNum.substring(0,255):req.indivPoliyNum;
            cont.Group_Policy_Number__c=req.groupPoliyNum?.length()>255?req.groupPoliyNum.substring(0,255):req.groupPoliyNum;
            cont.Accepted_New_TC__c=true;
            cont.Email=req.registrationEmail;
            System.debug('updateContOpt>>>cont:'+cont);
            update cont;

            // HKITSFDC-563 insert opt out history
            Opt_out_History__c objOptOutHistory = new Opt_out_History__c();
            objOptOutHistory.Account__c = regisUser.AccountId;
            objOptOutHistory.Update_Date_Time__c = DateTime.now();
            objOptOutHistory.Update_User__c = regisUser.Id;
            objOptOutHistory.Update_Value__c = req.marketingOptOut;
            insert objOptOutHistory;
        }
    }

    /**
     * inactivate User
     * @Author   Gong,Minghua
     * @DateTime 2023-05-12
     * @param    userid       userid
     */
    public static void inactivateUser(String userid){
        // call ws fail,update the user to be inactive
        if(String.isNotBlank(userid)){
            User u=[select id,email,username,isActive from User where id=:userId];
            u.username='WSL_ERR_'+DateTime.now().formatGmt('yyyyMMddHHmmss')+'_'+u.username;
            u.email='WSL_ERR_'+u.email;
            u.isActive=false;
            if (!Test.isRunningTest()) {
                update u;
            }
        }
    }

    /**
     * Get detail error message
     * @Author   Gong,Minghua
     * @DateTime 2023-05-12
     * @param    errorRes     Okta error
     * @return                the detail error message
     */
    public static String handErrMsg(HttpCalloutJsonVO.OktaErrorResponse errorRes){
        if (errorRes==null) {
            return '';
        }
        if (errorRes.errorCauses.isEmpty()) {
            return errorRes.errorSummary;
        }else{
            return errorRes.errorCauses[0].errorSummary;
        }
    }

    /**
     * [handle Phone]
     * @Author   Gong,Minghua
     * @DateTime 2023-06-31
     * @param    phone        [description]
     * @return                [description]
     */
    private static String handlePhone(String phone){
        String mobile='';
        if (String.isNotBlank(phone)) {
            phone=phone.replaceAll(' ', '').replaceAll('\\+', '').replaceAll('-', '').replaceAll('\\(', '').replaceAll('\\)', '');
            if (String.isNotBlank(phone)) {
                if (phone.length()==8) {
                    mobile=phone;
                }else if (phone.length()>8) {
                    if (phone.startsWith('852')) {
                        mobile=phone.substringAfter('852');
                    }else if (phone.startsWith('86')) {
                        mobile=phone.substringAfter('86');
                    }else{
                        mobile=phone;
                    }
                }
            }
        }
        return mobile;
    }

    /**
     * [Get custom error message from SFDC depend on error code]
     * @Author   Gong,Minghua
     * @DateTime 2023-07-31
     * @param    code         [error code returned from ws]
     * @param    message      [error message returned by ws]
     * @return                [error code returned from ws]
     */
    private static String processErrorMsg(String code, String message, String lang){
        if(String.isNotBlank(code)){
            String transKey='Error_Message_'+code;
            String errorMessage='';
            for(String s : transField.keySet()){
                if(s.contains(transKey)){
                    if (String.isBlank(errorMessage)) {
                        errorMessage=transField.get(s).get(lang);
                    }else{
                        errorMessage=errorMessage+'\n'+transField.get(s).get(lang);
                    }
                }
            }
            if(String.isBlank(errorMessage)){
                errorMessage=message+' ('+code+')';
            }
            return errorMessage;
        }else{
            return message;
        }
    }
}