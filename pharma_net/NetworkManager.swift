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
//        print("Checking interactions URL: \(urlString)")
//        print("Drugs passed to the function: \(drugs)")
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
//                print("Raw response: \(responseString)")
            }
            guard let data = data else {
                completion(nil, NSError(domain: "No Data", code: 1, userInfo: nil))
                return
            }
            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode([DrugInteraction].self, from: data)
//                print("Decoded interactions: \(results)")
                DispatchQueue.main.async {
                    completion(results, nil)
                }
            } catch {
//                print("Decoding error: \(error)")
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    static func fetchNewDrugInteractions(userID: String, drugName: String, completion: @escaping (Bool, Error?) -> Void) {
        let baseURL = "https://newdruginteractioncheck-414809634387.us-central1.run.app"
        
        // Encode drugName to be URL safe
        let encodedDrugName = drugName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? drugName
        
        // Construct the URL with both userID and drugName as query parameters
        let urlString = "\(baseURL)?userID=\(userID)&drugName=\(encodedDrugName)"
        print("Generated URL: \(urlString)") // Debug the URL
        
        guard let url = URL(string: urlString) else {
            completion(false, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        // Perform the API request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)") // Debug
                completion(false, error)
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("Server returned an empty response.") // Debug
                completion(false, NSError(domain: "No Data", code: 1, userInfo: nil))
                return
            }
            
            // Decode and parse the cleaned JSON manually
            var jsonString = String(data: data, encoding: .utf8) ?? ""
            jsonString = jsonString.replacingOccurrences(of: "\\r", with: "") // Remove escaped \r
            jsonString = jsonString.replacingOccurrences(of: "\r", with: "")  // Remove raw \r
            jsonString = jsonString.replacingOccurrences(of: "\n", with: "")  // Remove newlines
            print("Cleaned Response JSON: \(jsonString)") // Debug
            
            // Parse the JSON directly
            if let jsonArray = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: []) as? [[String: String]] {
                print("Parsed JSON Array: \(jsonArray)") // Debug
                
                // Check for "Moderate" or "Major"
                let hasModerateOrMajor = jsonArray.contains { dict in
                    if let severity = dict["Severity"] {
                        let normalizedSeverity = severity.trimmingCharacters(in: .whitespacesAndNewlines)
                        print("Checking Severity: \(normalizedSeverity)") // Debug
                        return normalizedSeverity == "Moderate" || normalizedSeverity == "Major"
                    }
                    return false
                }
                
                completion(hasModerateOrMajor, nil)
            } else {
                print("Failed to parse JSON as array.")
                completion(false, NSError(domain: "Invalid JSON Structure", code: 2, userInfo: nil))
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
    
    static func saveCombination(userID: Int, drugNames: [String], completion: @escaping (Bool, Error?) -> Void) {
        let baseURL = "https://save-combination-414809634387.us-central1.run.app"
        
        // Ensure the drugNames array has exactly 5 elements, filling missing ones with "NULL"
        let paddedDrugNames = drugNames + Array(repeating: "NULL", count: max(0, 5 - drugNames.count))
        let finalDrugNames = paddedDrugNames.prefix(5).map { "'\($0)'" } // Only keep the first 5 elements


        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "userID", value: "\(userID)"),
            URLQueryItem(name: "drugName1", value: finalDrugNames[0]),
            URLQueryItem(name: "drugName2", value: finalDrugNames[1]),
            URLQueryItem(name: "drugName3", value: finalDrugNames[2]),
            URLQueryItem(name: "drugName4", value: finalDrugNames[3]),
            URLQueryItem(name: "drugName5", value: finalDrugNames[4])
        ]
        
        guard let url = urlComponents?.url else {
            completion(false, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        // Perform the API request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)") // Debug
                completion(false, error)
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("Server returned an empty response.") // Debug
                completion(false, NSError(domain: "No Data", code: 1, userInfo: nil))
                return
            }
            
            // Parse the response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server Response: \(responseString)") // Debug
                
                if responseString.contains("Good") {
                    completion(true, nil) // Successful save
                } else {
                    completion(false, NSError(domain: "Unexpected Response", code: 2, userInfo: [NSLocalizedDescriptionKey: responseString]))
                }
            } else {
                completion(false, NSError(domain: "Invalid Response", code: 3, userInfo: nil))
            }
        }
        
        task.resume()
    }
    
    static func searchDrugs(_ searchText: String, completion: @escaping ([SearchResult]?) -> Void) { //KEYWORD SEARCH
            let baseURL = "https://us-central1-pharmanet-439720.cloudfunctions.net/search_drugs"
            let urlString = "\(baseURL)?searchText=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            
            print("Requesting URL: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion(nil)
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("HTTP Response Code: \(response.statusCode)")
                }
                
                guard let data = data else {
                    print("No data received from server")
                    completion(nil)
                    return
                }
                
                print("Raw Data: \(String(data: data, encoding: .utf8) ?? "No valid string data")")
                
                do {
                    let decoder = JSONDecoder()
                    let suggestions = try decoder.decode([SearchResult].self, from: data)
                    completion(suggestions)
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
            task.resume()
        }
    
    static func fetchDrugHistory(userID: String, completion: @escaping ([DrugHistoryItem]?, Error?) -> Void) {
            let baseURL = "https://us-central1-pharmanet-439720.cloudfunctions.net/get_drug_history"
            let urlString = "\(baseURL)?userID=\(userID)"
            
            print("Requesting URL for drug history: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    print("No data received from server")
                    completion(nil, NSError(domain: "No Data", code: 1, userInfo: nil))
                    return
                }
                
                print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode response to string")")
                
                do {
                    let decoder = JSONDecoder()
                    let history = try decoder.decode([DrugHistoryItem].self, from: data)
                    print("Decoded drug history: \(history)")
                    completion(history, nil)
                } catch {
                    print("Decoding error: \(error)")
                    print("Failed JSON String: \(String(data: data, encoding: .utf8) ?? "Unknown JSON")")
                    completion(nil, error)
                }
            }
            
            task.resume()
        }
    
    static func deleteDrugHistoryEntry(historyID: Int, completion: @escaping (Bool, Error?) -> Void) { //DELETE
                    let baseURL = "https://delete-entry-414809634387.us-central1.run.app"
                    let urlString = "\(baseURL)?historyID=\(historyID)"

                    print("Requesting URL for delete: \(urlString)")

                    guard let url = URL(string: urlString) else {
                        completion(false, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "GET" // Since the Cloud Run function uses GET to pass `historyID`

                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("Network error: \(error.localizedDescription)")
                            completion(false, error)
                            return
                        }

                        guard let httpResponse = response as? HTTPURLResponse else {
                            print("Invalid response: No HTTPURLResponse")
                            completion(false, NSError(domain: "Invalid response", code: 0, userInfo: nil))
                            return
                        }

                        if httpResponse.statusCode == 200 {
                            print("Successfully deleted entry with historyID: \(historyID)")
                            completion(true, nil)
                        } else {
                            let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                            print("Error Response Code: \(httpResponse.statusCode), Message: \(errorMessage)")
                            completion(false, NSError(domain: "Invalid response", code: httpResponse.statusCode, userInfo: ["message": errorMessage]))
                        }
                    }
                    task.resume()
                }
    
    static func updateEndDate(historyID: Int, completion: @escaping (Bool, Error?) -> Void) { //UPDATE
           let urlString = "https://us-central1-pharmanet-439720.cloudfunctions.net/update_end_date?historyID=\(historyID)"
           guard let url = URL(string: urlString) else {
               print("Invalid URL: \(urlString)")
               completion(false, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Network Error: \(error.localizedDescription)")
                   completion(false, error)
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse else {
                   print("Invalid response: No HTTPURLResponse")
                   completion(false, NSError(domain: "Invalid response", code: 0, userInfo: nil))
                   return
               }

               print("HTTP Response Code: \(httpResponse.statusCode)")

               if let data = data, let responseString = String(data: data, encoding: .utf8) {
                   print("Raw Response Body: \(responseString)")
               } else {
                   print("No response body")
               }

               if httpResponse.statusCode == 200 {
                   print("Drug history end date updated successfully.")
                   completion(true, nil)
               } else {
                   let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                   print("Error Response Code: \(httpResponse.statusCode), Message: \(errorMessage)")
                   completion(false, NSError(domain: "Invalid response", code: httpResponse.statusCode, userInfo: ["message": errorMessage]))
               }
           }

           task.resume()
       }
    
    static func addDrugToDatabase(userID: Int, drugName: String, completion: @escaping (Bool, Error?) -> Void) {
            let urlString = "https://us-central1-pharmanet-439720.cloudfunctions.net/update_db"
            guard let url = URL(string: urlString) else {
                print("Invalid URL: \(urlString)")
                completion(false, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // JSON payload
            let payload: [String: Any] = [
                "userID": userID,
                "drugName": drugName
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            } catch {
                print("Error serializing JSON: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response: No HTTPURLResponse")
                    completion(false, NSError(domain: "Invalid response", code: 0, userInfo: nil))
                    return
                }
                
                print("HTTP Response Code: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Raw Response Body: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 {
                    completion(true, nil)
                } else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    print("Error Response Code: \(httpResponse.statusCode), Message: \(errorMessage)")
                    completion(false, NSError(domain: "Invalid response", code: httpResponse.statusCode, userInfo: ["message": errorMessage]))
                }
            }
            
            task.resume()
        }

}
