import Foundation

class NetworkManager {
    static func fetchDrugResults(userID: String, completion: @escaping ([DrugResult]?, Error?) -> Void) {
        let baseURL = "https://us-central1-pharmanet-439720.cloudfunctions.net/get_drug_results"
        let urlString = "\(baseURL)?userID=\(userID)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "No Data", code: 1, userInfo: nil))
                return
            }

            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode([DrugResult].self, from: data)
                DispatchQueue.main.async {
                    completion(results, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
