import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent, NavigationMixin } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { IsConsoleNavigation, openSubtab, getTabInfo, getFocusedTabInfo, EnclosingTabId, setTabIcon, setTabLabel } from 'lightning/platformWorkspaceApi';

// import apex class function
import getTranslations from '@salesforce/apex/CSPolicyDetailLWCCtrl.getTranslations';
import getPolicyBasic from '@salesforce/apex/CSPolicyDetailLWCCtrl.getPolicyBasic';
import getPolicyBeneficiaryBasicList from '@salesforce/apex/CSPolicyDetailLWCCtrl.getPolicyBeneficiaryBasicList';
import getPolicyPaymentBasic from '@salesforce/apex/CSPolicyDetailLWCCtrl.getPolicyPaymentBasic';
import getPolicyBillingListBasic from '@salesforce/apex/CSPolicyDetailLWCCtrl.getPolicyBillingListBasic';
import getCoverageBasic4PaymentInfo from '@salesforce/apex/CSPolicyDetailLWCCtrl.getCoverageBasic4PaymentInfo';
import getPolicyClaimHistory from '@salesforce/apex/CSPolicyDetailLWCCtrl.getPolicyClaimHistory';
import getDocuments from '@salesforce/apex/CSPolicyDetailLWCCtrl.getDocuments';
import toggleDocState from '@salesforce/apex/CSPolicyDetailLWCCtrl.toggleDocState';
import getPolicyPersonCoverageBasic from '@salesforce/apex/CSPolicyDetailLWCCtrl.getPolicyPersonCoverageBasic';
import cancelPolicy from '@salesforce/apex/CSPolicyDetailLWCCtrl.cancelPolicy';
import resendWelcomeEmail from '@salesforce/apex/CSPolicyDetailLWCCtrl.resendWelcomeEmail';
import getDoc2 from '@salesforce/apex/CSPolicyDetailLWCCtrl.getDoc2';
import checkIsDocumentDownloadComplete from '@salesforce/apex/CSPolicyDetailLWCCtrl.checkIsDocumentDownloadComplete';
import validateCreditCardNumber from '@salesforce/apex/CSPolicyDetailLWCCtrl.validateCreditCardNumber';
import getCIProductCodes from '@salesforce/apex/CSPolicyDetailLWCCtrl.getCIProductCodes'; // HKITSFDC- 416


// import custom labels
import Pol_Policy_Information from '@salesforce/label/c.Pol_Policy_Information';
import Pol_Claim_History from '@salesforce/label/c.Pol_Claim_History';
import Pol_Coverage_Information from '@salesforce/label/c.Pol_Coverage_Information';
import Pol_Policy_No from '@salesforce/label/c.Pol_Policy_No';
import Pol_Policy_Effective_Date from '@salesforce/label/c.Pol_Policy_Effective_Date';
import Pol_Product_Name from '@salesforce/label/c.Pol_Product_Name';
import Pol_Product_Code from '@salesforce/label/c.Pol_Product_Code';
import Pol_Policy_Status from '@salesforce/label/c.Pol_Policy_Status';
import Pol_Payment_Mode from '@salesforce/label/c.Pol_Payment_Mode';
import Pol_Currency from '@salesforce/label/c.Pol_Currency';
import Pol_Paid_to_Date from '@salesforce/label/c.Pol_Paid_to_Date';
import Pol_Broker_Company from '@salesforce/label/c.Pol_Broker_Company';
import Pol_Broker_Contact_Person from '@salesforce/label/c.Pol_Broker_Contact_Person';
import Broker_Contact_No from '@salesforce/label/c.Broker_Contact_No';
import Pol_Broker_Code from '@salesforce/label/c.Pol_Broker_Code';
import Pol_Broker_Name from '@salesforce/label/c.Pol_Broker_Name';
import Source_System from '@salesforce/label/c.Source_System';
import IPAS_Ref_1 from '@salesforce/label/c.IPAS_Ref_1';
import IPAS_Ref_2 from '@salesforce/label/c.IPAS_Ref_2';
import IPAS_Ref_3 from '@salesforce/label/c.IPAS_Ref_3';
import IPAS_Ref_4 from '@salesforce/label/c.IPAS_Ref_4';
import IPAS_Ref_5 from '@salesforce/label/c.IPAS_Ref_5';
import IPAS_Ref_6 from '@salesforce/label/c.IPAS_Ref_6';
import IPAS_Ref_7 from '@salesforce/label/c.IPAS_Ref_7';
import CAPSIL_Ref from '@salesforce/label/c.CAPSIL_Ref';
import S6_Ref_1 from '@salesforce/label/c.S6_Ref_1';
import S6_Ref_2 from '@salesforce/label/c.S6_Ref_2';
import S6_Ref_3 from '@salesforce/label/c.S6_Ref_3';
import ILAS_Application_Date from '@salesforce/label/c.ILAS_Application_Date';
import Hardcopy_Medical_Card_Indicator from '@salesforce/label/c.Hardcopy_Medical_Card_Indicator';
import Pol_SellerName from '@salesforce/label/c.Pol_SellerName';
import Pol_Campaign_Code from '@salesforce/label/c.Pol_Campaign_Code';
import Pol_Retention_Eligibility_title from '@salesforce/label/c.Pol_Retention_Eligibility_title';
import Pol_Current_Insured_Age from '@salesforce/label/c.Pol_Current_Insured_Age';
import Pol_Days_Since_Policy from '@salesforce/label/c.Pol_Days_Since_Policy';
import Pol_Total_IP_Claim_Amt from '@salesforce/label/c.Pol_Total_IP_Claim_Amt';
import Pol_Retention_Health_Eligible from '@salesforce/label/c.Pol_Retention_Health_Eligible';
import Pol_Policy_holder_Information from '@salesforce/label/c.Pol_Policy_holder_Information';
import Pol_Policy_Holder from '@salesforce/label/c.Pol_Policy_Holder';
import Pol_Gender from '@salesforce/label/c.Pol_Gender';
import Pol_Date_of_Birth from '@salesforce/label/c.Pol_Date_of_Birth';
import Pol_Policyholder_ID_Passport_No from '@salesforce/label/c.Pol_Policyholder_ID_Passport_No';
import ILAS_RPQ_Status from '@salesforce/label/c.ILAS_RPQ_Status';
import ILAS_RPQ_Effective_Date from '@salesforce/label/c.ILAS_RPQ_Effective_Date';
import Pol_Contact_Information from '@salesforce/label/c.Pol_Contact_Information';
import CS_Mobile from '@salesforce/label/c.CS_Mobile';
import CS_Home_Phone from '@salesforce/label/c.CS_Home_Phone';
import CS_Business_Phone from '@salesforce/label/c.CS_Business_Phone';
import CS_Home_Fax from '@salesforce/label/c.CS_Home_Fax';
import CS_Business_Fax from '@salesforce/label/c.CS_Business_Fax';
import CS_Other_Phone from '@salesforce/label/c.CS_Other_Phone';
import CS_Correspondence_Phone from '@salesforce/label/c.CS_Correspondence_Phone';
import Pol_Email from '@salesforce/label/c.Pol_Email';
import Pol_Correspondence_Address from '@salesforce/label/c.Pol_Correspondence_Address';
import Pol_Person_s_Insured from '@salesforce/label/c.Pol_Person_s_Insured';
import Pol_Person_Insured from '@salesforce/label/c.Pol_Person_Insured';
import Pol_Person_Insured_ID_Passport_No from '@salesforce/label/c.Pol_Person_Insured_ID_Passport_No';
import Pol_Beneficiary_List from '@salesforce/label/c.Pol_Beneficiary_List';
import Pol_Beneficiary from '@salesforce/label/c.Pol_Beneficiary';
import Pol_Payment_Information from '@salesforce/label/c.Pol_Payment_Information';
import Pol_Total_Modal_Premium from '@salesforce/label/c.Pol_Total_Modal_Premium';
import Pol_Payment_Method from '@salesforce/label/c.Pol_Payment_Method';
import Pol_Account_No from '@salesforce/label/c.Pol_Account_No';
import Pol_Card_Type from '@salesforce/label/c.Pol_Card_Type';
import Pol_Debit_Day from '@salesforce/label/c.Pol_Debit_Day';
import Pol_Payor_ID from '@salesforce/label/c.Pol_Payor_ID';
import Pol_Credit_Card_Expiry_Date from '@salesforce/label/c.Pol_Credit_Card_Expiry_Date';
import Pol_Autopay_limit from '@salesforce/label/c.Pol_Autopay_limit';
import Pol_Payor from '@salesforce/label/c.Pol_Payor';
import Pol_Start_Date_of_Automatic_Premium_Payment from '@salesforce/label/c.Pol_Start_Date_of_Automatic_Premium_Payment';
import Pol_End_Date_of_Automatic_Premium_Payment from '@salesforce/label/c.Pol_End_Date_of_Automatic_Premium_Payment';
import Pol_Latest_Autopay_Reject_Date_And_Reason from '@salesforce/label/c.Pol_Latest_Autopay_Reject_Date_And_Reason';
import Only_Numeric_Input_Is_Allowed from '@salesforce/label/c.Only_Numeric_Input_Is_Allowed';
import Credit_Card_Number_Validation_Result from '@salesforce/label/c.Credit_Card_Number_Validation_Result';
import Account_No_Masked_Part from '@salesforce/label/c.Account_No_Masked_Part';
import Pol_Transaction_History from '@salesforce/label/c.Pol_Transaction_History';
import Pol_Transaction_Date from '@salesforce/label/c.Pol_Transaction_Date';
import Pol_Description from '@salesforce/label/c.Pol_Description';
import Pol_Bill_Amount from '@salesforce/label/c.Pol_Bill_Amount';
import Pol_Bill_Date from '@salesforce/label/c.Pol_Bill_Date';
import Pol_Billing_Start_Date from '@salesforce/label/c.Pol_Billing_Start_Date';
import Pol_Period from '@salesforce/label/c.Pol_Period';
import Pol_Status from '@salesforce/label/c.Pol_Status';
import Pol_Autopay_Premium_Reject_Reason from '@salesforce/label/c.Pol_Autopay_Premium_Reject_Reason';
import Pol_Paid_Date from '@salesforce/label/c.Pol_Paid_Date';
import Pol_Collector from '@salesforce/label/c.Pol_Collector';
import Pol_Discount_Offered from '@salesforce/label/c.Pol_Discount_Offered';
import Pol_Loading_Coverage_Level from '@salesforce/label/c.Pol_Loading_Coverage_Level';
import Pol_Exclusion_Coverage_Level from '@salesforce/label/c.Pol_Exclusion_Coverage_Level';
import Pol_Claim_No from '@salesforce/label/c.Pol_Claim_No';
import Pol_Claim_Type from '@salesforce/label/c.Pol_Claim_Type';
import Pol_Received_Date from '@salesforce/label/c.Pol_Received_Date';
import Pol_Claim_Status from '@salesforce/label/c.Pol_Claim_Status';
import Pol_Claim_Period_From from '@salesforce/label/c.Pol_Claim_Period_From';
import Pol_Claim_Period_To from '@salesforce/label/c.Pol_Claim_Period_To';
import Pol_Paid_Amount from '@salesforce/label/c.Pol_Paid_Amount';
import Pol_Last_Update_Date from '@salesforce/label/c.Pol_Last_Update_Date';
import CP_Claims_Histories_Portal from '@salesforce/label/c.CP_Claims_Histories_Portal';
import Policy_No from '@salesforce/label/c.Policy_No';
import Claim_Detial from '@salesforce/label/c.Claim_Detial';
import Claim_Type from '@salesforce/label/c.Claim_Type';
import Person_Insured from '@salesforce/label/c.Person_Insured';
import Submission_Date from '@salesforce/label/c.Submission_Date';
import Claim_Histroy_Status from '@salesforce/label/c.Claim_Histroy_Status';
import Pol_Claims_Status from '@salesforce/label/c.Pol_Claims_Status';
import Pol_Policy_Documents from '@salesforce/label/c.Pol_Policy_Documents';
import efulfillment_policy_correspondences from '@salesforce/label/c.efulfillment_policy_correspondences';
import Pol_Benefit from '@salesforce/label/c.Pol_Benefit';
import Pol_Sum_Insured from '@salesforce/label/c.Pol_Sum_Insured';
import Pol_Deductible_Amount from '@salesforce/label/c.Pol_Deductible_Amount';
import Pol_Effective_Date from '@salesforce/label/c.Pol_Effective_Date';
import Pol_Additional_Fund_Contribution_Amount from '@salesforce/label/c.Pol_Additional_Fund_Contribution_Amount';
import Pol_Additional_Fund_Contribution_Annual_Amount from '@salesforce/label/c.Pol_Additional_Fund_Contribution_Annual_Amount';
import Pol_Maturity_Expiry_Date from '@salesforce/label/c.Pol_Maturity_Expiry_Date';
import Pol_Benefit_Status from '@salesforce/label/c.Pol_Benefit_Status';
import Pol_Face_Amount from '@salesforce/label/c.Pol_Face_Amount';
import Pol_Renewal_Segment from '@salesforce/label/c.Pol_Renewal_Segment';
import Pol_Internal_Product_Name from '@salesforce/label/c.Pol_Internal_Product_Name';
import Pol_Actual_Segment from '@salesforce/label/c.Pol_Actual_Segment';
import Pol_NCD_Eligibility from '@salesforce/label/c.Pol_NCD_Eligibility';
import Pol_NCD_Percentage from '@salesforce/label/c.Pol_NCD_Percentage';
// START HKITSFDC- 416
import Pol_Remaining_Sum_Insured from '@salesforce/label/c.Pol_Remaining_Sum_Insured';
import Pol_Coverage_Period from '@salesforce/label/c.Pol_Coverage_Period';
import Pol_to from '@salesforce/label/c.Pol_to';
// END HKITSFDC- 416

export default class CSPolicyDetail extends LightningElement {
    @api policyNo = '';//'CTA9009896';
    @api effDate;//new Date('2021-05-07');
    @api holderSSN = '';//'G511262';
    @api sourceAccId = '';
    @track transField = [];
    @track policy = {};
    @track healthMigrationCancelPolicyId = '';
    @track holder = {};
    @track payment = {};
    @track couponList = [];
    @track discountList = [];
    @track insuredList = [];
    @track beneficiaryList = [];
    @track billingList = [];
    @track allBillingList = [];
    @track exclusionList = [];
    @track loadingList = [];
    @track ncdList = [];
    @track retentionList = [];
    @track claimList = [];
    @track allClaimList = [];
    @track filterClaimList = [];
    @track claimHistoryList = [];
    @track allClaimHistoryList = [];
    @track filterClaimHistoryList = [];
    @track docYear = '';
    @track docList = [];
    @track docYearMap = {};
    @track docYearList = [];
    @track corDocYear = '';
    @track corDocList = [];
    @track corDocYearMap = {};
    @track corDocYearList = [];
    @track isLoading = false;
    @track paymentMode = '';
    @track bankCode = '';
    @track bankAccount = '';
    @track personInsureId = '';
    @track customerAccountId = '';
    @track tmName = '';
    @track showDeductible = false;
    @track showAFCcolumns = false;
    @track showCIcolumns = false; // HKITSFDC-416
    @track showCoverage = false; // HKITSFDC-416
    @track isCS = false;
    @track isTM = false;
    @track displayResult = false;
    @track invalidString = false;
    @track validationResult = '';
    @track coverageList = [];
    @track allCoverageList = [];
    @track ciCodes = []; // HKITSFDC-416
    @track claimStatus = 'All';
    @track generalPageSize = 20;
    @track billingCurrentPage = 1;
    @track billingTotalRecords = 0;
    @track claimCurrentPage = 1;
    @track claimTotalRecords = 0;
    @track claimHistroyCurrentPage = 1;
    @track claimHistroyTotalRecords = 0;
    @track coverageCurrentPage = 1;
    @track coverageTotalRecords = 0;
    
    label = {
        Pol_Policy_Information,
        Pol_Claim_History,
        Pol_Coverage_Information,
        Pol_Policy_No,
        Pol_Policy_Effective_Date,
        Pol_Product_Name,
        Pol_Product_Code,
        Pol_Policy_Status,
        Pol_Payment_Mode,
        Pol_Currency,
        Pol_Paid_to_Date,
        Pol_Broker_Company,
        Pol_Broker_Contact_Person,
        Broker_Contact_No,
        Pol_Broker_Code,
        Pol_Broker_Name,
        Source_System,
        IPAS_Ref_1,
        IPAS_Ref_2,
        IPAS_Ref_3,
        IPAS_Ref_4,
        IPAS_Ref_5,
        IPAS_Ref_6,
        IPAS_Ref_7,
        CAPSIL_Ref,
        S6_Ref_1,
        S6_Ref_2,
        S6_Ref_3,
        ILAS_Application_Date,
        Hardcopy_Medical_Card_Indicator,
        Pol_SellerName,
        Pol_Campaign_Code,
        Pol_Retention_Eligibility_title,
        Pol_Current_Insured_Age,
        Pol_Days_Since_Policy,
        Pol_Total_IP_Claim_Amt,
        Pol_Retention_Health_Eligible,
        Pol_Policy_holder_Information,
        Pol_Policy_Holder,
        Pol_Gender,
        Pol_Date_of_Birth,
        Pol_Policyholder_ID_Passport_No,
        ILAS_RPQ_Status,
        ILAS_RPQ_Effective_Date,
        Pol_Contact_Information,
        CS_Mobile,
        CS_Home_Phone,
        CS_Business_Phone,
        CS_Home_Fax,
        CS_Business_Fax,
        CS_Other_Phone,
        CS_Correspondence_Phone,
        Pol_Email,
        Pol_Correspondence_Address,
        Pol_Person_s_Insured,
        Pol_Person_Insured,
        Pol_Person_Insured_ID_Passport_No,
        Pol_Beneficiary_List,
        Pol_Beneficiary,
        Pol_Payment_Information,
        Pol_Total_Modal_Premium,
        Pol_Payment_Method,
        Pol_Account_No,
        Pol_Card_Type,
        Pol_Debit_Day,
        Pol_Payor_ID,
        Pol_Credit_Card_Expiry_Date,
        Pol_Autopay_limit,
        Pol_Payor,
        Pol_Start_Date_of_Automatic_Premium_Payment,
        Pol_End_Date_of_Automatic_Premium_Payment,
        Pol_Latest_Autopay_Reject_Date_And_Reason,
        Only_Numeric_Input_Is_Allowed,
        Credit_Card_Number_Validation_Result,
        Account_No_Masked_Part,
        Pol_Transaction_History,
        Pol_Transaction_Date,
        Pol_Description,
        Pol_Bill_Amount,
        Pol_Bill_Date,
        Pol_Billing_Start_Date,
        Pol_Period,
        Pol_Status,
        Pol_Autopay_Premium_Reject_Reason,
        Pol_Paid_Date,
        Pol_Collector,
        Pol_Discount_Offered,
        Pol_Loading_Coverage_Level,
        Pol_Exclusion_Coverage_Level,
        Pol_Claim_No,
        Pol_Claim_Type,
        Pol_Received_Date,
        Pol_Claim_Status,
        Pol_Claim_Period_From,
        Pol_Claim_Period_To,
        Pol_Paid_Amount,
        Pol_Last_Update_Date,
        CP_Claims_Histories_Portal,
        Policy_No,
        Claim_Detial,
        Claim_Type,
        Person_Insured,
        Submission_Date,
        Claim_Histroy_Status,
        Pol_Claims_Status,
        Pol_Policy_Documents,
        efulfillment_policy_correspondences,
        Pol_Benefit,
        Pol_Sum_Insured,
        Pol_Deductible_Amount,
        Pol_Effective_Date,
        Pol_Additional_Fund_Contribution_Amount,
        Pol_Additional_Fund_Contribution_Annual_Amount,
        Pol_Maturity_Expiry_Date,
        Pol_Benefit_Status,
        Pol_Face_Amount,
        Pol_Renewal_Segment,
        Pol_Internal_Product_Name,
        Pol_Actual_Segment,
        Pol_NCD_Eligibility,
        Pol_NCD_Percentage,
        // START HKITSFDC- 416
        Pol_Remaining_Sum_Insured,
        Pol_Coverage_Period,
        Pol_to
        // END HKITSFDC- 416
    }

    async adjustLoadingPosition() {
        console.log('adjustLoadingPosition');
        const info = await getFocusedTabInfo();
        console.log('info: ', info);

        const hasSubtab = info?.isSubtab === true || (info.subtabs && info.subtabs.length > 0);
        const topOffset = hasSubtab ? '180px' : '140px';
        console.log('hasSubtab: ', hasSubtab);
        console.log('topOffset: ', topOffset);
        
        const overlay = this.template.querySelector('.content-container');
        if (overlay) {
            overlay.style.setProperty('--loading-top-offset', topOffset);
        }
    }

    @wire(getTranslations)
    wiredTranslations({ error, data }) {
        console.log('wiredTranslations');
        if (data) {
            console.log('get transalate data');
            this.transField = data;
            console.log('transField: ', this.transField);
            this.error = undefined;
        } else if (error) {
            console.log('get transalate error: ', error);
            this.error = error;
            this.transField = [];
        }
    }

    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) tabId;

    @wire(CurrentPageReference)
    getPageRef(currentPageReference) {
        console.log('getPageRef');
        if (currentPageReference) {
            this.policyNo = currentPageReference.state.c__policyNo;
            this.effDate = currentPageReference.state.c__effDate;
            this.holderSSN = currentPageReference.state.c__holderSSN;
            this.sourceAccId = currentPageReference.state.c__sourceAccId;
            console.log('Received params:', currentPageReference.state);
            console.log('>>> policyNo: ', this.policyNo);
            console.log('>>> effDate: ', this.effDate);
            console.log('>>> holderSSN: ', this.holderSSN);
            console.log('>>> sourceAccId: ', this.sourceAccId);

            console.log('start loading');
            this.loadData()
            // if effDate and holderSSN are provided, load the data directly
            // otherwise, load the data after policy info returned
            if (this.effDate && this.holderSSN) {
                this.getBeneficiaryList();
                this.getPaymentList();
                this.getBillingList();
                this.getCoverageForPayment();
                this.getClaimList();
                this.getDocumentList();
            }
        }
    }

    connectedCallback(event) {
        console.log('connected callback');

        getCIProductCodes()
            .then(result => {
                console.log('Loaded CI Product Codes:', result);
                this.ciCodes = result || [];
            })
            .catch(error => {
                console.error('Error loading CI Product Codes:', error);
            });

        if (this.tabId && this.isConsoleNavigation) {
            getTabInfo(this.tabId).then((tabInfo) => {
                console.log('tabInfo: ', tabInfo);
                setTabLabel(this.tabId, 'Policy Detail');
                setTabIcon(this.tabId, 'utility:edit_form');
            });
        }

        this.loadData();
    }


    renderedCallback() {
        console.log('renderedCallback');
        this.adjustLoadingPosition();
    }

    getBeneficiaryList() {
        console.log('>>> beneficiary list <<<');
        if (this.policyNo) {
            getPolicyBeneficiaryBasicList({policyNo: this.policyNo}).then(data => {
                console.log('getBeneficiaryList data: ', data);
                if (data) {
                    this.beneficiaryList = data.map((beneficiary, index) => ({
                        ...beneficiary,
                        displayIndex: index + 1
                    }));
                }
            }).catch(error => {
                console.log('getBeneficiaryList error: ', error);
            });
        }
    }

    getPaymentList() {
        console.log('>>> payment list <<<');
        if (this.policyNo) {
            getPolicyPaymentBasic({policyNo: this.policyNo}).then(data => {
                console.log('getPaymentList data: ', data);
                if (data) {
                    this.payment = data;
                    if (this.payment.discountList) {
                        this.discountList = this.payment.discountList;
                    }
                    if (this.payment.couponList) {
                        this.couponList = this.payment.couponList;
                    }
                }
            }).catch(error => {
                console.log('getPaymentList error: ', error);
            });
        }
    }

    getBillingList() {
        console.log('>>> billing list <<<');
        if (this.policyNo) {
            getPolicyBillingListBasic({policyNo: this.policyNo}).then(data => {
                console.log('getBillingList data: ', data);
                if (data) {
                    this.allBillingList = data.map((billing, index) => ({
                        ...billing,
                        formattedAmount: this.formatCurrencyWithCustomNegative(billing.finActivityGrossAmt, billing.currencySymbol),
                        displayIndex: index
                    }));
                    this.billingList = this.allBillingList.slice(0, this.generalPageSize);
                    this.billingTotalRecords = this.allBillingList.length;
                    this.billingCurrentPage = 1;
                    console.log('billingList: ', this.billingList);
                }
            }).catch(error => {
                console.log('getBillingList error: ', error);
            });
        }
    }

    formatCurrencyWithCustomNegative(amount, currencyCode) {
        const isNegative = amount < 0;
        const absoluteAmount = Math.abs(amount);
        
        const formattedAmount = absoluteAmount.toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
        
        if (isNegative) {
            return `${currencyCode} -${formattedAmount}`;
        } else {
            return `${currencyCode} ${formattedAmount}`;
        }
    }

    getCoverageForPayment() {
        console.log('>>> coverage list <<<');
        if (this.policyNo) {
            getCoverageBasic4PaymentInfo({policyNo: this.policyNo}).then(data => {
                console.log('getCoverageList data: ', data);
                if (data) {
                    if (data.exclusionList) {
                        this.exclusionList = data.exclusionList;
                    }
                    if (data.loadingList) {
                        this.loadingList = data.loadingList;
                    }
                }
            }).catch(error => {
                console.log('getCoverageList error: ', error);
            });
        }
    }

    getClaimList() {
        console.log('>>> claim list <<<');
        if (this.policyNo) {
            getPolicyClaimHistory({policyNo: this.policyNo}).then(data => {
                console.log('getClaimList data: ', data);
                if (data) {
                    if (data.claimList) {
                        this.allClaimList = data.claimList;
                        this.filterClaimList = data.claimList;
                        this.claimList = this.allClaimList.slice(0, this.generalPageSize);
                        this.claimTotalRecords = this.allClaimList.length;
                        this.claimCurrentPage = 1;
                        console.log('claimList: ', this.claimList.length);
                    }
                    if (data.claimHistoryList) {
                        this.allClaimHistoryList = data.claimHistoryList;
                        this.filterClaimHistoryList = data.claimHistoryList;
                        this.claimHistoryList = this.allClaimHistoryList.slice(0, this.generalPageSize);
                        this.claimHistroyTotalRecords = this.allClaimHistoryList.length;
                        this.claimHistroyCurrentPage = 1;
                        console.log('claimHistoryList: ', this.claimHistoryList.length);
                    }
                }
            }).catch(error => {
                console.log('getClaimList error: ', error);
            });
        }
    }

    getDocumentList() {
        console.log('>>> document list <<<');
        if (this.policyNo && this.effDate && this.holderSSN) {
            getDocuments({policyNo: this.policyNo, effDate: this.effDate, holderSSN: this.holderSSN}).then(data => {
                console.log('get document list');
                if (data) {
                    console.log('getDocuments data: ', data);
                    // policy document
                    if (data.docYearMap) {
                        this.docYearMap = data.docYearMap;
                    }
                    if (data.docYearList && data.docYearList.length > 0) {
                        this.docYearList = data.docYearList;
                        console.log('docYearList: ', this.docYearList);
                        this.docYear = this.docYearList[this.docYearList.length - 1].value;
                        console.log('Last value of docYearList: ', this.docYear);
                        
                        if (this.docYearMap[this.docYear]) {
                            this.docList = this.docYearMap[this.docYear];
                        }
                        console.log('docList: ', this.docList);
                    }

                    // policy correspondence
                    if (data.corDocYearMap) {
                        this.corDocYearMap = data.corDocYearMap;
                    }
                    if (data.corDocYearList && data.corDocYearList.length > 0) {
                        this.corDocYearList = data.corDocYearList;
                        console.log('corDocYearList: ', this.corDocYearList);
                        this.corDocYear = this.corDocYearList[this.corDocYearList.length - 1].value;
                        console.log('Last value of corDocYearList: ', this.corDocYear);
                        
                        this.corDocList = this.corDocYearMap[this.corDocYear];
                        console.log('corDocList: ', this.corDocList);
                    }

                    this.customerAccountId = data.customerAccountId;
                }
            }).catch(error => {
                console.log('getDocuments error: ', error);
            });
        }
    }

    getCoverageList() {
        console.log('>>> coverage list <<<');
        if (this.policyNo) {
            getPolicyPersonCoverageBasic({policyNo: this.policyNo}).then(data => {
                console.log('getCoverageList data: ', data);
                if (data) {
                    this.showDeductible = data.showDeductible;
                    this.showAFCcolumns = data.showAFCcolumns;

                    if (data.coverageList) {
                        this.allCoverageList = data.coverageList.map(coverage => {
                            const newCoverage = { ...coverage };
                            
                            if (this.policy && this.policy.policyStatusDisplayName !== 'Inforce') {
                                newCoverage.maturityExpiryDateInDate = this.policy.termDateInDate;
                            } else {
                                newCoverage.maturityExpiryDateInDate = coverage.termDateInDate;
                            }
                            newCoverage.isAFCR = coverage.benefitCode.startsWith('AFCR');
                            newCoverage.isAFCS = coverage.benefitCode.startsWith('AFCS');
                            return newCoverage;
                        });

                        this.coverageList = this.allCoverageList.slice(0, this.generalPageSize);
                        this.coverageTotalRecords = this.allCoverageList.length;
                        this.coverageCurrentPage = 1;
                        console.log('coverageList: ', this.coverageList);

                        // START HKITSFDC-416
                        const hasNotTakenCoverage = this.allCoverageList.some(coverage => coverage.coverageStatus && coverage.coverageStatus.toLowerCase() === 'not taken');
                        this.showCoverage = hasNotTakenCoverage;
                        console.log('showCoverage: ', this.showCoverage);
                        // END HKITSFDC-416
                    }
                }

            }).catch(error => {
                console.log('getCoverageList error: ', error);
            });
        }
    }

    loadData() {
        this.isLoading = true;
        getPolicyBasic({ policyNo: this.policyNo, sourceAccId: this.sourceAccId }).then(data => {
            console.log('getPolicyBasic data: ', data);
            if (data.policy) {
                this.policy = {
                    ...data.policy,
                    isElite: data.policy.marketingName && data.policy.marketingName.toLowerCase().includes('elite'),
                    isDMB: data.policy.productCode && data.policy.productCode.startsWith('DMB'),
                    isHealthMigration: data.policy.sourceCode === 'C',
                    ref1: data.policy.referenceList && data.policy.referenceList.length > 0 ? data.policy.referenceList[0].referenceDesc : '',
                    ref2: data.policy.referenceList && data.policy.referenceList.length > 1 ? data.policy.referenceList[1].referenceDesc : '',
                    ref3: data.policy.referenceList && data.policy.referenceList.length > 2 ? data.policy.referenceList[2].referenceDesc : '',
                    ref4: data.policy.referenceList && data.policy.referenceList.length > 3 ? data.policy.referenceList[3].referenceDesc : '',
                    ref5: data.policy.referenceList && data.policy.referenceList.length > 4 ? data.policy.referenceList[4].referenceDesc : '',
                    ref6: data.policy.referenceList && data.policy.referenceList.length > 5 ? data.policy.referenceList[5].referenceDesc : '',
                    ref7: data.policy.referenceList && data.policy.referenceList.length > 6 ? data.policy.referenceList[6].referenceDesc : '',
                };

                // START HKITSFDC-416
                this.showCIcolumns = this.policy.productCode && this.ciCodes.includes(this.policy.productCode);
                console.log('showCIcolumns: ', this.showCIcolumns);
                // END HKITSFDC-416

                if(this.policy.SellerId && this.policy.sellerName){
                    this.tmName = this.policy.SellerId + ' - ' + this.policy.sellerName;
                } else if(this.policy.SellerId){
                    this.tmName = this.policy.SellerId;
                } else if(this.policy.sellerName){
                    this.tmName = this.policy.sellerName;
                }

                this.ncdList.push({
                    ncdPercentage: data.policy.NcdInd == 'N' ? '0%' : (Math.round(data.policy.NcdPercentage * 10) / 10) + '%',
                    ncdInd: data.policy.NcdInd
                });
                
                const allDays = data.policy.daysSincePolicyEffectiveDate;
                const year = allDays ? Math.floor(allDays / 365) : 0;
                const remainingDays = allDays ? (allDays % 365) : 0;
                const month = allDays ? Math.floor(remainingDays / 30) : 0;
                const day = allDays ? (remainingDays % 30) : 0;

                this.retentionList.push({
                    currentInsuredAge: data.policy.currentInsuredAge,
                    policyDays: year + ' Y ' + month + ' M ' + day + ' D',
                    totalIpClaimAmt: data.policy.totalIpClaimAmt,
                    retentionHealthEligible: data.policy.retentionHealthEligible
                });
            }

            if (data.holder) {
                this.holder = data.holder;
            }
            
            if (data.insuredList) {
                this.insuredList = data.insuredList;
                
                let bankInfo = this.insuredList[0].bankAccount;
                if (bankInfo) {
                    this.paymentMode = bankInfo.payMethod;
                    this.bankCode = bankInfo.bankCode;
                    this.bankAccount = bankInfo.accountNumber;
                }

                this.getCoverageList();
            }

            if (!this.effDate && !this.holderSSN) {
                this.effDate = this.policy.effDateInDate;
                this.holderSSN = this.holder.ssnNumber;
                console.log('>>> effDate: ', this.effDate);
                console.log('>>> holderSSN: ', this.holderSSN);

                this.getBeneficiaryList();
                this.getPaymentList();
                this.getBillingList();
                this.getCoverageForPayment();
                this.getClaimList();
                this.getDocumentList();
            }

            this.personInsureId = data.personInsureId;
            this.healthMigrationCancelPolicyId = data.healthMigrationCancelPolicyId;
            this.isCS = data.isCS;
            this.isTM = data.isTM;
            this.isLoading = false;
        }).catch(error => {
            console.log('getPolicyBasic error: ', error);
            this.isLoading = false;
            this.showErrorToast(error.body.message);
        });
    }

    async handleGoToCustomerProfile(event) {
        console.log('event: ', event.target.dataset);
        const accountId = event.target.dataset.accountId;

        if (this.isConsoleNavigation) {
            console.log('in console navigation');
            const parentTab = await getFocusedTabInfo();
            let parentTabId = '';
            if (parentTab && parentTab.isSubtab) {
                parentTabId = parentTab.parentTabId;
            } else {
                parentTabId = parentTab.tabId;
            }
            console.log('parent tab: ', parentTabId);
            
            openSubtab(parentTabId, {
                recordId: accountId,
                focus: true
            }).then((subtabId) => {
                console.log('open subtab success, subtabId: ' + subtabId);
                this.isLoading = false;
            }).catch((error) => {
                console.error('open subtab error:', error);
                this.isLoading = false;
                this.navigateToRecord(accountId);
            });
        } else {
            this.navigateToRecord(accountId);
        }
    }

    navigateToRecord(accountId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
        this.isLoading = false;
    }

    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast(message) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    toggleSection(eve){
    	let sectionId = eve.target.dataset.sectionid;
    	console.info("sectionId", sectionId);
    	if(sectionId) {
	    	const sectionEle = this.template.querySelector("div[name='"+sectionId + "']");
	    	if(sectionEle.className.search("slds-is-open") == -1){
	    		sectionEle.className = 'slds-section slds-is-open';
	    	}else {
	    		sectionEle.className = 'slds-section slds-is-close';
	    	}
    	}
    }

    get claimStatusOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Cancelled', value: 'Cancelled' },
            { label: 'Processing', value: 'Processing' },
            { label: 'Paid', value: 'Paid' },
            { label: 'Reversal', value: 'Reversal' },
            { label: 'Rejected', value: 'Rejected' },
            { label: 'Pending Information', value: 'Pending Information' },
        ];
    }

    handleClaimStatusChange(event) {
        this.claimStatus = event.detail.value;
        console.log('selected claim status: ', this.claimStatus);
        if (this.claimStatus === 'All') {
            this.filterClaimList = this.allClaimList;
        } else {
            this.filterClaimList = this.allClaimList.filter(claim => claim.claimStatusDescription === this.claimStatus);
        }
        
        if (this.filterClaimList.length > 0) {
            this.claimList = this.filterClaimList.slice(0, this.generalPageSize);
            this.claimCurrentPage = 1;
            this.claimTotalRecords = this.filterClaimList.length;
        } else {
            this.claimList = [];
            this.claimCurrentPage = 1;
            this.claimTotalRecords = 0;
        }

        console.log('claimList: ', this.claimList.length);
    }

    handleDocYearChange(event) {
        this.docYear = event.detail.value;
        if (this.docYearMap[this.docYear]) {
            this.docList = this.docYearMap[this.docYear];
        } else {
            this.docList = [];
        }
    }

    handleCorDocYearChange(event) {
        this.corDocYear = event.detail.value;   
        if (this.corDocYearMap[this.corDocYear]) {
            this.corDocList = this.corDocYearMap[this.corDocYear];
        } else {
            this.corDocList = [];
        }
    }

    handleCancelPolicyChange(event) {
        this.isLoading = true;
        this.policy.isDisplayTooltip = event.target.checked;
        cancelPolicy({recordId: this.healthMigrationCancelPolicyId, policyNo: this.policyNo, holderSSN: this.holderSSN, newStatus: this.policy.isDisplayTooltip}).then(data => {
            if (data) {
                this.healthMigrationCancelPolicyId = data;
            }
        }).catch(error => {
            console.log('cancelPolicy error: ', error);
            this.showErrorToast(error.body.message);
        }).finally(() => {
            this.isLoading = false;
        });
    }

    handleToggleDoc(event) {
        this.isLoading = true;
        const { docKey, docType } = event.target.dataset;
        console.log('docKey: ', docKey);
        console.log('docType: ', docType);

        let targetDoc = null;
        if (docType === 'PolicyDoc') {
            targetDoc = this.docList.find(doc => doc.attachmentKey === docKey);
        } else if (docType === 'PolicyCorDoc') {
            targetDoc = this.corDocList.find(doc => doc.attachmentKey === docKey);
        }
        console.log('targetDoc: ', targetDoc);

        if (targetDoc) {
            toggleDocState({targetDoc: targetDoc, holderSSN: this.holderSSN}).then((data) => {
                console.log('toggleDocState data: ', data);
                if (data) {
                    // replace the old value with new value
                    if (docType === 'PolicyDoc') {
                        this.docList = this.docList.map(doc => 
                            doc.attachmentKey === docKey ? data : doc
                        );
                        this.docYearMap = {
                            ...this.docYearMap,
                            [this.docYear]: this.docYearMap[this.docYear].map(doc => 
                                doc.attachmentKey === docKey ? data : doc
                            )
                        };
                    } else if (docType === 'PolicyCorDoc') {
                        this.corDocList = this.corDocList.map(doc => 
                            doc.attachmentKey === docKey ? data : doc
                        );
                        this.corDocYearMap = {
                            ...this.corDocYearMap,
                            [this.corDocYear]: this.corDocYearMap[this.corDocYear].map(doc => 
                                doc.attachmentKey === docKey ? data : doc
                            )
                        };
                    }
                } else {
                    this.showErrorToast('Action failed');
                }
            }).catch(error => {
                console.log('toggleDocState error: ', error);
                this.showErrorToast(error.body.message);
            }).finally(() => {
                this.isLoading = false;
            });
        } else {
            this.showErrorToast('Document not found');
            this.isLoading = false;
        }
    }

    handleResendWelcomeEmail(event) {
        const con = confirm('Are you confirm to resend the welcome email?');
        if(con){
            this.isLoading = true;
            resendWelcomeEmail({policyNo: this.policyNo}).then(data => {
                console.log('resendWelcomeEmail data: ', data);
                if (data) {
                    this.showSuccessToast('Resend Welcome Email Successfully.');
                } else {
                    this.showErrorToast('Resend Welcome Email Failed.');
                }
            }).catch(error => {
                console.log('resendWelcomeEmail error: ', error);
                this.showErrorToast(error.body.message);
            }).finally(() => {
                this.isLoading = false;
            });
        }
    }

    async handleViewDoc(event) {
        this.isLoading = true;
        const { docKey } = event.target.dataset;
        console.log('docKey: ', docKey);
        getDoc2({policyNo: this.policyNo, targetAttachmentKey: docKey}).then(data => {
            console.log('file store id: ', data);
            if (data) {
                let fileStoreId = data;
                let attId = '';
                let isDownloadComplete = false;
                
                const checkDownloadInterval = setInterval(() => {
                    // Rancho_HKITSFDC321_20251013 - search the attachment under file store
                    // checkIsDocumentDownloadComplete({selectedDowlAttId: attId}).then(async (data) => {
                    checkIsDocumentDownloadComplete({fileStoreId: fileStoreId}).then(async (data) => {
                        console.log('file downloaded? ', data);
                        if (data) {
                            attId = data;
                            isDownloadComplete = true;
                            clearInterval(checkDownloadInterval);
                            clearTimeout(timeoutHandle);
                            this.isLoading = false;

                            if (this.isConsoleNavigation) {
                                console.log('console navigation');
                                const parentTab = await getFocusedTabInfo();
                                let parentTabId = '';
                                if (parentTab && parentTab.isSubtab) {
                                    parentTabId = parentTab.parentTabId;
                                } else {
                                    parentTabId = parentTab.tabId;
                                }
                                console.log('parent tab: ', parentTabId);

                                openSubtab(parentTabId, {
                                    recordId: attId,
                                    focus: true
                                }).then((response) => {
                                    console.log('Subtab opened with response: ', response);
                                }).catch((error) => {
                                    console.log('Error opening subtab: ', error);
                                });
                            } else {
                                console.log('standard navigation');
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__objectPage',
                                    attributes: {
                                        objectApiName: 'Attachment',
                                        actionName: 'view',
                                        recordId: attId,
                                    }
                                });
                            }
                        }
                    });
                }, 1000);

                // stop loading after 2 minutes, avoid file download failed in queue job
                const timeoutHandle = setTimeout(() => {
                    if (!isDownloadComplete) {
                        console.log('Download check timed out');
                        clearInterval(checkDownloadInterval);
                        this.isLoading = false;
                        this.showErrorToast('Request timeout, please contact the administrator.');
                    }
                }, 120000);
            }
        }).catch(error => {
            console.log('getDoc2 error: ', error);
            this.isLoading = false;
        });
    }

    async handleViewClaim(event) {
        this.isLoading = true;
        const { claimNo, policyNo, certNo, sourceType } = event.target.dataset;
        console.log('claimNo: ', claimNo);
        console.log('policyNo: ', policyNo);
        console.log('certNo: ', certNo);
        console.log('sourceType: ', sourceType);
        try {
            let policyType = '';
            if (this.policy.isIndividual) {
                if (this.policy.isILAS) {
                    policyType = 'ILAS';
                } else {
                    policyType = 'nonILAS';
                }
            } else {
                policyType = 'Group';
            }
            console.log('policyType: ', policyType);
            
            console.log('generate navigation url');
            const url = `/apex/CSClaimDetailsVFP?policyNumber=${policyNo}&claimNo=${claimNo}&policyType=${policyType}&certNumber=${certNo}&sourceType=${sourceType}`;
            console.log('url: ', url);

            if (this.isConsoleNavigation) {
                console.log('console navigation');
                const parentTab = await getFocusedTabInfo();
                let parentTabId = '';
                if (parentTab && parentTab.isSubtab) {
                    parentTabId = parentTab.parentTabId;
                } else {
                    parentTabId = parentTab.tabId;
                }
                console.log('parent tab: ', parentTabId);

                openSubtab(parentTabId, {
                    url: url,
                    focus: true
                }).then((tabId) => {
                    console.log('Tab opened with id: ', tabId);
                    this.isLoading = false;
                }).catch((error) => {
                    console.error('Error opening tab: ', error);
                    this.isLoading = false;
                    this.showErrorToast(error.body.message);
                });
            } else {
                console.log('standard navigation');
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url
                    }
                });
                this.isLoading = false;
            }
        } catch (error) {
            console.error('Error redirecting to claim details: ', error);
            this.isLoading = false;
            this.showErrorToast(error.body.message || 'Redirect to claim details failed');
        }
    }

    handleAccNoChange(event) {
        let value = event.target.value;
        console.log('value: ', value);
        value = value.replace(" ", "");

        if(!value) {
            console.log('clear value');
            this.invalidString = false;
            return;
        }

        this.displayResult = true; // display the result field when the account number is not blank

        if (this.isNumeric(value)) {
            console.log('only numeric');
            this.invalidString = false;

            if (value.length === 8) {
                this.isLoading = true;
                
                const accNo = this.payment.accountNumber;
                let fullCreditCardNo = accNo;
                for (let index = 0; index < value.length; index++) {
                    fullCreditCardNo = this.replaceCharOfStringAt(fullCreditCardNo, index + 4, value.charAt(index));
                }
                console.log('fullCreditCardNo: ', fullCreditCardNo);

                validateCreditCardNumber({policyNo: this.policyNo, creditCardNo: fullCreditCardNo}).then(data => {
                    console.log('validate result: ', data);
                    this.validationResult = data;
                }).catch(error => {
                    console.log('validateCreditCardNumber error: ', error);
                    this.showErrorToast(error.body.message);
                    this.isLoading = false;
                }).finally(() => {
                    this.isLoading = false;
                });
            }
        } else {
            console.log('invalid account number');
            this.invalidString = true;
        }
    }

    isNumeric(str) {
        return /^\d+$/.test(str);
    }

    replaceCharOfStringAt(s, n, t) {
        // replace the 'n'th character of 's' with 't':
        return s.substring(0, n) + t + s.substring(n + 1);
    }

    handleClaimPageChange(event) {
        const { currentPage, pageSize, startIndex, endIndex } = event.detail;
        this.claimCurrentPage = currentPage;
        this.claimList = this.filterClaimList.slice(startIndex, endIndex);
    }

    handleBillingPageChange(event) {
        const { currentPage, pageSize, startIndex, endIndex } = event.detail;
        this.billingCurrentPage = currentPage;
        this.billingList = this.allBillingList.slice(startIndex, endIndex);
    }

    handleCoveragePageChange(event) {
        const { currentPage, pageSize, startIndex, endIndex } = event.detail;
        this.coverageCurrentPage = currentPage;
        this.coverageList = this.allCoverageList.slice(startIndex, endIndex);
    }

    get coveragePeriodTitle() {
        const from = this.coverage?.CoveragePeriodFromInDate;
        const to = this.coverage?.CoveragePeriodToInDate;
        if (from && to) {
            return `${from} ${this.label.Pol_to} ${to}`;
        }
        return 'N/A';
    }
}