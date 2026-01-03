/********************************************************************************
 * Apex Class Name - TMPolicyTransactionValidationFactory
 * Created Date - Apr 23, 2018
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 10.0       Ken             11/10/2018              Revise Version
 ********************************************************************************/
public class TMPolicyTransactionValidationFactory {
    
    public static TMproductStrategy createProductStrategy(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        system.debug('ptvs.ctrl.selectedProduct.product_code__c'+ptvs.ctrl.selectedProduct.product_code__c);
        if('RSM'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyRSM(ptvs);
        }else if('RSPU'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyRSPU(ptvs);
        }else if('RSPH'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyRSPH(ptvs);
        }else if('RSPHS'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyDefault(ptvs,'RSPHS');//Added by lihao
        }else if('RSPUS'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyDefault(ptvs,'RSPUS'); //Added by lihao
        }else if('RSPSG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyDefault(ptvs,'RSPSG'); //Added by patrick
        }else if('RSPHG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyDefault(ptvs,'RSPHG'); //Added by patrick                         
        }else if('GAOP'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyDefault(ptvs,'GAOP');
        }else if('@PMGH'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyPMGH(ptvs);
        }else if('@DMBG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyDefault(ptvs,'DMBG');
        }else if('@NELG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNELG(ptvs);
        }else if('@NESG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNESG(ptvs);
        }else if('@NELG2'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNELG2(ptvs);
        }else if('@NESG2'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyNESG2(ptvs);
        }else if('SCIL'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategySCIL(ptvs);
        }else if('SCIY'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategySCIY(ptvs);
        }else if('TUPG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyTUPG(ptvs);
        }else if('TUSG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyTUSG(ptvs);
        }else if('TUWG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyTUWG(ptvs);
        }else if('TMC50'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyTMC50(ptvs);
        }else if('TMCPU'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyTMCPU(ptvs);
        }else if('@SP100'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategySP100(ptvs);
        }else if('@KIDSL'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyKIDSL(ptvs);
        }else if('@KIDSG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){ //Updated by Andy Li, from KIDSG TO @KIDSG
            return new TMProductStrategyKIDSG(ptvs);            
        }else if('LPCG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyLPCG(ptvs);
        }else if('@PBTG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyPBTG(ptvs);
        }
        //Add by Manuel for VHIS products (start)
        else if('VSTDG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyVSTDG(ptvs);
        }else if('VSMMG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyVSMMG(ptvs);
        }else if('VSUPG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyVSUPG(ptvs);
        }else if('VSPWG'.equals(ptvs.ctrl.selectedProduct.product_code__c)){   //JL20211206 - Add for VHIS day2
            return new TMProductStrategyVSPWG(ptvs);                           //JL20211206 - Add for VHIS day2
        }                                                                      //JL20211206 - Add for VHIS day2
        //Add by Manuel for VHIS products (stop)
        
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
        //add by jack for COMB
        else if('@CBOG'.equals(ptvs.ctrl.selectedProduct.product_code__c) ){
            return new TMProductStrategyCOMB(ptvs);
        }else if('@ABAG'.equals(ptvs.ctrl.selectedProduct.product_code__c) ){
            return new TMProductStrategyABAG(ptvs);
        }else if('@ABEG'.equals(ptvs.ctrl.selectedProduct.product_code__c) ){
            return new TMProductStrategyABEG(ptvs);
        }else if('ABWG'.equals(ptvs.ctrl.selectedProduct.product_code__c) ){
            return new TMProductStrategyABWG(ptvs);
        }
        // Rancho_HKITSFDC402_20250930 - add CI product
        else if('CIB25'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyCIB25(ptvs);
        }else if('CIR25'.equals(ptvs.ctrl.selectedProduct.product_code__c)){
            return new TMProductStrategyCIR25(ptvs);
        }
        else{
            return null;
        }
    }

}