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
    global static ID  updateContact() {
        // Accéder à la requête actuelle
        RestRequest request = RestContext.request;
        // méthode extrait l'ID du contact à partir de l'URL de la requête en récupérant la dernière partie de l'URL après le dernier /.
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        // récupérer le contact correspondant dans Salesforce en utilisant l'ID extrait
        Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        //convertit les données JSON de la requête 
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        //mettre à jour le champ correspondant du contact avec la valeur correspondante.
        for(String fieldName : params.keySet()) {
            thisContact.put(fieldName, params.get(fieldName));
        }
        update thisContact;
        return thisContact.Id;
        // Renvoie l'ID Salesforce du contact mis à jour
    }
    
    @HttpDelete
    global static ID deleteContact() {
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        Contact thisContact = [SELECT Id, Active__c FROM Contact WHERE Id = :contactId];
        update thisContact;
    
        if (thisContact != null) {
            // Désactivation du contact dans Salesforce (ne pas supprimer)
            thisContact.Active__c = false;
            update thisContact;
        }
        return thisContact.ID;
    }
    
    // Classe DTO (Data Transfer Object) pour faciliter la sérialisation/désérialisation JSON
    global class ContactDTO {
        global String firstName;
        global String lastName;
        global String email;
        global ID salesforceId;
    }
}
