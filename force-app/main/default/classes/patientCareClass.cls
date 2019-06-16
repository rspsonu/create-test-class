global class EISLER_CommunityService {

    /*
     * Fetches current user Id
     */
    @AuraEnabled
    static public Id [] currentUserId() {
        List<Id> value = new List<Id>();
        Id userId = UserInfo.getUserId();
		value.add(userId);
        return value;
    }

    /*
     * Fetches the particular welcome mat name for the logged in user
     */
    @AuraEnabled
    public static string fetchWelcomeMatName(){
        Id userId = UserInfo.getUserId();
        List<Id> permSetIds =  new List<Id>();
        for(PermissionSetAssignment permSetAssgn: [SELECT PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :userId]) {
            permSetIds.add(permSetAssgn.PermissionSetId);
        }
        for(PermissionSet permSet: [SELECT Id, Name FROM PermissionSet WHERE Id IN :permSetIds]) {
            if(permSet.Name == 'EISLER_Patient_Community_Access_Patient') {
                return 'EISLER_Community_Welcome_Patient';
            }
            if(permSet.Name == 'EISLER_Patient_Community_Access_Patient_Family') {
                return 'EISLER_Community_Welcome_Patient_Family';
            }
        }
        return 'nothing';
    }

    /*
     * Fetches welcome mat
     */
    @AuraEnabled
    static public Decimal [] currentUserWelcomeMat(String welcomeMatName) {
        List<Decimal> value = new List<Decimal>();
        Id userId = UserInfo.getUserId();
        for(WELCOME_Welcome__c welcomeMat: [SELECT Progress__c FROM WELCOME_Welcome__c WHERE Name = :welcomeMatName AND User__c = :userId]) {
            value.add(welcomeMat.Progress__c);
        }
        return value;
    }

    /*
     * Fetches goals for current user
     */
    @AuraEnabled
    static public Id [] goalsForCurrentUser() {
        Id userId = UserInfo.getUserId();
        List<Id> carePlanIds = new List<Id>();
        List<Id> careProblemIds = new List<Id>();
        Id [] result = new Id [] {};
        String patientId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        Contact patient = [SELECT AccountId FROM Contact WHERE Id =: patientId];
        List<Case> patientCarePlans = [SELECT Id FROM Case WHERE AccountId = :patient.AccountId];
        for(Case patientCarePlan: patientCarePlans) {
            carePlanIds.add(patientCarePlan.Id);
        }
        List<HealthCloudGA__CarePlanProblem__c> problemList = [SELECT Id, Name FROM HealthCloudGA__CarePlanProblem__c WHERE HealthCloudGA__CarePlan__c IN :carePlanIds];
        for(HealthCloudGA__CarePlanProblem__c problem: problemList) {
            careProblemIds.add(problem.Id);
        }
        for(HealthCloudGA__CarePlanGoal__c r: [SELECT Id FROM HealthCloudGA__CarePlanGoal__c WHERE HealthCloudGA__CarePlanProblem__c IN :careProblemIds]) {
            result.add(r.Id);
        }
        return result;
    }

    /*
     * Fetches care team for current user
     */
    @AuraEnabled
    static public Id [] careTeamForCurrentUser() {
        Id userId = UserInfo.getUserId();
        List<Id> carePlanIds = new List<Id>();
        List<Id> careTeamContactIds = new List<Id>();
        List<Id> careTeamUserIds = new List<Id>();
        String patientId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        Contact patient = [SELECT AccountId FROM Contact WHERE Id =: patientId];
        for(Case patientCarePlan: [SELECT Id FROM Case WHERE AccountId = :patient.AccountId]) {
            carePlanIds.add(patientCarePlan.Id);
        }
        for(CaseTeamMember caseMember: [SELECT MemberId FROM CaseTeamMember WHERE ParentId IN :carePlanIds]) {
            careTeamContactIds.add(caseMember.MemberId);
        }
        for(User careTeamUser: [SELECT Id FROM User WHERE ContactId IN :careTeamContactIds]) {
            careTeamUserIds.add(careTeamUser.Id);
        }
        return careTeamUserIds;
    }

    /***
     * This function fetches the medication prescriptions specified for the logged in user.
     * Input : None
     * Output : List of all Medication Ids that has been prescribed to the user.
     ***/
    @AuraEnabled
    static public Id [] medicationsForCurrentUser() {
        Id userId = UserInfo.getUserId();
        String patientId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        Contact patient = [SELECT AccountId FROM Contact WHERE Id =: patientId];
        Id [] medPrescriptionsIds = new Id [] {};
            for(HealthCloudGA__EhrMedicationPrescription__c prescription: [SELECT Id FROM HealthCloudGA__EhrMedicationPrescription__c
                                                                           WHERE HealthCloudGA__Account__c = :patient.AccountId
                        								   				   ORDER BY HealthCloudGA__DateWritten__c ASC]) {
            medPrescriptionsIds.add(prescription.Id);
        }
        return medPrescriptionsIds;
    }

    /***
     * This function fetches the next pending appointments for the logged in user.
     * The next assignment which is not in completed to cancelled status is fetched and shown in the Assignment panel component.
     * Input : None
     * Output : Appointment id that is assigned to the user and not in cancelled to completed status.
     ***/
    @AuraEnabled
    static public Id nextAppointmentForCurrentUser() {
        Id serviceAppointmentId;
        Id userId = UserInfo.getUserId();
        String patientId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        for(ServiceAppointment serviceAppointment: [SELECT Id FROM ServiceAppointment
                                                    WHERE DueDate >=: Date.today()
                                                    AND Status NOT IN ('Canceled','Completed')
                                                    AND ContactId = :patientId
                                                    ORDER BY DueDate ASC LIMIT 1]) {
                                                        serviceAppointmentId = serviceAppointment.Id;
                                                    }
        return serviceAppointmentId;
    }

    /***
     * This function fetches the list of all pending tasks for the logged in user.
     * Input : None
     * Output : List of tasks ids that are assigned to the user.
     ***/
    @AuraEnabled
    static public Id [] tasksForCurrentUser() {
    	Id [] taskIds = new Id [] {};
        for(HealthCloudGA__CarePlanTemplateTask__c task: [SELECT Id FROM HealthCloudGA__CarePlanTemplateTask__c
                        								  ORDER BY HealthCloudGA__SortOrder__c ASC]) {
            taskIds.add(task.Id);
        }
        return taskIds;
    }

    /***
     *******Temporarily aligned with the Case object for demo purpose*******
     * This function fetches the list of all messages for the logged in user.
     * Input : None
     * Output : List of message ids that are received by the user.
     ***/
    @AuraEnabled
    static public Id [] messagesForCurrentUser() {
        Id userId = UserInfo.getUserId();
        String patientId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
    	Id [] messageIds = new Id [] {};
        for(Case message: [SELECT Id FROM Case
                           WHERE ContactId = :patientId
                        		ORDER BY CreatedDate ASC]) {
            messageIds.add(message.Id);
        }
        return messageIds;
    }

    /*
     * Fetches patients for the doctor user
     */
    @AuraEnabled
    static public Id [] patientsForCurrentUser() {
        Id userId = UserInfo.getUserId();
        String permissionSetId = [SELECT Id, Name FROM PermissionSet WHERE Name = 'EISLER_Patient_Community_Access_Patient'].Id;

        List<Id> patientUserIds = new List<Id>();
        for(PermissionSetAssignment patientUserId : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetId]) {
            patientUserIds.add(patientUserId.AssigneeId);
        }
    	Id [] patientIds = new Id [] {};
        for(User patient: [SELECT Id FROM User
                           WHERE User.ContactId IN
                           (SELECT ContactId FROM Case
                            WHERE OwnerId =: userId)
                           AND Id IN :patientUserIds
                           ORDER BY CreatedDate ASC]) {
            patientIds.add(patient.Id);
        }
        return patientIds;
    }

    /*
     * Fetches candidate patients for the logged in doctor user
     */
    @AuraEnabled
    public static Id [] candidatePatientsForDoctorUser(){
        Id userId = UserInfo.getUserId();
        List<Id> candidatePatientIds = new List<Id>();
        for(HealthCloudGA__CandidatePatient__c candidatePatient: [SELECT Id FROM HealthCloudGA__CandidatePatient__c WHERE OwnerId =:userId]) {
            candidatePatientIds.add(candidatePatient.Id);
        }
        return candidatePatientIds;
    }

    /*
     * Fetches profile photo of the logged in user
     */
    @AuraEnabled
    global static string getProfilePhoto(){
        Id userId = UserInfo.getUserId();
        Id communityId = ConnectApi.Communities.getCommunities().communities[0].id;
        ConnectApi.Photo userPhoto = ConnectApi.UserProfiles.getPhoto(communityId,userId);
        return userPhoto.mediumPhotoUrl;
    }

    /*
     * Uploads a new profile photo for the logged in user
     */
    @AuraEnabled
    global static string uploadUserPhoto(String image){
        Id userId = UserInfo.getUserId();
        Id communityId = ConnectApi.Communities.getCommunities().communities[0].id;
        ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(EncodingUtil.base64Decode(image), 'image/png', 'userphoto.png');
        ConnectApi.Photo userPhotoUpload = ConnectApi.UserProfiles.setPhoto(communityId,userId,fileUpload);
        ConnectApi.Photo userPhoto = ConnectApi.UserProfiles.getPhoto(communityId,userId);
        return userPhoto.mediumPhotoUrl;
    }
}
