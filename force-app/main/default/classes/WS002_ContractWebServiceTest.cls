@isTest
private class WS002_ContractWebServiceTest {

    static id createNewAccount() {
        Account account = new Account(
            Name = 'Account1'
        );
        insert account;
        return account.Id;
    }
    @isTest
    static void testCreateContract() {

        // Création d'un account
        ID account = createNewAccount();
                
        // Création d'un contrat DTO pour les tests
        WS002_ContractWebService.ContractDTO contractDto = new WS002_ContractWebService.ContractDTO();
        contractDto.accountId = account;
        contractDto.contractTerm = 12;
        contractDto.startDate = Date.today();
        contractDto.salesforceId = null; // La valeur de salesforceId sera mise à jour lors de l'appel

        // Appel de la méthode createContract du service web
        Test.startTest();
        ID result = WS002_ContractWebService.createContract(contractDto);
        Test.stopTest();

        // Vérification du résultat
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testUpdateContract() {

        ID account = createNewAccount();
        

        // Création d'un contrat de test dans Salesforce
        Contract testContract = new Contract();
        testContract.AccountId = account;
        testContract.ContractTerm = 12;
        testContract.StartDate = Date.today();
        insert testContract;

        // Création des données JSON pour la mise à jour du contrat
        Map<String, Object> updateData = new Map<String, Object>{
            'contractTerm' => 24,
            'startDate' => Date.today().addDays(1)
        };

        // Appel de la méthode updateContract du service web
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/contracts/' + testContract.Id;
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(updateData));
        RestContext.request = request;
        WS002_ContractWebService.updateContract();
        Test.stopTest();

        // Vérification de la mise à jour des champs du contrat
        Contract updatedContract = [SELECT Id, ContractTerm, StartDate FROM Contract WHERE Id = :testContract.Id];
        System.assertEquals(24, updatedContract.ContractTerm);
        System.assertEquals(Date.today().addDays(1), updatedContract.StartDate);
    }
}