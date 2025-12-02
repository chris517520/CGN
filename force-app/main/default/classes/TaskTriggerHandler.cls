/********************************************************************************
 * Apex Class Name - TaskTriggerHandler
 * Version - 1.0
 * Created Date - Nov 11, 2017
 * @description Trigger Handler for Task
 *
 * Modification Log : 
 * --------------------------------------------------------------------------------
 * Version   Developer       Date                    Description
 * ------    -----------     ------------            -----------------------
 * 1.0       Jay             08/11/2017              Original Version
 * 2.0       Franco          04/02/2018              Reconsitution
 ********************************************************************************/
public without sharing class TaskTriggerHandler{
    
    public final static String RECORD_TYPE_TM_TASK = 'TM_Task';
    public final static String RECORD_TYPE_TM_CALL = 'TM_Call';
    
    public static Boolean isBDUser = false;
    public static Map<String, String> recordTypeMap = new Map<String, String>();
    
    static{
        for(RecordType rt : [select Id, Name, developerName from RecordType where sobjectType = 'Task']){
            recordTypeMap.put(rt.Id, rt.developerName);
            recordTypeMap.put(rt.developerName, rt.Id);
        }
        isBDUser = CignaUtil.isBDUser();
    }
    
    public static void onBeforeInsert(List<Task> newList){
        system.debug('TaskTriggerHandler.onBeforeInsert in');
        If(isBDUser){
            TaskTriggerHandler.dueDateValidation(newList);
        }
        
        List<Task> tmtaskList = new List<Task>(); //for tm call
        List<Task> tmtaskList2 = new List<Task>(); //for tm task
        if(CignaUtil.isTMUser(Userinfo.getUserId())){
            system.debug('[TaskTriggerHandler] onBeforeInsert ## TM USER ##');
            User currentUser = [select id, TM_Agent_ID__c from User where id = :Userinfo.getUserId()];
            //Owen_JOBR-317_20230605 to limit creat task or update task by Team_Leader_Approved__c
            TaskTriggerHandler.validateTask(newList);
            // Rancho_CallCenterUCID_20210618 get UCID in opportunity
            List<String> whatIdList = new List<String>();
            Map<String, String> oppUCIDMap = new Map<String, String>();
            for(Task t : newList){
                whatIdList.add(t.WhatId);
            }
            if(!whatIdList.isEmpty()){
                for(Opportunity o : [SELECT Id, UCID__c FROM Opportunity WHERE Id IN :whatIdList]){
                    oppUCIDMap.put(o.Id, o.UCID__c);
                }
            }

            for(Task t : newList){
                if(t.due_Time__c == null){
                    //Add by Manuel for term code enhancement
                    if(t.Result__c!=null){
                        List<String> strSplit = t.Result__c.split(' ');
                        t.Term_Code__c = strSplit[0];
                    }
                    // Rancho_CallCenterUCID_20210618
                    if(oppUCIDMap != null){
                        t.UCID__c = oppUCIDMap.get(t.WhatId);
                    }
                    
                    system.debug('[TaskTriggerHandler] onBeforeInsert Task Due Time is Empty, convert to TM call');
                    // Auto populate record type, TM agent Id
                    t.recordTypeId = recordTypeMap.get(RECORD_TYPE_TM_CALL); // all TM related records will be TM call
                    if(String.isBlank(t.TMR_Agent_ID__c)){
                        t.TMR_Agent_ID__c = currentUser.TM_Agent_ID__c;
                    }
                    System.debug('add by li hao t.calldurationinseconds '+t.calldurationinseconds);
                    // Get Call_Start_Time And Call_End_Time By Subject for Avaya Call
                    if(t.calldurationinseconds == null){
                        t.calldurationinseconds = 0;
                    }
                    try{
                        Datetime SubiectTime = Datetime.valueOf(t.Subject);
                        t.Call_Start_Time__c = SubiectTime;
                        t.Call_End_Time__c = t.Call_Start_Time__c.addSeconds(t.calldurationinseconds);
                    }catch(Exception e){ }
                    
                    tmtaskList.add(t);
                }else{
                    //add by li hao 2019/05/14
                    System.debug('add by li hao '+t.due_Time__c +'<------>'+t.ActivityDate);
                    t.ActivityDate.format();
                    //Add by Manuel for term code enhancement
                    if(t.Result__c!=null){
                        List<String> strSplit = t.Result__c.split(' ');
                        t.Term_Code__c = strSplit[0];
                    }
                    
                    system.debug('[TaskTriggerHandler] onBeforeInsert Task Due Time is not Empty, convert to TM task');
                    tmtaskList2.add(t);
                }
            }
        }
        if(!tmtaskList.isEmpty()){
            system.debug('[TaskTriggerHandler] onBeforeInsert tmtaskList Size : >> ' + tmtaskList.size());
            TaskTriggerHandler.validateDueDateForTMRUser(tmtaskList);
            TaskTriggerHandler.setUnidentifiedCallDetail(tmtaskList);
            TaskTriggerHandler.checkCallResultLevel(tmtaskList);
            TaskTriggerHandler.generateReminder(tmtaskList);
            TaskTriggerHandler.limitCallReocrdInDummyOppty(tmtaskList);
            TaskTriggerHandler.autoPopulateConcatString(tmtaskList);
        }
        if(!tmtaskList2.isEmpty()){
            system.debug('[TaskTriggerHandler] onBeforeInsert tmtaskList2 Size : >> ' + tmtaskList2.size());
            TaskTriggerHandler.validateDueDateForTMRUser(tmtaskList2);
            TaskTriggerHandler.autoPopulateSubjectFollowUpTime(tmtaskList2);
            TaskTriggerHandler.generateReminder(tmtaskList2);
            TaskTriggerHandler.autoPopulateConcatString(tmtaskList2);
        }
        //add by kit
        if(CignaUtil.isCSUser()){
            for(Task t : newList){
                if(String.isBlank(t.RecordTypeId) && String.isBlank(t.Called__c)){
                    RecordType rType = [SELECT Id,name FROM RecordType WHERE SobjectType = 'Task' and DeveloperName = 'Avaya_call_Log' limit 1];
                    t.RecordTypeId = rType.Id;  
                }
            }
        }
        system.debug('TaskTriggerHandler.onBeforeInsert out');
    }
    
    public static void onAfterInsert(List<Task> newList){
        system.debug('TaskTriggerHandler.onAfterInsert in');
        List<Task> tmtaskList = new List<Task>();
        for(Task t : newList){
            if(recordTypeMap.get(t.recordTypeId) == RECORD_TYPE_TM_CALL){
                tmtaskList.add(t);
            }
        }
        if(!tmtaskList.isEmpty()){
            TaskTriggerHandler.updateRelatedAccount(tmtaskList);
            TaskTriggerHandler.updateOppFieldsAfterCreateForTM(tmtaskList);
            TaskTriggerHandler.insertOptoutHistory(new Map<Id, Task>(), tmtaskList);
            // TaskTriggerHandler.newSARecd(tmtaskList);// Rancho_SpeechAnalytics_20210607
        }
        system.debug('TaskTriggerHandler.onAfterInsert out');
    }
    
    public static void onBeforeUpdate(Map<Id, Task> oldMap, Map<Id, Task> newMap, List<Task> newList){
        system.debug('TaskTriggerHandler.onBeforeUpdate in');
        If(isBDUser){
            TaskTriggerHandler.dueDateValidation(newList);
        }
        List<Task> tmtaskList = new List<Task>(); // for tm call
        List<Task> tmtaskList2 = new List<Task>(); // for tm task
        //Owen_JOBR-317_20230605 to limit creat task or update task by Team_Leader_Approved__c
        TaskTriggerHandler.validateTask(newList);
        for(Task t : newList){
            if(recordTypeMap.get(t.recordTypeId) == RECORD_TYPE_TM_CALL){
                // Rancho_ClickToDial_20210923: if Have Clicked to Dial is changed, allow update it only and bypass other logic
                // tmtaskList.add(t);
                if( (oldMap.get(t.id).Have_Clicked_to_Dial__c != t.Have_Clicked_to_Dial__c) && !t.Have_Clicked_to_Dial__c){
                    // Boolean tempClickToDial = t.Have_Clicked_to_Dial__c;
                    // system.debug('before');
                    // t = oldMap.get(t.id);
                    // system.debug('after');
                    // t.Have_Clicked_to_Dial__c = tempClickToDial;
                }else{
                    tmtaskList.add(t);
                }
            }else if(recordTypeMap.get(t.recordTypeId) == RECORD_TYPE_TM_TASK){
                tmtaskList2.add(t);
            }
        }
        if(!tmtaskList.isEmpty()){
            TaskTriggerHandler.blockUpdateResultNotEmpty(oldMap, tmtaskList);
            TaskTriggerHandler.validateDueDateForTMRUser(tmtaskList);
            TaskTriggerHandler.checkCallResultLevel(tmtaskList);
            TaskTriggerHandler.generateReminder(tmtaskList);
        }
        if(!tmtaskList2.isEmpty()){
            TaskTriggerHandler.validateDueDateForTMRUser(tmtaskList2);
            TaskTriggerHandler.autoPopulateSubjectFollowUpTime(tmtaskList2);
            TaskTriggerHandler.generateReminder(tmtaskList2);
        }
        system.debug('TaskTriggerHandler.onBeforeUpdate out');
    }
    
    public static void onAfterUpdate(Map<Id, Task> oldMap, List<Task> newList){
        system.debug('TaskTriggerHandler.onAfterUpdate in');
        List<Task> tmtaskList = new List<Task>();
        for(Task t : newList){
            if(recordTypeMap.get(t.recordTypeId) == RECORD_TYPE_TM_CALL){
                // Rancho_ClickToDial_20210923: if Have Clicked to Dial is changed, allow update it only and bypass other logic
                // tmtaskList.add(t);
                if(oldMap.get(t.id).Have_Clicked_to_Dial__c == t.Have_Clicked_to_Dial__c){
                    tmtaskList.add(t);
                }
            }
        }
        if(!tmtaskList.isEmpty()){
            TaskTriggerHandler.updateRelatedAccount(tmtaskList);
            TaskTriggerHandler.updateOppFieldsAfterUpdateForTM(tmtaskList);
            TaskTriggerHandler.insertOptoutHistory(oldMap, tmtaskList);
            // TaskTriggerHandler.newSARecd(tmtaskList);// Rancho_SpeechAnalytics_20210607
        }
        system.debug('TaskTriggerHandler.onAfterUpdate out');
    }
    
    public static void onBeforeDelete(List<Task> oldList){
        List<Task> tmtaskList = new List<Task>();
        for(Task t : oldList){
            if(recordTypeMap.get(t.recordTypeId) == RECORD_TYPE_TM_CALL){
                tmtaskList.add(t);
            }
        }
        if(!tmtaskList.isEmpty()){
            TaskTriggerHandler.blockDeleteTmTask(tmtaskList);
        }
    }
    
    /*
     * For BD
     */
    public static void dueDateValidation(List<Task> newtask){
        List<Id> leadIdList = new List<Id>();
        List<Id> ContactIdList = new List<Id>();
        List<Id> AccountIdList = new List<Id>();
        List<Id> campaignIdList = new List<Id>();
        for(Task task : newtask){
            leadIdList.add(task.whoId);
            ContactIdList.add(task.whoId);
            AccountIdList.add(task.whatId);
            campaignIdList.add(task.whatId);
        }
        Map<Id,Lead> leadMap = new Map<Id,Lead>([select Id,Name,CreatedDate from Lead where Id in :leadIdList]);
        Map<Id,Contact> ContactMap= new Map<Id,Contact>([select Id,Name,CreatedDate from Contact where Id in : ContactIdList]);
        Map<Id,Account> AccountMap = new Map<Id,Account>([select Id,Name,CreatedDate from Account where Id in : AccountIdList]);
        Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([select Id,Name,CreatedDate from Campaign where Id in : CampaignIdList]);
        for(Task task : newtask){
            if(leadMap.containsKey(task.whoId)){
                Date createdDate = leadMap.get(task.whoId).createdDate.date();
                if(task.ActivityDate < createdDate){
                    task.addError('Due date should be on or later than the lead creation date.');
                    continue;
                }
            }
            if(ContactMap.containsKey(task.whoId)){
                Date createdDate = ContactMap.get(task.whoId).createdDate.date();
                if(task.ActivityDate < createdDate){
                    task.addError('Due date should be on or later than the Contact creation date.');
                    continue;
                }
            }
            if(AccountMap.containsKey(task.whatId)){
                Date createdDate = AccountMap.get(task.whatId).createdDate.date();
                if(task.ActivityDate < createdDate){
                    task.addError('Due date should be on or later than the Contact creation date.');
                    continue;
                }
            }
            if(CampaignMap.containsKey(task.whatId)){
                Date createdDate = CampaignMap.get(task.whatId).createdDate.date();
                if(task.ActivityDate < createdDate){
                    task.addError('Due date should be on or later than the Campaign creation date.');
                    continue;
                }
            }
        }
    }
    
    /**
    * For TMR User
    * Due data and due time is not NULL: Don't allow the same TMR to schedule a task on the same date and time
    * When the same TMR schedule a task on the same date/time HKT with other tasks of the same assignee, the system should alert the warning message: You already have a task scheduled on this date and time, please change to another due date/time. 
    * Action : Before create, Before insert
    */    
    public static void validateDueDateForTMRUser(List<Task> newList){
        system.debug('validateDueDateForTMRUser begin');
        List<Id> ownerIdList = new List<Id>();
        List<Date> taskDueDateList = new List<Date>();        
        for(Task newTask : newList){
            ownerIdList.add(newTask.OwnerId);
            taskDueDateList.add(newTask.ActivityDate);
        }
        RecordType tmTaskRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' and developerName = 'TM_Task' and isActive = true];
        //List<Task> taskList = [SELECT Id,OwnerId,ActivityDate,Due_Time__c,WhoId,WhatId,RecordTypeId From Task where OwnerId in : ownerIdList ];
        List<Task> taskList = [SELECT Id,OwnerId,ActivityDate,Due_Time__c,WhoId,WhatId,RecordTypeId From Task 
            where OwnerId in : ownerIdList AND ActivityDate in :taskDueDateList AND recordTypeId = :tmTaskRecordType.Id];        
        for(Task newTask : newList){           
            for(Task task : taskList){
                //if(newTask.ActivityDate != null &&  newTask.ActivityDate == task.ActivityDate && newTask.Due_Time__c != null && newTask.Due_Time__c == task.Due_Time__c && task.Id != newTask.Id){
                    if(task.OwnerId == newTask.OwnerId 
                    && newTask.ActivityDate != null &&  newTask.ActivityDate == task.ActivityDate 
                    && newTask.Due_Time__c != null && newTask.Due_Time__c == task.Due_Time__c 
                    && task.Id != newTask.Id){
                    newTask.ActivityDate.addError('You already have a task scheduled on this date and time, please change to another due date/time.');
                    break;
                }
            }
        }
        system.debug('validateDueDateForTMRUser end');
    }
    /**
     * For TM : After Create
     * Update fields in opportunity:Record Type = Call and whatid is a id of opportunity
     * Update the following field in the opportunity:
     * Last3_Called_Date__c = Last2_Called_Date__c 
     * Last2_Called_Date__c =  Last_Called_Date__c
     * Last_Called_Date__c = Task.CreatedDate
     * No_of_Attempt__c = No_of_Attempt__c + 1
     * No_of_Current_Attempt__c = No_of_Current_Attempt__c +1 --No_of_Attempt_Current_Owner__c
     * First_Call_Date__c: if it is blank, then pass Task.CreatedDate.
     * */
    public static void updateOppFieldsAfterCreateForTM(List<Task> newList){
        system.debug('updateOppFieldsAfterCreateForTM begin');
        Map<Id,Task> oppIdTaskMap = new Map<Id,Task>();
        for(Task newTask : newList){
            String whatId = newTask.WhatId;
            
            if(isOpportunityId(whatId)){
                oppIdTaskMap.put(whatId, newTask);
            }
        }
        if(!oppIdTaskMap.isEmpty()){
            // Rancho_CallCenterUCID_20210618
            List<Opportunity> oppList = [SELECT Id,Name,Last_Called_Date__c,Last2_Called_Date__c,Last3_Called_Date__c,No_of_Attempt__c,No_of_Attempt_Current_Owner__c,First_Call_Date__c,Accountid,result__c,Final_Attempt__c,Owner.Name,UCID__c,Team_Leader_Approved__c FROM Opportunity where Id in :oppIdTaskMap.keySet() ];
            for(Opportunity opp : oppList){
                
                Task oppTask = oppIdTaskMap.get(opp.Id);
                DateTime lastCalledDate = oppTask !=null ? oppTask.CreatedDate : opp.Last_Called_Date__c;
                Decimal noOfAttempt = opp.No_of_Attempt__c;
                Decimal noOfAttemptCurrentOwner = opp.No_of_Attempt_Current_Owner__c;               
                opp.Last3_Called_Date__c = opp.Last2_Called_Date__c;
                opp.Last2_Called_Date__c = opp.Last_Called_Date__c;     
                opp.Last_Called_Date__c = lastCalledDate;
                opp.No_of_Attempt__c = noOfAttempt != null ? noOfAttempt + 1 : 1;
                // Rancho_20240604 - do not update opp result when it is 500
                if(oppTask.result__c != null && !oppTask.result__c.startsWith('500')){
                    opp.result__c = oppTask.result__c;
                    opp.Current_Status_From__c = System.now();
                }
                opp.Final_Attempt__c = oppTask.Final_Attempt__c;
                opp.No_of_Attempt_Current_Owner__c = noOfAttemptCurrentOwner != null ? noOfAttemptCurrentOwner + 1 : 1;
                if(opp.First_Call_Date__c == null){
                    opp.First_Call_Date__c = oppTask != null ? oppTask.CreatedDate : null;
                }
                opp.UCID__c = '';// Rancho_CallCenterUCID_20210618 delete UCID in opportunity when TM_Call task inserted
                //Owen_JOBR-317_20230605 to limit creat task or update task by Team_Leader_Approved__c
                String taskOpt = oppTask != null ? oppTask.Overall_Opt_in_Opt_out__c : '';
                if(taskOpt=='Opt-Out'){
                    opp.Team_Leader_Approved__c = false;
                }
            }
            System.debug('oppList:'+oppList);
            update oppList;
        }
        system.debug('updateOppFieldsAfterCreateForTM end');
    }

    /**
     * For TM : After Update
     * Update fields in Opportunity (When Updated) : Record Type = Call and whatid is a id of opportunity
     * Update the following field in the opportunity:
     *- History_Pending_Days__c: if opportunity. result__c is in pending list and task.result__c is not, it should be updated to History_Pending_Days__c + No_of_days_in_current_status__c
     *- Current_status_from__c: if the task.result__c is not equal to opportunity. result__c, update it to today.
     *- Result__c = task.Result__c
     *- Final_Attempt__c = task. Final_Attempt__c
     */    
    public static void updateOppFieldsAfterUpdateForTM(List<Task> newList){
        system.debug('updateOppFieldsAfterUpdateForTM begin');
        Map<Id,Task> oppIdTaskMap = new Map<Id,Task>();
        for(Task newTask : newList){
            String whatId = newTask.WhatId;  
            if(isOpportunityId(whatId)){
                oppIdTaskMap.put(whatId, newTask);
            }
        }
        if(!oppIdTaskMap.isEmpty()){
            List<Opportunity> oppList = [SELECT Id,Name,History_Pending_Days__c,Current_status_from__c,Result__c,Final_Attempt__c,No_of_days_in_current_status__c,Overall_Opt_in_Opt_out__c,Team_Leader_Approved__c FROM Opportunity where Id in :oppIdTaskMap.keySet() ];
            List<String> pendingResultList = new List<String>();
            pendingResultList.add('408 - Pending for U/W - manual order');
            pendingResultList.add('411 - Pending for U/W - CITAS order');                       
            for(Opportunity opp : oppList){
                Task oppTask = oppIdTaskMap.get(opp.Id);
                String taskResult = oppTask != null ? oppTask.Result__c : '';
                String oppResult = opp.Result__c;
                Decimal hisotryPendingDays = opp.History_Pending_Days__c != null ? opp.History_Pending_Days__c : 0;
                Decimal currentStatusDays = opp.No_of_days_in_current_status__c != null ? opp.No_of_days_in_current_status__c : 0;
                if(pendingResultList.contains(oppResult) && !pendingResultList.contains(taskResult)){
                    opp.History_Pending_Days__c = hisotryPendingDays + currentStatusDays;                               
                }
                // Rancho_PI170_20240604 - do not update opp result when it is 500
                if(taskResult != oppResult && !taskResult.startsWith('500')){
                    opp.Current_Status_From__c = System.now();
                    opp.Result__c =  taskResult;
                }
                //Owen_JOBR-317_20230605 to limit creat task or update task by Team_Leader_Approved__c
                String taskOpt = oppTask != null ? oppTask.Overall_Opt_in_Opt_out__c : '';
                if(taskOpt=='Opt-Out'){
                    opp.Team_Leader_Approved__c = false;
                }
            }
            update oppList;
        }        
        system.debug('updateOppFieldsAfterUpdateForTM end');
    }
    /**
    *TMR should not be able to assign a task to other TMRs, 
    *if the Assignee is changed to others, 
    *the system should not allow TMR to save the task and should alert the TMR
    */
    public static void forbidTMRAssignToOthers(List<Task> newList){
        
        for(Task newC : newList){
            if(newC.CreatedById <> newC.OwnerId){
                newC.addError(System.Label.TM_AssignedTaskError);
            }
        }
    }

    /**
    *TMR should not be able to assign a task to other TMRs, 
    *if the Assignee is changed to others, 
    *the system should not allow TMR to save the task and should alert the TMR
    */
    public static void generateReminder(List<Task> newList){
        if(TM_General_Setting__c.getValues('Default') != null){
            Integer reminderMin =  Integer.valueOf(0 - TM_General_Setting__c.getValues('Default').Task_Reminder_time_mins__c);
            system.debug('[generateReminder] reminderMin:'+ reminderMin);  
            for(Task newC : newList){
                system.debug('[generateReminder] newC:'+ newC);  
                if(newC.ActivityDate != null && newC.due_Time__c != null){
                    newC.ReminderDateTime = DateTime.newInstance(newC.ActivityDate, newC.due_Time__c).addMinutes(reminderMin);
                    newC.IsReminderSet = true;
                    system.debug('[generateReminder] newC.ReminderDateTime:'+ newC.ReminderDateTime);
                }
            }
            system.debug('generateReminder:'+ newList);
        }
    }
    
    /*
     * Update Related Accounts' information
     * 1.TS-650 update Overall_Opt_Out__pc for existing customer,
     *          update Opt_out_Exclusion__pc from TM customer
     * 
     */
    public static void updateRelatedAccount(List<Task> newList){
        system.debug('updateRelatedAccount begin');
        List<Id> accIdList = new List<Id>();
        for(Task newTask : newList){
            if(newTask.accountId != null){
                accIdList.add(newTask.accountId);
            }
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([select id, SSN__c, Opt_out_Exclusion__pc, Overall_Opt_Out__pc from Account where id in :accIdList]);
        
        List<Account> updatedAccList = new List<Account>();
        Account acc;
        for(Task newTask : newList){
            Boolean optOutFlag = ( newTask.Overall_Opt_in_Opt_out__c == 'Opt-Out' );
            acc = accountMap.get(newTask.accountId);
            if(acc != null){
                // if task opt-out flag changed and account opt-out not equals to task opt-out
                if(String.isNotBlank(acc.SSN__c) && acc.Overall_Opt_Out__pc != optOutFlag){
                    acc.Overall_Opt_Out__pc = optOutFlag;
                    updatedAccList.add(acc);
                }else if(acc.Opt_out_Exclusion__pc != optOutFlag){
                    acc.Overall_Opt_Out__pc = optOutFlag; // Also need to update overall opt out flag - DPSP-735
                    acc.Opt_out_Exclusion__pc  = optOutFlag;
                    updatedAccList.add(acc);
                }
            }
        }
        system.debug('updatedAccList: ' + updatedAccList);
        if(!updatedAccList.isEmpty()){
            update updatedAccList;
        }
        system.debug('updateRelatedAccount end');
    }

    /**
    *Opt-out checkbox changed
    *A Opt-out history should be inserted if the checkbox updated
    */
    public static void insertOptoutHistory(Map<Id, Task> oldMap, List<Task> newList){
        List<Opt_out_History__c> insertList = new List<Opt_out_History__c>();
        for(Task t : newList){
            if((Trigger.isInsert && t.Overall_Opt_in_Opt_out__c != null) || (Trigger.isUpdate && oldMap.get(t.Id).Overall_Opt_in_Opt_out__c <> t.Overall_Opt_in_Opt_out__c)){
                Opt_out_History__c newData = new Opt_out_History__c();
                newData.Account__c = (t.AccountId <> null) ? t.AccountId : null;
                newData.Call_History__c = isOpportunityId(t.WhatId) ? t.WhatId : null;
                newData.Update_Date_Time__c = DateTime.now();
                newData.Update_User__c = UserInfo.getUserId();
                newData.Update_Value__c = ( t.Overall_Opt_in_Opt_out__c == 'Opt-Out' );
                insertList.add(newData);
            }
        }
        if(insertList.size()>0){
            try {
                insert insertList;
            }catch(Exception e){
                system.debug('>>Exception when save Opt out history: ' + e.getMessage());
                system.debug('>>Exception when save Opt out history: ' + e.getStackTraceString());
            }
        }
    }
    
    /*
     * Block update when result not empty for TM CALL
     * DPSP-528 For TMR Agent, if result field is empty, TMR can edit the call detail.
     *          If result field is not empty, only team lead, sub team lead and tm manager are allowed to edit the call record.
     *          P.S. The edit right is for the whole call record. not just the specific field
     * Special handling for Aspect call flow:
     *   1. TMR create a call detail with result by click log a call button
     *   2. After TMR saved the record, Aspect will update this record to fill the Call start time.
     */
    public static void blockUpdateResultNotEmpty(Map<Id, Task> oldMap, List<Task> newList){
        for(Task t : newList){
            if(string.isNotBlank(oldMap.get(t.id).result__c) && !CignaUtil.isTMLeader(Userinfo.getUserId())){
                // Special handling for Aspect call flow
                if(oldMap.get(t.id).call_start_time__c == null && t.call_start_time__c != null){
                    // means it's update by Aspect
                    continue;
                }else{
                    t.addError('Task can not be changed when result field is not empty');                   
                }
            }
        }
    }
    
    /*
    * Block delete for TM Task
    */
    public static void blockDeleteTmTask(List<Task> oldList){
        if(CignaUtil.isTMUser(Userinfo.getUserId()) || CignaUtil.isCVMUser(Userinfo.getUserId())){
            for(Task t : oldList){
                t.addError('You have no permission to delete this Task');
                continue;
            }
        }
    }
    
    /*
    * For the case of recording unidentified inbound call
    * Call details will be created under this oppty with (1) TMR Agent ID; 
    * (2) call duration = 0; (3) Result = 105 invalid (TBC); (4) Opt-out
    *
    * DPSP-545 in transfer request case, the dummy opportunity has to be with 105 
    * term code and call details (i.e. same as invalid call handling)  
    * Added in 0706 call duration not set to 0 for transfer request case.
    * 
    */
    public static void setUnidentifiedCallDetail(List<Task> newList){
        system.debug('setUnidentifiedCallDetail begin');
        Map<Id,Task> oppTaskMap = new Map<Id,Task>();
        for(Task t : newList){
            oppTaskMap.put(t.whatId,t);
        }
        List<Opportunity> dummyOppList = [Select id,name, account.recordType.developerName from Opportunity where Is_Dummy_TM_opportunity__c = true 
            and id in :oppTaskMap.keySet()];
        if(!dummyOppList.isEmpty()){
            for(Opportunity o : dummyOppList){
                
                if(o.account.recordType.developerName == 'TM_Dummy_Account'){
                    oppTaskMap.get(o.id).CallDurationInSeconds = 0;
                }
                oppTaskMap.get(o.id).Result__c = '105 - Invalid';
                oppTaskMap.get(o.id).Overall_Opt_in_Opt_out__c = 'Opt-Out';
            }
        }
        system.debug('setUnidentifiedCallDetail end');
    }
    
    public static Boolean isOpportunityId(String whatId){
        return(whatId != null && whatId.startsWith(Schema.SObjectType.Opportunity.getKeyPrefix()));
    }
    
    /*
    * DPSP-607
    *   Logic 1. Define term code with different levels, and any new call details of the oppty should 
    *            not allow user to input term code being lower in level than the latest term code.
    *   Logic 2. When adding term code, check if Opportunity has a Policy created. If yes, term code must be Level 3 or above (changed in DPSP-776).
    *
    * DPSP-527
    *   Logic 3. Term code in "success"(400 only) category shd only be shown on log a call page when respective oppty is with policy record.
    *            Block insert/update if log a call result is "success" but last policy not complete with the oppty.
    *
    * DPSP-805
    *   logic 4. If last policy transaction in oppty is completed status. Only Level 4 term code can be inputted.
    *
    *
    * Supplyment in DPSP-835
    * below will be the summary of all validation logic relating to term code input. red are the changes:
    * Success term code (exclude 407) could be entered when policy status is completed or submitted only.
    * Success term code 407 could be entered only when latest manual application record is inputted.
    * Level 4 term code cannot be entered when policy status is not completed or submitted.
    * Level 3 or 4 term code could be entered when there is policy in the opportunity.
    * Term code to be entered should not be level down to latest term code result.
    */
    public static void checkCallResultLevel(List<Task> newList){
        system.debug('[TaskTriggerHandler] checkCallResultLevel begin'+newList);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Task t : newList){
            if(isOpportunityId(t.whatId)){
                oppIdSet.add(t.whatId);
            }
        }
        if(!oppIdSet.isEmpty()){
            oppMap = new Map<Id, Opportunity>([Select id, name, Result__c, Term_Code_Level__c, (Select Id, Name, Status__c from Policy_Transactions__r order by lastmodifieddate desc), 
                (Select id, name from Manual_Application__r order by lastmodifieddate desc) from Opportunity where id in :oppIdSet]);
            if(CignaUtil.isTMRUser(Userinfo.getUserId()) || CignaUtil.isCVMUser(Userinfo.getUserId())){
                for(Task t : newList){
                    Opportunity opp = oppMap.get(t.whatId);
                    if(opp != null){                         
                         // Logic 1
                         //Jobr-328,add by Owen 2023-09-13 to allow '500' term code pass
                         Boolean is500code=false;
                         if(String.isNotBlank(opp.result__c)){
                            if(opp.result__c.startsWith('500')){
                                is500code=true;
                            }
                         }
                        if(String.isNotBlank(t.Term_Code_Level__c)&&!is500code){
                            Integer oppTermCodeLevelInt = String.isBlank(opp.Term_Code_Level__c) ? 0 : Integer.valueOf(opp.Term_Code_Level__c);
                            Integer taskTermCodeLevelInt = String.isBlank(t.Term_Code_Level__c) ? 0 : Integer.valueOf(t.Term_Code_Level__c);
                            if(taskTermCodeLevelInt < oppTermCodeLevelInt && taskTermCodeLevelInt != 0){
                                system.debug('[TaskTriggerHandler] checkCallResultLevel logic1 term code level validation failed >>' + taskTermCodeLevelInt + '/' + oppTermCodeLevelInt);
                                t.addError('Please check the term code level');
                                continue;
                            }
                        }
                        // Logic 2
                        //if(t.Term_Code_Level__c != null && (t.Term_Code_Level__c != '4' && t.Term_Code_Level__c != '3' && !t.result__c.startsWith('105')) && opp.Policy_Transactions__r != null && opp.Policy_Transactions__r.size() > 0){
                        //    system.debug('[TaskTriggerHandler] checkCallResultLevel logic2 term code level validation failed >>' + t.Term_Code_Level__c);
                        //    t.addError('Term code level must be level 3 or above');
                        //    continue;
                        //}
                        
                        // Logic 3
                        if(t.result__c != null && (t.result__c.startsWith('400') )  //|| t.result__c.startsWith('407')
                            && ((opp.Policy_Transactions__r.size() > 0 && (opp.Policy_Transactions__r[0].Status__c != 'Completed' && opp.Policy_Transactions__r[0].Status__c != 'Submitted')) 
                                || opp.Policy_Transactions__r.isEmpty()) ){
                            system.debug('[TaskTriggerHandler] checkCallResultLevel logic3 term code level validation failed >>' + t.result__c);
                            t.addError('Please check the term code again since the policy is not completed.');
                            continue;
                        }
                        
                        //logic 4
                        //Jobr-328,add by Owen 2023-09-13 to allow '500' term code pass
                        if(t.result__c != null && ((t.Term_Code_Level__c != '4') && !t.result__c.startsWith('500'))
                            &&((opp.Policy_Transactions__r.size() > 0 
                            &&(opp.Policy_Transactions__r[0].Status__c == 'Completed' || opp.Policy_Transactions__r[0].Status__c == 'Submitted')))){
                            system.debug('[TaskTriggerHandler] checkCallResultLevel logic4 term code level validation failed >>' + t.result__c);
                            t.addError('Completed policy can only input Level 4 term code');
                            continue;
                        }
                        
                        //Logic 5 for manual application
                        if(t.result__c != null && t.result__c.startsWith('407') && opp.Manual_Application__r.isEmpty() && !t.result__c.startsWith('500')){
                            system.debug('[TaskTriggerHandler] checkCallResultLevel logic5 term code level validation failed >>' + t.result__c);
                            
                            t.addError('Please check the term code again since there is no submitted manual application.');
                            continue;
                        }
                        
                        if(t.result__c != null && !t.result__c.startsWith('407') && !opp.Manual_Application__r.isEmpty() && !t.result__c.startsWith('500')){
                            system.debug('[TaskTriggerHandler] checkCallResultLevel logic5 term code level validation failed >>' + t.result__c);
                            t.addError('Success term code 407 could be entered only when latest manual application record is inputted.');
                            continue;
                        }                   
                    }
                }
            }
        }
    }
    
    /*
    * DPSP-649
    * Limit call record to be 1 only in any dummy oppty.
    */
    public static void limitCallReocrdInDummyOppty(List<Task> newList){
        List<String> opptyIdList = new List<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<String> dummyOppIdList = new List<String>();
        List<Task> dummyCallList = new List<Task>();
        List<String> withCallDummyOppList = new List<String>();
        
        for(Task t : newList){
            opptyIdList.add(t.whatId);
        }
        
        oppList = [Select id,name,Is_Dummy_TM_opportunity__c from Opportunity where id in :opptyIdList and Is_Dummy_TM_opportunity__c = true];
        
        if(!oppList.isEmpty()){
            for(Opportunity o : oppList){
                dummyOppIdList.add(o.id);
            }
            
            dummyCallList = [Select id,whatId from Task where whatId in :dummyOppIdList];
            
            if(!dummyCallList.isEmpty()){
                for(Task t: dummyCallList){
                    withCallDummyOppList.add(t.whatId);
                }
                
                for(Task t : newList){
                    if(withCallDummyOppList.contains(String.valueOf(t.whatId))){
                        t.addError('Can not create more than 1 call record in Dummy Opportunity');
                    }
                }
            }
        }
    }
    
    
    /*
    * DPSP-731
    * Auto pop the due time in Task Subject.
    */
    public static void autoPopulateSubjectFollowUpTime(List<Task> newList){
        for(Task t : newList){
            if(Trigger.isInsert){
                String followUpStr = 'Follow Up At ' + String.valueOf(t.due_Time__c.hour()).leftPad(2, '0') + String.valueOf(t.due_Time__c.minute()).leftPad(2, '0') + ' - ';
                t.Subject = followUpStr + t.Subject;
            }else{
                String followUpStr = 'Follow Up At ' + String.valueOf(t.due_Time__c.hour()).leftPad(2, '0') + String.valueOf(t.due_Time__c.minute()).leftPad(2, '0');
                t.Subject = followUpStr;
            }
        }
    }
    
    /**
     *  Auto Populate Concat String for TM call log (Opportunity.Term_Code__c + Opportunity.Opportunity_ID__c)
     **/
    public static void autoPopulateConcatString(List<Task> newList){
        Map<Id,Opportunity> oppIDOpptyMap = new Map<Id,Opportunity>();
        Set<Id> parentIdSet = new Set<Id>();
        for(Task t : newList){
            parentIdSet.add(t.WhatId);
        }
        for(Opportunity opp : [SELECT Id, Term_Code__c, Opportunity_Id__c FROM Opportunity WHERE Id IN :parentIdSet]){
            oppIDOpptyMap.put(opp.Id, opp);
        }
        for(Task t : newList){
            Opportunity oppty = oppIDOpptyMap.get(t.WhatId);
            t.Concat_String__c = t.Term_Code__c + oppty.Opportunity_ID__c;
        }
    }

    // Owen_JOBR-317_20230605 to limit creat task or update task form opt-out to opt-in by Team_Leader_Approved__c
    public static void validateTask(List<Task> newList){
        List<Id> OppIdList = new List<Id>();
        for(Task t : newList){
            OppIdList.add(t.whatId);
        }
        Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>([SELECT Id,Team_Leader_Approved__c,Overall_Opt_in_Opt_out__c FROM Opportunity WHERE Id =:OppIdList]);
        for(Task t : newList){
            if(OppMap.containsKey(t.whatId)){
                if(t.Overall_Opt_in_Opt_out__c=='Opt-In'&&OppMap.get(t.whatId).Overall_Opt_in_Opt_out__c=='Opt out'&&OppMap.get(t.whatId).Team_Leader_Approved__c==false){
                    t.addError('Existing Opt-out customer. For changing to Opt-in, please obtain customer\'s consent and seek Team Leader for approval.');
                    break;
                }
            }
        }
    }
        
    /**
     *  Rancho_SpeechAnalytics_20210607 new Speech Analytics Log record when log a call
     **/
    /*public static void newSARecd(List<Task> newList){
        System.debug('TaskTriggerHandler.newSARecd');
        List<String> oppIdList = new List<String>();
        List<String> policyIdList = new List<String>();
        for(Task t : newList){
            if(isOpportunityId(t.whatId) && !oppIdList.contains(t.whatId)){
                oppIdList.add(t.whatId);
            }
        }
        if(!oppIdList.isEmpty()){
            CreateNewSpeechAnalyticsLogCtrl newSA = new CreateNewSpeechAnalyticsLogCtrl();
            newSA.newRecord(oppIdList, policyIdList);
        }
    }*/
}