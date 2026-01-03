/********************************************************************************
 * Apex Class Name - TMCreatePolicyStep2Strategy
 * Created Date - Apr 23, 2018
 * @description Policy Creation process steps 2
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 3.0       Ken             20/8/2018              Revise Version
 ********************************************************************************/
public class TMCreatePolicyStep2Strategy implements TMCreatePolicyStepStrategy{
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMCreatePolicyStep2Strategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        this.ptvs = ptvs;
    }
        
    public void stepInit(){
        
        initProductOption(ptvs.ctrl.productMap, ptvs.ctrl.productWithOutOfCamPro, ptvs.ctrl.selectedProduct.id, ptvs.ctrl.productOptions);
        //TMPolicyUtil.isShowTheOptionalField(ptvs.ctrl.selectedProduct.id, ptvs.ctrl.productMap, ptvs.ctrl.isShow);
        //TMPolicyUtil.isShowCRSField(ptvs.ctrl.selectedProduct.id, ptvs.ctrl.productMap, ptvs.ctrl.isShowCRSField);
        //ptvs.ctrl.initAssessRider(ptvs.ctrl.opp.Prod_Rider_Map__c,ptvs.ctrl.selectedProduct.Product_Code__c,ptvs.ctrl);//GL31 jack add
+       ptvs.ctrl.initAssessRider(); // GL31 Tovid add
        
    }
    
    public boolean stepValidation(){
        TMPolicyUtil.policyTransactionValidation(ptvs);        
        if(!ptvs.policyTransactionValidationItem.productValidation){
            ptvs.ctrl.currentStep -= 1;
            ptvs.ctrl.canSave = false;
            String errorMsg = String.isNotEmpty(ptvs.ctrl.pageMsg)?ptvs.ctrl.pageMsg:'This product is not eligible for the opportunity.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return false;
        }else if(ptvs.ctrl.showPolicyReplacement && null == ptvs.ctrl.policyTransaction.PolicyReplacement__c){
            ptvs.ctrl.currentStep -= 1;
            ptvs.ctrl.canSave = false;
            String errorMsg = 'You must enter a value in the required field';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return false;
        //}else if(!CignaUtil.TM_PRO_SCOPE.containsIgnoreCase(ptvs.ctrl.selectedProduct.Product_Code__c) && (String.isBlank(ptvs.ctrl.opp.Available_Product_Code_For_Assessment__c) || !ptvs.ctrl.opp.Available_Product_Code_For_Assessment__c.contains(ptvs.ctrl.selectedProduct.Product_Code__c))){
         }else if(!CignaUtil.TM_PRO_SCOPE.containsIgnoreCase(ptvs.ctrl.selectedProduct.Product_Code__c) && (String.isBlank(ptvs.ctrl.policyTransaction.Available_Product_Code_For_Assessment__c) || !ptvs.ctrl.policyTransaction.Available_Product_Code_For_Assessment__c.contains(ptvs.ctrl.selectedProduct.Product_Code__c))){
            ptvs.ctrl.currentStep -= 1;
            ptvs.ctrl.canSave = false;
            String errorMsg = 'Sorry, product chosen does not match with the needs assessment. Please try again.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return false;
        }else
            return true;
    }
    
    public void nextStep(){
        if(stepValidation())
            stepInit();
    }
    
    
    /**
　　* Resolve the factory method in the specified bean definition, if possible.
　　* {@link RootBeanDefinition#getResolvedFactoryMethod()} can be checked for the result.
　　* @param mbd the bean definition to check
　　* @return a BeanWrapper for the new instance
　　* @throws Exception in case of any kind of processing failure
　　*/
    private void initProductOption(Map<Id, Product__c> proMap, Product__c proOutOfCam, String selProId, List<SelectOption> proOptions){
        // System.debug('>>>>>>>>>>>>>>>>proMap:'+proMap);
        // System.debug('>>>>>>>>>>>>>>>>proOutOfCam:'+proOutOfCam);
        // System.debug('>>>>>>>>>>>>>>>>selProId:'+selProId);
        // System.debug('>>>>>>>>>>>>>>>>proOptions:'+proOptions);
        if(null != proOutOfCam && proOutOfCam.id != selProId){
            proMap.remove(proOutOfCam.id);
            proOptions.clear();
            for(Id productId : proMap.keySet()){
                proOptions.add(new SelectOption(productId, proMap.get(productId).name));
            }
            proOutOfCam = null;
        }
        // System.debug('>>>>>>>>>>>>>>>>proMap:'+proMap);
        // System.debug('>>>>>>>>>>>>>>>>proOptions:'+proOptions);
    }
    
    
}