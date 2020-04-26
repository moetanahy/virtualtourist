//
//  Client.swift
//  OnTheMap
//
//  Created by Moe El Tanahy on 17/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation

// MARK: Client class
// This Class has the generic GET & POST Methods (Udacity Provided previously)

class Client: ClientProtocol {
    
    
    class func taskForPOSTRequest<RequestType, ResponseType>(url: URL, responseType: ResponseType.Type, body: RequestType, secure:  Bool, completion: @escaping (ResponseType?, Error?) -> Void) where RequestType : Encodable, ResponseType : Decodable {
        
        print("taskForPOSTRequest - Called")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("taskForPOSTRequest - Guard failed")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            // Udacity removes the first 5 characters of the data for secure data
            var newData = data
            if secure {
                print("Secure - removing characters")
                let range = (5..<data.count)
                newData = data.subdata(in: range)
            }
            
            print("taskForPOSTRequest - going into first do")
            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                print("taskForPOSTRequest - Request Suceeded")
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print("taskForPOSTRequest - failed on decoding response")
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    print("taskForPOSTRequest - failed on decoding error response")
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        print("taskForGETRequest - called")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("taskForGETRequest - returned in callback")
            guard let data = data else {
                print("taskForGETRequest - failed in Guard")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            print("Response from get being printed")
            print(data.debugDescription)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                print("taskForGETRequest - responseObject parsed")
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print("taskForGETRequest - failed in decoding try")
                print(error)
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    print("taskForGETRequest - error response being returned")
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    print("taskForGETRequest - failed in error parsing")
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    class func taskForDELETERequest<ResponseType: Decodable> (url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        // for delete
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Guard failed")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            // Udacity's removal of first characters
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                print("taskForDELETERequest - Request Suceeded")
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
    }
    
}

protocol ClientProtocol {
    
    static func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>
        (url: URL, responseType: ResponseType.Type, body: RequestType, secure: Bool, completion: @escaping (ResponseType?, Error?) -> Void)
    
    @discardableResult static func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask
    
    static func taskForDELETERequest<ResponseType: Decodable> (url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void)
    
}
