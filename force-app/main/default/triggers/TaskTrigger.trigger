/********************************************************************************
 * Apex Class Name - TaskTrigger
 * Version - 1.0
 * Created Date - Nov 11, 2017
 * @description Trigger for Task
 *
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Jay             08/11/2017              Original Version
 * 2.0       Franco          04/02/2018              Reconsitution
 ********************************************************************************/
trigger TaskTrigger on Task (before insert, after insert, before update, after update, before delete) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        TaskTriggerHandler.onBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        TaskTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap, Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        TaskTriggerHandler.onAfterInsert(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        TaskTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        TaskTriggerHandler.onBeforeDelete(Trigger.old);
    }
}