/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-26-2023
 * @last modified by  : Ardbert.Wang
**/
@RestResource(urlMapping='/MySetting/*')
global without sharing class MyCgnMySetting {
    
    public class Response{
        public String status{get;set;}{status='error';}
        public List<Object> data; // ResponseBody
        public String message;
        public String eSign;
    }

    public static Map<String, Map<String, String>> transField{ 
        get{
            if(transField ==null){
                transField = CignaUtil.getTranslationByCategory('MyAccountUpdatePageCtrl');
            }
            return transField ;
        }
        set; 
    }

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        Map<String, Object> reqMap;
        if(String.isNotBlank(requestBody)){
            reqMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        }
        Response result=new Response();
        String reqUrl=RestContext.request.requestURI;
        try{
            if(reqUrl.equalsIgnoreCase('/MySetting/getCurrentUser')){
                List<Object> resultList = new List<object>{getCurrentUser()};
                result.data = resultList;
            }else if(reqUrl.equalsIgnoreCase('/MySetting/updateUserInfo')){
                updateUserInfo(reqMap);
            }else if(reqUrl.equalsIgnoreCase('/MySetting/enrollFactor')){
                result.data = new List<object>{enrollFactor(reqMap,'')};
            }else if(reqUrl.equalsIgnoreCase('/MySetting/activateFactor')){
                activateFactor(reqMap);
            }else if(reqUrl.equalsIgnoreCase('/MySetting/resendOTP')){
                result.data = new List<object>{enrollFactor(reqMap,'bypassValidation')};
            }else if(reqUrl.equalsIgnoreCase('/MySetting/getCountryCodeList')){
                result.data = CignaUtil.getCountryCodeList('en_US');
            }
            result.status = 'success';
            res.statusCode = 200;
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            result.message = e.getMessage();
            res.statusCode = 500;
        }
        res.responseBody=Blob.valueOf(JSON.serialize(result));
    }
    public class LoginSecurity{
        String loginEmail;
        String password;
    }
    public class OtpContact{
        String mobile;
        String verificationEmail;
    }
    public class Preference{
        String notificationMethod;
        String notificationLanguage;
        String marketingConsent;
    }
    public class MysettingForm{
        LoginSecurity loginSecurity;
        OtpContact otpContact;
        Preference preference;
        String type;
        String oriVerificationEmail;
        String newPassword;
        String oldPassword;
    }
    public class UserInput{
        String confirmNewEmail;
        String confirmPw;
        String currentPassword;
        String confirmNewMobile;
        String newMobile;
        String notificationMethod;
        String marketingConsent;
        String notificationLanguage;
        String buttonkey;
        MyCgnPolicyChange.ListWrap confirmCountryCode;
    }
    static final Map<String,String> lanMap = new Map<String,String>{'zh_TW'=>Label.Language_Chinese_Traditional,'en_US'=>Label.Language_English};
    static final Map<String,String> briefLanMap = new Map<String,String>{Label.Language_Chinese_Traditional=>'zh_TW',Label.Language_English=>'en_US'};
    public static MysettingForm getCurrentUser(){
        MysettingForm result = new MysettingForm();
        for(User user : [Select Id,OktaExternalId__c,OktaSMSFactorId__c,Account.Id,account.SSN__c,contact.Overall_Opt_Out__c, Name,UserName, Email, MobilePhone, Contact_No__c, Notification_Email_Address__c, Contact_No_Country_Code__c, Notification_Language__c, Notification_Channel__c, LanguageLocaleKey,FirstName,LastName,Company_Code__c,Agent_Code__c,ContactId,CreatedDate 
            From User Where Id = :UserInfo.getUserId()]){
                LoginSecurity ls = new LoginSecurity();
                ls.loginEmail = user.userName;
                ls.password = '**********';
                OtpContact oc = new OtpContact();
                // oc.mobile = String.isNotBlank(user.OktaSMSFactorId__c)?user.Contact_No_Country_Code__c+' '+user.Contact_No__c:'';
                Preference pre = new Preference();
                pre.notificationMethod = user.Notification_Channel__c;
                pre.notificationLanguage = lanMap.get(user.Notification_Language__c);
                // HKITSFDC-563 Update Overall Opt Out instead of Marketing Opt Out
                // pre.marketingConsent = user.contact.Marketing_Opt_Out__c?'No':'Yes';
                pre.marketingConsent = user.contact.Overall_Opt_Out__c?'No':'Yes';
                // PersonCallOutHelper helper = new PersonCallOutHelper();  
                // List<HttpCallOutVO.Person> pList = helper.getPersonBasic(user.account.SSN__c);
                OktaMFACalloutHelper helper = new OktaMFACalloutHelper();
                Map<String,String> paramsMap=new Map<String,String>();
                paramsMap.put('userId',user.OktaExternalId__c);
                HttpCalloutJsonVO.OktaMFAResult person=helper.getUserById(paramsMap);
                if(String.isNotBlank(person?.userRes?.profile?.email)){
                    oc.verificationEmail = person?.userRes?.profile?.email;
                    result.oriVerificationEmail = person?.userRes?.profile?.email;
                }
                if(String.isNotBlank(person?.userRes?.profile?.login)){
                    ls.loginEmail=person?.userRes?.profile?.login;
                }
                result.loginSecurity = ls;
                // get okta mfa sms phone number.
                HttpCalloutJsonVO.OktaMFAResult factors=helper.getFactorByUserId(paramsMap);
                for(HttpCalloutJsonVO.OktaFactorResponse factor:factors.factorArray){
                    if (factor.factorType?.equals('sms')) {
                        String factorSMS=factor?.profile?.phoneNumber;
                        if (factorSMS.startsWith('+86')) {
                            oc.mobile = '86'+' '+factorSMS.substringAfter('+86');
                        } else if (factorSMS.startsWith('+852')) {
                            oc.mobile = '852'+' '+factorSMS.substringAfter('+852');
                        }
                    }
                }
                result.otpContact = oc;
                result.preference = pre;


            }
        return result;
    }

    /* public static boolean checkUserPassword(String username,String password){
        if(String.isNotBlank(password)){
            String startUrl =  '/customer/CustomerLandingPage';
            // String startUrl =  Site.getPathPrefix() +'/CustomerLandingPage';
            system.debug('startUrl:'+startUrl);
            PageReference pr = Site.login(username, password , startUrl);
            if(pr!=null){
                return true;
            }
        }
            return false;
    } */

         public static Boolean loginRequest(String username,string password){
    // String username = 'm569056@cigna.smuat.com';
    // String password = 'Qwer1234@@';
    //String domain = RestContext.request.params.get('domain');
     
    
        string loginXML = '<?xml version="1.0" encoding="utf-8"?>';  
        loginXML += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">';  
        loginXML += '<soapenv:Header>';  
        loginXML += '<urn:LoginScopeHeader>';  
        loginXML += '<urn:organizationId>'+ UserInfo.getOrganizationId() +'</urn:organizationId>';  
        loginXML += '</urn:LoginScopeHeader>';  
        loginXML += '</soapenv:Header>';  
        loginXML += '<soapenv:Body>'; 
        loginXML += '<urn:login>';
        loginXML += '<urn:username>'+ username +'</urn:username>';
        loginXML += '<urn:password>'+ password +'</urn:password>';
        loginXML += '</urn:login>'; 
        loginXML += '</soapenv:Body>';  
        loginXML += '</soapenv:Envelope>';
         
        HttpRequest request = new HttpRequest();
        system.debug(loginXML);
        request.setEndpoint(Url.getOrgDomainUrl().toExternalForm()+'/services/Soap/c/44.0');
        request.setTimeout(60000); 
        request.setMethod('POST');
        request.setHeader('SOAPAction', 'login');
        request.setHeader('Accept','text/xml');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setBody(loginXML);       
        HttpResponse response = new Http().send(request);
        if(response.getStatusCode() == 200){
            return true;
        }else{
            return false;
        }
        // String responseBody = response.getBody();
        
    }

    public static void updateUserPassword(String newPassword, String oldPassword, string accountId,string oktaId){ // HkITSFDC-183
        String langStr = UserInfo.getLanguage();
        try {
            OktaMFACalloutHelper oktaHelper=new OktaMFACalloutHelper();
            Map<String,String> paramsMap=new Map<String,String>();
            //paramsMap.put('password',newPassword); //HKITSFDC-183
            paramsMap.put('newPassword',newPassword); //HKITSFDC-183
            paramsMap.put('oldPassword',oldPassword); //HKITSFDC-183
            paramsMap.put('userId',oktaId);
            //HttpCalloutJsonVO.OktaMFAResult oktaResult=oktaHelper.updateUserProfile(paramsMap);//HKITSFDC-183
            HttpCalloutJsonVO.OktaMFAResult oktaResult = oktaHelper.updatePassword(paramsMap);//HKITSFDC-183
            if(oktaResult.isResultSuccess) {
                //CR47 add by tovid for record the changeLong
                // System.setPassword(UserInfo.getUserId(), newPassword);
                saveUserInfoChangeRecord('set a new password',accountId);
            }else{
                throw new CignaWSException(MyCgnRegisterUser.handErrMsg(oktaResult.errorRes));
            }
            //add by andy for remove all the session when user update the password
            // List<AuthSession> sessionList = [select Id,LoginType, SessionType, UsersId, UserType from  AuthSession where UsersId =: userinfo.getUserId()];
            // delete sessionList;
            //updated by andy li end
        }catch(Exception e){
            System.debug('e.message:'+e.getMessage() +'---'+ e.getCause() +'---'+ e.getTypeName());
            if(e.getMessage().contains('INVALID_NEW_PASSWORD')){
                System.debug('INVALID_NEW_PASSWORD'+ transField.get('INVALID_NEW_PASSWORD').get(langStr));
                throw new CignaWSException(transField.get('INVALID_NEW_PASSWORD').get(langStr));
            }else if(e.getMessage().contains('invalid repeated password')){
                System.debug('invalid repeated password ' + transField.get('repeated_password').get(langStr));
                throw new CignaWSException(transField.get('repeated_password').get(langStr));
            }else if(e.getMessage().contains('Password cannot be your current password')){ //HKITSFDC-183
                System.debug('Password cannot be your current password. ' + transField.get('repeated_password').get(langStr)); //HKITSFDC-183
                throw new CignaWSException(transField.get('repeated_password').get(langStr)); //HKITSFDC-183
            }else if(e.getMessage().contains('This password was found in a list of commonly used passwords')){ //HKITSFDC-183
                System.debug('This password was found in a list of commonly used passwords. ' + transField.get('INVALID_NEW_PASSWORD').get(langStr)); //HKITSFDC-183
                throw new CignaWSException(transField.get('INVALID_NEW_PASSWORD').get(langStr)); //HKITSFDC-183
            }else if(e.getMessage().contains('Password requirements were not met.')){ //HKITSFDC-183
                System.debug('Password requirements were not met. ' + transField.get('INVALID_NEW_PASSWORD').get(langStr)); //HKITSFDC-183
                throw new CignaWSException(transField.get('INVALID_NEW_PASSWORD').get(langStr)); //HKITSFDC-183
            }else if(e.getMessage().contains('Old Password is not correct')){ //HKITSFDC-183
                System.debug('Please put the correct old password.'); //HKITSFDC-183
                //throw new CignaWSException('Please put the correct old password.'); //HKITSFDC-183 *** Add transField
                throw new CignaWSException(transField.get('INVALID_OLD_PASSWORD').get(langStr));
            }else if(e.getMessage().contains('Your password cannot be reset at this time')){
                System.debug('We can\'t reset your password because it was changed within the last 24 hours.');
                //throw new CignaWSException('We can\'t reset your password because it was changed within the last 24 hours.');
                throw new CignaWSException(transField.get('latest_reset_password').get(langStr));// *** Add transField
            }else if(e.getMessage().contains('Password has been used too recently')){//HKTISFDC-183 Begin
                System.debug('invalid repeated password ' + transField.get('repeated_password').get(langStr));
                throw new CignaWSException(transField.get('repeated_password').get(langStr));
            }//HKTISFDC-183 Ended
            else{
                System.debug('else');
                throw new CignaWSException('e.getMessage()');
            }
        }catch(System.UnexpectedException e){
            throw new CignaWSException('We can\'t reset your password because it was changed within the last 24 hours.'); 
        }catch(UnexpectedException e){
            throw new CignaWSException('We can\'t reset your password because it was changed within the last 24 hours.'); 
        }
    }

    public static void updateUserInfo(Map<String,object> reqMap){
        UserInput form = (UserInput)JSON.deserialize(JSON.serialize(reqMap),UserInput.class);
        system.debug('form:'+form);
        //HKITSFDC-318, add NonOTP_Notification_EmailAddress__c to query
       for(User user : [Select Id,OktaExternalId__c,Account.Id,account.SSN__c,contact.Overall_Opt_Out__c, Name,UserName, Email, MobilePhone, Contact_No__c, Notification_Email_Address__c, Contact_No_Country_Code__c, Notification_Language__c, Notification_Channel__c, LanguageLocaleKey,FirstName,LastName,Company_Code__c,Agent_Code__c,ContactId,CreatedDate ,NonOTP_Notification_EmailAddress__c
            From User Where Id = :UserInfo.getUserId()]){
            //step 1: verify password if needed
            if(form.buttonkey == 'loginEmail' || form.buttonkey == 'password' || form.buttonkey == 'verificationEmail'){
            // if(form.buttonkey == 'loginEmail' || form.buttonkey == 'mobile' || form.buttonkey == 'verificationEmail' || form.buttonkey == 'password'){
                if(!loginRequest(user.UserName,form?.currentPassword) && form.buttonkey != 'password'){ // HKITSFDC-183
                    throw new CignaWSException(Label.Error_Message_Invalid_Current_Password);
                }else if(form.buttonkey == 'password'){
                    updateUserPassword(form?.confirmPw, form?.currentPassword, user.account.id, user.OktaExternalId__c); // HKITSFDC-183
                    //updateUserPassword(form?.confirmPw,user.account.id,user.OktaExternalId__c); // HKITSFDC-183
                    return;
                }else if(form.buttonkey == 'verificationEmail'){
                    OktaMFACtrl.updateUserProfile(user.OktaExternalId__c, '', '', form.confirmNewEmail, '','');
                }
            }else if(form.buttonkey == 'marketingConsent'){
                Contact contact = [select id from Contact where id=:user.contactId];
                contact.Overall_Opt_Out__c = (form?.marketingConsent=='No'); // HKITSFDC-563 Update Overall Opt Out instead of Marketing Opt Out
                update contact;
                // HKITSFDC-563 insert opt out history
                Opt_out_History__c objOptOutHistory = new Opt_out_History__c();
                objOptOutHistory.Account__c = user.Account.Id;
                objOptOutHistory.Update_Date_Time__c = DateTime.now();
                objOptOutHistory.Update_User__c = UserInfo.getUserId();
                objOptOutHistory.Update_Value__c = (form?.marketingConsent=='No'? true : false);
                insert objOptOutHistory;
                
                return;
            }
            User userOld = user.clone();
            //step 2:load common data 
            HttpCalloutVO.User APIuser = new HttpCalloutVO.User();
            APIuser.roleId = 'PH';
            //CR-47 Tovid 20210727 maybe userName not equals Email, use Email as loginId
            APIuser.loginid = user.userName;
            APIuser.CompanyCode = user.Company_Code__c;
            APIuser.AgentCode = user.Agent_Code__c;
            APIuser.FirstName = user.FirstName;
            APIuser.LastName = user.LastName;
            APIuser.EmailAddress = user.userName;
            APIuser.PhoneNumber = user.Contact_No_Country_Code__c+user.Contact_No__c;
            APIuser.StatusCode = 'E';
            APIuser.NoticeLanguage = user.Notification_Language__c;
            APIuser.NoticeChannel = (user.Notification_Channel__c=='Email'?'EML':user.Notification_Channel__c);//HKITSFDC-318 
            APIuser.NoticePhoneArea = user.Contact_No_Country_Code__c;
            APIuser.NoticePhoneNum = user.Contact_No__c;
            
            //HKITSFDC-318 Remove update to NoticeEmailAddress in ws 
            APIuser.personalEMailAddress = user.Notification_Email_Address__c;

            if(user.Notification_Channel__c=='Email' && String.isBlank(user.Notification_Email_Address__c)){
                APIuser.personalEMailAddress = user.Email;
            }
            if(user.NonOTP_Notification_EmailAddress__c!=null && user.NonOTP_Notification_EmailAddress__c!=''){//HKITSFDC-318 
                APIuser.NoticeEmailAddress = user.NonOTP_Notification_EmailAddress__c;//HKITSFDC-318 APIuser.NoticeEmailAddress = user.Email;
            }//HKITSFDC-318 
            /*APIuser.NoticeEmailAddress = user.Notification_Email_Address__c;

            if(user.Notification_Channel__c=='Email' && String.isBlank(user.Notification_Email_Address__c)){
                APIuser.NoticeEmailAddress = user.Email;
            }*/
             //HKITSFDC-318 Ended

            //step 3: load user input data
            if(form.buttonkey == 'loginEmail'){
                APIuser.emailAddress = form.confirmNewEmail;
                user.userName = form.confirmNewEmail; 
                user.email = form.confirmNewEmail;
            }else if(form.buttonkey == 'mobile'){
                // user.OktaSMSFactorId__c=newFactorId;
                // user.Contact_No_Country_Code__c=form.confirmNewMobile;
                String phonenum=form.confirmNewMobile?.trim();
                if (String.isNotBlank(phonenum)) {
                    phonenum=phonenum.replaceAll(' ', '');
                }
                user.Contact_No__c=phonenum;
                user.MobilePhone=user.Contact_No_Country_Code__c+user.Contact_No__c;
                APIuser.PhoneNumber = user.Contact_No_Country_Code__c+user.Contact_No__c;
            }else if(form.buttonkey == 'verificationEmail'){
                APIuser.personalEMailAddress = form.confirmNewEmail;
                user.Notification_Email_Address__c=form.confirmNewEmail;
                // add Okta MFA factor id by Ardbert.Wang 2022.10.25
                // user.OktaEmailFactorId__c=newFactorId;

            }else if(form.buttonkey == 'notificationMethod'){
                user.Notification_Channel__c = form.notificationMethod;
                APIuser.NoticeChannel = (user.Notification_Channel__c=='Email'?'EML':user.Notification_Channel__c);
            }else if(form.buttonkey == 'notificationLanguage'){
                system.debug('form.preference.language:'+form.notificationLanguage);
                user.Notification_Language__c = briefLanMap.get(form.notificationLanguage);
                APIuser.NoticeLanguage = user.Notification_Language__c;
            }

            //step 4: update user from WS
            UserCalloutHelper uHelper = new UserCalloutHelper();
            try{
                APIuser.isSuccess = uHelper.updateUser(APIuser);
                system.debug('APIuser:'+APIuser);
            }catch(CignaWSException e){
                if(!uhelper.getCalloutSuccessfully()){
                    system.debug('call WS Failed');
                    if(uhelper.getResultInfo() != null){
                        throw new CignaWSException(uhelper.getResultInfo().resultInfoDesc);
                    }
                }else{
                    system.debug('call WS Success');
                    if(!APIuser.isSuccess){
                        throw new CignaWSException(uhelper.getResultInfo().resultInfoDesc);
                    }
                    // else{
                    //     throw new CignaWSException(e.getMessage());
                    // }
                }
            }

            //step 5: update in okta if needed
            if(form.buttonkey == 'loginEmail' || form.buttonkey == 'notificationLanguage'){
                OktaMFACalloutHelper oktaHelper=new OktaMFACalloutHelper();
                Map<String,String> paramsMap=new Map<String,String>();
                paramsMap.put('loginEmail',user.userName);
                paramsMap.put('userId',user.OktaExternalId__c);
                paramsMap.put('locale',user.Notification_Language__c);
                HttpCalloutJsonVO.OktaMFAResult oktaResult=oktaHelper.updateUserProfile(paramsMap);
                if(!oktaResult.isResultSuccess) {
                    throw new CignaWSException(MyCgnRegisterUser.handErrMsg(oktaResult.errorRes));
                }
            }
            

            //step 6: update user in SF
            if(form.buttonkey != 'mobile' && form.buttonkey != 'loginEmail'){
                update user;
                // Update_User_Email__e event = new Update_User_Email__e(User_Id__c=UserInfo.getUserId(),email__c=form.confirmNewEmail);
                // EventBus.publish(event);  
                system.debug('user:'+user);
            }

            //step 7: add change log after updating successfully
            try{
                String eventDetail;
                if(form.buttonkey == 'loginEmail'){
                    eventDetail = 'change Login Email from ' + userOld.Email + ' to ' + user.Email;
                }else if(form.buttonkey == 'verificationEmail'){
                    eventDetail = 'change Verification Code Email Address from ' + userOld.Notification_Email_Address__c + ' to ' + user.Notification_Email_Address__c;
                }else if(form.buttonkey == 'mobile'){
                    eventDetail = 'change Contact Number from ' + userOld.Contact_No_Country_Code__c + ' to ' + user.Contact_No_Country_Code__c;
                }else if(form.buttonkey == 'notificationMethod'){
                    eventDetail = 'change Notification Channel from ' + userOld.Notification_Channel__c + ' to ' + user.Notification_Channel__c;
                }else if(form.buttonkey == 'notificationLanguage'){
                    eventDetail = 'change Notification Language from ' + userOld.Notification_Language__c + ' to ' + user.Notification_Language__c;
                }
                saveUserInfoChangeRecord(eventDetail,user.Account.Id);
            }catch(exception e){
                system.debug('error:'+e.getMessage()+' stack:'+e.getStackTraceString());
            }
        }
       
    }
    @future
    public static void saveUserInfoChangeRecord(String eventDetail, Id accountId){
        AccountChangeLog__c accountChangeLog = new AccountChangeLog__c(); 
        accountChangeLog.event_detail__c = eventDetail;
        accountChangeLog.Account__c = accountId;
        insert accountChangeLog;           
    }

    public static String enrollFactor(Map<String,object> reqMap,String type){
        UserInput form = (UserInput)JSON.deserialize(JSON.serialize(reqMap),UserInput.class);
        // system.debug('form:'+form);
        for(User user : [Select Id,OktaExternalId__c,Account.Id,account.SSN__c,contact.Marketing_Opt_Out__c, Name,UserName, Email, MobilePhone, Contact_No__c, Notification_Email_Address__c, Contact_No_Country_Code__c, Notification_Language__c, Notification_Channel__c, LanguageLocaleKey,FirstName,LastName,Company_Code__c,Agent_Code__c,ContactId,Country__c,CreatedDate 
        From User Where Id = :UserInfo.getUserId()]){
            if(!loginRequest(user.UserName,form?.currentPassword) && type != 'bypassValidation'){
                throw new CignaWSException(Label.Error_Message_Invalid_Current_Password);
            }else{
                Map<String, Object> paramMap = new Map<String, object>();
                String userInput;
                if(form.buttonkey == 'mobile'){
                    String phonenum=form?.confirmNewMobile?.trim();
                    if (String.isNotBlank(phonenum)) {
                        phonenum=phonenum.replaceAll(' ', '');
                    }
                    paramMap.put('contactNo',phonenum);
                    // System.debug('form.confirmNewMobile:'+form.confirmNewMobile.trim());
                    // paramMap.put('countryCode',user.Contact_No_Country_Code__c);
                    // userInput = user.Contact_No_Country_Code__c+form.confirmNewMobile;
                    paramMap.put('countryCode',form.confirmCountryCode.key);
                    userInput = form.confirmCountryCode.key+phonenum;
                }else{
                    paramMap.put('email',form.confirmNewEmail);
                    userInput = form.confirmNewEmail;
                }
                
                return OktaMFACtrl.enrollFactor(form.buttonkey == 'mobile'?'sms':'email',userInput,JSON.serialize(paramMap));
            }
        }
        throw new CignaWSException('System error. Please contact system admin');
    }

    public static void activateFactor(Map<String,object> reqMap){
        String factorId = String.valueOf(reqMap.get('factorId'));
        String passCode = String.valueOf(reqMap.get('passCode'));
        String userInput = String.valueOf(reqMap.get('userInput'));
        String factorType = String.valueOf(reqMap.get('factorType'));
        String countryCode = String.valueOf(reqMap.get('countryCode'));
        system.debug('factorId:'+factorId);
        system.debug('passCode:'+passCode);
        for(User user : [Select Id,OktaExternalId__c,Account.Id,account.SSN__c,contact.Marketing_Opt_Out__c, Name,UserName, Email, MobilePhone, Contact_No__c, Notification_Email_Address__c, Contact_No_Country_Code__c, Notification_Language__c, Notification_Channel__c, LanguageLocaleKey,FirstName,LastName,Company_Code__c,Agent_Code__c,ContactId,Country__c,CreatedDate 
        From User Where Id = :UserInfo.getUserId()]){
            Map<String,String> paramMap = new Map<String,String>();
            if(factorType == 'sms'){
                // paramMap.put('contactNo',userInput.trim());
                // paramMap.put('countryCode',countryCode.trim());
                if (String.isNotBlank(userInput)) {
                    userInput=userInput.replaceAll(' ', '');
                }
                paramMap.put('contactNo',userInput);
                if (String.isNotBlank(countryCode)) {
                    countryCode=countryCode.trim();
                    countryCode=countryCode.startsWith('+')?countryCode:'+'+countryCode;
                }
                paramMap.put('countryCode',countryCode);
            }else{
                paramMap.put('email',userInput);
            }
            String resetFactorInput = JSON.serialize(paramMap);
            String result = OktaMFACtrl.activateFactor(factorType, factorId, passCode, resetFactorInput);
            if('success'== result){
                // Map<String,object> formMap = new Map<String,object>();
                // if(factorType == 'sms'){
                //     formMap.put('buttonkey','mobile');
                //     formMap.put('confirmNewMobile',userInput);
                // }else{
                //     formMap.put('buttonkey','verificationEmail');
                //     formMap.put('confirmNewEmail',userInput);
                // }
                // updateUserInfo(formMap);
            }else{
                throw new CignaWSException(result);
            }
        }
        
    }
    
}