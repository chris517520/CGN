/********************************************************************************
 * Apex Class Name - TMDiscountFactory
 * Created Date - Apr 23, 2018
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMDiscountFactory{
        
    public static TMproductStrategy createProdcutDiscountStrategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){ 
        System.debug('[TMDiscountFactory] createProdcutDiscountStrategy().ptvs.ctrl.selectedProduct.product_code__c='+ptvs.ctrl.selectedProduct.product_code__c);
        if('@NELG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNELG(ptvs);
        }else if('@NESG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNESG(ptvs);
        }else if('@NELG2'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNELG2(ptvs);
        }else if('@NESG2'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNESG2(ptvs);
        }else if('SCIY'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategySCIY(ptvs);
        }else if('SCIL'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategySCIL(ptvs);
        }else if('@PMGH'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyPMGH(ptvs);
        }else if('TMC50'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyTMC50(ptvs);
        }else if('TMCPU'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyTMCPU(ptvs);
        }else if('@SP100'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategySP100(ptvs);
        }
        //Add by Manuel for VHIS product start
        else if('VSTDG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyVSTDG(ptvs);
        }else if('VSMMG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyVSMMG(ptvs);
        }else if('VSUPG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyVSUPG(ptvs);
        }else if('VSPWG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){    //JL20211206
            return new TMProductStrategyVSPWG(ptvs);							//JL20211206
        }																		//JL20211206
        //Add by Manuel for VHIS product stop

        //Combo: 
        else if('@CBOG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyCOMB(ptvs);
        }
        
        //Wellness CI
        else if('15C1L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy15C1L(ptvs);
        }else if('15C6L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy15C6L(ptvs);
        }else if('15R6L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy15R6L(ptvs);
        }else if('25C1L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy25C1L(ptvs);
        }else if('25C6L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy25C6L(ptvs);
        }else if('25R6L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy25R6L(ptvs);
        }else if('15C8L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy15C8L(ptvs);
        }else if('25C8L'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategy25C8L(ptvs);
        }
        //Wellness CI
        //Rancho_HKITSFDC398_20250909 - 2025Q4 CX Campaign - add AB product
        else if('@ABAG'.equals(ptvs.ctrl.selectedProduct.product_code__c) ){
            return new TMProductStrategyABAG(ptvs);
        }else if('@ABEG'.equals(ptvs.ctrl.selectedProduct.product_code__c) ){
            return new TMProductStrategyABEG(ptvs);
        }else if('ABWG'.equals(ptvs.ctrl.selectedProduct.product_code__c) ){
            return new TMProductStrategyABWG(ptvs);
        }
        else
            return new TMProductStrategyDefault(ptvs,ptvs.ctrl.selectedProduct.product_code__c.replace('@',''));
    }

}