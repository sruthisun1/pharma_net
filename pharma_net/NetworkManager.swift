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
    static func checkDrugInteractions(drugs: [String], completion: @escaping ([DrugInteraction]?, Error?) -> Void) {
        let baseURL = "https://us-central1-pharmanet-439720.cloudfunctions.net/get_drug_interactions_visual"
        guard let drugsData = try? JSONSerialization.data(withJSONObject: drugs),
              let drugsString = String(data: drugsData, encoding: .utf8),
              let encodedDrugs = drugsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil, NSError(domain: "Invalid drugs data", code: 0, userInfo: nil))
            return
        }
        let urlString = "\(baseURL)?drugs=\(encodedDrugs)"
        print("Checking interactions URL: \(urlString)")
        print("Drugs passed to the function: \(drugs)")
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            guard let data = data else {
                completion(nil, NSError(domain: "No Data", code: 1, userInfo: nil))
                return
            }
            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode([DrugInteraction].self, from: data)
                print("Decoded interactions: \(results)")
                DispatchQueue.main.async {
                    completion(results, nil)
                }
            } catch {
                print("Decoding error: \(error)")
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    static func fetchNewDrugInteractions(userID: String, drugName: String, completion: @escaping ([DrugInteraction]?, Error?) -> Void) {
            let baseURL = "https://us-central1-pharmanet-439720.cloudfunctions.net/newDrugInteractionCheck"
            let urlString = "\(baseURL)?userID=\(userID)&drugName=\(drugName)"
            
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
                    // Preprocess the raw JSON string to remove carriage returns
                    if var jsonString = String(data: data, encoding: .utf8) {
                        jsonString = jsonString.replacingOccurrences(of: "\\r", with: "")
                        if let cleanedData = jsonString.data(using: .utf8) {
                            let results = try decoder.decode([DrugInteraction].self, from: cleanedData)
                            DispatchQueue.main.async {
                                completion(results, nil)
                            }
                            return
                        }
                    }
                    throw NSError(domain: "Data Parsing Error", code: 2, userInfo: nil)
                } catch {
                    completion(nil, error)
                }
            }
            task.resume()
        }
    
    static func countSevereInteractions(userID: Int, completion: @escaping ([DrugSeverityCount]?, Error?) -> Void) {
            let baseURL = "https://us-central1-pharmanet-439720.cloudfunctions.net/get_count_sever_inter"
            let urlString = "\(baseURL)?userID=\(userID)"

            guard let url = URL(string: urlString) else {
                let error = NSError(domain: "Invalid URL", code: 0, userInfo: ["reason": "The provided URL is invalid"])
                completion(nil, error)
                return
            }

            print("Checking severe interactions URL: \(urlString)")

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(nil, error)
                    return
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseString)")
                    print("Raw response type: \(type(of: responseString))")
                }

                guard let data = data else {
                    let error = NSError(domain: "No Data", code: 1, userInfo: ["reason": "The server did not return any data"])
                    print("No data received")
                    completion(nil, error)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([DrugSeverityCount].self, from: data)
                    print("Decoded results: \(results)")
                    print("Decoded results type: \(type(of: results))")
                    DispatchQueue.main.async {
                        completion(results, nil)
                    }
                } catch {
                    let nsError = NSError(domain: "Decoding Error", code: 2, userInfo: ["reason": "The data could not be decoded: \(error.localizedDescription)"])
                    print("Decoding error: \(error)")
                    completion(nil, nsError)
                }
            }
            task.resume()
        }

}
