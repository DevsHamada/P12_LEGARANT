// * Web service class to REST request for Contact
@RestResource(urlMapping='/Contacts/*')
global class WS001_ContactWebService {
    
    @HttpPost
    global static ID createContact(ContactDTO contactDto) {
        List<Contact> matchingContacts = [SELECT Id FROM Contact WHERE Email = :contactDto.email LIMIT 1];
        
        if (matchingContacts.size() > 0) {
            // Mise à jou de l'ID de Salesforce dans le CRM AXG
            contactDto.salesforceId = matchingContacts[0].Id;
        } else {
            // Création d'un nouveau contact dans Salesforce
            Contact newContact = new Contact();
            newContact.FirstName = contactDto.firstName;
            newContact.LastName = contactDto.lastName;
            newContact.Email = contactDto.email;
            insert newContact;
            
            // Récupération de l'ID du nouveau contact créé dans Salesforce
            contactDto.salesforceId = newContact.Id;
        }
        // Renvoie l'ID Salesforce du contact mis à jour ou créé
        return contactDto.salesforceId;
    }
    
    
    @HttpPut
    global static String updateContact() {
        // Accéder à la requête actuelle
        RestRequest request = RestContext.request;
        // méthode extrait l'ID du contact à partir de l'URL de la requête en récupérant la dernière partie de l'URL après le dernier /.
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
    
        // Vérifier si le contact existe
        List<Contact> matchingContacts = [SELECT Id FROM Contact WHERE Id = :contactId];
        if (matchingContacts.isEmpty()) {
            // Cas : ID non existant
            // Retourner un message d'erreur spécifique
            return 'Contact with ID ' + contactId + ' does not exist';
        }
    
        Contact thisContact = matchingContacts[0];
        //convertit les données JSON de la requête 
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
        //mettre à jour le champ correspondant du contact avec la valeur correspondante.    
        for (String fieldName : params.keySet()) {
            thisContact.put(fieldName, params.get(fieldName));
        }
    
        update thisContact;
        return 'Contact updated successfully';
    }
    
    
    @HttpDelete
    global static String deleteContact() {
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
    
        // Vérifier si le contact existe
        List<Contact> matchingContacts = [SELECT Id FROM Contact WHERE Id = :contactId];
        if (matchingContacts.isEmpty()) {
            // Cas : ID non existant
            // Retourner un message d'erreur spécifique
            return 'Contact with ID ' + contactId + ' does not exist';
        }
    
        Contact thisContact = matchingContacts[0];
        thisContact.Active__c = false;
        update thisContact;
    
        return 'Contact deactivated successfully';
    }
    
    // Classe DTO (Data Transfer Object) pour faciliter la sérialisation/désérialisation JSON
    global class ContactDTO {
        global String firstName;
        global String lastName;
        global String email;
        global ID salesforceId;
    }
}
