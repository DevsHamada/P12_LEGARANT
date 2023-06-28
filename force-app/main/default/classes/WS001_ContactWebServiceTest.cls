@isTest
private class WS001_ContactWebServiceTest {

    @isTest
    static void testCreateContact() {
        // Création d'un contact DTO pour les tests
        WS001_ContactWebService.ContactDTO contactDto = new WS001_ContactWebService.ContactDTO();
        contactDto.firstName = 'Med';
        contactDto.lastName = 'Zej';
        contactDto.email = 'Med.zej@example.com';
        contactDto.salesforceId = null; // La valeur de salesforceId sera mise à jour lors de l'appel

        // Appel de la méthode createContact du service web
        Test.startTest();
        ID result = WS001_ContactWebService.createContact(contactDto);
        Test.stopTest();

        // Vérification du résultat
        System.assertEquals(true, result != null);
        System.assertNotEquals(null, contactDto.salesforceId);
    }

    @isTest
    static void testUpdateContact() {
        // Création d'un contact de test dans Salesforce
        Contact testContact = new Contact();
        testContact.FirstName = 'Med';
        testContact.LastName = 'Momo';
        testContact.Email = 'med.momo@example.com';
        insert testContact;

        // Création des données JSON pour la mise à jour du contact
        Map<String, Object> updateData = new Map<String, Object>{
            'firstName' => 'UpdatedFirstName',
            'lastName' => 'UpdatedLastName',
            'email' => 'updated.email@example.com'
        };

        // Appel de la méthode updateContact du service web
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/Contacts/' + testContact.Id;
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(updateData));
        RestContext.request = request;
        ID result = WS001_ContactWebService.updateContact();
        Test.stopTest();

        // Vérification du résultat
        System.assertEquals(testContact.Id, result);

        // Vérification de la mise à jour des champs du contact
        Contact updatedContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('UpdatedFirstName', updatedContact.FirstName);
        System.assertEquals('UpdatedLastName', updatedContact.LastName);
        System.assertEquals('updated.email@example.com', updatedContact.Email);
    }

    @isTest
    static void testDeleteContact() {
        // Création d'un contact de test dans Salesforce
        Contact testContact = new Contact();
        testContact.FirstName = 'test';
        testContact.LastName = 'Doe';
        testContact.Email = 'test.doe@example.com';
        insert testContact;

        // Appel de la méthode deleteContact du service web
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/Contacts/' + testContact.Id;
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        ID result = WS001_ContactWebService.deleteContact();
        Test.stopTest();

        // Vérification du résultat
        System.assertEquals(testContact.Id, result);

        // Vérification de la désactivation du contact
        Contact deletedContact = [SELECT Id, Active__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(false, deletedContact.Active__c);
    }
}