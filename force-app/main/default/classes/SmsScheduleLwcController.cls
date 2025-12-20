public with sharing class SmsScheduleLwcController {
    public class TemplateDTO {
        @AuraEnabled public String smsType;
        @AuraEnabled public String smsSubType;
        @AuraEnabled public String contentEnglish;
        public TemplateDTO(String type, String subType, String content) {
            smsType = type;
            smsSubType = subType;
            contentEnglish = content;
        }
    }

    public class LogRowDTO {
        @AuraEnabled public String policyNo;
        @AuraEnabled public String contactNo;
        @AuraEnabled public String smsType;
        @AuraEnabled public String smsSubType;
        @AuraEnabled public String lastUpdateBy;
        @AuraEnabled public DateTime lastUpdateDateTime;
        public LogRowDTO(SMS_Log__c objSMSLog) {
            policyNo = objSMSLog.Policy_No__c;
            contactNo = objSMSLog.Contact_No__c;
            smsType = objSMSLog.SMS_Type__c;
            smsSubType = objSMSLog.SMS_Sub_type__c;
            lastUpdateBy = objSMSLog.LastModifiedBy.Name;
            lastUpdateDateTime = objSMSLog.LastModifiedDate;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TemplateDTO> getTemplates() {
        try {
            List<TemplateDTO> result = new List<TemplateDTO>();
            for (SMS_Template__mdt m : [
                SELECT SMS_Type__c, SMS_Sub_type__c, Content_English__c
                FROM SMS_Template__mdt
            ]) {
                result.add(new TemplateDTO(m.SMS_Type__c, m.SMS_Sub_type__c, m.Content_English__c));
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getContentByType(String smsType, String smsSubType) {
        try {
            String contentVal = null;
            if (smsSubType == null) {
                for (SMS_Template__mdt m : [
                    SELECT Content_English__c
                    FROM SMS_Template__mdt
                    WHERE SMS_Type__c = :smsType
                    LIMIT 1
                ]) {
                    contentVal = m.Content_English__c;
                }
            } else {
                for (SMS_Template__mdt m : [
                    SELECT Content_English__c
                    FROM SMS_Template__mdt
                    WHERE SMS_Type__c = :smsType AND SMS_Sub_type__c = :smsSubType
                    LIMIT 1
                ]) {
                    contentVal = m.Content_English__c;
                }
            }
            return contentVal;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<LogRowDTO> reloadLogs(Id refRecordId) {
        try {
            List<LogRowDTO> rows = new List<LogRowDTO>();
            for (SMS_Log__c objSMSLog : [
                SELECT Policy_No__c, Contact_No__c, SMS_Type__c, SMS_Sub_type__c, LastModifiedBy.Name, LastModifiedDate
                FROM SMS_Log__c
                WHERE Ref_Record_Id__c = :refRecordId
                ORDER BY CreatedDate DESC
            ]) {
                rows.add(new LogRowDTO(objSMSLog));
            }
            return rows;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createSMSLog(String smsType, String smsSubType, String policyNo, Id refRecordId) {
        try {
            SMS_Log__c objSMSLog = new SMS_Log__c();
            objSMSLog.Ref_Record_Id__c = refRecordId;
            objSMSLog.Policy_No__c = policyNo;
            objSMSLog.SMS_Type__c = smsType;
            objSMSLog.SMS_Sub_type__c = smsSubType;
            if ('Account' == refRecordId.getSObjectType().getDescribe().getName()) {
                
            } else if ('Case' == refRecordId.getSObjectType().getDescribe().getName()) {
                
            }
            insert objSMSLog;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}