public class TMProductStrategyABWG extends TMProductStrategyAB{
    public static final string productCode = 'ABWG';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyABWG(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode); 
        this.ptvs = ptvs;
    }
}