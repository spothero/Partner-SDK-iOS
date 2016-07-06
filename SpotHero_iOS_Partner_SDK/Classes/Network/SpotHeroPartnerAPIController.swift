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
typealias NoResponseExpectedAPISuccessCompletion = (() -> ())

/// Success completion for any JSON endpoint. Returns a deserialized JSON dict.
typealias JSONAPISuccessCompletion = ((JSON: JSONDictionary) -> ())

/// Error completion for any endpoint. Returns an NSError explaining what ya done fucked up.
public typealias APIErrorCompletion = ((error: NSError) -> ())

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
        None,
        JSONData,
        FormData
    }
    
    private static let URLSession: NSURLSession = {
        let defaultConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: defaultConfiguration)
        return session
    }()
    
    static func useURLProtocols(protocols: [AnyClass]?) {
        self.URLSession.configuration.protocolClasses = protocols
    }
    
    private static func formDataFromParameters(parameters: JSONDictionary) -> NSData? {
        //Internal functions here are taken from Alamofire's ParameterEncoding class to simplify
        //generating correct form data.
        //https://github.com/Alamofire/Alamofire/blob/24df4a7acff6b768914b67a5d59be0ccca32c370/Source/ParameterEncoding.swift
        func escape(string: String) -> String {
            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
            let subDelimitersToEncode = "!$&'()*+,;="
            
            let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
            allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
            return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
        }
        
        func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
            var components: [(String, String)] = []
            
            if let dictionary = value as? [String: AnyObject] {
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
        
        func query(queryParameters: [String : AnyObject]) -> String {
            var components: [(String, String)] = []
            
            for key in queryParameters.keys.sort(<) {
                let value = queryParameters[key]!
                components += queryComponents(key, value)
            }
            
            return (components.map { "\($0)=\($1)" } as [String]).joinWithSeparator("&")
        }
        
        return query(parameters).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
    }
    
    private static func dataTaskWithMethod(method: HTTPMethod,
                                           encoding: EncodingType = .None,
                                           fullURLString: String,
                                           headers: [String : String],
                                           parameters: JSONDictionary? = nil,
                                           errorCompletion: APIErrorCompletion,
                                           noResponseSuccessCompletion: NoResponseExpectedAPISuccessCompletion? = nil,
                                           jsonSuccessCompletion: JSONAPISuccessCompletion?) -> NSURLSessionDataTask? {
        
        //Pre-flight checks
        if ((noResponseSuccessCompletion != nil && jsonSuccessCompletion != nil) //Both are there
            //##SWIFTCLEAN_SKIP##
            || (noResponseSuccessCompletion
            //^ known bug with swift-clean
            //##SWIFTCLEAN_ENDSKIP##
                == nil && jsonSuccessCompletion == nil)) { //both are nil
            let error = APIError.errorWithDescription("You must select one, JSON success or no response expected success. You cannot has both or neither.",
                                                      andStatusCode: APIError.PartnerSDKErrorCode.InvalidParameter.rawValue)
            errorCompletion(error: error)
            return nil
        }
        
        guard let url = NSURL(string: fullURLString) else {
            let error = APIError.errorWithDescription("Could not create URL from string \(fullURLString)",
                                                      andStatusCode: APIError.PartnerSDKErrorCode.CouldntMakeURLOutOfString.rawValue)
            errorCompletion(error: error)
            return nil
        }
        
        
        //Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        //Encode and add data
        if let uploadData = parameters {
            switch encoding {
            case .JSONData:
                do {
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(uploadData, options:  NSJSONWritingOptions())
                    request.HTTPBody = jsonData
                } catch let error as NSError {
                    //Something went wrong with JSON encoding
                    errorCompletion(error: error)
                    return nil
                }
            case .FormData:
                request.HTTPBody = self.formDataFromParameters(uploadData)
            case .None:
                //Do nothing.
                break
            }
            
        }
        
        //Make the call.
        let task = self.URLSession.dataTaskWithRequest(request) {
            data, response, error in
            self.handleResponse(data,
                                response,
                                error,
                                errorCompletion,
                                noResponseSuccessCompletion,
                                jsonSuccessCompletion)
        }
        
        task.resume()
        return task
    }
    
    private static func handleResponse(data: NSData?,
                                       _ response: NSURLResponse?,
                                         _ error: NSError?,
                                           _ errorCompletion: APIErrorCompletion,
                                             _ noResponseSuccessCompletion: NoResponseExpectedAPISuccessCompletion?,
                                               _ jsonSuccessCompletion: JSONAPISuccessCompletion?) {
        
        if ServerEnvironment.ShouldDebugPrintInfo {
            self.debugPrintResponseInfo(response, data: data)
        }
        
        guard let urlResponse = response as? NSHTTPURLResponse else {
            //Fail with some kind of ceci n'est pas une URL respones
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
                noResponseCompletion()
                return
            }
            
            assertionFailure("Nobody to notify that we succeeded!")
        default:
            self.handleErrorWithStatusCode(statusCode,
                                           andData: data,
                                           completion: errorCompletion)
        }
        
    }
    
    private static func debugPrintResponseInfo(response: NSURLResponse?, data: NSData?) {
        if let response = response as? NSHTTPURLResponse {
            DLog("URL: \(response.URL)")
            DLog("Status: \(response.statusCode)")
            DLog("Headers: \(response.allHeaderFields)")
        } else {
            DLog("Response was not an NSHTTPURLResponse!")
        }
        
        if let data = data {
            DLog("Data: \(NSString(data: data, encoding: NSUTF8StringEncoding))")
        } else {
            DLog("No data received!")
        }
    }
    
    private static func handleDataSuccessWithStatusCode(statusCode: Int,
                                                        andData data: NSData?,
                                                                errorCompletion: APIErrorCompletion,
                                                                completion: JSONAPISuccessCompletion) {
        guard let returnedData = data else {
            // There ought to be something here.
            let error = APIError.errorWithDescription("No data received. Did you mean to use the NoResponseExpected completion?",
                                                      andStatusCode: APIError.PartnerSDKErrorCode.UnexpectedEmptyResponse.rawValue)
            errorCompletion(error: error)
            return
        }
        
        guard let successJSON = self.jsonDictionaryFromData(returnedData, errorCompletion: errorCompletion) else {
            //JSON method will call the error completion with the JSON error.
            return
        }
        
        guard let actualData = successJSON["data"] as? JSONDictionary else {
            let jsonError = APIError.parsingError(successJSON)
            errorCompletion(error: jsonError)
            return
        }
        
        // Ermahgerd! It worked!
        completion(JSON: actualData)
    }
    
    private static func handleErrorWithStatusCode(statusCode: Int,
                                                  andData data: NSData?,
                                                          completion: APIErrorCompletion) {
        guard let errorData = data else {
            let error = APIError.errorFromHTTPStatusCode(statusCode)
            completion(error: error)
            return
        }
        
        guard let errorJSON = self.jsonDictionaryFromData(errorData, errorCompletion: completion) else {
            //JSON method will call the error completion with the JSON error.
            return
        }
        
        do {
            let serverErrors = try ServerErrorJSON(json: errorJSON)
            let error = APIError.errorFromServerJSON(serverErrors, statusCode: statusCode)
            completion(error: error)
        } catch let parsingError {
            DLog("Parsing error: \(parsingError)")
            let error = APIError.parsingError(errorJSON)
            completion(error: error)
        }
        
    }
    
    private static func jsonDictionaryFromData(data: NSData, errorCompletion: APIErrorCompletion) -> JSONDictionary? {
        do {
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSONDictionary
            return dictionary
        } catch let error as NSError {
            errorCompletion(error: error)
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
    static func getJSONFromEndpoint(endpoint: String,
                                    withHeaders headers: HeaderDictionary,
                                    additionalParams: [String : String]? = nil,
                                    errorCompletion: APIErrorCompletion,
                                    successCompletion: JSONAPISuccessCompletion) {
        
        let stringHeaders = APIHeaders.headerStringDict(headers)
        
        //Set up url query items for additional headers.
        var queryItems = [NSURLQueryItem]()
        if let params = additionalParams {
            queryItems = NSURLQueryItem.shp_queryItemsFromDictionary(params)
        }
        
        let fullURLString = ServerEnvironment
            .CurrentEnvironment
            .fullURLStringForEndpoint(endpoint, withQueryItems: queryItems)
        
        self.dataTaskWithMethod(.GET,
                                fullURLString: fullURLString,
                                headers: stringHeaders,
                                errorCompletion: errorCompletion,
                                jsonSuccessCompletion: successCompletion)
    }
    
    /**
     POSTs JSON to a given endpoint
     
     - parameter endpoint:          The endpoint, without the base url
     - parameter endpointIsDumb:    `true` if the endpoint is dumb and barfs on actual json input and needs everything put in the headers as well, `false` if it's smart enough to accept actual json.
     - parameter headers:           A dictionary of headers. Types can be found in APIHeaders.swift
     - parameter jsonToPost:        A dictionary to post as JSON.
     - parameter errorCompletion:   The completion block to execute on error
     - parameter successCompletion: The completion block to execute on success, which will return a JSONDictionary object.
     
     */
    static func postJSONtoEndpoint(endpoint: String,
                                   endpointIsDumb: Bool = false,
                                   jsonToPost json: [String : AnyObject],
                                   withHeaders headers: HeaderDictionary,
                                   errorCompletion: APIErrorCompletion,
                                   successCompletion: JSONAPISuccessCompletion) {
        
        let fullURLString = ServerEnvironment
            .CurrentEnvironment
            .fullURLStringForEndpoint(endpoint)
        var stringHeaders = APIHeaders.headerStringDict(headers)
        
        //TODO: Remove this when DRF 1.8 update occurs.
        if (endpointIsDumb) {
            //BOOOOO FORM STUFF
            stringHeaders[APIHeaders.HTTPHeaderField.ContentType.rawValue] = APIHeaders.HTTPContentType.Form.rawValue
            self.postFormDataToFullURLString(fullURLString,
                                             dictionaryToPost: json,
                                             withHeaders: stringHeaders,
                                             errorCompletion: errorCompletion,
                                             successCompletion: successCompletion)
            return
        }
        
        self.dataTaskWithMethod(.POST,
                                encoding: .JSONData,
                                fullURLString: fullURLString,
                                headers: stringHeaders,
                                parameters: json,
                                errorCompletion: errorCompletion,
                                jsonSuccessCompletion: successCompletion)
    }
    
    /**
     Workaround for certain APIs being too dumb to handle actual JSON input. Srsly.
     */
    private static func postFormDataToFullURLString(fullURLString: String,
                                                    dictionaryToPost dictionary: JSONDictionary,
                                                    withHeaders headers: [String : String],
                                                    errorCompletion: APIErrorCompletion,
                                                    successCompletion: JSONAPISuccessCompletion) {
        
        self.dataTaskWithMethod(.POST,
                                encoding: .FormData,
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
    static func putJSONtoEndpoint(endpoint: String,
                                  jsonToPut json: JSONDictionary,
                                  withHeaders headers: HeaderDictionary,
                                  errorCompletion: APIErrorCompletion,
                                  successCompletion: JSONAPISuccessCompletion) {
        
        let stringHeaders = APIHeaders.headerStringDict(headers)
        let fullURLString = ServerEnvironment
            .CurrentEnvironment
            .fullURLStringForEndpoint(endpoint)
        
        self.dataTaskWithMethod(.PUT,
                                encoding: .JSONData,
                                fullURLString: fullURLString,
                                headers: stringHeaders,
                                parameters: json,
                                errorCompletion: errorCompletion,
                                jsonSuccessCompletion: successCompletion)
    }
}
