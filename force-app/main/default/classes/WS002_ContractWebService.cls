@RestResource(urlMapping='/contracts/*')
global class WS002_ContractWebService {
    
    @HttpPost
    global static ID createContract(ContractDTO contractDto) {
        // Création d'un nouveau contrat dans Salesforce
        Contract newContract = new Contract();
        newContract.AccountId = contractDto.accountId;
        newContract.ContractTerm = contractDto.contractTerm;
        newContract.StartDate = contractDto.startDate;
        insert newContract;
        
        // Récupération de l'ID du nouveau contrat créé dans Salesforce
        contractDto.salesforceId = newContract.Id;
        
        // Renvoie l'ID Salesforce du contrat créé
        return contractDto.salesforceId;
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
        // Vérification du champ StartDate et conversion de la chaîne de caractères en Date
            if (fieldName == 'startDate') {
                thisContract.StartDate = Date.valueOf(String.valueOf(params.get(fieldName)));
            } else {
                // Mise à jour des autres champs du contrat avec les nouvelles valeurs
                thisContract.put(fieldName, params.get(fieldName));
            }
        }
        
        // Mise à jour du contrat dans Salesforce
        update thisContract;
    }
    
    // DTO pour les contrats
    global class ContractDTO {
        global id accountId;
        global Integer contractTerm;
        global Date startDate;
        global id salesforceId;

        
        // Autres champs du contrat si nécessaire
    }
}
