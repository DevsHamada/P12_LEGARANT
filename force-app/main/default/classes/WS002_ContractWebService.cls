@RestResource(urlMapping='/contracts/*')
global class WS002_ContractWebService {
    
    @HttpPost
    global static ID createContract(ContractDTO contractDto) {
        {
            // Création d'un nouveau contract dans Salesforce
            contract newContract = new contract();
            newContract.accountId = ContractDTO.accountId;
            newContract.contractTerm = ContractDTO.contractTerm;
            newContract.status = ContractDTO.status;
            newContract.startDate = ContractDTO.startDate;
            insert newContract;
            
            // Récupération de l'ID du nouveau contract créé dans Salesforce
            ContractDTO.salesforceId = newContract.Id;
        }
        // Renvoie l'ID Salesforce du contract mis à jour
        return ContractDTO.salesforceId;
        
    }
    
    @HttpPut
    global static void updateContract() {
        RestRequest request = RestContext.request;
    
        // Extraction de l'ID du contrat à partir de l'URL de la requête
        String contractId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
    
        // Récupération du contrat correspondant dans Salesforce en utilisant l'ID fourni
        Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
    
        // Désérialisation des données de la requête dans un map de paramètres
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(request.requestbody.tostring());
        
        // Parcours des clés du map de paramètres
        for (String fieldName : params.keySet()) {
            // Mise à jour des champs du contrat avec les nouvelles valeurs
            thisContract.put(fieldName, params.get(fieldName));
        }
        
        // Mise à jour du contrat dans Salesforce
        update thisContract;
    }
    
    // DTO pour les contrats
    global class ContractDTO {
        global id salesforceId;
        global id accountId;
        global Integer contractTerm;
        global String status;
        global Date startDate;
        
        // Autres champs du contrat si nécessaire
    }
}
