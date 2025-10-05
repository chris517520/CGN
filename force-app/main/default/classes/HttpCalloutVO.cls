/*********************************************************************************
 * Name: HttpCalloutVO
 *
 * Version History
 * Version           Author                 Date                      Description
 * ---------------  --------------------    -----------------------  ---------------------------------------------------------
 * V1.0             Franco, Nicole          2016-10-24               provides the requests/responses wrap classes for the WS functions
 * ......           
 * JR1774           Lawrence BP Wong        2019-11                  JR1774
 * AH18454          Lawrence BP Wong        2020-01                  AH18454
 * HKITSFDC-8       Kamlesh, PCCW           2024-01                  Add 3 new field for Elite 360 Migration    
 ********************************************************************************/
public class HttpCalloutVO{
    /*
     * Class for GetPolicyListBasicByCriteria, GetPolicyBasic
     * Client portal:  add @AuraEnabled for lwc component - Zane 2021-01-11
     */
    public class Policy implements Comparable{
        public String renewalNoticeInd{get;set;}// Rancho_JOBR367_20240513 - update premium display
        @AuraEnabled public String sourceCode{get;set;} //20220829 - minghua - JOBR-152 Health Migration
        @AuraEnabled public String rateScaleName{get;set;}//AM project rate scale name
        //public List<Coupon> couponList{get;set;}//AM project coupon jack add
        // 20200610 - minghua - levyII
        public Decimal levyCurrentPremium{get;set;}
        @AuraEnabled public Decimal nextLevy{get;set;}
        public Decimal currentPremiumIncludeLevy{get;set;}
        @AuraEnabled public Decimal modalPremiumIncludeLevy{get;set;}
        public Boolean effectiveLevy{get;set;}
        // 20200306 - minghua - ILAS
        public Date applicationDate{get;set;}
        public String acknowledgementType{get;set;}
        public Date acknowledgementDate{get;set;}
        public Investment investment{get;set;}
        //junda add 20201201
        @AuraEnabled public Boolean isDisplayTooltip{get;set;}{isDisplayTooltip=false;}
        //junda add end
      
        //Bob add 20210310
        @AuraEnabled
        public String numOfBranchs{get;set;}
        @AuraEnabled
        public String numOfPlans{get;set;}
        //Bob end 20210310

        //2020123 - Nicole - Beqlogo data
        public Boolean isQbeLogo{get;set;}
        @AuraEnabled
        public String policyNumber{get;set;}        // Policy numberperson
        //CTUI-220-20220622-Kirk
        @AuraEnabled
        public String token;
        @AuraEnabled
        public String policyType{get;set;}        // Policy Type
        public String policyValue{get;set;}
        @AuraEnabled
        public String productType{get;set;}         // Product type description
        public String productTypeCode{get;set;}         // Product type description
        @AuraEnabled
        public String productCode{get;set;}         // Product code
        @AuraEnabled
        public String planName{get;set;}            // Product name
        @AuraEnabled
        public String marketingName{get;set;}       // Marketing name
        public String policyStatus{get;set;}        // Policy status description
        public String policyStatusCode{get;set;}    // Policy status code
        @AuraEnabled
        public String policyStatusDisplayName{get;set;}
        public String effDate{get;set;}             // Effective date
        @AuraEnabled
        public Date effDateInDate{get;set;}
        public String termDate{get;set;}            // Termination date
        @AuraEnabled
        public Date termDateInDate{get;set;}
        //Add by Caden for JR1753 - change from policy level to member level coverage start
        public Date memberEffDateInDate{get;set;}
        public String memberTermDate{get;set;}// Rancho_JOBR376_20240612
        public Date memberTermDateInDate{get;set;}
        public String memberStatusDisplayName{get;set;}
        //Add by Caden for JR1753 - change from policy level to member level coverage end
        public String paidToDate{get;set;}          // Paid to date
        @AuraEnabled public Date paidToDateInDate{get;set;}
        public String issueDate{get;set;}           // Issue date
        public Date issueDateInDate{get;set;}
        public String annualPaymentAmt{get;set;}
        public String monthlyPaymentAmt{get;set;}
        @AuraEnabled public Decimal paymentAmt{get;set;}         // Modal premium
        public Decimal lastPaymentAmt{get;set;}         // JR1797 - Last Modal premium
        @AuraEnabled
        public String paymentMode{get;set;}         // Payment Mode
        public String paymentModeCode{get;set;}         // Payment Mode Code
        public String paymentMethod{get;set;}       // Payment Method
        public String brokerName{get;set;}
        public String brokerCompany{get;set;}
        public String brokerContactPerson{get;set;}
        public String brokerContactNo{get;set;}
        public String mailingAddress{get;set;}
        public String holderContactNumber{get;set;}
        public String currencyCode{get;set;}
        @AuraEnabled
        public String currencyCodeDesc{get;set;}
        @AuraEnabled
        public String currencySymbol{get;set;}
        @AuraEnabled
        public String holderName{get;set;}
        public String holderSSN{get;set;}
        @AuraEnabled
        public List<HttpCalloutVO.Person> insuredList{get;set;}
        @AuraEnabled
        public HttpCalloutVO.Person broker{get;set;}
        //add Bob 20210318
        @AuraEnabled
        public HttpCalloutVO.Person adminPer{get;set;}
        @AuraEnabled
        public HttpCalloutVO.Person claimsPer{get;set;}
        //end
        public String holdingID{get;set;}
        public String partyID{get;set;}
        @AuraEnabled
        public HttpCalloutVO.Person holder{get;set;}
        @AuraEnabled public String sourceSystem{get;set;} //added by Nicole in Phase2   // newly base on CS_CR_WS_XML_Spec_r1.xlsx
        //for Group Result
        public String coveragePeriodFrom{get;set;}
        public Date coveragePeriodFromInDate{get;set;}
        public String coveragePeriodTo{get;set;}
        public Date coveragePeriodToInDate{get;set;}
        @AuraEnabled
        public String numberofEmployees{get;set;}
        @AuraEnabled
        public String numberofSpouse{get;set;}
        @AuraEnabled
        public String numberofChildren{get;set;}
        public String planTypeCode{get;set;}
        public String planTypeDescription{get;set;}
        public String policyHolder{get;set;}
        //add test field for test by Nicole
        public List<String> policyPackage{get;set;}
        public String validUntil{get;set;}
        public String brokerCode{get;set;}
        //add field for PolicyChangeSubmitVFP by Nicole
        public String agentCode{get;set;}
        public Boolean allowChangeOwner{get;set;}
        public Boolean allowChangePaymentDate{get;set;}
        //JR1809 see if policy been inactive more than 90 days
        public Integer inactiveDays{get;set;}
        public String isLifeGeneral{get;set;} // old  L ? G ?
        //minghua - 20221010 - JOBR-184 - JOBR-237 - to get is life policy in aura component
        @AuraEnabled
        public Boolean isLifePolicy{get;set;} // new TRUE/FALSE
        @AuraEnabled public Boolean isILAS{get;set;}
        @AuraEnabled public Boolean isIndividual{get;set;}
        public String distChannelCode{get;set;}
        public String distChannelDesc{get;set;}
        public Boolean isSystem6{get;set;}
        public Boolean isIPMIPolicy{get;set;}
        public Boolean isTUpPolicy{get;set;}
        public Boolean isIPMITUpPolicy{get;set;}
        public Boolean isLHBPolicy{get;set;}
        public Boolean isLHBPackagePolicy{get;set;}
        public Boolean isLHBEligibleForGOPPolicy{get;set;}
        public Boolean isGAOPPolicy{get;set;}
        public PolicyPayment paymentInfo{get;set;}
        public String insuredNameStr{get;set;}
        public Boolean ishideAfter1Year{get;set;}
        @AuraEnabled public Integer EMedicalCardCount{get;set;}{EMedicalCardCount=0;}
        //for appLink
        public String OrgCode{get;set;}
        //Added by Andy in Phase2
        public String policyAddressInd{get;set;}
        public Integer workingDaysFromEffDate{get;set;}
        //Added by Nicole for test in Phase2
        @AuraEnabled public Date cancelDate{get;set;}
        public String certNumber{get;set;}
        public String policyRemark{get;set;}
        public Decimal SuspenseAmt{get;set;}  //getPolicyBasic
        public Decimal PremiumSuspenseAmt{get;set;}
        public String RiskClass{get;set;}
        public Integer PolicyYear{get;set;}
        @AuraEnabled public String SellerId{get;set;}
        public String planNumber{get;set;}
        @AuraEnabled public String diabetesTypeCode{get;set;}
        public Boolean renewalInd{get;set;}
        public Date RenewalDate{get;set;}
        @AuraEnabled public Boolean cashRewardInd{get;set;}
        @AuraEnabled public Date cashRewardDate{get;set;}
        //Added by Nicole for test in Phase2 End
        //HC-217 Add by Owen , 2023.06.30 for GetPolicyPersonListBasicByCriteria to get GOPIndicator and PreAuthIndicator
        // @AuraEnabled
        // public Boolean GOPIndicator{get;set;}
        //add by jay
        
        //START HKITSFDC-265
        public String planLevel{get;set;}
        public String AreaOfCover{get;set;}
        public String RoomType{get;set;}
        //END HKITSFDC-265
        
        public String insuredSsn{get;set;}
        public List<IncentivesInformation> incentiviesInfoList{get;set;}{incentiviesInfoList = new List<IncentivesInformation>();}
        public String customId{get;set;}
        @AuraEnabled public List<Reference> referenceList{get;set;}{referenceList = new List<Reference>();} //added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
        //Hardcopy Indicator added start
        @AuraEnabled public String medCardIndicator{get;set;}
        public String letterIndicator{get;set;}
        //Hardcopy Indicator added end
        @AuraEnabled public String rateScale{get;set;} // WS GetPolicyBasic enhanced added by ZaiHong 20180427
        @AuraEnabled public String sellerName{get;set;}//Added by lu weizheng at 20180516 in Phase 2
        public String wardLevel{get;set;} // for CheckProductEligibilityByCriteria

        // BEGIN changes HKITSFDC-22
        @AuraEnabled public Integer currentInsuredAge {get; set;}
        @AuraEnabled public Integer daysSincePolicyEffectiveDate {get; set;}
        @AuraEnabled public Decimal totalIpClaimAmt {get; set;}
        @AuraEnabled public String retentionHealthEligible {get; set;}
        
        // END changes HKITSFDC-22
 
        // BEGIN HKITSFDC-267
        @AuraEnabled public String NcdInd {get;set;}
        @AuraEnabled public Double NcdPercentage {get;set;}
        // END BEGIN HKITSFDC-267
            
        // David Zhang - CB - 20190221
        public String memberCertNo{get;set;} //for group PI
        //David Zhang - Policy Function Mapping
        public Map<String, FunctionMap> functionMap{get;set;}{functionMap = new Map<String, FunctionMap>();}
        public Integer compareTo(Object ct){
            HttpCalloutVO.policy object2 = (HttpCalloutVO.policy)ct;
            if(this.effDateInDate != null && object2.effDateInDate != null){
                if(this.effDateInDate > object2.effDateInDate){ return -1; }
                else if(this.effDateInDate < object2.effDateInDate){ return 1; }
                else{ return 0; }
            }else{
                if(this.effDateInDate != null){ return 1; }
                else if (object2.effDateInDate != null){ return -1; }
                else{ return 0; }
            }
        }

        public String category;//JR-1785

        //Nicole_20200107_Policy Detail Security Access
        public String SHA256Key{
            get{
                String key = '';
                if(String.IsNotBlank(policyNumber) && String.IsNotBlank(policyType)){
                    KeyGenerationStrategy keyGenerationStrategy = new SHA256KeyGenerationStrategy();
                    key = keyGenerationStrategy.generate(policyNumber+policyType);
                }
                return key;
            }
            set;
        }

        public String contactNo{get;set;}//SPS-381
        public Boolean accessible{get;set;}//JR-1785
        //JR1783
        @AuraEnabled public String campaignCode{get;set;}
        //JR1783
        public String masterPolicyNo{get;set;} // Rancho_FriendDiscount_20210812: enable phone number search for TM
        public String partnerCode{get;set;}//Owen 20230530 For PS-23 add new columu 'Partner Code'
        
        // Adding 3 new fields https://jira.express-scripts.com/browse/HKITSFDC-8
        @AuraEnabled public String internalProductName{get;set;} 
        @AuraEnabled public String renewalSegment{get;set;} 
        @AuraEnabled public String actualSegment{get;set;} 
        

        // Elite 360 Migration - NCD
        public String nCDEligibility{get;set;}
        @AuraEnabled public String nCDUpdateDate{get;set;}
        public Boolean isNCDEligible {get; set;}
        // END https://jira.express-scripts.com/browse/HKITSFDC-15  

        // BEGIN HKITSFDC-148	
        public String lastAgent {get;set;}
        public String writingAgent {get;set;}
        public Date brokerChangeDate {get;set;}
        // END HKITSFDC-148 
    }

    //20210621 Bob Asia Mile 
    public class Membership{
        @AuraEnabled public String channel{get;set;}
        @AuraEnabled public String membershipId{get;set;}
        @AuraEnabled public String membershipFirstName{get;set;}
        @AuraEnabled public String membershipLastName{get;set;}
    }

    // 20200306 - minghua - ILAS
    public class Investment{
        public String id{get;set;}
        public List<SubAccount> subAccountList{get;set;}{subAccountList = new List<SubAccount>();}
    }
    public class SubAccount{
        public String id{get;set;}
        public String productCode{get;set;} //Fund code
        public String productFullName{get;set;} //Fund name
        public String riskLevelCode{get;set;} //Risk Level Code
        public String riskLevelDesc{get;set;} //Risk Level Description
        public Date riskEffDate{get;set;}    //Risk Level Effective Date (yyyy-mm-dd)
    }

    //David Zhang - Policy Function Mapping - 210190823
    public class FunctionMap{
        public String functionName{get;set;}
        public String functionDesc{get;set;}
        public Integer priority{get;set;}
        public String isActive{get;set;}
    }

    //Added by Nicole in Pahase 2, used to teransfer policy criteria
    /*
     * Critieria for GetPolicyListBasicByCriteria
     */
    public class PolicyRequest{
        public Boolean isIndividual{get;set;}{ isIndividual = true; } // default
        public String policyNumber{get;set;}
        public String PolicyType{get;set;}
        public String holderName{get;set;}
        public String holderId{get;set;}
        public String holderPhone{get;set;}
        public Date holderDOB{get;set;}
        public String insuredName{get;set;}
        public String insuredId{get;set;}
        public Date insuredDOB{get;set;}
        public List<String> statusList{get;set;}
        public String brokerAgentCode{get;set;}
        public Boolean isIPMI{get;set;}
        public String companyCode{get;set;}
        public String userLoginName{get;set;}
        public String roleID{get;set;}
        public String memberName{get;set;}
        public Boolean isTUpPolicy{get;set;}
        //public Boolean isCPlusPolicy{get;set;}
        public Boolean isLHBPolicy{get;set;}
        public Boolean isLHBPackagePolicy{get;set;}
        public Boolean isLHBEligibleForGOPPolicy{get;set;}
        public Boolean isGAOPPolicy{get;set;}
        public String claimNumber{get;set;}
        public String bankAccountNumber{get;set;} //AccountNumber
        public DateTime policyCreationDateTime{get;set;}
        public String SellerId{get;set;}
        public String FamilyRecInd{get;set;}
        public String SortOrder{get;set;}           //Please input 'A'/'D'
        public String submissionDateTimeFrom{get;set;}
        public String submissionDateTimeTo{get;set;}
        //add Bob 20201116 Additional option to search their client case by renewing month
        public String policyRenewingMonth{get;set;}
        public String policyRenewingYear{get;set;}
        //end
        public Boolean isTDUser{get;set;} //Nicole_SMT_20210425
    }

    public class EMedicalCard{
        public string InsuredName{get;set;}
        public string InsuredSSNNumber{get;set;}
        public string PolicyNumber{get;set;}
        public string CertNumber{get;set;}
        public string FileFormat{get;set;}
        @AuraEnabled public string frontUrl{get;set;}
        @AuraEnabled public string backUrl{get;set;}
    }

    public class PolicyAgent{
        public String polNumber{get;set;}{polNumber = '';}
        public String companyCode{get;set;}{companyCode = '';}
        public String agentCode{get;set;}{agentCode = '';}
        public Boolean isSuccess{get;set;}{isSuccess = false;} // just used to store the request result
    }

    public class Relation{
        public String id{get;set;}
        public String OriginatingObjectID{get;set;}
        public String RelatedObjectID{get;set;}
        public String OriginatingObjectType{get;set;}
        public String OriginatingObjectCode{get;set;}
        public String RelatedObjectType{get;set;}
        public String RelatedObjectCode{get;set;}
        public String RelationRoleCode{get;set;}
        public String RelationRoleType{get;set;}
        public String InsurableInterestReason{get;set;}
        public String InterestPercent{get;set;}
    }

    public class GroupPolicy{
        public String GroupPolicyId{get;set;}
        public String GroupPolicyKey{get;set;}
        public String NumEmployees{get;set;}
        public String NumInsured{get;set;}
        public String NumSpouse{get;set;}
        public String NumChildren{get;set;}
    }

    /*
     * sub Class for familyList in Person
     */
    public class PersonFamily{
        public String name{get;set;}
        public String relationship{get;set;}
        public String SSN{get;set;}
    }

    public class Impairment{
        public String ImpairmentId{get;set;}
        public String ImpairmentCode{get;set;}
        public String ImpairmentDesc{get;set;}
    }
    /*
     * Class for GetPersonListBasicByCriteria, GetPersonBasic, GetPolicyPersonListBasic
     */
    public class Person implements Comparable{
        /* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
        // Rancho_HKITSFDC250_20250514 - add aura enabled for fields
        @AuraEnabled public String PlaceOfBirth{get;set;}
        public String PlaceOfBirthCode{get;set;}
        public String PlaceOfBirthDesc{get;set;}
        public String ResidenceaddressConutryCode{get;set;}
        public String addressCountryCode{get;set;}
        
        //20210621 Bob Asia Mile
        @AuraEnabled public Membership membership{get;set;}
        // 20200306 - minghua - ILAS
        @AuraEnabled public String rPQStatus{get;set;}
        @AuraEnabled public Date rPQEffectiveDate{get;set;}
        // jack add for ILAS
        public String rPQStatusCode{get;set;}
        public String rPQUpdateSource{get;set;}
        public Date rPQUpdateDate{get;set;}
        public Time rPQUpdateTime{get;set;}

        public String partyID{get;set;}
        @AuraEnabled
        public String policyNumber{get;set;}
        public String personId{get;set;}
        public String firstName{get;set;}
        public String middleName{get;set;}
        public String lastName{get;set;}
        @AuraEnabled
        public String fullName{get;set;}
        public String employeeName{get;set;}
        public String title{get;set;}
        @AuraEnabled
        public String gender{get;set;}
        @AuraEnabled
        public String employmentDate{get;set;}
        @AuraEnabled
        public String salary{get;set;}
        @AuraEnabled
        public String occupation{get;set;}
        @AuraEnabled
        public String stationedCountry{get;set;}
        @AuraEnabled
        public String stationedCountryCode{get;set;}
        @AuraEnabled
        public String alias{get;set;}
        @AuraEnabled
        public String years{get;set;}
        @AuraEnabled
        public String postalAddress{get;set;}
        @AuraEnabled
        public String bankName{get;set;}
        @AuraEnabled
        public String bankCode{get;set;}
        @AuraEnabled
        public String planDesc{get;set;}  // JR1904  Linus
        @AuraEnabled
        public Boolean hasEMedicalCard{get;set;} // added by Connor CP-266(Client Portal)
        public String genderCode{get;set;}
        @AuraEnabled
        public String birthDate{get;set;}
        @AuraEnabled
        public Date birthDateInDate{get;set;}
        @AuraEnabled
        public String ssnNumber{get;set;}
        public String ssnNumberTC{get;set;}
        public String renewalRemarks{get;set;}
        public String diagnosisCode{get;set;}
        public String diagnosisDesc{get;set;}
        
        // BEGIN HKITSFDC-4
        public Boolean isPersonVIP{get;set;}
        public Boolean hasAnyActiveComplaints{get;set;}
        // END HKITSFDC-4 
        
        //add Bob 20210318 Client Policy Information
        @AuraEnabled
        public String contactPerson{get;set;}
        @AuraEnabled
        public String adminName{get;set;}
        @AuraEnabled
        public String adminEmail{get;set;}
        @AuraEnabled
        public String adminNo{get;set;}
        @AuraEnabled
        public String adminAddr{get;set;}
        @AuraEnabled
        public String claimsName{get;set;}
        @AuraEnabled
        public String claimsEmail{get;set;}
        @AuraEnabled
        public String claimsNo{get;set;}
        @AuraEnabled
        public String claimsAddr{get;set;}
        //end
        @AuraEnabled
        public String mobilePhoneNo{get;set;}
        public String mobileCountryCode{get;set;}
        public String mobileAreaCode{get;set;}
        public String mobileTelephoneNo{get;set;}
        public String mobileSourceSystem{get;set;}
        @AuraEnabled
        public String homePhoneNo{get;set;}
        public String homePhoneCountryCode{get;set;}
        public String homePhoneAreaCode{get;set;}
        public String homeSourceSystem{get;set;}
        @AuraEnabled
        public String businessPhoneNo{get;set;}
        @AuraEnabled public String businessPhoneCountryCode{get;set;}
        public String businessPhoneAreaCode{get;set;}
        public String businessPhoneExt{get;set;}
        public String businessPhoneSourceSystem{get;set;}
        @AuraEnabled public String businessFaxNo{get;set;}
        public String businessFaxCountryCode{get;set;}
        public String businessFaxAreaCode{get;set;}
        public String businessFaxSourceSystem{get;set;}
        @AuraEnabled public String homeFaxNo{get;set;}
        public String homeFaxCountryCode{get;set;}
        public String homeFaxAreaCode{get;set;}
        public String homeFaxSourceSystem{get;set;}
        //SPS-400
        @AuraEnabled public String otherPhoneNo{get;set;}
        public String otherPhoneCountryCode{get;set;}
        public String otherPhoneAreaCode{get;set;}
        public String otherPhoneSourceSystem{get;set;}
        @AuraEnabled public String correspondencePhoneNo{get;set;}
        public String correspondencePhoneCountryCode{get;set;}
        public String correspondencePhoneAreaCode{get;set;}
        public String correspondencePhoneSourceSystem{get;set;}
        //SPS-400
        @AuraEnabled
        public String contactPersonPhoneNo{get;set;}

        @AuraEnabled public String ResidenceaddressLine1{get;set;}
        @AuraEnabled public String ResidenceaddressLine2{get;set;}
        @AuraEnabled public String ResidenceaddressLine3{get;set;}
        @AuraEnabled public String ResidenceaddressLine4{get;set;}
        @AuraEnabled public String ResidenceaddressConutry{get;set;}
        @AuraEnabled public String ResidenceaddressSourceSystem{get;set;}
        @AuraEnabled public String PermanentaddressLine1{get;set;}
        @AuraEnabled public String PermanentaddressLine2{get;set;}
        @AuraEnabled public String PermanentaddressLine3{get;set;}
        @AuraEnabled public String PermanentaddressLine4{get;set;}
        @AuraEnabled public String PermanentaddressConutry{get;set;}
        @AuraEnabled public String PermanentaddressSourceSystem{get;set;}

        public String email{get;set;}
        @AuraEnabled
        public String emailAddress{get;set;}
        public String personalEmailAddress{get;set;}   // add by minghua - 20190812 - Customer portal GS login flow
        public String emailAddressSourceSystem{get;set;}
        public String addressType{get;set;}
        public String addressLine1{get;set;}
        public String addressLine2{get;set;}
        public String addressLine3{get;set;}
        public String addressLine4{get;set;}
        @AuraEnabled public String fullAddress{get;set;}
        public String city{get;set;}
        public String zip{get;set;}
        public String addressState{get;set;}
        public String addressCountry{get;set;}
        public String sourceSystem{get;set;}
        public String FamilyRecInd{get;set;}   //Added by Nicole in Phase2
        public String RelationRole{get;set;}
        public String memberName{get;set;}
        @AuraEnabled
        public String certificateNo{get;set;}
        public String certificateEffDate{get;set;}
        @AuraEnabled
        public String effDate{get;set;}  //IBM KOU PEI-156
        @AuraEnabled
        public Date effDateInDate{get;set;}   //Caden HKSIR4516
        public Date certificateEffDateInDate{get;set;}
        @AuraEnabled
        public String memberStatusDesc{get;set;}
        public String memberStatusDisplay{get;set;}
        @AuraEnabled
        public String branchCode{get;set;}
        @AuraEnabled
        public String branchDesc{get;set;}
        public String lifeSumAssured{get;set;}
        public String tpdSumAssured{get;set;}
        public String addSumAssured{get;set;}
        public String ltdSumAssured{get;set;}
        public String cibSumAssured{get;set;}
        @AuraEnabled
        public Decimal lifeSumAssuredInNumber{get;set;}
        @AuraEnabled
        public Decimal tpdSumAssuredInNumber{get;set;}
        @AuraEnabled
        public Decimal addSumAssuredInNumber{get;set;}
        @AuraEnabled
        public Decimal ltdSumAssuredInNumber{get;set;}
        @AuraEnabled
        public Decimal cibSumAssuredInNumber{get;set;}

        public Boolean isIndividual{get;set;}
        @AuraEnabled
        public String GroupMedicalBenefitStr{get;set;}  // Benefit Type
        @AuraEnabled public String brokerAgentCode{get;set;}         // CompanyProducerID
        @AuraEnabled
        public String planNumber{get;set;}
        public String planDescription{get;set;}
        public String insuredName{get;set;}

        @AuraEnabled public String idCopyReceivedInd{get;set;}
        public String idCopyReceivedSource{get;set;}
        public Date pastIdProofDate{get;set;}
        @AuraEnabled public String permanentAddressProofReceivedInd{get;set;}
        public String permanentAddressProofReceivedSource{get;set;}
        @AuraEnabled public String residentialAddressProofReceivedInd{get;set;}
        public String residentialAddressProofReceivedSource{get;set;}
        public String nationalityCode{get;set;}
        @AuraEnabled
        public String nationalityDesc{get;set;}
        public Date passportExpiryDate{get;set;}
        @AuraEnabled public String PassportProofRecInd{get;set;}
        @AuraEnabled public Date PassportProofRecDate{get;set;}
        public String PassportProofSource{get;set;}
        public String IPASClientId{get;set;}
        public String SYSTEM6ClientId{get;set;}
        public String CAPSILClientId{get;set;}
        @AuraEnabled
        public String orgCode{get;set;}
        @AuraEnabled
        public HttpCalloutVO.Person organization{get;set;}
        @AuraEnabled
        public String insurableInterestReason{get;set;}
        public String interestPercent{get;set;}
        public Integer index{get;set;}
        public String wardLevelByPerson{get;set;} // IBM KOU 20180618 for Portable Underwriting Determination

        //start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
        @AuraEnabled
        public String planName{get;set;}  //Plan name (For group policy)
        public String eMedicalCardType{get;set;} //E-Medical Card Type (For group policy)
        //end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx

        //Hardcopy Indicator added start
        public String medCardIndicator{get;set;}
        @AuraEnabled public String letterIndicator{get;set;}
        //Hardcopy Indicator added end

        //Added by Nicole in Phase2 for getPolicyPersonListBasicByCriteria getPersonBasic
        public String policyHolderName{get;set;}
        public String policyHolderChineseName{get;set;}
        @AuraEnabled
        public Date effectiveDate{get;set;}
        @AuraEnabled
        public Date terminationDate{get;set;}
        public String policyStatus{get;set;}
        public String productType{get;set;}
        public String productTypeCode{get;set;}
        @AuraEnabled public Date IDcopyReceivedDate{get;set;}
        @AuraEnabled public Date permanentAddressProofReceivedDate{get;set;}
        @AuraEnabled public Date residentialAddressProofReceivedDate{get;set;}
        @AuraEnabled public Date correspondenceAddressProofReceivedDate{get;set;}
        @AuraEnabled public Date nationalityProofReceivedDate{get;set;}
        public String anyMissedContactNumber{get;set;}
        public List<PersonFamily> familyList{get;set;}{ familyList = new List<HttpCalloutVO.PersonFamily>(); }
        public String certNumber{get;set;}
        public Date policyEffectiveDate{get;set;}
        public Date policyTerminationDate{get;set;}
        public String CFARemark_PolicyLevel{get;set;}
        public String claimRemark{get;set;}
        public String policyRemark{get;set;} //Added by Nicole in Phase2 for read getPolicyList response
        public List<HttpCalloutVO.Impairment> ImpairmentList{get;set;}
        @AuraEnabled public String ChineseFullName{get;set;}
        @AuraEnabled public List<HttpCalloutVO.Sensitivity> sensitivityList{get;set;}{ sensitivityList = new List<HttpCalloutVO.Sensitivity>(); }
        //public List<HttpCalloutVO.PersonBasic> CRSList{get;set;}{ CRSList = new List<HttpCalloutVO.PersonBasic>(); }
        @AuraEnabled public List<HttpCalloutVO.ContactHistory> contactList{get;set;}{ contactList = new List<HttpCalloutVO.ContactHistory>(); }
        public List<HttpCalloutVO.PersonTax> taxList{get;set;}{ taxList = new List<HttpCalloutVO.PersonTax>(); }
        public List<String> selectCustomerCategoryList{get;set;}{ selectCustomerCategoryList = new List<String>(); }
        public List<HttpCalloutVO.Policy> policyList{get;set;}{ policyList = new List<HttpCalloutVO.Policy>(); }

        //add by Andy
        public String addressIndex{get;set;}
        //Add by Manuel
        public String height{get;set;}
        public String weight{get;set;}
        public String placeOfResCode{get;set;}
        public String languagePref{get;set;} //Add by Manuel that supplement a field indicate preferred language
        //junda add 20200925
        @AuraEnabled
        public String waiverPreExist{get;set;}
        public String productCode{get;set;}

        @AuraEnabled
        public String idType{get;set;} //added by Connor CP-156
        @AuraEnabled
        public String idTypeCode{get;set;} //added by Connor
        @AuraEnabled
        public String countryOfResidence{get;set;} //added by Connor CP-156
        @AuraEnabled
        public String countryOfResidenceCode{get;set;} //added by Connor
        @AuraEnabled
        public Integer age{ 
            get{
                if(birthDateInDate != null){
                    return Date.today().year() - birthDateInDate.year();
                }
                return null;
            }
            set;
        } //added by Connor CP-156  
        @AuraEnabled
        public String maritalStatus{get;set;} //added by Connor CP-156  
        @AuraEnabled
        public String maritalStatusCode{get;set;} //added by Connor
        @AuraEnabled
        public String staffID{get;set;} //added by Connor CP-156
        @AuraEnabled
        public String companyDesc{get;set;} //added by Connor CP-156
        @AuraEnabled
        public String departmentDesc{get;set;} //added by Connor CP-156
        @AuraEnabled
        public String departmentCode{get;set;} //Rancho_CP782_20220206


        //end
        //Zane SFDC 20200812
        // TM work at home : mask sensitive data if user work at home
        @AuraEnabled public String ssnNumberMasked{
            get{
                if(String.isNotBlank(ssnNumber)){
                    return ssnNumber.left(4).rightPad(ssnNumber.length(), '*');
                }
                return '';
            }
            set;
        }

        @AuraEnabled public String mobilePhoneNoMasked{
            get{
                if(String.isNotBlank(mobilePhoneNo)){
                    return mobilePhoneNo.left(4).rightPad(mobilePhoneNo.length(), '*');
                }
                return '';
            }
            set;
        }

        @AuraEnabled public String homePhoneNoMasked{
            get{
                if(String.isNotBlank(homePhoneNo)){
                    return homePhoneNo.left(4).rightPad(homePhoneNo.length(), '*');
                }
                return '';
            }
            set;
        }

        @AuraEnabled public String businessPhoneNoMasked{
            get{
                if(String.isNotBlank(businessPhoneNo)){
                    return businessPhoneNo.left(4).rightPad(businessPhoneNo.length(), '*');
                }
                return '';
            }
            set;
        }

        @AuraEnabled public String fullAddressMasked{
            get{
                if(String.isNotBlank(fullAddress)){
                    if(fullAddress.contains(',')){
                        Integer split = fullAddress.indexOf(',');
                        return '*'.repeat(split) + fullAddress.subString(split);
                    }else if(fullAddress.contains('，')){
                        Integer split = fullAddress.indexOf('，');
                        return  '*'.repeat(split) + fullAddress.subString(split);
                    }else{
                        return (String.isNotBlank(addressLine1) ? addressLine1.left(0).rightPad(addressLine1.length(), '*') : '')
                                + addressLine2+','+addressLine3+','+addressLine4+','+addressState+','+addressCountry;
                    }
                }
                return '';
            }
            set;
        }
        //SFDC end

        public Integer compareTo(Object obj){
            HttpCalloutVO.Person ct = (HttpCalloutVO.Person)obj;
            if(this.insurableInterestReason.equalsIgnoreCase('EMPLOYEE')){ return -1; }
            else if (ct.insurableInterestReason.equalsIgnoreCase('EMPLOYEE')){ return 1; }
            else if (this.insurableInterestReason.equalsIgnoreCase('SPOUSE') && ct.insurableInterestReason.equalsIgnoreCase('SPOUSE')){
                if(this.index > ct.index){ return 1; }
                else{ return -1; }
            } else if (this.insurableInterestReason.equalsIgnoreCase('CHILD') && ct.insurableInterestReason.equalsIgnoreCase('CHILD')){
                if(this.index > ct.index){ return 1; }
                else{ return -1; }
            } else if (this.insurableInterestReason.equalsIgnoreCase('SPOUSE')){ return -1; }
            else if (ct.insurableInterestReason.equalsIgnoreCase('SPOUSE')){ return 1; }
            else{ return -1; }
        }

        //David Zhang - VC - 20190219
        @AuraEnabled public String meansOfIncome{get;set;}
        @AuraEnabled public String educationLevel{get;set;}
        public String DDASignatureStatus{get;set;}
        public String policyHolderId{get;set;}
        //Raistlin - GS claim - 20191024
        @AuraEnabled
        public HttpCalloutVo.BankAccount bankAccount{get;set;}
        //JR-1785
        public String category{get;set;}
        public Boolean accessible{get;set;}
        //JR-1785

        //CS Member Level Jack add begin
        public String addressValidFlag{get;set;}
        public String emailValidFlag{get;set;}
        @AuraEnabled
        public String nationality{get;set;}
        public String CorrespondenceAddress{get;set;}
        public String ARaddressLine1{get;set;}
        public String ARaddressLine2{get;set;}
        public String ARaddressLine3{get;set;}
        public String ARaddressLine4{get;set;}
        public String ARaddressState{get;set;}
        public String ARaddressCountry{get;set;}
        public String ARdefaultAddressInd{get;set;}
        public String ClaimAddressLine1{get;set;}
        public String ClaimAddressLine2{get;set;}
        public String ClaimAddressLine3{get;set;}
        public String ClaimAddressLine4{get;set;}
        public String ClaimAddressState{get;set;}
        public String ClaimAddressCountry{get;set;}
        public String ClaimDefaultAddressInd{get;set;}
        //CS Member Level Jack add end

        //HC-217 Add by Owen , 2023.06.30 for GetPolicyPersonListBasicByCriteria to get GOPIndicator and PreAuthIndicator
        // @AuraEnabled
        // public Boolean PreAuthIndicator{get;set;}

    }

    public class Sensitivity{
        public String sensitivityCode{get;set;}
        // Rancho_HKITSFDC250_20250514 - add aura enabled for fields
        @AuraEnabled public String sensitivityDesc{get;set;}
        public String action{get;set;}
    }

    public class PersonTax{
        public String taxResidenceCountryCode{get;set;}
        public String taxResidenceCountryDesc{get;set;}
        public String tin{get;set;}
        public String crsFollowUpLetterInd{get;set;}
        public Date crsFollowUpLetterDate{get;set;}
        public String tinReceiveInd{get;set;}
        public Date tinReceiveDate{get;set;}
    }

    /*
     * Class for GetPolicyClaimBasic, GetClaimListBasicByCriteria
     */
    public class Claim{
        public String holdingID{get;set;}
        //Add by Nicole for GetClaimListBasicByCriteria
        //Rancho_HKITSFDC250_20250514 - add aura enabled for fields
        @AuraEnabled public String polNumber{get;set;}
        @AuraEnabled public String claimNumber{get;set;}
        public String currencyCode{get;set;}
        public String currencyDescription{get;set;}
        public String currencySymbol{get;set;}
        public String billingCurrencyCode{get;set;}
        public String billingCurrencyDescription{get;set;}
        public String billingCurrencySymbol{get;set;}
        public String paymentCurrencyCode{get;set;}
        public String paymentCurrencyDescription{get;set;}
        public String paymentCurrencySymbol{get;set;}
        public Decimal sumInsured{get;set;}
        public String paymentMethodCode{get;set;}
        public String paymentMethodDescription{get;set;}
        public String claimStatusCode{get;set;}
        @AuraEnabled public String claimStatusDescription{get;set;}
        public String actualObjectType{get;set;}
        public Date claimPeriodFrom{get;set;}    //Added by Nicole in Phase2
        public Date claimPeriodTo{get;set;}      //Added by Nicole in Phase2
        public String claimRemark{get;set;}
        //Add by Nicole for GetClaimListBasicByCriteria Individual
        public String claimant{get;set;}
        @AuraEnabled public String policyInsuredName{get;set;}
        @AuraEnabled public String submitDate{get;set;}
        @AuraEnabled public Date submitDateInDate{get;set;}
        @AuraEnabled public String claimDate{get;set;}
        @AuraEnabled public Date claimDateInDate{get;set;}
        public String claimStatus{get;set;}           // Claim status description
        public String productCode{get;set;}
        public String planName{get;set;}
        public Date lossPeriodFrom{get;set;}                // for Individual
        public Date lossPeriodTo{get;set;}                  // for Individual
        public Date eventDate{get;set;}
        public String benefitDescription{get;set;}
        public String paymentTo{get;set;}
        public String remarks{get;set;}
        public String adviceRemarks{get;set;}
        public String claimRemarks{get;set;}
        public String renewalRemarks{get;set;}
        public String hgRemarks{get;set;}
        public String diagnosisCode{get;set;}
        public String diagnosisDesc{get;set;}
        public List<benefit> benefit{get;set;}
        //Add by Nicole for GetClaimListBasicByCriteria Group
        public String ssnNumber{get;set;}
        @AuraEnabled public String certNumber{get;set;}
        public String memberName{get;set;}
        public String memberStatusDescription{get;set;}
        public String consultationDate{get;set;}            // for Group
        @AuraEnabled public Date consultationDateInDate{get;set;}        // for Group
        public String dischargeDate{get;set;}               // for Group
        @AuraEnabled public Date dischargeDateInDate{get;set;}           // for Group
        //add String for incurredAmount to handle "N/A" CP-481
        public String incurredAmountTxt{get;set;}
        public Decimal incurredAmount{get;set;}
        public String incurredAmountCurrencyCode{get;set;}
        public String claimTypeCode{get;set;}
        public String claimTypeDescription{get;set;}
        @AuraEnabled public String claimTypeDisplay{get;set;}
        public String benefitItemCode{get;set;}
        public String benefitItemDescription{get;set;}
        public String admissionDate{get;set;}
        public Date admissionDateInDate{get;set;}
        public String insuredName{get;set;}
        //add test fields for test by Nicole
        public String benefitType{get;set;}
        public String benefitTypeDescription{get;set;}
        public String benefitTypeDisplay{get;set;}
        //add String for PaidAmount to handle "N/A" CP-481
        public String paidAmountTxt{get;set;}
        @AuraEnabled public Decimal paidAmount{get;set;}
        public String paidAmountCurrencyCode{get;set;}
        // AH18015 revise claim paid amount retrieval in claim detail
        public Decimal refundAmount{get;set;}
        public Decimal deductPremium{get;set;}
        public String paymentDate{get;set;}
        public Date paymentDateInDate{get;set;}
        public String branch{get;set;}
        public String branchCode{get;set;}
        @AuraEnabled
        public String branchDesc{get;set;}
        public String receivedDate{get;set;}
        public Date receivedDateInDate{get;set;}
        public String lastUpdateDate{get;set;}
        @AuraEnabled public Date lastUpdateDateInDate{get;set;}
        public Boolean isBrokerClaim{get;set;}
        public Boolean isIndividual{get;set;}
        public String rejectCode{get;set;}
        public String rejectReason{get;set;}
        public String paymentCurrencyTypeCode{get;set;}
        public String staffId{get;set;} //added by Connor CP-167
        public String shortfallAmount{get;set;} //added by Connor CP-167 
        public String shortfallAmountCurrencyCode{get;set;}
        @AuraEnabled public String sfdcClaimNumber{get;set;} //MRP-242 Quinto 20231010
        public List<HttpCalloutVO.PendingMemo> pendingMemoList{get;set;}{ pendingMemoList = new List<HttpCalloutVO.PendingMemo>(); }
        public List<HttpCalloutVO.HealthGuard> healthGuardList{get;set;}{ healthGuardList = new List<HttpCalloutVO.HealthGuard>(); }
        @AuraEnabled public List<HttpCalloutVO.ClaimCoverage> coverageList{get;set; }{ coverageList = new List<HttpCalloutVO.ClaimCoverage>(); }
    }

    public class ClaimCoverage{
        public String benefitItemCode{get;set;}
        public String productCode{get;set;}
        public Decimal coveragePaidAmount{get;set;}
        public String planName{get;set;}
        public String claimTypeDisplay{get;set;}
        public String piName{get;set;}
    }

    /*
     * Class for ReplyClaimPendingMemo
     */
    public class ReplyClaimRequest{
        public String policyNumber{get;set;}
        public String claimNumber{get;set;}
        public String certNo{get;set;}
        public boolean isIPMIPolicy{get;set;}
        public boolean isTUpPolicy{get;set;}
        public boolean isGAOPPolicy{get;set;}
        public boolean isIndividualPolicy{get;set;}
        public List<HttpCalloutVO.Attachment> attList{get;set;}
    }

    public class Benefit{
        public String benefit{get;set;}
        public Decimal maximumAmount{get;set;}
        public Decimal incurredAmount{get;set;}
        public String dayClass{get;set;}
        public Decimal paidAmount{get;set;}
        public String remarks{get;set;}
        public String benefitLevelName{get;set;} // add in phase 2 for GetPlanInfoListBasic
        public String benefitLevelCode{get;set;} // add in phase 2 for GetPlanInfoListBasic
        public String planCode{get;set;} // add in phase 2 for GetPlanInfoListBasic
        public Boolean isAvailable{get;set;}{ isAvailable = false; } // add in phase 2 for GetPlanInfoListBasic

        public List<EligibleAge> eligibleAgeList{get;set;}{ eligibleAgeList = new List<EligibleAge>(); } //added by Andy 20180727 for GetPlanInfoListBasic
        public List<BenefitDetail> benefitDetailList{get;set;}{ benefitDetailList = new List<BenefitDetail>(); } // phase 2 for GetPlanInfoListBasic
    }

    // phase 2 for GetPlanInfoListBasic
    public class BenefitDetail{
        public Integer sequenceNumber{get;set;}
        public String description{get;set;}
        public Decimal amount{get;set;}
    }

    //added by Andy 20180727 for GetPlanInfoListBasic
    public class EligibleAge{
        public Integer MinAgeYear{get;set;}
        public Integer MinAgeDay{get;set;}
        public Integer MaxAgeYear{get;set;}
        public Integer MaxAgeDay{get;set;}
        public String RelationRoleCode{get;set;}
    }

    public class HealthGuard{
        public String dayClass{get;set;}
        public String maxDay{get;set;}
        public Decimal amountBilled{get;set;}
        public Decimal amountPayable{get;set;}
        public String benefitName{get;set;}
        public Decimal benefitLevel{get;set;}
        public String benefitLevelonString{get;set;}
    }

    /*
     * Class for GetPolicyPaymentBasic
     */
    public class PolicyPayment{
        public String renewalNoticeInd{get;set;}// Rancho_JOBR367_20240513 - update premium display
        //AM project coupon jack add
        public Decimal couponUsedAmt{get;set;}
        @AuraEnabled public List<Coupon> couponList{get;set;}

        // 20200610 - minghua - levyII
        public Decimal nextLevy{get;set;}
        public Decimal levyCurrentPremium{get;set;}
        public Decimal currentPremiumIncludeLevy{get;set;}
        @AuraEnabled public Decimal totalModalPremiumIncludeLevy{get;set;}
        public Boolean effectiveLevy{get;set;}

        // Policy
        public String policyNumber{get;set;}
        public String effDate{get;set;}               // Effective date / Coverage period from
        public Date effDateInDate{get;set;}
        public String termDate{get;set;}              // Cancel date / Coverage period to
        public Date termDateInDate{get;set;}
        public String paidToDate{get;set;}            // Paid to date
        @AuraEnabled public Date paidToDateInDate{get;set;}
        public String paymentAmt{get;set;}            // Modal premium
        public String paymentMode{get;set;}           // Payment mode description
        public String paymentModeCode{get;set;}         // Payment Mode Code
        @AuraEnabled public String paymentMethod{get;set;}         // Payment method description
        public String paymentMethodCode{get;set;}     // Payment method Code
        @AuraEnabled public Decimal modalPremium{get;set;}
        public Decimal lastModalPremium{get;set;}     // JR1797 - add last modal premium
        public Decimal totalModalPremium{get;set;}
        // Bank
        public String PayerName{get;set;}
        public String creditCardType{get;set;}        // Credit card type description
        public String creditCardExpDate{get;set;}     // Credit card expiry date
        @AuraEnabled public Date creditCardExpDateInDate{get;set;}
        @AuraEnabled public String accountNumber{get;set;}         // Account/Credit card number
        @AuraEnabled public String accountMaskedNumber{get;set;}   // JR1774 - Masked Account/Credit card number
        public String acctHolderName{get;set;}        // Account/Credit card holder name
        public String bankName{get;set;}              // Bank name
        @AuraEnabled public String CardType{get;set;}              // Card Type
        // Party
        @AuraEnabled public String fullName{get;set;}              // Full name
        public String ssnNumber{get;set;}             // SSN number
        public String firstName{get;set;}             // First Name
        public String middleName{get;set;}            // Middle Name
        public String lastName{get;set;}              // LastName
        //add test field for test by Nicole
        public Decimal annualPremium{get;set;}
        public String polDebitDay{get;set;}
        @AuraEnabled public String polDebitDayDisplay{get;set;}
        public Decimal polAdditionalFundContribution{get;set;}
        public String startDateofAutomaticPremiumPayment{get;set;}
        @AuraEnabled public Date startDateofAutomaticPremiumPaymentInDate{get;set;}
        public String endDateofAutomaticPremiumPayment{get;set;}
        @AuraEnabled public Date endDateofAutomaticPremiumPaymentInDate{get;set;}
        public Decimal sumInsured{get;set;}

        //Added by Nicole in Phase2
        @AuraEnabled public String LatestAutopayRejectDateandReason{get;set;}
        @AuraEnabled public String AutopayLimit{get;set;}
        @AuraEnabled public String CardHolderID{get;set;}

        //JR1783
        @AuraEnabled public List<Discount> discountList{get;set;}
        //JR1783

        //Zane SFDC 20200812
        @AuraEnabled public String CardHolderIDMasked{
            get{
                if(String.isNotBlank(CardHolderID)){
                    return CardHolderID.left(4).rightPad(CardHolderID.length(), '*');
                }
                return '';
            }
            set;
        }
        
        
        // BEGIN https://jira.express-scripts.com/browse/HKITSFDC-15
        // Elite 360 Migration - NCD
        public String nCDEligibility{get;set;}
        public String nCDUpdateDate{get;set;}
        public Boolean isNCDEligible {get; set;}
        // END https://jira.express-scripts.com/browse/HKITSFDC-15  

        
    }

    /*
     * Class for GetPolicyBillingListBasic
     * change by kit 2018/05/07 implement Comparable
     * Client portal:  add @AuraEnabled for lwc component - Zane 2021-01-11
     */
    public class PolicyBilling implements Comparable{
        // 20200610 - minghua - levyII
        @AuraEnabled
        public String outstandingLevyIndicator {get;set;}
        @AuraEnabled
        public Decimal totalPremiumIncludingLevy{get;set;}
        @AuraEnabled
        public Decimal levy{get;set;}
        @AuraEnabled
        public String policyNumber{get;set;}
        @AuraEnabled
        public String description{get;set;}            // Billing description
        @AuraEnabled
        public Decimal finActivityGrossAmt{get;set;}    // Billing amount
        @AuraEnabled
        public String finActivityDate{get;set;}        // Billing date
        @AuraEnabled
        public Date finActivityDateInDate{get;set;}
        @AuraEnabled
        public Decimal commissionAmt{get;set;}          // Broker commission amount
        @AuraEnabled
        public Decimal paymentAmt{get;set;}             // Settled amount
        @AuraEnabled
        public String paymentStatusDate{get;set;}      // Settled date
        @AuraEnabled
        public Date paymentStatusDateInDate{get;set;}
        @AuraEnabled
        public String payerName{get;set;}              // Payer name
        @AuraEnabled
        public String rejCode{get;set;}                // Reject reason code
        @AuraEnabled
        public String rejCodeDesc{get;set;}            // Reject reason description
        @AuraEnabled
        public String invoiceNumber{get;set;}          // Invoice number
        @AuraEnabled
        public String branchCode{get;set;}             // Branch code
        @AuraEnabled
        public String branchDesc{get;set;}             // Branch description
        @AuraEnabled
        public String currencyTypeCode{get;set;}       // Currency Code  e.g. 840
        @AuraEnabled
        public String currencyTypeDesc{get;set;}       // Currency description  e.g. USD
		//BEGIN HKITSFDC-148
        @AuraEnabled
        public String paymentDescription{get;set;}
        //END HKITSFDC-148
        //for Group
        @AuraEnabled
        public String issueDate{get;set;}
        @AuraEnabled
        public Date issueDateInDate{get;set;}
        @AuraEnabled
        public Decimal invoiceAmount{get;set;}
        //add test field for test by Nicole
        @AuraEnabled
        public Decimal automaticPremiumPayment{get;set;}
        @AuraEnabled
        public Decimal settledAmount{get;set;}
        @AuraEnabled
        public Decimal unsettleBalance{get;set;}

        //Added by Nicole in Phase2
        @AuraEnabled
        public String Collector{get;set;}
        @AuraEnabled
        public Date PayDate{get;set;}
        @AuraEnabled
        public String Status{get;set;}
        @AuraEnabled
        public String Period{get;set;}
        @AuraEnabled
        public Date BillingStartDate{get;set;}

        //add by kit to sort by finActivityDateInDate
        public Integer compareTo(Object ct){
            HttpCalloutVO.PolicyBilling obj = (HttpCalloutVO.PolicyBilling) ct;
            if(this.finActivityDateInDate != null && obj.finActivityDateInDate != null){
                if(this.finActivityDateInDate > obj.finActivityDateInDate){ return -1; }
                else if(this.finActivityDateInDate < obj.finActivityDateInDate){ return 1; }
                else{ return 0; }
            }else{
                if(this.finActivityDateInDate != null){ return 1;}
                else if (obj.finActivityDateInDate != null){ return -1; }
                else{ return 0; }
            }
        }

        // add by kermit to get the currencySymbol
        @AuraEnabled public String currencySymbol{
            get{
                if(String.isNotBlank(currencyTypeDesc)){
                    String[] temp = currencyTypeDesc.split('\\(');
                    if(temp.size() > 0){ return temp[0].trim(); }
                    else{ return ''; }
                }else{ return ''; }
            }
            set;
        }
    }

    /*
     * Class for GetPolicyFundListBasic
     */
    public class PolicyFund{
        public String policyNumber{get;set;}
        public Decimal accountValue{get;set;}           // Total fund value (USD)
        public Decimal netSurrValueAmt{get;set;}        // Surrender charge (USD)
        public Decimal surrenderChargeAmt{get;set;}     // Surrender value (USD)
        public Decimal totalCashValue{get;set;}         // Total cash value (USD)
        public Decimal totalInterimFundValue{get;set;}  // Total interim fund value (USD)
        public String valuationDate{get;set;}          // Valuation date
        public Date valuationDateInDate{get;set;}
        public Decimal maxFundWithdrawalAmt{get;set;}   // Max fund withdrawal amount (USD)
        public Decimal withdrawalCharge{get;set;}       // Incurred withdrawal charge (USD)
        public String fundAllocType{get;set;}          // Fund allocation type (S:single B:basic R:regular)

        //add by kit for CR Fund / Bonus Details for individual policy 2018/07/09
        public String CurrencyType{get;set;}
        public String TotalDeclaredBonus{get;set;}
        public List<BonusTransaction> bonusTransactionList{get;set;}
    }

    /*
     * Class for GetPolicyFundListHistBasic
     */
    public class PolicyFundHist implements Comparable{
        public String policyNumber{get;set;}
        public String productCode{get;set;}         // Fund code
        public String productFullName{get;set;}     // Fund name
        public Decimal unitValue{get;set;}           // Unit price (USD)
        public Decimal unitValueBuyRate{get;set;}    // Exchange rate (USD HKD)
        public Decimal payoutUnitValue{get;set;}     // Unit purchase
        public Decimal totValue{get;set;}            // Fund value (USD)
        public String initPurchaseDate{get;set;}    // Transaction date
        public Date initPurchaseDateInDate{get;set;}
        public String distRatioBasic{get;set;}      // Distribution Ratio (Base)
        public String distRatioRegular{get;set;}    // Distribution Ratio (Regular)
        public String distRatioSingle{get;set;}     // Distribution Ratio (Single)
        public Decimal totalHKDValue{get;set;}

        //Added by Nicole in Phase2
        public String policyProductCode{get;set;}
        public String coverageNumber{get;set;}
        public String transactionType{get;set;}
        public String valuationDate{get;set;}
        public Date valuationDateInDate{get;set;}
        public Decimal grossAmount{get;set;}
        public Decimal netAmount{get;set;}
        //End

        public Integer compareTo(Object ct){
            HttpCalloutVO.PolicyFundHist object2 = (HttpCalloutVO.PolicyFundHist)ct;
            if(this.initPurchaseDateInDate != null && object2.initPurchaseDateInDate != null){
                if(this.initPurchaseDateInDate > object2.initPurchaseDateInDate){ return -1; }
                else if(this.initPurchaseDateInDate < object2.initPurchaseDateInDate){ return 1; }
                else{ return 0; }
            }else{
                if(this.initPurchaseDateInDate != null){ return 1; }
                else if (object2.initPurchaseDateInDate != null){ return -1; }
                else{ return 0; }
            }
        }
    }

    /*
     * Class for GetPolicyAvailFundListBasic
     */
    public class PolicyAvailFund{
        public String policyNumber{get;set;}
        public String productCode{get;set;}         // Fund code
        public String productFullName{get;set;}     // Fund name
        public Decimal currNumberUnits{get;set;}     // Unit balance
        public Decimal unitValue{get;set;}           // Unit price (USD)
        public Decimal unitValueBuyRate{get;set;}    // Exchange rate (USD HKD)
        public Decimal totValue{get;set;}            // Fund value (USD)
        public String basicPlanPercent{get;set;}    // Basic Plan %
        public String regularAFCPercent{get;set;}   // Regular AFC %
        public String singleAFCPercent{get;set;}    // Single AFC %
        public Decimal basicPlanPercentInNumber{get;set;}    // Basic Plan %
        public Decimal regularAFCPercentInNumber{get;set;}   // Regular AFC %
        public Decimal singleAFCPercentInNumber{get;set;}    // Single AFC %
        public Decimal totalHKDValue{get;set;}
        public Decimal withdrawalValue{get;set;}       // Added by Linus 2020-Jun-24

        //junda add for plus profile
        public Decimal totalcurrNumberUnits{get;set;}
        //20210111 - Nicole - fund discontinued date
        public Date discontinuedDate{get;set;}
    }

    /*
     * Class for GetPolicyPersonCoverageBasic
     */
    public class PolicyPersonCoverage implements Comparable{
        public String renewalNoticeInd{get;set;}// Rancho_JOBR367_20240513 - update premium display
        public String partyTypeCode{get;set;}            // Product code
        public String govtID{get;set;}
        public String originatingObjectType{get;set;}
        public String relatedObjectType{get;set;}
        public String relationRoleCode{get;set;}
        public String indicatorCode{get;set;}
        @AuraEnabled
        public String planName{get;set;}                 // Benefit description
        //add by Andy Li for GOP 2020-05-26 start
        public String wardType{get;set;}
        //add by Andy Li for GOP 2020-05-26 end
        public String currentAmt{get;set;}               // Benefit amount
        public String policyNumber{get;set;}             // Product type description
        public Date policyEffectiveDate{get;set;}
        public Date policyIssueDate{get;set;}
        public String effectiveDate{get;set;}            // Effective date
        @AuraEnabled public Date effectiveDateInDate{get;set;}
        public String issueDate{get;set;}                // Issue date
        @AuraEnabled public Date issueDateInDate{get;set;}
        public String termDate{get;set;}                 // Termination date
        @AuraEnabled public Date termDateInDate{get;set;}
        public String maturityExpiryDate{get;set;}
        @AuraEnabled public Date maturityExpiryDateInDate{get;set;}
        public String policyProductCode{get;set;}        //
        public String productCode{get;set;}              //
        public String productName{get;set;}
        @AuraEnabled
        public String productType{get;set;}              // Product Type
        public String marketingName{get;set;}            // Marketing name
        public Decimal modalPremium{get;set;}            // Modal premium
        public Decimal annualPremium{get;set;}           // Annual premium
        public Decimal sumInsured{get;set;}              // Sum Insured
        @AuraEnabled public String insuredName{get;set;}
        public String insuredSSN{get;set;}
        @AuraEnabled
        public String benefitCode{get;set;}              // I: Benefit code G: Benefit detail item number
        public String benefitName{get;set;}              // I: Benefit description G: Benefit detail item description
        @AuraEnabled
        public String benefitDesc{get;set;}              // For Individual
        public String benefitAmount{get;set;}
        @AuraEnabled public Decimal benefitAmountInNumber{get;set;}
        public String coverageIndicator{get;set;}
        public String benefitLevel{get;set;}             // for Group
        public String benefitCodeDesc{get;set;}          // for Group
        public String benefitPlanName{get;set;}          // I: Product name  G: Benefit code descritpion
        @AuraEnabled public String benefitMarketingName{get;set;}     // I: Product marketing name  G: Benefit code descritpion
        public String businessCompanyCode{get;set;}
        //public String productName{get;set;}
        public String productMarketingName{get;set;}
        public String rateScale{get;set;}
        public String coverageNumber{get;set;}
        @AuraEnabled public String coverageStatus{get;set;}
        public String planTypeCode{get;set;}             // Plan Type Code
        public String planTypeDesc{get;set;}             // Plan Type Description
        @AuraEnabled
        public String planNo{get;set;}                   // Plan No
        public String benefitDetailItemNo{get;set;}       // Benefit Detail Item No
        @AuraEnabled
        public String benefitDetailItemDesc{get;set;}    // Benefit Detail Item Description
        @AuraEnabled
        public String benefitLevelDesc{get;set;}         // Benefit Detail Item Level Benefit Description
        public String planDescription{get;set;}          // Description indentiy the group of members of the plan
        @AuraEnabled
        public String benefitItemIdentity{get;set;}      // for details under the benefit codes (HOS,OPB),
        public String benefitItemDescDtl{get;set;}       // the detail description
        @AuraEnabled
        public String benefitItemCode{get;set;}           // Benefit Detail Item Code
        
        //START HKITSFDC-265
        @AuraEnabled
        public String planLevel{get;set;}
        @AuraEnabled
        public String AreaOfCover{get;set;}
        @AuraEnabled
        public String RoomType{get;set;}
        //END HKITSFDC-265

        public String currencySymbol{get;set;}
        public String currencyTypeCodeTC{get;set;}
        public String benefit{get;set;}                  // Benefit
        @AuraEnabled public Decimal deductibleAmount{get;set;}        // Deductible Amount
        public String deductibleType{get;set;}          // Deductible Type
        public Decimal loadingAmount{get;set;}
        public Decimal loadingPercentage{get;set;}
        public Decimal loadingAmountDuration{get;set;}
        public Decimal loadingPercentageDuration{get;set;}

        //for Group Result
        public String memberCertNo{get;set;}
        public String memberName{get;set;}
        //add for test BasePolicyDetailsPageVFP by Nicole
        @AuraEnabled public String additionalFundContributionAmount{get;set;}
        @AuraEnabled public Decimal additionalFundContributionAmountInNumber{get;set;}
        @AuraEnabled public String additionalFundContributionAnnualAmount{get;set;}
        @AuraEnabled public Decimal additionalFundContributionAnnualAmountInNumber{get;set;}

        public String relation{get;set;}         //Not used in BasePolicyDetailsPageVFP any more
        public String plan{get;set;}             //Not used in BasePolicyDetailsPageVFP any more
        public String memberEffDate{get;set;}    //Not used in BasePolicyDetailsPageVFP any more
        public Date memberEffDateInDate{get;set;}
        public String memberStatus{get;set;}     //Not used in BasePolicyDetailsPageVFP any more
        public String benefitType{get;set;}      //Not used in BasePolicyDetailsPageVFP any more
        public String lifeSumAssured{get;set;}   //Not used in BasePolicyDetailsPageVFP any more
        public String TPDSumAssured{get;set;}    //Not used in BasePolicyDetailsPageVFP any more
        public String ADandDSumAssured{get;set;} //Not used in BasePolicyDetailsPageVFP any more
        public String LTDSumAssured{get;set;}    //Not used in BasePolicyDetailsPageVFP any more
        public String CIBSumAssured{get;set;}    //Not used in BasePolicyDetailsPageVFP any more
        public String branch{get;set;}           //Not used in BasePolicyDetailsPageVFP any more
        public List<HttpCalloutVO.BenefitScheduleRemark> benefitScheduleRemarkList{get;set;} { benefitScheduleRemarkList = new List<HttpCalloutVO.BenefitScheduleRemark>(); }  //Added by Nicole in Phase2

        public String holdingID{get;set;}
        public String paymentMode{get;set;}
        public String paymentModeCode{get;set;}         // Payment Mode Code
        public Boolean isDisplay{get;set;}{ isDisplay = true;} // Display flag for hot fix
        public List<HttpCalloutVO.Exclusion> exclusionList{get;set;}
        public String sectionType{get;set;}
        public String benefitEnName{get;set;}// Rancho_JOBR382_20240730
        public Integer compareTo(Object ct){
            PolicyPersonCoverage that = (PolicyPersonCoverage) ct;
             //Begin HKITSFDC-47
            if(String.isNotBlank(this.indicatorCode) && String.isNotBlank(that.indicatorCode)){
                if(this.indicatorCode> that.indicatorCode){ return 1; }
                else if(this.indicatorCode< that.indicatorCode){ return -1; }
                else{ return 0; }
            }
            else if(String.isNotBlank(this.benefitEnName) && String.isNotBlank(that.benefitEnName)){
                if(this.benefitEnName> that.benefitEnName){ return 1; }
                else if(this.benefitEnName< that.benefitEnName){ return -1; }
                else{ return 0; }
            }
            //End HKITSFDC-47 , original sort by coverageNumner and benefitCode only
            else if(String.isNotBlank(this.coverageNumber) && this.coverageNumber.isNumeric()
                    && String.isNotBlank(that.coverageNumber) && that.coverageNumber.isNumeric()){
                Integer thisNo = Integer.valueOf(this.coverageNumber);
                Integer thatNo = Integer.valueOf(that.coverageNumber);
                if(thisNo > thatNo){ return 1; }
                else if(thisNo < thatNo){ return -1; }
                else{ return 0; }
            }
            else if(String.isNotBlank(this.benefitCode) && String.isNotBlank(that.benefitCode)){
                if(this.benefitCode > that.benefitCode){ return 1; }
                else if(this.benefitCode < that.benefitCode){ return -1; }
                else{ return 0; }
            } else { return 0; }
        }
        //JR1783
        @AuraEnabled public Decimal faceAmt{get;set;}
        //JR1783
    }

    public class BenefitScheduleRemark{
        public String BenefitScheduleRemarkItem{get;set;}
        public String BenefitScheduleRemarkDesc{get;set;}
    }

    public class Exclusion{
        @AuraEnabled public Integer ExclusionSeqNo{get;set;}
        @AuraEnabled public String ExclusionCode{get ; set;}
        @AuraEnabled public String ExclusionDesc{get;set;}
        @AuraEnabled public String planCode{get;set;}// Rancho_HKITSFDC352_20250825 - add plan code
    }

    /*efulfillment enhanced   start*/
    /*
     * Class for GetPolicyDocTypeList
     */
    public class PolicyDocType{
        @AuraEnabled
        public String policyNumber{get;set;}
        @AuraEnabled
        public String attachmentType{get;set;}
        @AuraEnabled
        public String fileName{get;set;}
        @AuraEnabled
        public String attachmentTypeCode{get;set;}
        @AuraEnabled
        public String attchmentPolNumber{get;set;} //policy number in attachment node. client portal JIRA-327
        @AuraEnabled public String description{get;set;}
        public String claimNo{get;set;}
        public String certNumber{get;set;}
        public String claimNumber{get;set;}
        @AuraEnabled
        public String attachmentKey{get;set;}
        public String documentLocation{get;set;}
        public String documentLocationTypeCode{get;set;}
        public String DocumentShortName{get;set;}
        public String followUpDateStr{get;set;}
        @AuraEnabled public String createdDateStr{get;set;}
        public String docCreatedYear{get{return string.isBlank(createdDateStr)?'': createdDateStr.substring( 0, 4 ); } set;}
        @AuraEnabled public string createdDateStrDisp{get{return createdDateStr;} set;}
        public String docPolicyYear{get;set;}// Rancho_HKITSFDC70_20240802 - initial year, only has value when doc regenerated
        public integer newPeriod = 6;
        @AuraEnabled public String status{get;set;}  //added by Connor CR-47
        public String resultCode{get;set;}  //added by Connor CR-47
        @AuraEnabled public String hiddenDateStr{get;set;}  //added by Connor CR-47
        @AuraEnabled public String hiddenBy{get;set;}  //added by Connor CR-47
        @AuraEnabled public String policyHolderName{get;set;}  //Premium Reminders search Connor LPCSC-12
        public String attId{get;set;}//MR-247 display policy doc attachment 

        public Date createdDateObj{
            get{
                if (string.isblank(createdDateStr) ) return null;
                string year = createdDateStr.substring( 0, 4 );
                string month = createdDateStr.substring( 5, 7 );
                string day = createdDateStr.substring( 8, 10 );
                Date dt = Date.newInstance( integer.valueof(year), integer.valueof(month),integer.valueof(day));
                return dt;
            }
            set;
        }
        public Boolean isNew{
            get{
                if ( string.isblank(createdDateStr) ) return false;
                string year = createdDateStr.substring( 0, 4 );
                string month = createdDateStr.substring( 5, 7 );
                string day = createdDateStr.substring( 8, 10 );
                Date dt = Date.newInstance( integer.valueof(year), integer.valueof(month),integer.valueof(day));
                if (string.isblank(followUpDateStr) && dt.addMonths(newPeriod)> Date.today()){ return true; }
                else{ return  false; }
            }
            set;
        }
        @AuraEnabled public Boolean isHidden{
            get{
                if (String.isNotBlank(status) && status == 'Y') {return true;}
                return false;
            }
            set;
        }
    }

    /*
     * Class for GetPolicyDoc
     */
    public class PolicyDoc{
        public String policyNumber{get;set;}
        public String attachmentType{get;set;}
        public String fileName{get;set;}
        public String attachmentData64Binary{get;set;} // Please use attBody to replace this, it will hit the limit of heap size
        public String mimeTypeTC{get;set;}
        public String mimeTypeTCNumber{get;set;}
        public String attachmentLocation{get;set;}
        public String attachmentHashValue{get;set;}

        public String certNumber{get;set;}
        public String claimNumber{get;set;}
        public String attachmentKey{get;set;}
        public blob attBody{get;set;}
    }
    /*efulfillment enhanced  end*/

    // 20200918 - junda add
    //     public class AttachmentList{
    //         public List<HttpCalloutVO.Attachment> attList {get;set;}
    //     }
    /*
     * Class for GetWorkDoc ,ReplyClaimPendingMemo
     */
    public class Attachment{
        public String description{get;set;}
        public String attachmentType{get;set;}
        public String attachmentData64Binary{get;set;}
        public String mimeType{get;set;}{mimeType = '';}
        public String mimeTypeTC{get;set;}
        public String attachmentLocation{get;set;}
        public String attachmentLocationCode{get;set;}
        public String fileName{get;set;}{fileName = '';}
        public String sequence{get;set;}
        public String attachmentHashValue{get;set;}
        public String fileExtension{get;set;}{fileExtension = '';}
        public blob fileBody{get;set;}
        public String CreatedDate{get;set;}
        public Id salesforceAttachmentId{get;set;}      //Id of Master record for query att body
        public String seqNo{get;set;} //David Zhang - 20190425 - Pull Doc
        public String documentId{get;set;}  //add by andy for TM UWmessgae
        public String signal{get;set;}// 20190827 - Appian Pull Doc JR
        public String attachmentKey{get;set;}// 20200918 - junda add
        public String creationTime{get;set;}// 20200918 - junda add
    }

    /*
     * Class for GetWorkPendingMemoMsg
     */
    public class Activity{
        public String activityDetails{get;set;}
        public String activityCode{get;set;}
        public String endDate{get;set;}
        public Date endDateInDate{get;set;}
        public String endTime{get;set;}
        public String attachment{get;set;}
        public String processID{get;set;}
        public String workType{get;set;}
        public String subWorkType{get;set;}
        public String pendingMemoId{get;set;}
        public String pendingQuestion{get;set;}
        public Date questionRaisedDate{get;set;}
        public String documentId{get;set;}
        public String requestType{get;set;}
        public String requestStatus{get;set;}
        public String policyNumber{get;set;}

        public String answer{get;set;}    //pendingResponse    //Added by Nicole in Phase2
        public String documentName{get;set;}        //Added by Nicole in Phase2
        public String pendingMemoStatus{get;set;}
        public String fileExtension{get;set;}{fileExtension = '';} //David Zhang - 190401 - Pending Memo Doc Async
    }

    /*
     * Class for GetWorkStatus
     */
    public class WorkStatus implements Comparable{
        @AuraEnabled public String workType{get;set;}
        @AuraEnabled public String workItem{get;set;}
        public String subWorkType{get;set;}
        public String polDetailList{get;set;}
        public String processID{get;set;}
        //add test fields for test by Nicole
        public String workStatus{get;set;} //is not used in policy detail any more
        public String receivedDate{get;set;} //is not used in policy detail any more
        public Date receivedDateInDate{get;set;}
        public String lastUpdateDate{get;set;} //is not used in policy detail any more
        public Date lastUpdateDateInDate{get;set;}
        @AuraEnabled public String requestId{get;set;}
        @AuraEnabled public String policyNumber{get;set;}
        @AuraEnabled public String personInsured{get;set;}
        public String policyHolder{get;set;}
        public String policyHolderId{get;set;}
        @AuraEnabled public DateTime submittedDateTime{get;set;}
        public String productType{get;set;}
        @AuraEnabled public DateTime statusUpdatedDateTime{get;set;}
        @AuraEnabled public String requestStatus{get;set;}
        @AuraEnabled public String salesForceWorkType{get;set;}
        @AuraEnabled public String salesForceWorkTypeTC{get;set;} // Rancho_HKITSFDC193_20250409 - add work item
        public String brokerComapnyName{get;set;}// for BD New Business Detail
        public String individualConsultantName{get;set;}// for BD New Business Detail
        public String UWRequestStatus{get;set;} // for BD New Business Detail
        @AuraEnabled public String UWStage{get;set;} // for BD New Business Detail
        //Added by Nicole in Phase2
        @AuraEnabled public String sourceType{get;set;}
        public String sourcePortal{get;set;}
        @AuraEnabled public Date turnaroundDate{get;set;}
        @AuraEnabled public String productName{get;set;}
        public String brokerRegistrationNumber{get;set;}
        @AuraEnabled public String requestType{get;set;}
        public String overallPendingMemoStatus{get;set;}
        public String caseID{get;set;}
        public String caseStatus{get;set;}
        public String caseWorkType{get;set;}
        public String caseWorkItem{get;set;}
        public String caseSalesForceWorkType{get;set;}
        //Added by Nicole in Phase2 End

        // appianRequestURL for Ref#3 9.1.2.12 Case ID, Request ID from Appian are linked to Appian designed page
        @AuraEnabled public String appianRequestURL{get;set;} //added by Zaihong 20180423

        public Integer compareTo(Object ws){
            HttpCalloutVO.WorkStatus workStatus2 = (HttpCalloutVO.WorkStatus)ws;
            if(this.submittedDateTime != null && workStatus2.submittedDateTime != null){
                if(this.submittedDateTime > workStatus2.submittedDateTime){ return -1; }
                else if(this.submittedDateTime < workStatus2.submittedDateTime){ return 1; }
                else{ return 0; }
            } else{
                if(this.submittedDateTime != null){ return 1; }
                else if (workStatus2.submittedDateTime != null){ return -1; }
                else{ return 0; }
            }
        }
    }

    /*
     * Class for SubmitWorkRequest
     */
    public class WorkRequest{
        public Blob fileBody{get;set;}                  // Attachment Data
        public String mimeTypeCode{get;set;}            // MIME Type Type Code
        public String mimeTypeDescription{get;set;}     // MIME Type Type Code description
        public String fileName{get;set;}                // File name
        public String fileExtension{get;set;}           // File extension
        public String requestType{get;set;}             // Request type
        public String signal{get;set;}                  // Signal
        public String documentId{get;set;}              // Document id
        public String requestId{get;set;}               // Request id
        public String workType{get;set;}                // Work Type
        public String subWorkType{get;set;}             // Sub Work Type
        public String policyNumberList{get;set;}        // Policy Number
        public Boolean isBrokerSubmit{get;set;}         // BrokerSubmitInd
        public String salesForceWorkType{get;set;}      // SalesForceWorkType
        public String initialPaymentMethod{get;set;}    // InitialPaymentMethod
        public String subsequentPayment{get;set;}       // SubsequentPayment
        public String underwritingDecision{get;set;}    // UnderwritingDecision
        public String processID{get;set;}               // just use to store the result
        public String appealComment{get;set;}
        public String appealRequest{get;set;}
        public Id salesforceAttachmentId{get;set;}      //Id of Master record for query att body
        public Boolean postDeduplicationInd{get;set;}  // add by Zaihong 20180705 for TM submit policy transaction
        public Boolean sideOrderInd{get;set;}  // add by Zaihong 20180705 for TM submit policy transaction
        public String sourcePortal{get;set;} //add by Andy 20180830 for submit work request
        public String ReasonForPIAgeOver18{get;set;} /* add by Jack on 2021-12-03 for project: JR1829 */
        public String OtherReasonForPIAgeOver18{get;set;} /* add by Jack on 2021-12-03 for project: JR1829 */

        public Id eSalesTxId{get;set;}
        // add by David 31/10/2017 for ThirdPartyPayment CR start
        public String pendingMemoId{get;set;}           // pending memo id
        // add by David 31/10/2017 for ThirdPartyPayment CR start
        public List<HttpCalloutVO.Attachment> AttachmentList{get;set;}

        //add by jack for policy replacement
        public String customerDecisionPR{get;set;}       
        //add by bob for Policy Change
        public String pNSRole{get;set;}
        public String pNSRecordType{get;set;}
        public String pNSFirstName{get;set;}
        public Date pNSDob{get;set;}
        public String pNSGovID{get;set;}
        public String pNSPHRelationship{get;set;}
        //end
        public String resultCode{get;set;}//SPS-667 jack add

        //add by zane for policy pdf 2022/09/20 start
        public String policyHolder{get;set;}
        public String policyNoList{get;set;}
        public String personInsuredList{get;set;}
        //add by zane for policy pdf 2022/09/20 end
    }
    
    /*
     * add 20201023 Bob
     * Class for SubmitPolicyNameScreening
     */
    public class SubmitPolicyNameScreeningRequest{
        public String holdingTypeCode{get;set;}
        public String polNumber{get;set;}
        public String pNSRecordID{get;set;}
        public Date pNSLogDate{get;set;}
        public String pNSLogBy{get;set;}
        public String pNSSourceID{get;set;}
        public String pNSRole{get;set;}
        public String pNSRecordType{get;set;}
        public String pNSFirstName{get;set;}
        public String lastName{get;set;}
        public String fullName{get;set;}
        public String gender{get;set;}
        public Date dateOfBirth{get;set;}
        public String govID{get;set;}
        public String pHRelationship{get;set;}
        public String policyHolderName{get;set;}
        public Decimal paymentAmountUSD{get;set;}
        public Decimal paymentAmountHKD{get;set;}
        public String paymentMethod{get;set;}
        public String paymentRefNo{get;set;}
        public Date paymentDate{get;set;}
        public String address1{get;set;}
        public String address2{get;set;}
        public String address3{get;set;}
        public String city{get;set;}
        public String stateProvince{get;set;}
        public String postalCode{get;set;}
        public String country{get;set;}
        public String comment1{get;set;}
        public String comment2{get;set;}
        public String status{get;set;}
        public List<HttpCalloutVO.Attachment> AttachmentList{get;set;}
        public String processID{get;set;}
        public Id salesforceAttachmentId{get;set;}
    }

    /*
     * Class for Request Message to ReplyWorkPendingMemo
     */
    public class WorkPendingMemoReply{
        public String replyContent{get;set;}        // Pending memo reply
        public String pendingMemoId{get;set;}       // Pending memo id
        public String replyDate{get;set;}           // Reply date
        public Date replyDateInDate{get;set;}
        public String replyTime{get;set;}           // Reply time
        public Blob fileBody{get;set;}              // Attachment Data
        public String mimeTypeCode{get;set;}        // MIME Type Type Code
        public String mimeTypeDescription{get;set;} // MIME Type Type Code description
        public String fileName{get;set;}            // File name
        public String fileExtension{get;set;}       // File extension
        public String signal{get;set;}              // Signal
        public String documentId{get;set;}          // Document id
        public String requestId{get;set;}           // Request id
        public String requestType{get;set;}         // Request type
        public String workType{get;set;}            // Work Type
        public String subWorkType{get;set;}         // Sub Work Type
        public String policyNumberList{get;set;}    // Policy Number
        public Id salesforceAttachmentId{get;set;}      //Id of Master record for query att body
        public String processID{get;set;}           // just use to store the result
    }

    /*
     * Class for SetNBComplete, SetNBDropOff
     */
    public class NBResult{
        public String transactionId{get;set;}
        public String statusCode{get;set;}
        // for NBSummary
        public Boolean isSuccess{get;set;}{isSuccess = false;}
        public String errorMsg{get;set;}
    }

    /*
     * Class for Transfer Criteria to setNBComplete
     */
    public class NBCriteria{
        public String resCountry{get;set;}/* add by Jack on 2021-12-22 for project: IA AML nationality mandatory */
        public Boolean newAccountNumberInd{get;set;} // 20200717 - minghua - SF Modeling
        public String polNumber{get;set;}
        public String transId{get;set;}
        public String applicantNumber{get;set;}
        public String planType{get;set;}
        public String birthDate{get;set;}
        public String birthPlace{get;set;}// Rancho_IA_AML_Inspection_20211005
        public String smokeInd{get;set;}
        public String productCode{get;set;}
        public String productPremium{get;set;} // add by Jason Guo 20180608
        public String rateScale{get;set;}
        public String sumInsured{get;set;}
        public String loginId{get;set;}//add by lihao group govitId
        public String rider1{get;set;}
        public String riderPremium1{get;set;} // add by Jason Guo 20180608
        public String riderRateScale1{get;set;}
        public String rider2{get;set;}
        public String riderPremium2{get;set;}
        public String riderRateScale2{get;set;}
        public String rider3{get;set;}
        public String riderPremium3{get;set;}
        public String riderRateScale3{get;set;}
        public String rider4{get;set;}
        public String riderPremium4{get;set;}
        public String riderRateScale4{get;set;}
        public String rider5{get;set;}
        public String riderPremium5{get;set;}
        public String riderRateScale5{get;set;}
        public String rider6{get;set;}
        public String riderPremium6{get;set;}
        public String riderRateScale6{get;set;}
        //Combo: maybe has 7 riders
        public String rider7{get;set;}
        public String riderPremium7{get;set;}
        public String riderRateScale7{get;set;}       
        public String campaignCode{get;set;}

        public String quoteId{get;set;}
        public String title{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String maritalStatus{get;set;}
        public String gender{get;set;}
        public String relationship{get;set;}
        public String ssnNumber{get;set;}
        public String emailAddress{get;set;}
        public String phoneNumber{get;set;}

        public String resAddrLine1{get;set;}
        public String resAddrLine2{get;set;}
        public String resAddrLine3{get;set;}
        public String resAddrLine4{get;set;}
        //Nationality & Country of Residence CR
        public String resAddrLine4Code{get;set;}
        public String nationality{get;set;}
        public String nationalityCode{get;set;}
        //Nationality & Country of Residence CR End

        public String line1{get;set;}
        public String line2{get;set;}
        public String line3{get;set;}
        public String line4{get;set;}
        //new add at 14/04/2017
        public String permAddrLine1{get;set;}
        public String permAddrLine2{get;set;}
        public String permAddrLine3{get;set;}
        public String permAddrLine4{get;set;}
        public String emplAddrLine1{get;set;}
        public String emplAddrLine2{get;set;}
        public String emplAddrLine3{get;set;}
        public String emplAddrLine4{get;set;}
        //end add at 14/04/2017
        public String height{get;set;}
        public String weight{get;set;}
        public String fcCode{get;set;}
        public String companyCode{get;set;}
        public String jobTitle{get;set;}
        public String privacyStatementInd{get;set;}
        public String optOutInd{get;set;}
        //add discount code fields
        public String discountCode1{get;set;}
        public String discountCode2{get;set;}
        public String policyProduct{get;set;}
        public String BenefitLevel{get;set;}
        public String loadingPremiumRate{get;set;}
        public String uwPreUWId{get;set;}
        public String uwPreUWResult{get;set;}

        public String uwFullUWId{get;set;}
        public String uwFullUWResult{get;set;}
        public String fullUWProductCode{get;set;}
        public String uwFullUWRiskType{get;set;}
        public String paymentMode{get;set;}
        public String paymentModeCode{get;set;}         // Payment Mode Code
        public String paymentStatusCode{get;set;}
        public String transactionVpcCode{get;set;}
        public String payAmount{get;set;}
        public String transactionDate{get;set;}
        public String transactionTime{get;set;}
        public String dropOffPoint{get;set;}
        public String preferContactTime{get;set;}

        public String uwOverallUWResult{get;set;}
        public String uwBasicProductResult{get;set;}
        public String uwRiderResult1{get;set;}
        public String uwRiderResult2{get;set;}
        public String uwRiderResult3{get;set;}
        public String uwRiderResult4{get;set;}
        public String uwRiderResult5{get;set;}
        public String uwRiderResult6{get;set;}
        //Combo: maybe has 7 riders
        public String uwRiderResult7{get;set;}
        // Added by IBM minglei added 4filds to backend system 20180607 start
        public String LHBPolicyNo{get;set;}
        public String LHBCertificateNo{get;set;} //Added by Andy 2019-04-12
        public String LHBBrokerCode{get;set;} //broker company code,Added by Andy 2019-04-12
        public String LHBAgentCode{get;set;}
        public String LHBEffeDate{get;set;}
        public String LHBTermDate{get;set;}
        // Added by IBM minglei added 4filds to backend system 20180607 end
        public List<HttpCalloutVO.NBPolicyHolder> policyHolderList{get;set;}
        public List<HttpCalloutVO.BeneficiaryOwner> beneficiaryOwnerList{get;set;}
        public List<HttpCalloutVO.NBFullUWRiskResult> fullUWRiskList{get;set;}
        public List<HttpCalloutVO.NBFullUWProductLoadingResult> fullUWProductLoadingResultList{get;set;}

        //new added by TM Stream
        public String policyStatus{get;set;} // 1 - GA; 4 - Auto accept; 5 - Auto reject; 6 - Refer
        public Date policyEffDate{get;set;} // policy effective date
        public String productLicense{get;set;}
        public String IDType{get;set;}
        public String corrAddrLine1{get;set;} // Correspondence address line 1, To SLP only, and eligible ="DP"
        public String corrAddrLine2{get;set;}
        public String corrAddrLine3{get;set;}
        public String corrAddrLine4{get;set;}
        public String placeOfRes{get;set;} //Add by Manuel for VHIS products
        public String eligible{get;set;}
        public String income{get;set;}
        public String occupation{get;set;}
        public String billFreq{get;set;} // Billing Frequency
        public String billMethod{get;set;}
        public String policyRef{get;set;} // Existing MM policy number, or free text input during policy creation.
        public String bankCodeOrCreditCardCollectorID{get;set;} // Bank account / credit card collector ID
        public String accountNumber{get;set;}
        public Date creditCardExpiryDate{get;set;}
        public String policyCurrency{get;set;}
        public Date initialBillDate{get;set;}
        public String masterPolicy{get;set;}
        public String relationshipOfPolicy{get;set;}
        public String policyPremium{get;set;}
        public Boolean AMLHighRiskInd{get;set;}
        public String exclusion{get;set;}
        public String medicalLoading{get;set;}
        public String loadingDuration{get;set;}
        public String PayType{get;set;} // 70 for credit card, 20 for bank, 30 for cheque
        public HttpCalloutVO.NBProspect prospect{get;set;}
        Public List<HttpCalloutVO.Beneficiary> beneficiaryList{get;set;}{beneficiaryList = new List<HttpCalloutVO.Beneficiary>();}
        //new added by TM Stream
        public String clientDecision{get;set;}//add by kermit 20190718 for JR1727
        public Date appDate{get;set;}//add by jack for policy replacement
        public HttpCalloutVO.NBAssessment assessment {get;set;}//GL31 jack add
        
        //Wellness CI
        public String refundDiscountCode{get;set;}
        public String refundPolicyRef{get;set;}
        //Wellness CI
        
        //AM project jack add 
        // public String AMMembershipNum{get;set;}
        // public String AMMembershipFirstName{get;set;}
        // public String AMMembershipLastName{get;set;}
        public Membership membership{get;set;}

        //AM project coupon jack add
        public List<Coupon> couponList{get;set;}
    }
    //GL31 jack add
    public class NBAssessment{
        public String Q1A1{get;set;}
        public String Q1A2{get;set;}
        public String Q1A3{get;set;}
        public String Q1A4{get;set;}
        public String Q2A1{get;set;}
        public String Q2A2{get;set;}
        public String SubmissionDate{get;set;}
    }
    //GL31 jack add
    public class NBProspect{
        public String runningNumber{get;set;}
        public String prospectID{get;set;}
        public String IQID{get;set;}
        public String activity{get;set;}
        public String supervisorID{get;set;}
        public String agentID{get;set;}
        //public Date callStartDate{get;set;}
        public String callStartTime{get;set;}
        //public Date callEndDate{get;set;}
        public String callEndTime{get;set;}
        public String callID{get;set;}
        public String campaignID{get;set;} // abandon
        public String IPASCampaignCode{get;set;}
        public String callListID{get;set;}
        public Date callListStartDate{get;set;}
        public Date callListEndDate{get;set;}
        public String sponsorCode{get;set;}
        public String channelCode{get;set;}
        public String campaignType{get;set;}
        public String remark1{get;set;}
        public String remark2{get;set;}
        public String remark3{get;set;}
        public String remark4{get;set;}
        public String remark5{get;set;}
        public Date createDate{get;set;}
        public String optOutFlag{get;set;}
        public String QuotePlan1{get;set;}
        public String QuotePlan2{get;set;}
        public String QuotePlan3{get;set;}
        public String QuotePlan4{get;set;}
        public Date optOutDate{get;set;}
    }

    /*
     * Sub Class for Transfer Criteria to setNBComplete
     */
    public class NBFullUWRiskResult{
        public String fullUWCode{get;set;}
        public String fullUWPlan{get;set;}
        public String fullUWType{get;set;}
        public String fullUWDescription{get;set;}
        public String fullUWDeclineInd{get;set;} //Add by Manuel for VHIS products
    }

    /*
     * Sub Class for Transfer Criteria to setNBComplete
     */
    public class NBFullUWProductLoadingResult{
        public String fullUWProductCode{get;set;}
        public String fullUWLoadingType{get;set;}
        public String fullUWLoadingValue{get;set;}
        public String fullUWLoadingDuration{get;set;}
    }

    /*
     * Sub Class for Transfer Criteria to setNBComplete
     */
    public class NBPolicyHolder{
        public String planType{get;set;}
        public String birthDate{get;set;}
        public String gender{get;set;}
        public String smokeInd{get;set;}
        public String title{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String maritalStatus{get;set;}
        public String ssnNumber{get;set;}
        public String emailAddress{get;set;}
        public String phoneNumber{get;set;}
        public String nationality{get;set;}
        public String line1{get;set;}
        public String line2{get;set;}
        public String line3{get;set;}
        public String line4{get;set;}
        public String loginId{get;set;}//add by lihao group govitId
        public String resAddrLine1{get;set;}
        public String resAddrLine2{get;set;}
        public String resAddrLine3{get;set;}
        public String resAddrLine4{get;set;}
        public String resAddrLine4Code{get;set;}
        //Nationality & Country of Residence CR
        public String line4Code{get;set;}
        public String nationalityCode{get;set;}
        //Nationality & Country of Residence CR End
        public String permAddrLine1{get;set;}
        public String permAddrLine2{get;set;}
        public String permAddrLine3{get;set;}
        public String permAddrLine4{get;set;}
        public String emplAddrLine1{get;set;}
        public String emplAddrLine2{get;set;}
        public String emplAddrLine3{get;set;}
        public String emplAddrLine4{get;set;}

        //new added by TM Stream
        public String chineseName{get;set;}
        public String IDType{get;set;}
        public Date IDExpiryDate{get;set;}
        public String birthPlace{get;set;}
        public String homePhoneNumber{get;set;}
        public String officePhoneNumber{get;set;}
        public String mobilePhoneNumber{get;set;}
        public String resCountry{get;set;} // Residential address country
        public String permCountry{get;set;} // Permanent address country
        public String corrAddrLine1{get;set;} // Correspondence address line 1
        public String corrAddrLine2{get;set;}
        public String corrAddrLine3{get;set;}
        public String corrAddrLine4{get;set;}
        public String corrCountry{get;set;} // Correspondence address country
        public String taxNumber1{get;set;}
        public String taxCountry1{get;set;}
        public String taxNumber2{get;set;}
        public String taxCountry2{get;set;}
        public String taxNumber3{get;set;}
        public String taxCountry3{get;set;}

        //new added for AML
        public String businessNature{get;set;}
        public String sourceOfFund{get;set;}
        public String sourceOfFundOther{get;set;}
        public String meansOfIncome{get;set;}
        public String meansOfIncomeOther{get;set;}
        public String position{get;set;}
        public String companyName{get;set;}
        public String companyCountry{get;set;}
        public String educationLevel{get;set;}
        public String educationLevelOther{get;set;}
        //new added by TM Stream
        //AM project jack add
        public Membership membership{get;set;} 
    }

    /*
     * Sub Class for Transfer Criteria to setNBComplete
     */
    public class BeneficiaryOwner{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String ssnNumber{get;set;}
        public String gender{get;set;}
        public Date birthDate{get;set;}
        public String relationship{get;set;}
        public String split{get;set;}
    }

    /*
     * Class for Transfer Criteria to setNBSummary
     */
    public class NBSummary{
        public String TransDate{get;set;}
        public String TransId{get;set;}
        public String PolNumber{get;set;}
        public String ApplicantNumber{get;set;}
        public String CompanyCode{get;set;}
        public String CompanyName{get;set;}
        public String AgentCode{get;set;}
        public String AgentLastName{get;set;}
        public String AgentFirstName{get;set;}
        public String HolderSSNNumber{get;set;}
        public String HolderLastName{get;set;}
        public String HolderFirstName{get;set;}
        public String InsuredSSNNumber{get;set;}
        public String InsuredLastName{get;set;}
        public String InsuredFirstName{get;set;}
        public String ProductCode{get;set;}
        public String ProductName{get;set;}
        public String PlanLevelDesc{get;set;}
        public String CoverageLevelDesc{get;set;}
        public String DeductibleLevelDesc{get;set;}
        public Decimal DiscountPremium{get;set;}
        public Decimal DiscountAnnualPremium{get;set;}
        public String PaymentModeDesc{get;set;}
        public Decimal SumInsured{get;set;}
        public String UWPreUWId{get;set;}
        public String UWPreUWResult{get;set;}
        public String UWFullUWId{get;set;}
        public String UWFullUWResult{get;set;}
    }

    /*
     * Class for SendSMS - Added by In-gage for SendSMS functionality
     */
    public Class SMSRequest{
        public String AreaCode{get;set;}
        public String DialNumber{get;set;}
        public String MessageContent{get;set;}
        public Boolean isSuccess{get;set;}
    }

    /*
     * Class for GetClinicVisitCount
     */
    public class ClinicVisit{
        public String policyNumber{get;set;}                // Policy number
        public String certNumber{get;set;}                  // Certificate number
        public String memberName{get;set;}                  // Member name
        public String memberStatusDescription{get;set;}     // Member status description
        public String planTypeCode{get;set;}
        public String planTypeDescription{get;set;}
        @AuraEnabled
        public String planNumber{get;set;}                  // Plan number

        //Updated by Nicole refer Digital WS XML Specification v1.17.xlsx satrt
        //Result list addded fot Customer and Broker Portal
        public List<BenefitCategory> benefitCategoryList{get;set;}

        //Changed to protect CS not be affected
        //public List<BenefitDetailItem> benefitList{get;set;}
        //public List<CombinedBenefit> combinedBenefitList{get;set;}
        public List<BenefitDetailItem> BenefitList{
            get{
                List<BenefitDetailItem> benefitList = new List<BenefitDetailItem>();
                if(benefitCategoryList!=null){
                    for(BenefitCategory benefitCategory : benefitCategoryList){
                        for(BenefitDetailItem benefit : benefitCategory.benefitList){
                            if(benefit.IsCombinedBenefit==null || (benefit.IsCombinedBenefit!=null && !benefit.IsCombinedBenefit)) benefitList.add(benefit);
                        }
                    }
                }
                return benefitList;
            }
            set;
        }
        public List<CombinedBenefit> CombinedBenefitList{
            get{
                List<CombinedBenefit> combinedBenefitList = new List<CombinedBenefit>();
                if(benefitCategoryList!=null){
                    for(BenefitCategory benefitCategory : benefitCategoryList){
                        for(BenefitDetailItem benefit : benefitCategory.benefitList){
                            if(benefit.IsCombinedBenefit!=null && benefit.IsCombinedBenefit && benefit.IsSummary!=null && benefit.IsSummary){
                                CombinedBenefit combinedBenefit = new CombinedBenefit();
                                combinedBenefit.sequenceNumber = benefit.sequenceNumber;
                                combinedBenefit.overallOutpatientMaximumNo = benefit.maxNoofVisitPerYear;
                                combinedBenefit.overallOutpatientMaximumNoStr = benefit.maxNoofVisitPerYearStr;
                                combinedBenefit.totalVisitedCount = benefit.visitedCount;
                                combinedBenefit.benefitItemCodeList = benefit.benefitDetailItemCode;
                                combinedBenefit.benefitSectionCode = benefit.benefitSectionCode;
                                combinedBenefit.networkType = benefit.networkType;
                                combinedBenefit.benefitVisitBalance = Integer.Valueof(benefit.visitBalance);
                                combinedBenefit.benefitMaxAmt = benefit.benefitMaxAmt;
                                combinedBenefit.benefitPaidAmt = benefit.benefitPaidAmt;
                                combinedBenefit.benefitAmtBalance = benefit.benefitAmtBalance;
                                combinedBenefit.benefitItemDescList = benefit.benefitDetailItemDescription;
                                combinedBenefit.totalVisitBalance = Integer.Valueof(benefit.visitBalance);
                                combinedBenefit.allMaxVisit = benefit.maxNoofVisitPerYear;
                                combinedBenefitList.add(combinedBenefit);
                            }
                        }
                    }
                }
                return combinedBenefitList;
            }
            set;
        }
        //Changed by Nicole refer Digital WS XML Specification v1.17.xlsx end
    }

    /*
     * Sub Class of GetClinicVisitCount
     */
    public class BenefitCategory{
        public String categoryCode{get;set;}
        public String categoryDescription{get;set;}
        public String sequence{get;set;}
        public List<BenefitDetailItem> benefitList{get;set;}
    }

    /*
     * Sub Class of PolicyEmployee
     */
    public class BenefitDetailItem implements Comparable{
        public String sequenceNumber{get;set;}                    // Sequence number
        public String benefitDetailItemCode{get;set;}            // Benefit Detail Item Code
        public String benefitDetailItemDescription{get;set;}     // Benefit Detail Item Description
        public Integer maxNoofVisitPerYear{get;set;}              // Max. no. of visit per year
        public String maxNoofVisitPerYearStr{get;set;}              // Max. no. of visit per year String type by caden
        public Integer visitedCount{get;set;}                     // Visited count
        public String visitBalance{get;set;}                     // Visit balance add by caden

        //add test fields for test by Nicole
        public String benefitType{get;set;}
        public Integer benefitVisitBalance{get;set;}  //Total visit balance

        //start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
        public String benefitSectionCode{get;set;}  //Benefit Section Code (OPB = Out-patient Benefits, HOS = Hospitalization & Surgical Benefits)
        public String networkType{get;set;}         //Network Type (Non-Network,Network,Overall,<Blank> = Not care)
        public Decimal benefitMaxAmt{get;set;}     //Total benefit amount
        public Decimal benefitPaidAmt{get;set;}     // Total benefit paid amount
        public Decimal benefitAmtBalance{get;set;}  //Total benefit amount balance
        //end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx

        public List<String> RemarkList{get;set;}
        public Boolean IsCombinedBenefit{get;set;}
        public Boolean IsSummary{get;set;}

        //add by Raistlin sort by IsCombinedBenefit
        public Integer compareTo(Object compareItem){
            BenefitDetailItem compare = (BenefitDetailItem)compareItem;
            if(null != this.IsCombinedBenefit){
                if(this.IsCombinedBenefit == false && compare.IsCombinedBenefit == true){ return -1; }
                else if(this.IsCombinedBenefit == true && compare.IsCombinedBenefit == false){ return 1; }
                else{  return 0; }
            } else{ return 0; }
        }
    }

    /*
     * Sub Class of PolicyEmployee
     */
    public class CombinedBenefit{
        public String sequenceNumber{get;set;}                    // Sequence number
        public Integer overallOutpatientMaximumNo{get;set;}        // Overall Outpatient Maximum no. of Visit per Policy Year
        public String overallOutpatientMaximumNoStr{get;set;}        // Overall Outpatient Maximum no. of Visit per Policy Year String type by caden
        public Integer totalVisitedCount{get;set;}                 // Total Visited count
        public String benefitItemCodeList{get;set;}               // Benefit Detail Item Codes

        //add test fields for test by Nicole
        public Integer totalRemainingVisitBalance{get;set;}
        public String totalRemainingVisitBalanceStr{get;set;}

        //start - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
        public String benefitSectionCode{get;set;}  //Benefit Section Code (OPB = Out-patient Benefits, HOS = Hospitalization & Surgical Benefits)
        public String networkType{get;set;}         //Network Type (Non-Network,Network,Overall,<Blank> = Not care)
        public Integer benefitVisitBalance{get;set;}  //Total visit balance
        public Decimal benefitMaxAmt{get;set;}     //Total benefit amount
        public Decimal benefitPaidAmt{get;set;}     // Total benefit paid amount
        public Decimal benefitAmtBalance{get;set;}  //Total benefit amount balance
        //end - added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx

        //Add by Manuel that supplement the fields of GetClinicVisitCount response
        public String benefitItemDescList{get;set;}
        public Integer totalVisitBalance{get;set;}
        public Integer allMaxVisit{get;set;}
        public List<String> RemarkList{get;set;}
    }

    //Add by Manuel that create a class that union two classes
    public class UnionStructBenefitCombined{
        public BenefitDetailItem usBenefitDetailItem{get;set;}
        public CombinedBenefit usCombinedBenefit{get;set;}
    }

    /*
     * Class for GetCompanyList, SetCompanyLink
     */
    public class Company{
        public String companyCode{get;set;}
        public String companyName{get;set;}
        public String companyType{get;set;}
    }

    /*
     * Class for ValidateUser, RegisterUser, CreateUser, UpdateUser
     */
    public class User{
        public String password{get;set;}
        public String confirmPassword{get;set;}
        // Rancho_Neat_20221129 - health combo campaign
        public String parentPromoCode{get;set;} // partner level promote code
        public String childPromoCode{get;set;} // customer level promote code
        //add Bob 20210629 SMT-61
        public String marketingOpt{get;set;}
        public String nationality{get;set;}
        public String residency{get;set;}
        //END
        public String hkId{get;set;}                // XmlElement(name = "HKId")
        public String roleId{get;set;}              // XmlElement(name = "RoleId")
        public String loginId{get;set;}             // XmlElement(name = "LoginId")
        public String dob{get;set;}                 // XmlElement(name = "DOB")
        public String statusCode{get;set;}          // XmlElement(name = "StatusCode")
        public String companyCode{get;set;}         // XmlElement(name = "CompanyCode")
        public String linkedCompanyCode{get;set;}   // XmlElement(name = "LinkedCompanyCode")
        public String companyName{get;set;}         // XmlElement(name = "CompanyName")
        public String companyType{get;set;}         // XmlElement(name = "CompanyType")
        public String gisCompanyCode{get;set;}      // XmlElement(name = "GISCompanyCode")

        public String customerKey{get;set;}         // XmlElement(name = "CustomerKey")
        public String partner{get;set;}             // XmlElement(name = "Partner")
        public String function{get;set;}            // XmlElement (name = "Function")
        public String isNew{get;set;}               // XmlElement(name = "IsNew")
        public String isCignaCustomer{get;set;}      // XmlElement(name = "IsCignaCustomer")
        public String partnerOTPNumber{get;set;}    // XmlElement(name = "PartnerOTPNumber")
        public String gender{get;set;}              // XmlElement(name = "Gender")
        
        public String firstName{get;set;}           // XmlElement(name = "FirstName")
        public String lastName{get;set;}            // XmlElement(name = "LastName")
        public String phoneNumber{get;set;}         // XmlElement(name = "PhoneNumber")
        public String emailAddress{get;set;}        // XmlElement(name = "EmailAddress")
        public String agentCode{get;set;}           // XmlElement(name = "AgentCode")
        public String subAgentCode{get;set;}        // XmlElement(name = "subAgentCode")//CR-47 Tovid subAgentCode
        public String action{get;set;}              // XmlElement(name = "Action")
        public String NoticeLanguage{get;set;}      // XmlElement(name = "NoticeLanguage")
        public String NoticeChannel{get;set;}       // XmlElement(name = "NoticeChannel")
        public String NoticePhoneArea{get;set;}     // XmlElement(name = "NoticePhoneArea")
        public String NoticePhoneNum{get;set;}      // XmlElement(name = "NoticePhoneNum")
        public String NoticeEmailAddress{get;set;}  // XmlElement(name = "NoticeEmailAddress")
        public Boolean isSuccess{get;set;}{isSuccess = false;} // just used to store the request result
        public String internalCustomerID{get;set;} // for BD Group Policies Details
        public String registerCode{get;set;}        // XmlElement(name = "RegisterCode")

        // add by minghua - 20190812 - Customer portal GS login flow
        public String fARight{get;set;}        // XmlElement(name = "Rights")
        public String personalEMailAddress{get;set;}        // XmlElement(name = "PersonalEMailAddress")

        // add by Christina - 20210727 - Client Portal - CP-454 Control Update UserId
        public String UpdateLoginIdByEmail{get;set;}
        
        //junda 20200922 add
        public String ssn {get;set;}        // XmlElement(name = "SSN")
        public String contentType {get;set;}     // XmlElement(name = "ContentType")
        public String functionType {get;set;}    // XmlElement(name = "FunctionType")
        //Xgate change
        public String whatsapp {get;set;}
        public String afterRegister{get;set;}  // 20200923 - minghua - WhatsApp request link
        public List<Policy> policyList{get;set;} //20201028 - Zane - marketing opt out for customer portal
        public String forgetPassword{get;set;} // XmlElement(name = "ForgetPassword") "Y" or "N", Rancho_JOBR300_20230214 - detect forgot password and register user
        public String isHKID{get;set;} // XmlElement(name = "GovtIDIndicator") "Y" or "N", Rancho_JOBR300_20230214 - identity number user registered with
        public String newAgentCode{get;set;}        // Rancho_PI83_20221110 - only pass value when update user agent code
        public String openId{get;set;} // Rancho_iAMSmart_20250806 - iAM Smart Open ID
        public User() {
            this.hkId = '';
            this.roleId = '';
            this.loginId = '';
            this.dob = '';
            this.statusCode = '';
            this.companyCode = '';
            this.linkedCompanyCode = '';
            this.companyName = '';
            this.companyType = '';
            this.gisCompanyCode = '';
            this.firstName = '';
            this.lastName = '';
            this.phoneNumber = '';
            this.emailAddress = '';
            this.agentCode = '';
            this.subAgentCode = '';//CR-47 Tovid subAgentCode
            this.action = '';
            this.UpdateLoginIdByEmail = '';
            this.personalEMailAddress = ''; //add by minghua - 20190812 - Customer portal GS login flow
            this.fARight = ''; //add by minghua - 20190812 - Customer portal GS login flow
            this.whatsapp = '';//Xgate change
            this.policyList = new List<Policy>(); //20201028 - Zane - marketing opt out for customer portal
        }
    }

    /*
     * Represent the result of the WS call
     */
    public class TransResult{
        public String resultCode{get;set;}
        public String resultInfoCode{get;set;}
        public String resultInfoDesc{get;set;}
        public String resultLoginId{get;set;}
        public Boolean isSuccess{get;set;}{isSuccess = false;}
        public String recordsFound{get;set;}{recordsFound = '0';}
        public String nextRecord{get;set;}{nextRecord = '';}// Rancho_HKITSFDC393_20250827 - add next record
    }

    public class Fund{
        public String fundName{get;set;}
        public String fundCode{get;set;}
        public Decimal unitValue{get;set;}
        public Date valuationDate{get;set;}
    }
    /*
     *Class for Transfer Criteria to UpdateAgentHierarchy
     */
    public class AgentHierarchy{
        public String companyCode{get;set;}{companyCode = '';}
        public String agentCode{get;set;}{agentCode = '';}
        public String subCompanyCode{get;set;}{subCompanyCode = '';}
        public String subAgentCode{get;set;}{subAgentCode = '';} //CR-47 Tovid subAgentCode
        public Boolean isAltruist{get;set;}{isAltruist = false;}
        public Boolean isSuccess{get;set;}{isSuccess = false;} // just used to store the request result
    }
    /*
     *Class for Transfer Criteria to UpdateCustomerOptInOut
     */
    public class SensitivityCriteria{
        public String sensitivityCode{get;set;}{sensitivityCode = '';}
        public String action{get;set;}{action = '';}
    }

    /*
     * Class for SendNotification
     *   @sourceCode  APP,NCS,QNCS,SFD,IEB
     */
    public class Notification{
        public String sourceCode{get;set;}{sourceCode = '';}
        public String triggerId{get;set;}{triggerId = '';}
        public String polNumber{get;set;}{polNumber = '';}
        public List<String> SSNList{get;set;}{SSNList = new List<String>();} // deprecated
        public String ssn{get;set;}{ssn = '';}
        public String certificateNo{get;set;}{certificateNo = '';}
        public Boolean isSuccess{get;set;}{isSuccess = false;} // just used to store the request result
    }

    /*
     * Class for Pending Memo
     *
     */
    public Class PendingMemo{
        public String code{get;set;}
        public String message{get;set;}
        public String claimNo{get;set;}
        public String sequenceNumber{get;set;}
    }
    /*
    * Class for SendEmail
    */
    public Class EmailRequest{
        public String MailFrom{get;set;}
        public String MailTo{get;set;}
        public String MailCC{get;set;}
        public String MailBCC{get;set;}//HC200-Generic sending emails functions for all clinic cases-20220228-Kirk
        public String MailTitle{get;set;}
        public String MailBody{get;set;}
        public Boolean SecureMailInd{get;set;}
        //public Blob fileBody{get;set;}
        //public String fileName{get;set;}
        //public String fileType{get;set;}
        public Boolean isSuccess{get;set;}
        public List<HttpCalloutVO.Attachment> AttachmentList{get;set;}
        /********add by andy li for gop enhancment
        *•   1 = No Reply HK (no-replyhk@cigna.com)
        *•   2 = Enquiry HK (enquiryhk@cigna.com)
        *•   3 = Pre-auth HK (preauthhk@cigna.com)
        ********************************************/
        public String MailSenderType{get;set;}
        //end for andy li for gop enhancement
    }

    public class FullBranch{
        @AuraEnabled
        public List<HttpCalloutVO.Branch> branchList{get;set;}
        public String policyNumber{get;set;}
    }

    public class Branch{
        @AuraEnabled
        public String branchCode{get;set;}
        @AuraEnabled
        public String branchDesc{get;set;}
    }

    public class FullPlan{
        public List<String> planList{get;set;}
        public List<String> planDescList{get;set;}  //added by Connor CP-143
        public Map<String, String> planNoMap{get;set;}   // Added by Linus JR1904
        public String policyNumber{get;set;}
    }

    /*
     * Class for SubmitLHBApplicationRequest
     */
    public class SubmitLHBRequest{
        public String uploadRequestType{get;set;} // added for Fax-to-case(Outbound)
        public String resultCode{get;set;}
        public String resultCodeDesc{get;set;}
        public List<HttpCalloutVO.Attachment> attachmentList{get;set;}
    }

    // for general file upload ws
    public class UploadFileRequest{
        // 20210319 - minghua - Client Portal
        public String processID{get;set;}
        public String accessLevel{get;set;}
        public String uploadRequestType{get;set;}
        public String resultCode{get;set;}
        public String resultCodeDesc{get;set;}
        // Rancho_JOBR149_20220815 - add new field for passing policy no and cert no when submit DDA
        public String polNumber{get;set;}
        public String certificateNo{get;set;}
        public List<HttpCalloutVO.Attachment> attachmentList{get;set;}
    }

    public class IncentivesInformation{
        public String policyNumber{get;set;}
        public String marketingName{get;set;}
        public String phName{get;set;}
        public String messageID{get;set;}
        public String description{get;set;}
    }

    public class ContactHistory{
        @AuraEnabled public String messageId{get;set;}
        public String phSsnNumber{get;set;}
        public String sentDate{get;set;}
        public String sentTime{get;set;}
        @AuraEnabled public DateTime sentDateIntime{get;set;}
        @AuraEnabled public DateTime sentDateInTimeGMT{get;set;}// Rancho_HKITSFDC250_20250911 - add GMT time
        @AuraEnabled public String channel{get;set;}
        public String subject{get;set;}
        public String content{get;set;}
        public String recipient{get;set;}
        @AuraEnabled public String status {get;set;}	//HKITSFDC-342
    }

    public class CaseRequest{
        public String roleId{get;set;}
        //public String transmstId{get;set;}
        //public String transactionId{get;set;}
        public String SsnNumber{get;set;}
        public String clientName{get;set;}
        public DateTime receivedDateTime{get;set;}
        public Integer categoryId{get;set;}
        public String userId{get;set;}
        public Integer sourceId{get;set;}
        public Integer mediaId{get;set;}
        public Integer type{get;set;}
        public Integer subType{get;set;}
        public Integer status{get;set;}
        public String policyNumber{get;set;}
        public String BP{get;set;}
        public String channel{get;set;}
        public String remarks{get;set;}
        public String CRFlag{get;set;}
        public DateTime lastTransactionDate{get;set;}
        public String campaign{get;set;}
        public Boolean softDelete{get;set;}
        public DateTime softDeleteDate{get;set;}
        public Boolean hardDelete{get;set;}
        public DateTime hardDeleteDate{get;set;}
        //public String SFDCid{get;set;}
        public String SFDCMasterId{get;set;}
        public String SFDCDetailId{get;set;}
        public Boolean isSuccess{get;set;}
        public Integer natureId{get;set;}
    }

    public class ContactHistoryDetail{
        public date send{get;set;}
        public String sendTo{get;set;}
        public string subject{get;set;}
        public string content{get;set;}
    }

    /*
     * Class for BD New Business UW Comment
     */
    public class UWComment{
        public String policyNumber{get;set;}
        public String appianRequestID{get;set;}
        public String commentedBy{get;set;}
        public DateTime commentedDateTime{get;set;}
        public String comments{get;set;}
    }

    public class Prospect{
        public String policyId{get;set;}
        public Integer activityId{get;set;}
        public String activityType{get;set;}
        public String prospectId{get;set;}
        public String productTypeCode{get;set;}
        public String productTypeDesc{get;set;}
        public String productType{get;set;}{productType=productTypeCode +'| '+ productTypeDesc;}
        public String productCode{get;set;}
        public String planName{get;set;}
        public String holderName{get;set;}
        public String insuredName{get;set;}
        public String phGovtId{get;set;}
        public String piGovtId{get;set;}
        public Date submissionDate{get;set;}
        public Time submissionTime{get;set;}
        public String polNumber{get;set;} // added for DPSP-118
        public person holderDetail{get;set;}{holderDetail = new person();}// Holder detail
        public person insuredDetail{get;set;}{insuredDetail = new person();} // Insured detail
        public person beneficiaryDetail{get;set;}{beneficiaryDetail = new person();} // Beneficiary detail
    }

    public class ProspectDetail{
        public String ProspectId{get;set;}
        public String ActivityId{get;set;}
        public String ActivityType{get;set;}
        public String SubmissionDate{get;set;}
        public String SubmissionTime{get;set;}
        public DateTime SubmissionDateInTime{get;set;}
        public String RunningNumber{get;set;}
        public String PolicyStatus{get;set;}
        public String IQId{get;set;}
        public String ProductCode{get;set;}
        public Boolean JointInd{get;set;}
        public Boolean GetQuoteCompleteInd{get;set;}
        public Boolean HolderInfoCompleteInd{get;set;}
        public Boolean PreSalesCompleteInd{get;set;}
        public Boolean UWQuestionaireCompleteInd{get;set;}
        public Boolean UWReviewCompleteInd{get;set;}
        public Boolean ApplicationCompleteInd{get;set;}
        public Boolean PaymentRequestSubmitInd{get;set;}
        public Boolean PaymentAcceptInd{get;set;}
        public String PresalesResult{get;set;}
        public String FinalUWResult{get;set;}
        public String FinalResult{get;set;}
        public String preferContactTime{get;set;}
        public Boolean smokeInd{get;set;}
        public String howToKnow{get;set;}
        public String transactionStatus{get;set;}
        public String planLevel{get;set;}
        public String rateScale{get;set;}
        public String RiderPlanLevel1{get;set;}
        public String Rider1{get;set;}
        public String RiderPlanLevel2{get;set;}
        public String Rider2{get;set;}
        public String RiderPlanLevel3{get;set;}
        public String Rider3{get;set;}
        public String RiderPlanLevel4{get;set;}
        public String Rider4{get;set;}
        //add by kermit
        public String RiderPlanLevel5{get;set;}
        public String Rider5{get;set;}
        public String RiderPlanLevel6{get;set;}
        public String Rider6{get;set;}
        //end add
        
        //Combo: maybe has 7 riders
        public String RiderPlanLevel7{get;set;}
        public String Rider7{get;set;}
        
        public String CampaignCode{get;set;}
        public String Enquiry{get;set;}
        public Boolean OptOutInd{get;set;}  //add by Andy 20180716
        public String language{get;set;} // for Contact

        //Add by Manuel
        public String PlaceOfResCode{get;set;}
        public String DiscountCode1{get;set;}
        public String DiscountCode2{get;set;}

        public Policy policy{get;set;}{policy = new Policy();}
        public PersonRelation holderDetail{get;set;}{holderDetail = new PersonRelation();}// Holder detail
        public List<PersonRelation> insuredDetailList{get;set;}{insuredDetailList = new List<PersonRelation>();} // Insured detail
        public List<PersonRelation> beneficiaryDetailList{get;set;}{beneficiaryDetailList = new List<PersonRelation>();} // Beneficiary detail

        //add for JR-GA by kermit
        public String GAClientID{get;set;}
        public String GATrackID{get;set;}
        public String GAUserId{get;set;}
        public String GASource{get;set;}
        public String GAMedium{get;set;}
        public String GACampaign{get;set;}
        //add for JR-GA by kermit
        //JR-1846
        public String GAKeyword{get;set;}
        //JR-1846
        //add for Covid19 by Andy Li start
        public String QuestionAns1{get;set;}
        public String QuestionAns2{get;set;}
        //add for Covid19 by Andy Li end        
        //add for Combo Product by Rancho
        public String QuestionAns3{get;set;}
        public String QuestionAns4{get;set;}
        public String QuestionAns5{get;set;}
        //Combo TM
        public String planDeclaration{get;set;}
        //add for Combo Product by Rancho        
        //for get AUW URL
        public String UWApplicationId{get;set;}
        //for SPS-97 missing exclusion message
        public List<UWExclusionDetail> exclusionDetails{get;set;}
        public List<UWExclusionDetail> remarkDetailsList{get;set;}
        public String remarkDetails{get;set;}

        //Nicole_SPS-340_20200429
        public String baiscPlanUWResult{get;set;}
        public String rider1UWResult{get;set;}
        public String rider2UWResult{get;set;}
        public String rider3UWResult{get;set;}
        public String rider4UWResult{get;set;}
        public String rider5UWResult{get;set;}
        public String rider6UWResult{get;set;}
        public String LoadingPremiumRate{get;set;}/* add by Jack on 2021-10-28 for project: SUQ loading for drop-off */
public String PromoCode{get;set;} // Add by Owen,20230523, For JOBR-312 to get promote code
    }

    //for SPS-97 missing exclusion message
    public class UWExclusionDetail{
        public String detail{get;set;}
        public String description{get;set;}
    }
    //for SPS-97 end

    public class PersonRelation{
        public Person person{get;set;}{person = new Person();}
        public Relation relation{get;set;}{relation = new Relation();}
    }

    /*
     * Class for GetDiscountListBasic
     */
    public class Discount{
        public String discountCode{get;set;}
        public Integer discountStartYear{get;set;}
        @AuraEnabled public Integer discountDuration{get;set;}
        @AuraEnabled public Decimal discountPercentage{get;set;}
        @AuraEnabled public String description{get;set;}
    }

    public class Loading{
        @AuraEnabled public Decimal loadingAmount{get;set;}
        @AuraEnabled public String loadingPercentageStr{get;set;}
        @AuraEnabled public Decimal loadingAmountDuration{get;set;}
        @AuraEnabled public Decimal loadingPercentageDuration{get;set;}
    }

    /*
     * Class for GetPlanInfoListBasic
     */
    public class Product{
        public String productCode{get;set;}
        public List<Benefit> benefitList{get;set;}{benefitList = new List<Benefit>();}
        public List<Rider> riderList{get;set;}{riderList = new List<Rider>();}
        private Map<String, List<Rider>> benefitRiderMap;
        public Map<String, List<Rider>> getBenefitRiderMap(){
            Map<String, List<Rider>> result = new Map<String, List<Rider>>();
            for(Benefit ben : benefitList){
                result.put(ben.BenefitLevelCode, new List<Rider>());
                for(Rider r : riderList){
                    if(ben.BenefitLevelCode == r.benefitLevelCode){
                        result.get(ben.benefitLevelCode).add(r);
                    }
                }
            }
            return result;
        }
    }

    public class Rider implements Comparable{
        public String riderName{get;set;}
        public String riderCode{get;set;}
        public String benefitLevelCode{get;set;}
        public Boolean isUWProduct{get;set;}{isUWProduct = false;}
        public Boolean isAvailable{get;set;}{isAvailable = false;}
        public Boolean isSameLevel{get;set;}{isSameLevel = false;}
        public List<EligibleAge> eligibleAgeList{get;set;}{eligibleAgeList = new List<EligibleAge>();} //added by Andy 20180727 for GetPlanInfoListBasic
        public List<BenefitDetail> benefitDetailList{get;set;}{benefitDetailList = new List<BenefitDetail>();} // phase 2 for GetPlanInfoListBasic

        public Integer compareTo(Object riderToCompare){
            Rider rider2Compare = (Rider)riderToCompare;
            if(null != this.riderName){ return this.riderName.compareTo(rider2Compare.riderName); }
            else{ return -1; }
        }
    }

    public Class Beneficiary{
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String gender{get;set;}
        public String relationship{get;set;}
        public String SSNNumber{get;set;} // HKID
        public Date birthDate{get;set;} // DOB
        public String interestPercent{get;set;} // Share %
    }

    /*
     * Class for NationalityRequest and CountryRequest (MasterList)
     * Nationality & Country of Residence CR
     */
    public class MasterList implements Comparable{
        public String typeId{get;set;} // added by Jason Guo 20180619
        public String code{get;set;}
        public String name{get;set;}
        //add bob 20210209 Client Portal
        @AuraEnabled
        public String branchCode{get;set;}
        @AuraEnabled
        public String branchName{get;set;}
        public String departmentCode{get;set;}
        public String departmentName{get;set;}
        //end
        //add by Andy for TD/Watsons project start
        public String shopRegion{get;set;}
        public String shopDistrict{get;set;}
        public String shopName{get;set;}
        public String shopAddress{get;set;}
        public String shopOpeningHours{get;set;}
        public String shopAddressLatitude{get;set;}
        public String shopAddressLongitude{get;set;}
        public String shopEmailAddress{get;set;}
        public String shopStatus{get;set;}
        //add by Andy for TD/Watsons project end

        //add by junda for TD/Watsons project start
        public String pharmacyContactNumber{get;set;}
        public String shopContactNumber{get;set;}
        //add by junda for TD/Watsons project end
        //add by kirk 20210426 for client portal
        public Country country{get;set;}{country = new Country();}
        public Nationality nationality{get;set;}{nationality = new Nationality();} 
        public BankAccount bank{get;set;}{bank = new BankAccount();}
        //add by kirk end

        //Link_IA_AML_Inspection_20211228 start
        public Boolean isSanction{get;set;}
        public String countryISOCode{get;set;}
        //Link_IA_AML_Inspection_20211228 end

        public Integer compareTo(Object ct){
            HttpCalloutVO.MasterList compare = (HttpCalloutVO.MasterList)ct;
            return this.name.compareTo(compare.name);
        }
    }

    //add by junda 20201120
    public class MasterProductList{
        public String masterProductCode{get;set;}
        public String masterProductNameEng{get;set;}
        public String masterProductNameChi{get;set;}
        public Integer ipmiIndicator{get;set;}
        public Integer ipmiTopupIndicator{get;set;}
        public Integer gaopIndicator{get;set;}
    }
    //add by junda end

    //add by kirk for client portal 20210426
    public class Country{
        @AuraEnabled
        public String countryCode{get;set;}
        @AuraEnabled
        public String countryDescriptionLong{get;set;}
        @AuraEnabled
        public String countryDescriptionShort{get;set;}
        @AuraEnabled
        public String countryChineseDescriptionLong{get;set;}
        @AuraEnabled
        public String countryChineseDescriptionShort{get;set;}
        @AuraEnabled
        public String riskLevel{get;set;}
        @AuraEnabled
        public String status{get;set;}
        // 20220221 - minghua - IA-11, 144018 - Add Error Message on Member Movement Frontend (Client Portal) 
        @AuraEnabled
        public Boolean isSanction{get;set;}
    }
    
    public class Nationality{
        @AuraEnabled
        public String nationalityId{get;set;}//Kirk-CP585-20211119
        @AuraEnabled
        public String nationality{get;set;}
        @AuraEnabled
        public String nationalityChinese{get;set;}
        @AuraEnabled
        public String riskLevel{get;set;}
        @AuraEnabled
        public String status{get;set;}
    }
    //add by kirk end

    /**
     * This Reference Class is for Policy
     * added by ZaiHong 20180423 base on CS_CR_WS_XML_Spec_r1.xlsx
    */
    public class Reference{
        @AuraEnabled public String referenceId{get;set;}
        @AuraEnabled public String referenceDesc{get;set;}
    }

    /**
     * Class For MsgWithUW
     * added by lu weizheng at 20180619 base on TM UW Messaging WS XML Spec_v2.xlsx
     */
    public class Message{
        public String createDate{get;set;} //sentOn
        public String content{get;set;}  //message
        public String commenter{get;set;} //sentBy,TMRID
        public String messageID{get;set;} //messageID
        public Boolean isSeen{get;set;} //seen
        public String Signal{get;set;} //Signal
        public String AttachmentData64Binary{get;set;} //AttachmentData64Binary
        public List<HttpCalloutVO.Attachment> attachments{get;set;}
        public String MimeTypeTC{get;set;} //MimeTypeTC
        public String FileName{get;set;} //FileName
        public String AttachmentID{get;set;}  //attachmentID
        public String AttachmentHashValue{get;set;} //AttachmentHashValue
        public String TrackingID{get;set;} //Tracking ID

        public List<String> contentList{get;set;} //break line for message
        public boolean clickInd{get;set;}{clickInd = false;}//add by Andy for indicate the is click to seen
    }

    public class UnreadMessage{
        public String RequestID{get;set;}
        public String policyNumber{get;set;}
        public String requestStatus{get;set;}
        public String policyHolderName{get;set;}
        public String policyHolderID{get;set;}
        public String tmSalesID{get;set;}
    }

    /**
     * This Class is for GenerateReport WS
     * added by Charles 20180626
    */
    public class GenerateReportRequest{
        public Date transactionDate{get;set;}
        public String transactionDateStr{
            get{
                if(transactionDate==null){ return ''; }
                else{
                    string y = string.valueof(transactionDate.year());
                    string m = string.valueof(transactionDate.month());
                    string d = string.valueof(transactionDate.day());
                    return y + '-'+ (m.length()<2?'0'+m :m) + '-' + (d.length()<2?'0'+d :d);
                }
            }
        }
        public String partnerName{get;set;}
        public String mailTo{get;set;}
        public String mailCC{get;set;}
        public String result{get;set;}
        public String resultCode{get;set;}
    }

    /**
     * This Class is for UpdateWorkGroup WS
     * added by Charles 20180713
    */
    public class UpdateWorkGroupRequest{
        public String WorkGroupName{get;set;}
        public String PartnerName{get;set;}
        public String WorkGroupID{get;set;}
    }

    /**
     * This Class is for UpdateWorkingHour WS
     * added by Andy 20180713
    */
    public class UpdateWorkingHourRequest{
        public String Seller{get;set;}
        public String SellerName{get;set;}
        public String LoginID{get;set;}
        public Date TransactionDate{get;set;}
        public String TransactionDateStr{get;set;}  //MM/DD/YYYY TS677
        public String PartnerName{get;set;}
        public String WorkGroupID{get;set;}
        public Decimal WorkingHour{get;set;}
        public String resultCode{get;set;}
    }

    /*
     * This Class is for CR CS Policy Transaction History
     * add by kit
     */
    public class TransactionHistory implements Comparable{
        public String seqNum{get;set;}  //TRANSACTION
        public String status{get;set;}  //TRANSACTION
        public Date effective{get;set;} //Effective
        public String userId{get;set;}  //by
        public Date transactionDate{get;set;}   //On
        public String sellerId{get;set;}    //Seller
        public String premiumAmount{get;set;}   //Premium
        public String paymentMode{get;set;}     //Premium
        public String premiumChangeAmount{get;set;} //Premium Change

        /***********    above is required    ************/
        public String premiumOverrideAmount{get;set;} //Premium Override
        public String suspendReason{get;set;}   //Suspended Policy
        public Date unsuspendDate{get;set;} //Unsuspended On
        public String unsuspendUserID{get;set;} //Unsuspended On
        public String cancellationReason{get;set;}  //Cancellation Reason
        public String adjustmentAmount{get;set;}    //Adjustment Amount
        public String adjustmentReason{get;set;}    //AdjustmentReason

        public Boolean hasAccountNumberChange{get;set;}
        public String accountNumberChange_ValueFrom{get;set;}    //Change Account No From Account
        public String accountNumberChange_ValueTo{get;set;}  //Change Account No From Account
        public Boolean hasCreditCardNumberChange{get;set;}
        public String creditCardNumberChange_ValueFrom{get;set;}    //Change Credit Card No From
        public String creditCardNumberChange_ValueTo{get;set;}  //Change Credit Card No From

        public String taxExclusion{get;set;}    //Adjustment Tax Exclusion
        public String campaignCode{get;set;}    //Campaign/Split
        public String campaignSplit{get;set;}   //Campaign/Split
        public String packageShortName{get;set;}    //Package
        public Boolean hasBenefitLevelChange{get;set;}
        public List<benefitLevelChange> benefitLevelChangeList{get;set;}

        public String coverageChangeInd{get;set;}   //Changed Coverages from Holder to Holder
        public Boolean hasBeneficiaryChange{get;set;}
        public List<BeneficiaryChange> beneficiaryChangeList{get;set;}
        public Boolean hasOverrideExpireDateChange{get;set;}
        public String overrideExpireDateChange_valueFrom{get;set;}
        public String overrideExpireDateChange_ValueTo{get;set;}
        public String notes{get;set;}
        public String productName{get;set;}

        public Integer compareTo(Object ct){
            HttpCalloutVO.TransactionHistory object2 = (HttpCalloutVO.TransactionHistory)ct;
            if(this.effective != null && object2.effective != null){
                if(this.effective > object2.effective){ return -1; }
                else if(this.effective < object2.effective){ return 1; }
                else{ return 0; }
            } else{
                if(this.effective != null){ return 1; }
                else if (object2.effective != null){ return -1; }
                else{ return 0; }
            }
        }
    }

    /*
     * This Class is for CR CS Policy Fund / Bonus Detail
     * add by kit
     */
    public Class BonusTransaction{
        public String transDate{get;set;}
        public String currencyType{get;set;}
        public Decimal amount{get;set;}
        public String acct{get;set;}
        public String description{get;set;}
    }

    public class BenefitLevelChange{
        public String beneficiaryName{get;set;}      //Changed Benefit Level
        public String productCode{get;set;}  //Changed Benefit Level
        public String valueFrom{get;set;}    //Changed Benefit Level
        public String valueTo{get;set;}  //Changed Benefit Level
        public String relationship{get;set;}
        public String action{get;set;}
    }

    public class BeneficiaryChange{
        public String productName{get;set;} //BeneficiaryChange
        public String beneficiaryName{get;set;} //BeneficiaryChange
    }

    /*
     * Copy from CRUAT by Andy for TM Portable Medical Plan CR
     * ProductEligibility Class for WS CheckProductEligibility
     */
    public class CheckProdEligCriteria{
        public String policyType{get;set;}  //mandatory, value = I or G
        public String polNumber{get;set;}  //mandatory, Policy number
        public String referrerSSN{get;set;} //mandatory, SSN number of referrer
        public String potentialInsuredSSN{get;set;}  //mandatory, SSN number of potential insured
        public String certificateNo{get;set;}//mandatory for group policy
        public String productCode{get;set;}//mandatory, Search value = Plan code
        public String relationRoleCode{get;set;} //optional, value = Insured or Family
        public Boolean triggeringEvent{get;set;}//optional, Search value = True/False 0 = OLI_BOOL_FALSE
        public Boolean brokerCriteriaCheck{get;set;}//optional; Search value = True/False ;0 = OLI_BOOL_FALSE,1 = OLI_BOOL_TRUE; add by ken
    }

    /*
     * Copy from CRUAT by Andy for TM Portable Medical Plan CR
     * ProductEligibility Class for WS CheckProductEligibility
     */
    public class ProductEligibility{
        public List<Relation> relationList{get;set;}
        public List<Person> personList{get;set;}
        public List<Policy> policyList{get;set;}
        //public List<GroupPolicy> groupPolicyList{get;set;}
    }

    /*
    * Added by Andy 20180830
    * For TM retrive the credit card number.
    */
    public class PersonPayment{
        public String policyNumber{get;set;}
        public String paymentMethod{get;set;}
        public String accountNumber{get;set;}
        public String partyTypeCode{get;set;}
        public String ssn{get;set;} //GovtID
    }

    public class ClaimApplication{
        public String submissionDate{get;set;}
        public String source{get;set;}

        // 20210803 - minghua - CR48
        public Boolean isFastTrackClaim{get;set;}
        public Boolean inSepMedicCharge{get;set;} //  include separate medication charge
        public String consulAmount{get;set;} // Consultation fee
        public String medicAmount{get;set;} //  Medication fee
        public String otherAmount{get;set;}
        public String consulCurrency{get;set;}
        public List<String> diagnosis{get;set;}   // symptoms and diagnosis code
        public Boolean isPublicHospital{get;set;} // Rancho_CR48_20210706
        public String batchNo{get;set;} // Quinto_MRP-242_20230911

        //add by minghua for claim submitClaim - 20190621
        public List<HttpCalloutVO.Policy> policyList{get;set;}
        public List<ClaimType> claimTypeList{get;set;}
        public List<String> benefitTypeList{get;set;}
        public List<String> opConsultationDateList{get;set;}
        public List<HospitalStay> hospitalStayList{get;set;}
        public Claimant claimant{get;set;}
        public HttpCalloutVO.Policy policy{get;set;}
        public String claimType{get;set;}
        public String claimTypeCode{get;set;}
        public Boolean hasReferralLetter{get;set;}
        public Boolean isSpecialist{get;set;}

        public String doctorName{get;set;}
        public String doctorId{get;set;}
        public String doctorContactNo{get;set;}
        public String hospitalName{get;set;}
        public String hospitalId{get;set;}
        public String hospitalContactNo{get;set;}

        public Boolean hasAdmission{get;set;}
        public String firstConsultationDate{get;set;}
        public String opConsultationDate{get;set;}
        public String totalAmount{get;set;}
        public String benefitType{get;set;}
        public Boolean isOnSickLeave{get;set;}
        public String clearicalJobPercentage{get;set;}
        public String manualJobPercentage{get;set;}
        public String sickLeaveStartDate{get;set;}
        public String admissionDateTime{get;set;}
        public String dischargeDateTime{get;set;}
        public Boolean hasOtherInsurancePolicy{get;set;}
        public Boolean hasRoomCharge{get;set;}
        public List<HttpCalloutVO.OtherInsurer> otherInsurerPolicy{get;set;} //Map<company, policyno>
        public HttpCalloutVO.BankAccount bankAccount{get;set;}
        public String paymentCurrency{get;set;}
        public List<HttpCalloutVO.Attachment> attachmentList{get;set;}
        public String destination{get;set;}
        public Integer numOfAttachment{get;set;}
        public String claimNumber{get;set;}

        //Raistlin - GS claim - 20191024
        public String incurredCountry{get;set;}
        public String incurredCurrency{get;set;}
        // 20200928 - minghua - new Claim flow
        public List<String> outpatientSubtypeList{get;set;}
        public String lateSubmissionReason{get;set;}
        public String speciality{get;set;}
        public String specialityFreeText{get;set;}
        public String admittedWardClass{get;set;}
        public Boolean prePostHospital{get;set;}
        public Boolean isAccident{get;set;}
        public Boolean isEmergency{get;set;}
        public String iPMIOnsetDate{get;set;}
    }

    public class OtherInsurer{
        public String name{get;set;}
        public String policyNo{get;set;}
    }

    //add by minghua for claim submitClaim - 20190621
    public class ClaimType{
        public String claimType{get;set;}
        public String claimTypeCode{get;set;}
    }

    //add by minghua for claim submitClaim - 20190621
    public class HospitalStay{
        public String admissionDateTime{get;set;}
        public String dischargeDateTime{get;set;}
        public String wardType{get;set;}
        public String roomCharge{get;set;}
    }

    //add by minghua for claim submitClaim - 20190621
    public class Claimant{
        public String fullName{get;set;}
        public String ssnNumber{get;set;}
        public String birthDate{get;set;}
    }

    public class BankAccount{
        public String type{get;set;}
        public String acctHolderName{get;set;}
        @AuraEnabled
        public String bankName{get;set;}
        @AuraEnabled
        public String bankCode{get;set;}
        @AuraEnabled//client portal ----add by kirk 
        public String status{get;set;}
        public String branchCode{get;set;}
        public String routingCode{get;set;}
        @AuraEnabled
        public String accountNumber{get;set;}
        public String branchAddress{get;set;}

        //Nicole_20200210_Customer Portal UAT-Swift Code Missing Issue
        public String swiftCode{get;set;}
        //Raistlin - 20191101 - GS claim
        public String bankAccountCountry{get;set;}
        public String policyNumber{get;set;}
        public String certNo{get;set;}
        public String countryName{get;set;}        
        //junda add 20200925
        @AuraEnabled public String payMethod{get;set;}
        //end

        //Quinto_20230726 MRP-78
        @AuraEnabled
        public String beneficiaryAddress1{get;set;}
        @AuraEnabled
        public String beneficiaryAddress2{get;set;}
        @AuraEnabled
        public String beneficiaryAddress3{get;set;}
        @AuraEnabled
        public String beneficiaryAddress4{get;set;}
        @AuraEnabled
        public String beneficiaryPhoneNumber{get;set;}
    }

    // JR1774 - [[
    /*
    * Class for VerifyPolicyInfo
    * Author: Lawrence BP Wong
    * Project code: JR1774
    * For credit card number validation.
    */
    public class CreditCardNumber{
        public String creditCardNumber{get;set;}
        public Boolean isCreditCardNumberValid{get;set;}
        public String policyNumber{get;set;}
        public Boolean isWebServiceCallSuccess{get;set;}    // AH18454
    }
    // ]] - JR1774

    //CS Member Level Jack add
    public class auditLog{
        public String fieldCode{get;set;}
        public String fieldName{get;set;}
        public String valueFrom{get;set;}
        public String valueTo{get;set;}
        public String updateUser{get;set;}
        public String updateDate{get;set;}
        public String updateTime{get;set;}
    }
    //CS Member Level Jack add

    //policy replacement Jack add
    public class replacementInfo{
        public String replacementPolicyNumber{get;set;}
        public String productCode{get;set;}
        public String sourceSystem{get;set;}
        public Date changeDate{get;set;}
        public String shortCode{get;set;}
        public String details{get;set;}
        public String planName{get;set;}
    }

    public class policyReplacement{
        public String polNumber{get;set;}
        public Date applicationDate{get;set;}
        public Date policyReplacementEffectiveDate{get;set;}
        public Date notificationDate{get;set;}
        public String notificationType{get;set;}
        public String acknowledgementType{get;set;}
        public Date acknowledgementDate{get;set;}
        public List<replacementInfo> replacementInfoList{get;set;}
    }
    //policy replacement Jack add

    //ILAS Jack add
    public class RiskProfile{
        @AuraEnabled public String rPQStatus{get;set;}
        @AuraEnabled public Date rPQEffectiveDate{get;set;}
        public String rPQStatusCode{get;set;}
        @AuraEnabled public String rPQUpdateSource{get;set;}
        public Date rPQUpdateDate{get;set;}
        public Time rPQUpdateTime{get;set;}
        //junda add for plus profile
        public Datetime rpqUpdateDateTime{get;set;}
        @AuraEnabled public String rpqUpdateDateTimeString{get;set;}
    }

    // 20200902 - minghua - Check Sensitivity code for e-sales
    public class PersonSenvCode{
        public String partyTypeCode{get;set;}
        public String govtID{get;set;}
        public String senvCode{get;set;}
    }

    public class ClaimRequest{
        public String holderId{get;set;}
        public String userLoginName{get;set;}
        public String claimStatus{get;set;}
        public Boolean isBrokerClaim{get;set;}
        public String claimNumber{get;set;}
        public Integer startRecordIndex{get;set;}
        public Integer recordCount{get;set;}
        public String policyNumber{get;set;}
        public String holderName{get;set;}
        public String insuredSSNnumber{get;set;}
        public String insuredName{get;set;}
        public String memberName{get;set;}
        public String certNo{get;set;}
        public String  brokerAgentCode{get;set;}
        public Boolean isHolderAndInsured{get;set;}
        public String familyRecordIndicator{get;set;}
        public String holderRelation{get;set;}
        public String insuredRelation{get;set;}
    }
    
    public class Shortfall{  //added by Connor CP-156
        @AuraEnabled public String ShortfallAmount{get;set;}
        @AuraEnabled public String ShortfallAmountCurrencyCode{get;set;}
        @AuraEnabled public String ShortfallOutStandingAmount{get;set;}
        @AuraEnabled public String ShortfallAmountwCurrency{get;set;}
        @AuraEnabled public String ShortfallOSAmountwCurrency{get;set;}
        @AuraEnabled public String DebitNoteNo{get;set;}
        @AuraEnabled public String ClaimNo{get;set;}
        @AuraEnabled public Date DateOfService{get;set;}
        @AuraEnabled public String NameOfClaimant{get;set;}
        @AuraEnabled public String ShortfallOutStandingDate{get;set;}
        @AuraEnabled public String ShortfallStatus{get;set;}
        @AuraEnabled public String CertificateNo{get;set;}
        @AuraEnabled public String BranchDesc{get;set;}
        @AuraEnabled public String FullName{get;set;}
        @AuraEnabled public String ShortfallFullySettledDate{get;set;}
        @AuraEnabled public Date ShortfallDate{get;set;}
        @AuraEnabled public String PlanName{get;set;}
        @AuraEnabled public String ConsultationDate{get;set;}
        @AuraEnabled public String HoldClaimIndicator{get;set;}
        @AuraEnabled public String PolicyNumber{get;set;}
    }
    
    public class PersonMovement{  //added by Connor CP-156
        @AuraEnabled public String EndorsementNo{get;set;}
        @AuraEnabled public Date EndorsementDate{get;set;}
        @AuraEnabled public String MemberName{get;set;}
        @AuraEnabled public Date EffectiveDate{get;set;}
        @AuraEnabled public String PlanNumber{get;set;}
        @AuraEnabled public String SubPlanNumber{get;set;}
        @AuraEnabled public String Sex{get;set;}
        @AuraEnabled public Date DateOfBirth{get;set;}
        @AuraEnabled public Integer Age{ 
            get{
                if(DateOfBirth != null){
                    return Date.today().year() - DateOfBirth.year();
                }
                return null;
            }
            set;
        } 
        @AuraEnabled public String IDType{get;set;}
        @AuraEnabled public String IDNumber{get;set;}
        @AuraEnabled public String groupPersonMovement{get;set;}
        @AuraEnabled public String Branch{get;set;}
        @AuraEnabled public String Department{get;set;}
        @AuraEnabled public Date EmploymentDate{get;set;}
        @AuraEnabled public String PreExist{get;set;}
        @AuraEnabled public String CertNo{get;set;}
        @AuraEnabled public String BankAccNo{get;set;}
        @AuraEnabled public String BankCode{get;set;}
        @AuraEnabled public String MaritalStatus{get;set;}
        @AuraEnabled public String EmailAddress{get;set;}
        @AuraEnabled public String Salary{get;set;}
        @AuraEnabled public String Occupation{get;set;}
        @AuraEnabled public String StationedCountry{get;set;}
        @AuraEnabled public String Nationality{get;set;}
        @AuraEnabled public String StaffID{get;set;}
        @AuraEnabled public String Alias{get;set;}
        @AuraEnabled public String CorrespondenceAddress{get;set;}
        @AuraEnabled public String CountryOfResidence{get;set;}
        @AuraEnabled public String MobileNumber{get;set;}
        @AuraEnabled public String HomeNumber{get;set;}
        @AuraEnabled public String OfficeNumber{get;set;}
        @AuraEnabled public String FamilyRecInd{get;set;}         

    }
    public class MovementResult{  //added by Connor CP-163
        @AuraEnabled public String ProcessID{get;set;}
        @AuraEnabled public String ProcessStatus{get;set;}
        @AuraEnabled public String FileName{get;set;}
        @AuraEnabled public String FileID{get;set;}
        @AuraEnabled public String ActionDate{get;set;}
        @AuraEnabled public List<Report> Reports{get;set;}
        @AuraEnabled public String ResultFileName{get;set;}
        @AuraEnabled public String ResultFileID{get;set;}
    }
    //added by Connor CP-163
    public class Report{
        public String FileDesp{get;set;}
        public String FileName{get;set;}
        public String FileID{get;set;}
        public String FileExt{get;set;}
        @AuraEnabled public String PolicyNum{get;set;}
        @AuraEnabled public String FilePdfName{get;set;}
        @AuraEnabled public String FileExcelName{get;set;}
        @AuraEnabled public String FilePdfID{get;set;}
        @AuraEnabled public String FileExcelID{get;set;}
    }

    // Client Portal
    public Class MemberAction{
        @AuraEnabled public String memberId{get;set;}
        @AuraEnabled public String policyNo{get;set;}
        @AuraEnabled public String effectiveDate{get;set;}
        @AuraEnabled public String planNo{get;set;}
        @AuraEnabled public String subPlan{get;set;}
        @AuraEnabled public String memberName{get;set;}
        @AuraEnabled public String gender{get;set;}
        @AuraEnabled public String dateOfBirth{get;set;}
        @AuraEnabled public String IDType{get;set;}
        @AuraEnabled public String IDNo{get;set;}
        @AuraEnabled public String stationedCountry{get;set;}
        @AuraEnabled public String nationality{get;set;}
        @AuraEnabled public String email{get;set;}
        @AuraEnabled public String termDate{get;set;}
        @AuraEnabled public String certNoControl{get;set;}
        @AuraEnabled public Boolean isGenderM{get;set;}
        @AuraEnabled public Boolean isGenderF{get;set;}
        @AuraEnabled public String branch{get;set;}
        @AuraEnabled public String dept{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String bankCode{get;set;}
        @AuraEnabled public String eedate{get;set;}
        @AuraEnabled public String staffNo{get;set;}
        @AuraEnabled public String alias{get;set;}
        @AuraEnabled public String bankNo{get;set;}
        @AuraEnabled public String position{get;set;}
        @AuraEnabled public String salary{get;set;}
        @AuraEnabled public String changeSeq{get;set;}
    }

    
    public class MemberInfo{  // for client portal, easy for deployment 
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String PolicyNo{get;set;}
        @AuraEnabled public String CertNo{get;set;}
        @AuraEnabled public String DOB{get;set;}
        @AuraEnabled public String IDType{get;set;}
        @AuraEnabled public String IDNo{get;set;}
        @AuraEnabled public String StCountry{get;set;}  //stationed country
        @AuraEnabled public String Nationality{get;set;}
        @AuraEnabled public String MaStatus{get;set;}  //marital status
        @AuraEnabled public String Email{get;set;}
        @AuraEnabled public String BankAcc{get;set;}
        @AuraEnabled public String bankCodePayMethod{get;set;}
        @AuraEnabled public String Gender{get;set;}
        @AuraEnabled public Boolean isGenderM{get;set;}
        @AuraEnabled public Boolean isGenderF{get;set;}
        @AuraEnabled public String StaffNo{get;set;}
        @AuraEnabled public String Plan{get;set;}
        @AuraEnabled public String Company{get;set;}
        @AuraEnabled public String Branch{get;set;}
        @AuraEnabled public String BranchDesc{get;set;}
        @AuraEnabled public String Dept{get;set;}   // department description
        @AuraEnabled public String deptCode{get;set;} // department code
        @AuraEnabled public String StartDate{get;set;}
        @AuraEnabled public String TermDate{get;set;}
        @AuraEnabled public String PlanNo{get;set;} 
        @AuraEnabled public String Role{get;set;}
        @AuraEnabled public Boolean dependentSign{get;set;}
        @AuraEnabled public String effectiveDate{get;set;}
        @AuraEnabled public String familyRecInd{get;set;}
        @AuraEnabled public String Occupation{get;set;}
        @AuraEnabled public String alias{get;set;}
        @AuraEnabled public String salary{get;set;}
        @AuraEnabled public String newPlan{get;set;}
        @AuraEnabled public String newEffDate{get;set;}
        @AuraEnabled public String employmentDate{get;set;}
        @AuraEnabled public String changeEmpDate{get;set;}
        @AuraEnabled public Boolean empDateShow = false;
        @AuraEnabled public String changeEffDate{get;set;}
        @AuraEnabled public Boolean effShow = false;
        @AuraEnabled public String changedName{get;set;}
        @AuraEnabled public Boolean nameShow = false;
        @AuraEnabled public String changedIDType{get;set;}
        @AuraEnabled public Boolean IDTypeShow = false;
        @AuraEnabled public String changedIDNo{get;set;}
        @AuraEnabled public Boolean IDNOShow = false;
        @AuraEnabled public String changedStCountry{get;set;}
        @AuraEnabled public Boolean stCountryShow = false;
        @AuraEnabled public String changedNationality{get;set;}
        @AuraEnabled public Boolean nationShow = false;
        @AuraEnabled public String changedMaStatus{get;set;}
        @AuraEnabled public Boolean maStatusShow = false;
        @AuraEnabled public String changedEmail{get;set;}
        @AuraEnabled public Boolean emailShow = false;
        @AuraEnabled public String changedGender{get;set;}
        @AuraEnabled public Boolean genderShow = false;
        @AuraEnabled public String changedDOB{get;set;}
        @AuraEnabled public Boolean showDOB = false;
        @AuraEnabled public String changedBranch{get;set;}
        @AuraEnabled public Boolean branchShow = false;
        @AuraEnabled public String changedDept{get;set;}
        @AuraEnabled public Boolean deptShow = false;
        @AuraEnabled public String changedPosition{get;set;}
        @AuraEnabled public Boolean positionShow = false;
        @AuraEnabled public String changedEmpId{get;set;}
        @AuraEnabled public Boolean empIDShow = false;
        @AuraEnabled public String changedAlias{get;set;}
        @AuraEnabled public Boolean aliasShow = false;
        @AuraEnabled public String newSalary{get;set;}
        @AuraEnabled public String changedPayMethod{get;set;}
        @AuraEnabled public Boolean payMethodShow = false;
        @AuraEnabled public String changedAccNo{get;set;}
        @AuraEnabled public Boolean accNoShow = false;
        @AuraEnabled public String maritalStatusCode{get;set;}
        @AuraEnabled public String idTypeCode{get;set;}
        @AuraEnabled public String stationedCountryCode{get;set;}
        @AuraEnabled public String govtID{get;set;}
        @AuraEnabled public Boolean isLife{get;set;}
        // Rancho_CP782_20220206 - check if have department setup in PolyEB
        @AuraEnabled public Boolean deptValid = false;
    }


    // Rancho_JOBR347_20231108 - doctor portal get member list
    public class DocMember{
        @AuraEnabled public String fullName{get;set;}
        @AuraEnabled public String surname{get;set;}
        @AuraEnabled public String givenName{get;set;}
        @AuraEnabled public String ssnNumber{get;set;}
        @AuraEnabled public String policyNo{get;set;}
        @AuraEnabled public String planName{get;set;}
        @AuraEnabled public String companyName{get;set;}
        @AuraEnabled public String residence{get;set;}
        @AuraEnabled public String age{get;set;}
        @AuraEnabled public String dob{get;set;}
        @AuraEnabled public String sex{get;set;}
        @AuraEnabled public String vasISOS{get;set;}// Y/N
        @AuraEnabled public String vasIMC{get;set;}// Y/N
        @AuraEnabled public String vasSMO{get;set;}// Y/N
        @AuraEnabled public String vasGMN{get;set;}// Y/N
        @AuraEnabled public String vasGC{get;set;}// Y/N
        
        //HKTISFDC-57 Begin Virtus Search
        @AuraEnabled public String opRider{get;set;}// Y/N
        @AuraEnabled public String endoscopy{get;set;}// Y/N
        // @AuraEnabled public String rateScale{get;set;}//
        //HKTISFDC-57 End Virtus Search

        // Rancho_HKITSFDC207_20250327 - display deductible fields for doctor portal virtus
        @AuraEnabled public String deductiblePlan{get;set;}// Y/N
        @AuraEnabled public String deductibleFulfilment{get;set;}// Y/N
    }
    
    // BEGIN BodyCheckEligibility
    public class BodyCheckEligibility{
        @AuraEnabled public String PlanDescription{get;set;}
        @AuraEnabled public String PolicyNumber{get;set;}
        @AuraEnabled public String CompanyName{get;set;}
        @AuraEnabled public String Residence{get;set;}
        @AuraEnabled public String Age{get;set;}
        @AuraEnabled public String DOB{get;set;}
        @AuraEnabled public String Sex{get;set;}
        @AuraEnabled public String Eligibility{get;set;}
        @AuraEnabled public String EffectiveDate{get;set;}
        @AuraEnabled public String ExpiryDate{get;set;}
        @AuraEnabled public String FullName{get;set;}
        @AuraEnabled public String GovtID{get;set;}
      
        //Blank attributes 
        
        @AuraEnabled public String BodyCheckPlanCode{get;set;}
        @AuraEnabled public String AvailableTests{get;set;}
        @AuraEnabled public String FirstName{get;set;}
        @AuraEnabled public String LastName{get;set;}
    }
    
    public class RedeemBodyCheck{
        @AuraEnabled public String RedeemId{get;set;}
        
        // Following 2 attributes based on the document
        @AuraEnabled public String PolicyNo{get;set;}
        @AuraEnabled public String BodyCheckID{get;set;}
    }
    
    public class BodyCheckHistoryRecordWrap{
        
        @AuraEnabled public List<BodyCheckHistoryRecord> bodyCheckHistoryRecord{get;set;}
        @AuraEnabled public String RecordsFound{get;set;}
    }
    
    public class BodyCheckHistoryRecord implements Comparable{
        
        @AuraEnabled public String PolicyNo{get;set;}
        @AuraEnabled public String BodyCheckID{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String ServiceDate{get;set;}
        @AuraEnabled public String CentreCode{get;set;}
        @AuraEnabled public String DoctorCode{get;set;}
        @AuraEnabled public Double ExtraCharge{get;set;}
        @AuraEnabled public String ExtraItem{get;set;}
        @AuraEnabled public String SubmissionDate{get;set;}
        @AuraEnabled public Double BilledAmount{get;set;}
        @AuraEnabled public Integer MaxRecord{get;set;}
        @AuraEnabled public Integer StartRecord{get;set;}
        @AuraEnabled public Integer NextRecord{get;set;}
        @AuraEnabled public String RecordsFound{get;set;}
        
        public Integer compareTo(Object o){
            if(this.SubmissionDate != null){
                BodyCheckHistoryRecord otherRecord = (BodyCheckHistoryRecord) o;
                // Converting SubmissionDate to DateTime
                DateTime thisDate = DateTime.valueOf(this.SubmissionDate);
                DateTime otherDate = DateTime.valueOf(otherRecord.SubmissionDate);
                
                if(thisDate > otherDate){
                    return 1;
                } else if(thisDate < otherDate){
                    return -1;
                } else {
                    return 0;
                }
            } else{
                // Handling null cases
                BodyCheckHistoryRecord otherRecord = (BodyCheckHistoryRecord) o;
                if(this.SubmissionDate != null){
                    return 1;
                } else if (otherRecord.SubmissionDate !=null) {
                    return -1;
                } else {
                    return 0;
                }
            }
        }
    }
    
// END BodyCheckEligibility

    
}