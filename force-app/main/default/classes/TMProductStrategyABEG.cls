public class TMProductStrategyABEG extends TMProductStrategyAB{
    public static final string productCode = 'ABEG';
    
    public TMPolicyUtil.PolicyTransactionValidationStruct ptvs;
    
    public TMProductStrategyABEG(TMPolicyUtil.PolicyTransactionValidationStruct ptvs){
        super(ptvs,productCode); 
        this.ptvs = ptvs;
    }
}