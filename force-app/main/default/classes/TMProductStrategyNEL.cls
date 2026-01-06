/********************************************************************************
 * Apex Class Name - TMProductStrategyNEL
 * Created Date - Apr 23,2018
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public abstract class TMProductStrategyNEL extends TMProductStrategy{     
    public string productCode;    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;     
    private Map<String,String> conversionMap;
    private Map<String,TMEsalesHelper.Portalproduct> planProductMap=new Map<String,TMEsalesHelper.Portalproduct>();        
    public TMProductStrategyNEL(TMPolicyUtil.PolicyTransactionValidationStruct ptvs,String productCode){ 
        super();
        this.ptvs=ptvs; 
        this.productCode=productCode;
        conversionMap=new Map<String,String>{'A'=>'10','B'=>'11','C'=>'12','D'=>'13','E'=>'14','F'=>'15','G'=>'16','H'=>'17'};//jack add for Elite Revamp
    }      
   
    public override void discountValidation(){
        super.discountValidation(ptvs,productCode);        
        //Nicole_Elite Revamp_20210319
        // Rancho_AH24240_20220224: comment for duplicate logic
        // system.debug('[TMProductStrategyNEL firstYDisEliMap]'+ptvs.ctrl.firstYDisEliMap);
        // for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){    
        //     system.debug(pis.pi.Personal_ID__c+'s discount before:'+pis.availableDiscountMap);
        //     if(pis.availableDiscountMap.containsKey('PROMOTION') && ptvs.ctrl.firstYDisEliMap!=null){
        //         if(ptvs.ctrl.firstYDisEliMap.containsKey(pis.pi.Personal_ID__c)&&ptvs.ctrl.firstYDisEliMap.get(pis.pi.Personal_ID__c)){
        //             pis.availableDiscountMap.put('PROMOTION',true);
        //         }else{
        //             pis.availableDiscountMap.put('PROMOTION',false);
        //         }
        //     }
        //     system.debug(pis.pi.Personal_ID__c+'s discount after:'+pis.availableDiscountMap);
        // }
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){                        
            if(pis.availableDiscountMap.containsKey('CHILD DISCOUNT*')){
                childDiscountValidation();
            }
            //DPSP-992 : Please remove the "SP Discount" validation for all products
            /**
            if(null != pis.availableDiscountMap.get('SPOUSE DISCOUNT')){
                spouseDiscountValidation();
            }
            **/
            break;
        }       
    }
    
    public override void piValidation(){        
        if(ptvs.ctrl.currentStep>2 && ptvs.ctrl.isStep2ValidationCalled==false){
            super.piValidation(ptvs,productCode);            
            //TS-672 MATG rider (i.e. Maternity Benefit ) only applies to female aged 18-49.  Added by Andy
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                //System.debug('[TMProductStrategyNEL] piValidation() >>> Validation for MATG rider begin');
                System.debug('[TMProductStrategyNEL] piValidation() >>> pis.piValidationItem.otherValidation='+pis.piValidationItem.otherValidation);
                system.debug('[TMProductStrategyNEL] piValidation() >>> pis.selectedRidersMap='+pis.selectedRidersMap);
                if(pis.selectedRidersMap.keySet().contains('MATG')&&(!(pis.pi.Gender__c=='Female')||!(pis.pi.pi_age__c>=18&&pis.pi.pi_age__c<=49))){
                    system.debug('[TMProductStrategyNEL] piValidation() >>> Validation for MATG rider NOT Pass>> '+'Gender : '+pis.pi.Gender__c+' Age : '+pis.pi.pi_age__c);
                    pis.piValidationItem.otherValidation=false;
                }else{
                    system.debug('[TMProductStrategyNEL] piValidation() >>> Validation for MATG rider Pass>> '+'Gender : '+pis.pi.Gender__c+' Age : '+pis.pi.pi_age__c);
                }
            }            
        }
        
        //Add by Owen, 2024.1.12 add for elite360 for child validation skip.
        //System.debug('=============product_code__c'+ptvs.ctrl.selectedProduct.product_code__c);
        Boolean eliet360SkipChildCheck = true;
        if(ptvs.ctrl.selectedProduct.product_code__c=='@NELG2'||ptvs.ctrl.selectedProduct.product_code__c=='@NESG2'){
            eliet360SkipChildCheck = false;
            //System.debug('=========eliet360SkipChildCheck'+eliet360SkipChildCheck);
        }
        if(ptvs.ctrl.currentStep>5&&eliet360SkipChildCheck){
            //PolicyCalloutHelper helper=new PolicyCalloutHelper();
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                //System.debug('[TMProductStrategyNEL] piValidation()>>>>>>>>>> before otherValidation');
                System.debug('[TMProductStrategyNEL] piValidation().pis.piValidationItem.otherValidation='+pis.piValidationItem.otherValidation);
                if(pis.pi.pi_age__c<6){
                    boolean isPass=false;
                    /**
                    if(null != pis.pi.Parent_PI_ID__c){
                       List<HttpCalloutVO.Policy> plist=helper.getIndividualPolicyListBasicByCriteria('','',pis.pi.Parent_PI_ID__c,'','','');                        
                    }**/
                    if(null != pis.parentIDPolicylist){
                        for(HttpCalloutVO.Policy p : pis.parentIDPolicylist){
                            //System.debug('[TMProductStrategyNEL] piValidation().p.policyStatusDisplayName='+p.policyStatusDisplayName);
                            System.debug('[TMProductStrategyNEL] piValidation().pis.pi.Benefit_Level__c='+pis.pi.Benefit_Level__c);
                            System.debug('[TMProductStrategyNEL] piValidation().p.productCode='+p.productCode);
                            //for DPSP-947,benefitlevel no need to equal
                            //System.debug('[TMProductStrategyNEL] piValidation().benefitLevelConversion(p.rateScale)='+benefitLevelConversion(p.rateScale));
                            //if((p.policyStatusDisplayName=='Inforce' || p.policyStatusDisplayName=='生效')
                               //&& benefitLevelConversion(p.rateScale)==pis.pi.Benefit_Level__c
                               //&& p.productCode==productCode){
                                   //system.debug('[TMProductStrategyNEL] ws checking success');
                                   //isPass=true;
                                   //break;
                               //}
                            // Changed at 20190321 by kermit: Aged below 6,Enroll in the same area of coverage as the parent
                            if(p.productCode==productCode && (p.policyStatusDisplayName=='Inforce' || p.policyStatusDisplayName=='生效')){
                                planProductMap=TMEsalesHelper.getProductMappingByBasicPlan(new Set<String>{'NESG','NELG'});                               
                                String parentAreaOfCoverage=planProductMap.get(p.productCode+'_'+benefitLevelConversion(p.rateScale)).areaOfCoverage;
                                //String childAreaOfCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+pis.pi.Benefit_Level__c).areaOfCoverage;
                                // avoid exception because Benefit_Level__c can be alpha now
                                String childAreaOfCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+benefitLevelConversion(pis.pi.Benefit_Level__c)).areaOfCoverage;                               
                                childAreaofCoverage=childAreaofCoverage.contains('Asia')?'Asia':childAreaofCoverage;
                                parentAreaofCoverage=parentAreaofCoverage.contains('Asia')?'Asia':parentAreaofCoverage;
                                
                                if(parentAreaOfCoverage==childAreaOfCoverage){
                                    system.debug('[TMProductStrategyNEL] ws checking success');
                                    isPass=true;
                                    break;
                                }
                            }
                            //system.debug('[TMProductStrategy] firstValidation productCode= '+productCode);
                        }
                    }
                    //pis.piValidationItem.otherValidation=pis.piValidationItem.otherValidation==false?false:isPass;                    
                    //for DPSP-947,parent must have a completed or submitted policy 
                    //if(null != pis.pi.Parent_PI_ID__c){
                        //List<New_policy__c> parentPolicies=[select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c=:pis.pi.Parent_PI_ID__c) and (policy_status__c='Completed' or policy_status__c='Submitted') and (product_code__c=:productCode or product_code__c='@NELG' or product_code__c='@NESG')];
                        //if(null != parentPolicies && parentPolicies.size()>0){
                            //isPass=true;
                        //}
                    //}
                    //Change at 20190321 by kermit: Aged below 6,Enroll in the same area of coverage as the parent
                    if(null!=pis.pi.Parent_PI_ID__c){
                        List<New_policy__c> parentPolicies=[select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c=:pis.pi.Parent_PI_ID__c) and (policy_status__c='Completed' or policy_status__c='Submitted') and (product_code__c=:productCode or product_code__c='@NELG' or product_code__c='@NESG')];
                        if(null!=parentPolicies&&parentPolicies.size()>0){
                            //List<Person_Insured__c> parentPIsList=[SELECT Id,Basic_Plan__c,Benefit_Level__c FROM Person_Insured__c WHERE Personal_Id__c=:pis.pi.Parent_PI_ID__c AND Basic_Plan__c=:pis.pi.Basic_Plan__c];
                            List<Person_Insured__c> parentPIsList=[SELECT Id,Basic_Plan__c,Benefit_Level__c FROM Person_Insured__c WHERE Personal_Id__c=:pis.pi.Parent_PI_ID__c AND Basic_Plan__c in ('NESG','NELG')];
                            if(null!=parentPisList&&parentPIsList.size()>0){
                                for(Person_Insured__c parent : parentPIsList){
                                    planProductMap=TMEsalesHelper.getProductMappingByBasicPlan(new Set<String>{'NESG','NELG'});
                                    // avoid exception because Benefit_Level__c can be alpha now
                                    //String childAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+pis.pi.Benefit_Level__c).areaOfCoverage;
                                    //String parentAreaofCoverage=planProductMap.get(parent.Basic_Plan__c+'_'+parent.Benefit_Level__c).areaOfCoverage;
                                    String childAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+benefitLevelConversion(pis.pi.Benefit_Level__c)).areaOfCoverage;
                                    String parentAreaofCoverage=planProductMap.get(parent.Basic_Plan__c+'_'+benefitLevelConversion(parent.Benefit_Level__c)).areaOfCoverage;
                                    
                                    childAreaofCoverage=childAreaofCoverage.contains('Asia')?'Asia':childAreaofCoverage;
                                    parentAreaofCoverage=parentAreaofCoverage.contains('Asia')?'Asia':parentAreaofCoverage;                                    
                                    if(childAreaofCoverage==parentAreaofCoverage){isPass=true;}
                                }
                            }
                        }
                    }
                    pis.piValidationItem.otherValidation=isPass;
                }            
                System.debug('[TMProductStrategyNEL] piValidation().pis.piValidationItem.otherValidation='+pis.piValidationItem.otherValidation);
            }
            
            //System.debug('[TMProductStrategyNEL] piValidation() TMEsalesHelper.getProductMappingByBasicPlan begin');
            
            planProductMap=TMEsalesHelper.getProductMappingByBasicPlan(new Set<String>{'NESG','NELG','NELG2','NESG2'});
          
            System.debug('[TMProductStrategyNEL] piValidation() TMEsalesHelper.getProductMappingByBasicPlan end.  planProductMap >> '+planProductMap);
                        
            //System.debug('[TMProductStrategyNEL] piValidation() secondValidation start >>>>>>>>>');
            Map<String,List<TMCreatePolicyCtrl.PersonInsuredStructure>> parentPIIdChildPIListMap=new Map<String,List<TMCreatePolicyCtrl.PersonInsuredStructure>>();
            Set<String> availableChildIdSet=new Set<String>();
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                if(pis.pi.PI_Age__c<6 && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c)) && null != pis.pi.Parent_PI_ID__c){
                    if(parentPIIdChildPIListMap.containsKey(pis.pi.Parent_PI_ID__c))
                        parentPIIdChildPIListMap.get(pis.pi.Parent_PI_ID__c).add(pis);
                    else{
                        List<TMCreatePolicyCtrl.PersonInsuredStructure> childPIList=new List<TMCreatePolicyCtrl.PersonInsuredStructure>();
                        childPIList.add(pis);
                        parentPIIdChildPIListMap.put(pis.pi.Parent_PI_ID__c,childPIList);
                    }                    
                }
            }
            System.debug('[TMProductStrategyNEL] piValidation().parentPIIdChildPIListMap='+parentPIIdChildPIListMap);
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                //if(parentPIIdChildPIListMap.containsKey(pis.pi.Personal_ID__c) && 'Accepted'.equals(pis.piPolicy.UW_Overrall_Result__c)){
                if(parentPIIdChildPIListMap.containsKey(pis.pi.Personal_ID__c)){
                    for(TMCreatePolicyCtrl.PersonInsuredStructure childPi : parentPIIdChildPIListMap.get(pis.pi.Personal_ID__c)){
                        //if(childPi.pi.Benefit_Level__c==pis.pi.Benefit_Level__c){//Comment in 20181126 to align with requirement and remove this logic                       
                        //eligiable when aged<6 with same area of coverage as the parent 
                        //String childAreaOfCoverage=planProductMap.get(childPi.pi.basic_plan__c+'_'+childPi.pi.Benefit_Level__c).areaOfCoverage;
                        //String parentAreaOfCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+pis.pi.Benefit_Level__c).areaOfCoverage;
                        System.debug('planProductMap:'+planProductMap+' childPi.pi:'+childPi.pi.basic_plan__c+' childPi.pi.Benefit_Level__c：'+childPi.pi.Benefit_Level__c);
                        String childAreaofCoverage=planProductMap.get(childPi.pi.basic_plan__c+'_'+benefitLevelConversion(childPi.pi.Benefit_Level__c)).areaOfCoverage;
                        String parentAreaofCoverage=planProductMap.get(pis.pi.Basic_Plan__c+'_'+benefitLevelConversion(pis.pi.Benefit_Level__c)).areaOfCoverage;
                        
                        childAreaofCoverage=childAreaofCoverage.contains('Asia')?'Asia':childAreaofCoverage;
                        parentAreaofCoverage=parentAreaofCoverage.contains('Asia')?'Asia':parentAreaofCoverage;               
                        if(childAreaOfCoverage==parentAreaOfCoverage){
                            availableChildIdSet.add(childPi.pi.id);
                        }                        
                        //}
                    }
                }
            }
            //System.debug('[TMProductStrategyNEL] piValidation().availableChildIdSet='+availableChildIdSet);
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                if(pis.pi.PI_Age__c<6 && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c))){
                    pis.piValidationItem.otherValidation=(availableChildIdSet.contains(pis.pi.id) || pis.piValidationItem.otherValidation);
                }                               
                System.debug('[TMProductStrategyNEL] piValidation().pis.piValidationItem.otherValidation='+pis.piValidationItem.otherValidation);
            }
            System.debug('[TMProductStrategyNEL] piValidation() secondValidation end >>>>>>>>>');
        }               
    }
    
    public override void transactionValidation(){
        super.transactionValidation(ptvs,productCode);        
        //WS param can not be null
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.PI_Age__c<6)
                pis.isParentPIIdMandatory=true;
            else
                pis.isParentPIIdMandatory=false;
        }        
        //ptvs.policyTransactionValidationItem.isParentIDMandatory=true;
    }
    /**
    Conversion: CITAS - IPAS
    1,10,2,3 - 1,A,2,3
    4,11,5,6 - 4,B,5,6
    7,12,8,9 - 7,C,8,9
    **/
    private String benefitLevelConversion(String ipasBenefitLevel){            
        return null!=conversionMap.get(ipasBenefitLevel)?conversionMap.get(ipasBenefitLevel):ipasBenefitLevel;
    }
    
    public void childDiscountValidation(){
        System.debug('[TMProductStrategyNEL] childDiscountValidation() firstValidation start >>>>>>>>>'); 
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){           
            pis.availableDiscountMap.put('CHILD DISCOUNT*',false);//default false
            if(pis.pi.pi_age__c<18){
                System.debug('[TMProductStrategyNEL] childDiscountValidation().pis.pi.Parent_PI_ID__c='+pis.pi.Parent_PI_ID__c);
                if(null != pis.pi.Parent_PI_ID__c){                 
                    //List<HttpCalloutVO.Policy> plist=helper.getIndividualPolicyListBasicByCriteria('','',pis.pi.Parent_PI_ID__c,'','','');
                    //if(null != plist && plist.size()>0){
                    System.debug('[TMProductStrategyNEL] childDiscountValidation().pis.parentIDPolicylist='+pis.parentIDPolicylist);
                    if(null != pis.parentIDPolicylist && pis.parentIDPolicylist.size()>0){
                        System.debug('12/04 pis.parentIDPolicylist='+pis.parentIDPolicylist);
                        for(HttpCalloutVO.Policy p : pis.parentIDPolicylist){
                            //System.debug('[TMProductStrategyNEL] childDiscountValidation().p.policyStatusDisplayName='+p.policyStatusDisplayName);
                            System.debug('[TMProductStrategyNEL] childDiscountValidation().benefitLevelConversion(p.rateScale)='+benefitLevelConversion(p.rateScale));
                            System.debug('[TMProductStrategyNEL] childDiscountValidation().p.productCode='+p.productCode);
                            //if((p.policyStatusDisplayName=='Inforce' || p.policyStatusDisplayName=='生效')
                               //&& benefitLevelConversion(p.rateScale)==pis.pi.Benefit_Level__c
                               //&& p.productCode==productCode){
                                    //pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                                    //break;
                               //}
                            System.debug('12/04  p.productCode='+p.productCode);
                            System.debug('12/04  productCode='+productCode);
                            if(p.productCode==productCode){
                              
                                planProductMap=TMEsalesHelper.getProductMappingByBasicPlan(new Set<String>{'NESG','NELG','NELG2','NESG2'});
                                //String childAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+pis.pi.Benefit_Level__c).areaOfCoverage;
                                //String parentAreaofCoverage=planProductMap.get(p.productCode+'_'+benefitLevelConversion(p.rateScale)).areaOfCoverage;
                                String childAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+benefitLevelConversion(pis.pi.Benefit_Level__c)).areaOfCoverage;
                                String parentAreaofCoverage=planProductMap.get(p.productCode+'_'+benefitLevelConversion(p.rateScale)).areaOfCoverage;                                
                                childAreaofCoverage=childAreaofCoverage.contains('Asia')?'Asia':childAreaofCoverage;
                                parentAreaofCoverage=parentAreaofCoverage.contains('Asia')?'Asia':parentAreaofCoverage;
                                
                                system.debug('[TMProductStrategy] firstValidation childAreaofCoverage= '+childAreaofCoverage);
                                system.debug('[TMProductStrategy] firstValidation parentAreaofCoverage= '+parentAreaofCoverage);
                                if(childAreaofCoverage==parentAreaofCoverage && (p.policyStatusDisplayName=='Inforce' || p.policyStatusDisplayName=='生效')){
                                    system.debug('[TMProductStrategyNEL] discount ws checking success');
                                    system.debug('09/04 childAreaCoverate is same as parentAreaCoverage and inforce | p.policyStatusDisplayName = '+ p.policyStatusDisplayName);
                                    pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                                    break;
                                }
                                else{  // BEGIN https://jira.express-scripts.com/browse/HKITSFDC-17 patch 19/06
                                    List<String> childDiscountApplyProdCodeList= new List<String>{'NELG2','NESG2'};
                                    if ( childDiscountApplyProdCodeList.contains(productCode) && (p.policyStatusDisplayName=='Inforce' || p.policyStatusDisplayName=='生效')){
                                         system.debug('[TMProductStrategyNEL] child discount firstValidation 2 attempts success');
                                         pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                                         break;
                                    }
                                }// END https://jira.express-scripts.com/browse/HKITSFDC-17 patch  19/06
                                
                                
                            } else {
                                // BEGIN https://jira.express-scripts.com/browse/HKITSFDC-17  12/04 
                                // Else condition is added HKITSFDC-17
                                
                                // Parent code -PH code should be any of the 'NESG','NELG','NELG2','NESG2','NESGM','NELGM' (p.productCode)
                                List<String> policyHolderProdCodeList = new List<String>{
                                    'NESG','NELG','NELG2','NESG2','NESGM','NELGM'
                                };
                                // Product Selected during the Insurance purchase
                                // Child policy code -PI code should either of 'NELG2','NESG2' (productCode)
                                List<String> policyInsuredProdCodeList = new List<String> {'NELG2','NESG2'};
                              
                                if(policyHolderProdCodeList.contains(p.productCode) && policyInsuredProdCodeList.contains(productCode)){
                                    System.debug('12/04 else condition of p.productCode==productCode');
                                    System.debug('12/04 productCode='+productCode);
                                    System.debug('12/04 p.productCode='+p.productCode);
                                    try {
                                         planProductMap=TMEsalesHelper.getProductMappingByBasicPlan(new Set<String>{'NESG','NELG','NELG2','NESG2','NESGM','NELGM'});
                                        String childAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+benefitLevelConversion(pis.pi.Benefit_Level__c)).areaOfCoverage;
                                        String parentAreaofCoverage=planProductMap.get(p.productCode+'_'+benefitLevelConversion(p.rateScale)).areaOfCoverage;                                
                                        childAreaofCoverage=childAreaofCoverage.contains('Asia')?'Asia':childAreaofCoverage;
                                        parentAreaofCoverage=parentAreaofCoverage.contains('Asia')?'Asia':parentAreaofCoverage;
                                        
                                        system.debug('[TMProductStrategy] firstValidation childAreaofCoverage= '+childAreaofCoverage);
                                        system.debug('[TMProductStrategy] firstValidation parentAreaofCoverage= '+parentAreaofCoverage);
                                        system.debug('p.policyStatusDisplayName= '+ p.policyStatusDisplayName);
                                        // removed "childAreaofCoverage==parentAreaofCoverage" guided by use 12042024 to remove area of code coverge check.
                                        //  if(childAreaofCoverage==parentAreaofCoverage && (p.policyStatusDisplayName=='Inforce' || p.policyStatusDisplayName=='生效')){
                                    } catch(Exception e){
                                        System.debug('An Exception has occured: '+e.getMessage());
                                    }
                                   
                                    if(p.policyStatusDisplayName=='Inforce' || p.policyStatusDisplayName=='生效'){
                                        system.debug('[TMProductStrategyNEL] discount ws checking success');
                                        system.debug('12/04 childAreaCoverate is same as parentAreaCoverage and inforce | p.policyStatusDisplayName = '+ p.policyStatusDisplayName);
                                        pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                                        break;
                                    }
                                }
                               
                            }
                            System.debug('12/04 After p.productCode==productCode condition');
                            // END https://jira.express-scripts.com/browse/HKITSFDC-17  12/04 
                        }
                    }
                    //else{
                    //    System.debug('[TMProductStrategyNEL] childDiscountValidation() >>>> NOT INFORCE POLICY FOUND');
                    //    pis.availableDiscountMap.put('CHILD DISCOUNT*',false);
                    //}
                }
                //else{
                //    pis.availableDiscountMap.put('CHILD DISCOUNT*',false);
                //    System.debug('[TMProductStrategyNEL] childDiscountValidation().pis.pi.Parent_PI_ID__c==null');
                //}
                //DPSP-1025 : if parent ID has a completed or submitted policy,their child can be applied Child discount
                //if(String.isNotEmpty(pis.pi.Parent_PI_ID__c)){
                    //List<New_policy__c> parentPolicies=[select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c=:pis.pi.Parent_PI_ID__c) and (policy_status__c='Completed' or policy_status__c='Submitted') and (product_code__c=:productCode or product_code__c='@NELG' or product_code__c='@NESG')];
                    //if(null != parentPolicies && parentPolicies.size()>0){
                        //pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                    //}
                //}
                //change by kermit at 20190321,now need to consider the area of coverage.           
                if(null!=pis.pi.Parent_PI_ID__c){
                    List<New_policy__c> parentPolicies=[select id,name from new_policy__c where id in (select new_policy__c from person_insured__c where personal_id__c=:pis.pi.Parent_PI_ID__c) and (policy_status__c='Completed' or policy_status__c='Submitted') and (product_code__c=:productCode or product_code__c='@NELG' or product_code__c='@NESG' or product_code__c='@NELG2' or product_code__c='@NESG2')];
                    if(null!=parentPolicies && parentPolicies.size()>0){
                       List<Person_Insured__c> parentPIsList=[SELECT Id,Basic_Plan__c,Benefit_Level__c FROM Person_Insured__c WHERE Personal_Id__c=:pis.pi.Parent_PI_ID__c AND Basic_Plan__c IN ('NESG','NELG','NELG2','NESG2','NESGM','NELGM')];
                        if(null!=parentPisList&&parentPIsList.size()>0){
                            for(Person_Insured__c parent : parentPIsList){
                                planProductMap=TMEsalesHelper.getProductMappingByBasicPlan(new Set<String>{'NESG','NELG','NELG2','NESG2'});    
                                //String childAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+pis.pi.Benefit_Level__c).areaOfCoverage;
                                //String parentAreaofCoverage=planProductMap.get(parent.Basic_Plan__c+'_'+parent.Benefit_Level__c).areaOfCoverage;
                                String childAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+benefitLevelConversion(pis.pi.Benefit_Level__c)).areaOfCoverage;
                                String parentAreaofCoverage=planProductMap.get(parent.Basic_Plan__c+'_'+benefitLevelConversion(parent.Benefit_Level__c)).areaOfCoverage;                                
                                childAreaofCoverage=childAreaofCoverage.contains('Asia')?'Asia':childAreaofCoverage;
                                parentAreaofCoverage=parentAreaofCoverage.contains('Asia')?'Asia':parentAreaofCoverage;
                                
                                system.debug('[TMProductStrategy] firstValidation(sfdc) childAreaofCoverage= '+childAreaofCoverage);
                                system.debug('[TMProductStrategy] firstValidation(sfdc) parentAreaofCoverage= '+parentAreaofCoverage);
                                if(childAreaofCoverage==parentAreaofCoverage){
                                    system.debug('[TMProductStrategyNEL] discount sfdc checking success');
                                    pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                                }
                            }
                        }
                         
                    }
                }           
            }
            //else{
            //    pis.availableDiscountMap.put('CHILD DISCOUNT*',false);
            //}            
            System.debug('[TMProductStrategyNEL] childDiscountValidation().pis.availableDiscountMap.get(CHILD DISCOUNT*)='+pis.availableDiscountMap.get('CHILD DISCOUNT*'));
        }        
        //System.debug('[TMProductStrategyNEL] childDiscountValidation() firstValidation end >>>>>>>>>');
        
        System.debug('[TMProductStrategyNEL] childDiscountValidation() secondValidation start >>>>>>>>>');
        Map<String,List<TMCreatePolicyCtrl.PersonInsuredStructure>> parentPIIdChildPIListMap=new Map<String,List<TMCreatePolicyCtrl.PersonInsuredStructure>>();
        Set<String> availableChildIdSet=new Set<String>();
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.PI_Age__c<18 && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c)) && null != pis.pi.Parent_PI_ID__c){
                if(parentPIIdChildPIListMap.containsKey(pis.pi.Parent_PI_ID__c))
                    parentPIIdChildPIListMap.get(pis.pi.Parent_PI_ID__c).add(pis);
                else{
                    List<TMCreatePolicyCtrl.PersonInsuredStructure> childPIList=new List<TMCreatePolicyCtrl.PersonInsuredStructure>();
                    childPIList.add(pis);
                    parentPIIdChildPIListMap.put(pis.pi.Parent_PI_ID__c,childPIList);
                }                    
            }
        }
        System.debug('[TMProductStrategyNEL] childDiscountValidation().parentPIIdChildPIListMap='+parentPIIdChildPIListMap);
        
        //System.debug('[TMProductStrategyNEL] childDiscountValidation() TMEsalesHelper.getProductMappingByBasicPlan begin');
        planProductMap=TMEsalesHelper.getProductMappingByBasicPlan(new Set<String>{'NESG','NELG','NELG2','NESG2'});
       
        System.debug('[TMProductStrategyNEL] childDiscountValidation() TMEsalesHelper.getProductMappingByBasicPlan end.  planProductMap >> '+planProductMap);
        
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            //system.debug('[TMProductStrategyNEL] childDiscountValidation().pis Personal_ID__c >> '+pis.pi.Personal_ID__c+' UW Overrall_Result__c >> '+pis.piPolicy.UW_Overrall_Result__c);
            //if(parentPIIdChildPIListMap.containsKey(pis.pi.Personal_ID__c) && 'Accepted'.equals(pis.piPolicy.UW_Overrall_Result__c)){
            if(parentPIIdChildPIListMap.containsKey(pis.pi.Personal_ID__c)){// DPSP-947 : adjust parent overall result to cover any result for child discount
                system.debug('[TMProductStrategyNEL] childDiscountValidation() Has parentId >> '+pis.pi.Personal_ID__c);
                for(TMCreatePolicyCtrl.PersonInsuredStructure childPi : parentPIIdChildPIListMap.get(pis.pi.Personal_ID__c)){
                    system.debug('[TMProductStrategyNEL] childDiscountValidation() Validate childPi >> '+childPi);
                    if( 'Accepted'.equals(childPi.piPolicy.UW_Overrall_Result__c) || 'Referred'.equals(childPi.piPolicy.UW_Overrall_Result__c)){                           
                        /*Supplement from DPSP-773
                        * Case 1. PI age<6 : Child discount should be applied when PI's benefit level is the same as that of parent ID's policy
                        * Case 2. PI age between 6 to 17 inclusively : PI policy's benefit level is having the same area of coverage as that of parent ID's policy
                        */
                        /**
                        if(childPi.pi.PI_Age__c<6 && childPi.pi.Benefit_Level__c==pis.pi.Benefit_Level__c){ //Case 1
                            availableChildIdSet.add(childPi.pi.id);
                        }else if(childPi.pi.PI_Age__c>=6){//Case 2
                            String childAreaOfCoverage=planProductMap.get(childPi.pi.basic_plan__c+'_'+childPi.pi.Benefit_Level__c).areaOfCoverage;
                            String parentAreaOfCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+pis.pi.Benefit_Level__c).areaOfCoverage;
                            if(childAreaOfCoverage==parentAreaOfCoverage){
                                availableChildIdSet.add(childPi.pi.id);
                            }
                        }
                        **/
                        //for DPSP-947,for age<18 ,PI policy's benefit level is having the same area of coverage as that of parent ID's policy
                        //String childAreaOfCoverage=planProductMap.get(childPi.pi.basic_plan__c+'_'+childPi.pi.Benefit_Level__c).areaOfCoverage;
                        //String parentAreaOfCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+pis.pi.Benefit_Level__c).areaOfCoverage;
                        String childAreaofCoverage=planProductMap.get(childPi.pi.basic_plan__c+'_'+benefitLevelConversion(childPi.pi.Benefit_Level__c)).areaOfCoverage;
                        String parentAreaofCoverage=planProductMap.get(pis.pi.basic_plan__c+'_'+benefitLevelConversion(pis.pi.Benefit_Level__c)).areaOfCoverage;
                        
                        childAreaofCoverage=childAreaofCoverage.contains('Asia')?'Asia':childAreaofCoverage;
                        parentAreaofCoverage=parentAreaofCoverage.contains('Asia')?'Asia':parentAreaofCoverage;                        
                        if(childAreaOfCoverage==parentAreaOfCoverage){
                            availableChildIdSet.add(childPi.pi.id);
                        }
                    }
                }
            }
        }
        System.debug('[TMProductStrategyNEL] childDiscountValidation().availableChildIdSet='+availableChildIdSet);
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.PI_Age__c<18 && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c))){
                if(availableChildIdSet.contains(pis.pi.id)){
                    pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                }else{
                    if(pis.availableDiscountMap.get('CHILD DISCOUNT*')!=true){
                        pis.availableDiscountMap.put('CHILD DISCOUNT*',false);
                    }
                }
            }                            
            //System.debug('[TMProductStrategyNEL] childDiscountValidation().pis.availableDiscountMap='+pis.availableDiscountMap);
        }

        //Add by owen for elite 360 discount check,2024.01.05
        Boolean haveChild = false;
        Boolean haveAdult = false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(pis.pi.PI_Age__c<18){
                haveChild = true;
            }else if(pis.pi.PI_Age__c>=18){
                haveAdult = true;
            }                           
        }
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            // if(pis.availableDiscountMap.get('ELITE 360 3 MONTH REFUND')==true&&haveChild&&!haveAdult){
            //     pis.availableDiscountMap.put('ELITE 360 3 MONTH REFUND',false);
            // }
            if(ptvs.ctrl.selectedProduct.product_code__c=='@NELG2'||ptvs.ctrl.selectedProduct.product_code__c=='@NESG2'){
                if(pis.pi.PI_Age__c<18 && ('Son'.equals(pis.pi.Relationship__c) || 'Daughter'.equals(pis.pi.Relationship__c))&&haveAdult){
                    pis.availableDiscountMap.put('CHILD DISCOUNT*',true);
                }
            }
        }

        System.debug('[TMProductStrategyNEL] childDiscountValidation() secondValidation end >>>>>>>>>');
    }
    
    /**
    public void spouseDiscountValidation(){
        System.debug('[TMProductStrategyNEL] spouseDiscountValidation() start');
        Boolean isPHEqualsPI=false;
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            if(ptvs.ctrl.newPolicy.Personal_ID__c.equals(pis.pi.Personal_ID__c) && 'PH=PI'.equals(pis.pi.Insured_Type__c) ){
                isPHEqualsPI=true;
                break;
            }
        }
        if(isPHEqualsPI){
            //case 2:
            if(ptvs.ctrl.personInsuredStructureList.size()>=2){
                Boolean existsPHPI=false;
                Boolean existsSpouse=false;
                for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                    if(pis.pi.Insured_Type__c=='PH=PI'){
                        existsPHPI=true;
                    }else if(pis.pi.Insured_Type__c=='Spouse'){
                        existsSpouse=true;
                    }
                    
                }
                if(existsPHPI && existsSpouse){
                    for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                        if(pis.pi.Insured_Type__c=='PH=PI'){
                            pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                        }else if(pis.pi.Insured_Type__c=='Spouse'){
                            pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                        }else
                            pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                        System.debug('[TMProductStrategyNEL] spouseDiscountValidation().pis.availableDiscountMap='+pis.availableDiscountMap);
                    }
                }else{
                    for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){                        
                        pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                        System.debug('[TMProductStrategyNEL] spouseDiscountValidation().pis.availableDiscountMap='+pis.availableDiscountMap);
                    }
                }                
            }else{
                for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                    pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                    System.debug('[TMProductStrategyNEL] spouseDiscountValidation().pis.availableDiscountMap='+pis.availableDiscountMap);
                }                
            }            
        }else{
            //case 1:(Two conditions are not mutually exclusive)
            //PolicyCalloutHelper helper=new PolicyCalloutHelper();
            //List<HttpCalloutVO.Policy> plist=helper.getIndividualPolicyListBasicByCriteria('','',ptvs.ctrl.newPolicy.Personal_ID__c,'','','');
            for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
                if(pis.pi.Insured_Type__c=='Spouse'){
                    if(null != ptvs.ctrl.PHPersonalIDPolicylist && ptvs.ctrl.PHPersonalIDPolicylist.size()>0){
                        for(HttpCalloutVO.Policy p : ptvs.ctrl.PHPersonalIDPolicylist){
                            if(p.productCode==productCode && null != p.effDateInDate && p.effDateInDate.daysBetween(Date.today())<=28){
                                pis.availableDiscountMap.put('SPOUSE DISCOUNT',true);
                                break;
                            }else{
                                pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                            }
                        }
                    }else{
                        pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                    }                    
                }else{
                    pis.availableDiscountMap.put('SPOUSE DISCOUNT',false);
                }
            }
        }
        for(TMCreatePolicyCtrl.PersonInsuredStructure pis : ptvs.ctrl.personInsuredStructureList){
            System.debug('[TMProductStrategyNEL] spouseDiscountValidation().pis.availableDiscountMap='+pis.availableDiscountMap);
        }
    }
    **/
}