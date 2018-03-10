//
//  SpotHeroPartnerAPIController.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

//MARK: - Completion Types

/// Success completion for any endpoint expecting no response.
typealias NoResponseExpectedAPISuccessCompletion = (() -> Void)

/// Success completion for any JSON endpoint. Returns a deserialized JSON dict.
typealias JSONAPISuccessCompletion = ((_ JSON: JSONDictionary) -> Void)

/// Error completion for any endpoint. Returns an NSError explaining what ya done fucked up.
public typealias APIErrorCompletion = ((_ error: Error) -> Void)

//MARK: Main API Controller

struct SpotHeroPartnerAPIController {
    
    //MARK: - NSURLSession
    
    private enum HTTPMethod: String {
        case
        POST,
        GET,
        PUT
    }
    
    private enum EncodingType {
        case
        none,
        jsonData,
        formData
    }
    
    private static func formDataFromParameters(_ parameters: JSONDictionary) -> Data? {
        //Internal functions here are taken from Alamofire's ParameterEncoding class to simplify
        //generating correct form data.
        //https://github.com/Alamofire/Alamofire/blob/24df4a7acff6b768914b67a5d59be0ccca32c370/Source/ParameterEncoding.swift
        func escape(_ string: String) -> String {
            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
            let subDelimitersToEncode = "!$&'()*+,;="
            
            var allowedCharacterSet = CharacterSet.urlQueryAllowed
            allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
            return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        }
        
        func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
            var components: [(String, String)] = []
            
            if let dictionary = value as? [String: Any] {
                for (nestedKey, value) in dictionary {
                    components += queryComponents("\(key)[\(nestedKey)]", value)
                }
            } else if let array = value as? [AnyObject] {
                for value in array {
                    components += queryComponents("\(key)[]", value)
                }
            } else {
                components.append((escape(key), escape("\(value)")))
            }
            
            return components
        }
        
        func query(_ queryParameters: [String: Any]) -> String {
            var components: [(String, String)] = []
            
            for key in queryParameters.keys.sorted(by: <) {
                let value = queryParameters[key]! // swiftlint:disable:this force_unwrapping
                components += queryComponents(key, value)
            }
            
            return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
        }
        
        return query(parameters).data(using: String.Encoding.utf8, allowLossyConversion: false)
        
    }
    
    private static func dataTaskWithMethod(_ method: HTTPMethod,
                                           encoding: EncodingType = .none,
                                           fullURLString: String,
                                           headers: [String: String],
                                           parameters: JSONDictionary? = nil,
                                           errorCompletion: @escaping APIErrorCompletion,
                                           noResponseSuccessCompletion: NoResponseExpectedAPISuccessCompletion? = nil,
                                           jsonSuccessCompletion: JSONAPISuccessCompletion?) -> URLSessionDataTask? {
        
        //Pre-flight checks
        if
            (noResponseSuccessCompletion != nil && jsonSuccessCompletion != nil) //Both are there
            || (noResponseSuccessCompletion == nil && jsonSuccessCompletion == nil) { //OR both are nil
                let description = "You must select one, JSON success or no response expected success. You cannot has both or neither."
                let error = APIError.errorWithDescription(description,
                                                          andStatusCode: APIError.PartnerSDKErrorCode.invalidParameter.rawValue)
                OperationQueue.main.addOperation {
                    errorCompletion(error)
                }
                return nil
        }
        
        guard let url = URL(string: fullURLString) else {
            let error = APIError.errorWithDescription("Could not create URL from string \(fullURLString)",
                                                      andStatusCode: APIError.PartnerSDKErrorCode.couldntMakeURLOutOfString.rawValue)
            OperationQueue.main.addOperation {
                errorCompletion(error)
            }
            return nil
        }
        
        //Create the request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        //Encode and add data
        if let uploadData = parameters {
            switch encoding {
            case .jsonData:
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: uploadData)
                    request.httpBody = jsonData
                } catch let error as NSError {
                    //Something went wrong with JSON encoding
                    OperationQueue.main.addOperation {
                        errorCompletion(error)
                    }
                    return nil
                }
            case .formData:
                request.httpBody = self.formDataFromParameters(uploadData)
            case .none:
                //Do nothing.
                break
            }
            
        }
        
        //Make the call.
        let task = SharedURLSession.sharedInstance.session.dataTask(with: request, completionHandler: {
            data, response, error in
            
            self.handleResponse(data,
                                response,
                                error,
                                errorCompletion,
                                noResponseSuccessCompletion,
                                jsonSuccessCompletion)
        })
        
        task.resume()
        return task
    }
    
    private static func handleResponse(_ data: Data?,
                                       _ response: URLResponse?,
                                       _ error: Error?,
                                       _ errorCompletion: @escaping APIErrorCompletion,
                                       _ noResponseSuccessCompletion: NoResponseExpectedAPISuccessCompletion?,
                                       _ jsonSuccessCompletion: JSONAPISuccessCompletion?) {
        
        if ServerEnvironment.ShouldDebugPrintInfo {
            self.debugPrintResponseInfo(response, data: data)
        }
        
        if let error = error {
            OperationQueue.main.addOperation {
                errorCompletion(error)
            }
            return
        }
        
        guard let urlResponse = response as? HTTPURLResponse else {
            //If theres no response
            return
        }
        
        let statusCode = urlResponse.statusCode
        switch statusCode {
        case 200..<300:
            if let dataCompletion = jsonSuccessCompletion {
                self.handleDataSuccessWithStatusCode(statusCode,
                                                     andData: data,
                                                     errorCompletion: errorCompletion,
                                                     completion: dataCompletion)
                return
            }
            
            if let noResponseCompletion = noResponseSuccessCompletion {
                OperationQueue.main.addOperation {
                    noResponseCompletion()
                }
                return
            }
            
            assertionFailure("Nobody to notify that we succeeded!")
        default:
            self.handleErrorWithStatusCode(statusCode,
                                           andData: data,
                                           completion: errorCompletion)
        }
        
    }
    
    private static func debugPrintResponseInfo(_ response: URLResponse?, data: Data?) {
        if let response = response as? HTTPURLResponse {
            DLog("URL: \(String(describing: response.url))")
            DLog("Status: \(response.statusCode)")
            DLog("Headers: \(response.allHeaderFields)")
        } else {
            DLog("Response was not an NSHTTPURLResponse!")
        }
        
        if let data = data {
            DLog("Data: \(String(data: data, encoding: .utf8) ?? "")")
        } else {
            DLog("No data received!")
        }
    }
    
    private static func handleDataSuccessWithStatusCode(_ statusCode: Int,
                                                        andData data: Data?,
                                                        errorCompletion: @escaping APIErrorCompletion,
                                                        completion: @escaping JSONAPISuccessCompletion) {
        guard let returnedData = data else {
            // There ought to be something here.
            let error = APIError.errorWithDescription("No data received. Did you mean to use the NoResponseExpected completion?",
                                                      andStatusCode: APIError.PartnerSDKErrorCode.unexpectedEmptyResponse.rawValue)
            OperationQueue.main.addOperation {
                errorCompletion(error)
            }
            return
        }
        
        guard let successJSON = self.jsonDictionaryFromData(returnedData, errorCompletion: errorCompletion) else {
            //JSON method will call the error completion with the JSON error.
            return
        }
        
        // Ermahgerd! It worked!
        OperationQueue.main.addOperation {
            completion(successJSON)
        }
    }
    
    private static func handleErrorWithStatusCode(_ statusCode: Int,
                                                  andData data: Data?,
                                                  completion: @escaping APIErrorCompletion) {
        guard let errorData = data else {
            let error = APIError.errorFromHTTPStatusCode(statusCode)
            OperationQueue.main.addOperation {
                completion(error)
            }
            return
        }
        
        guard let errorJSON = self.jsonDictionaryFromData(errorData, errorCompletion: completion) else {
            //JSON method will call the error completion with the JSON error.
            return
        }
        
        do {
            let serverErrors = try ServerErrorJSON(json: errorJSON)
            let error = APIError.errorFromServerJSON(serverErrors, statusCode: statusCode)
            OperationQueue.main.addOperation {
                completion(error)
            }
        } catch let parsingError {
            DLog("Parsing error: \(parsingError)")
            let error = APIError.parsingError(errorJSON)
            OperationQueue.main.addOperation {
                completion(error)
            }
        }
        
    }
    
    private static func jsonDictionaryFromData(_ data: Data, errorCompletion: @escaping APIErrorCompletion) -> JSONDictionary? {
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data) as? JSONDictionary
            return dictionary
        } catch let error as NSError {
            OperationQueue.main.addOperation {
                errorCompletion(error)
            }
            return nil
        }
    }
    
    //MARK: JSON Requests
    
    /**
     GETs JSON from a given endpoint
     
     - parameter endpoint:          The endpoint, without the base url
     - parameter headers:           A dictionary of headers. Types can be found in APIHeaders.swift
     - parameter additionalParams:  A dictionary of any additional parameters to include in the GET request as query params.
     - parameter errorCompletion:   The completion block to execute on error
     - parameter successCompletion: The completion block to execute on success, which will return a  JSONDictionary object.
     */
    @discardableResult
    static func getJSONFromEndpoint(_ endpoint: String,
                                    withHeaders headers: HeaderDictionary,
                                    additionalParams: [String: String]? = nil,
                                    errorCompletion: @escaping APIErrorCompletion,
                                    successCompletion: @escaping JSONAPISuccessCompletion) -> URLSessionDataTask? {
        
        let stringHeaders = APIHeaders.headerStringDict(headers)
        
        //Set up url query items for additional headers.
        var queryItems = [URLQueryItem]()
        if let params = additionalParams {
            queryItems = URLQueryItem.shp_queryItemsFromDictionary(params)
        }
        
        let fullURLString = ServerEnvironment
            .CurrentEnvironment
            .fullURLStringForEndpoint(endpoint, withQueryItems: queryItems)
        
        return self.dataTaskWithMethod(.GET,
                                       fullURLString: fullURLString,
                                       headers: stringHeaders,
                                       errorCompletion: errorCompletion,
                                       jsonSuccessCompletion: successCompletion)
    }
    
    static func getJSONFromFullURLString(_ fullURLString: String,
                                         withHeaders headers: HeaderDictionary,
                                         errorCompletion: @escaping APIErrorCompletion,
                                         successCompletion: @escaping  JSONAPISuccessCompletion) -> URLSessionDataTask? {
        let stringHeaders = APIHeaders.headerStringDict(headers)
        return self.dataTaskWithMethod(.GET,
                                       fullURLString: fullURLString,
                                       headers: stringHeaders,
                                       errorCompletion: errorCompletion,
                                       jsonSuccessCompletion: successCompletion)
    }
    
    /**
     POSTs JSON to a given endpoint
     
     - parameter endpoint:          The endpoint, without the base url
     - parameter endpointIsDumb:    `true` if the endpoint is dumb and barfs on actual json input and needs everything put in the headers 
                                    as well, `false` if it's smart enough to accept actual json.
     - parameter headers:           A dictionary of headers. Types can be found in APIHeaders.swift
     - parameter jsonToPost:        A dictionary to post as JSON.
     - parameter errorCompletion:   The completion block to execute on error
     - parameter successCompletion: The completion block to execute on success, which will return a JSONDictionary object.
     
     */
    static func postJSONtoEndpoint(_ endpoint: String,
                                   endpointIsDumb: Bool = false,
                                   jsonToPost json: [String: Any],
                                   withHeaders headers: HeaderDictionary,
                                   errorCompletion: @escaping APIErrorCompletion,
                                   successCompletion: @escaping JSONAPISuccessCompletion) {
        
        let fullURLString = ServerEnvironment
            .CurrentEnvironment
            .fullURLStringForEndpoint(endpoint)
        var stringHeaders = APIHeaders.headerStringDict(headers)
        
        //TODO: Remove this when DRF 1.8 update occurs.
        if endpointIsDumb {
            //BOOOOO FORM STUFF
            stringHeaders[APIHeaders.HTTPHeaderField.contentType.rawValue] = APIHeaders.HTTPContentType.form.rawValue
            self.postFormDataToFullURLString(fullURLString,
                                             dictionaryToPost: json,
                                             withHeaders: stringHeaders,
                                             errorCompletion: errorCompletion,
                                             successCompletion: successCompletion)
            return
        }
        
        _ = self.dataTaskWithMethod(.POST,
                                    encoding: .jsonData,
                                    fullURLString: fullURLString,
                                    headers: stringHeaders,
                                    parameters: json,
                                    errorCompletion: errorCompletion,
                                    jsonSuccessCompletion: successCompletion)
    }
    
    /**
     Workaround for certain APIs being too dumb to handle actual JSON input. Srsly.
     */
    private static func postFormDataToFullURLString(_ fullURLString: String,
                                                    dictionaryToPost dictionary: JSONDictionary,
                                                    withHeaders headers: [String: String],
                                                    errorCompletion: @escaping APIErrorCompletion,
                                                    successCompletion: @escaping JSONAPISuccessCompletion) {
        
        _ = self.dataTaskWithMethod(.POST,
                                    encoding: .formData,
                                    fullURLString: fullURLString,
                                    headers: headers,
                                    parameters: dictionary,
                                    errorCompletion: errorCompletion,
                                    jsonSuccessCompletion: successCompletion)
    }
    
    /**
     PUTs JSON to a given endpoint
     
     - parameter endpoint:          The endpoint, without the base url
     - parameter headers:           A dictionary of headers. Types can be found in APIHeaders.swift
     - parameter jsonToPost:        A dictionary to put as JSON.
     - parameter errorCompletion:   The completion block to execute on error
     - parameter successCompletion: The completion block to execute on success, which will return a JSONDictionary object.
     */
    static func putJSONtoEndpoint(_ endpoint: String,
                                  jsonToPut json: JSONDictionary,
                                  withHeaders headers: HeaderDictionary,
                                  errorCompletion: @escaping APIErrorCompletion,
                                  successCompletion: @escaping JSONAPISuccessCompletion) {
        
        let stringHeaders = APIHeaders.headerStringDict(headers)
        let fullURLString = ServerEnvironment
            .CurrentEnvironment
            .fullURLStringForEndpoint(endpoint)
        
        _ = self.dataTaskWithMethod(.PUT,
                                    encoding: .jsonData,
                                    fullURLString: fullURLString,
                                    headers: stringHeaders,
                                    parameters: json,
                                    errorCompletion: errorCompletion,
                                    jsonSuccessCompletion: successCompletion)
    }
}
