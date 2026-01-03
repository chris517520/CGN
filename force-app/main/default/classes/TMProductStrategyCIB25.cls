public class TMProductStrategyCIB25 extends TMProductStrategyCI {
    
    public static final String productCode = 'CIB25';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyCIB25(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode);
        this.ptvs = ptvs;
    }

}