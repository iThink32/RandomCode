Random Code:-

    class func switchResponder<T:Countable>(textField:UITextField,arrTextFields:[UITextField],enumInstance:T.Type) {
        let nextTag = (textField.tag + 1) % enumInstance.count()
        let nextTextFieldTag = arrTextFields.filter({ (textField) -> Bool in
            return textField.tag == nextTag
        }).first
        guard textField.tag != enumInstance.count() - 1, let reqdTextField = nextTextFieldTag else{
            textField.resignFirstResponder()
            return
        }
        reqdTextField.becomeFirstResponder()
    }

    class func stringMatches(text:String,regex:String) -> [NSTextCheckingResult]? {
        guard let regExpression = try? NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive) else {
            return nil
        }
        let matches = regExpression.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        let arrReqdmatches = matches.filter { (match) -> Bool in
            return match.range.length > 0
        }
        return arrReqdmatches
    }

enum APITypealias<Type> {
    typealias apiCallBack = (Type?,ValidationError?) -> Void
    typealias UploadImageCallBack = (Type?,Type?,ValidationError?) -> Void
    
}
eg:-

    func validateForUniquePhoneNumber(callback:@escaping APITypealias<RegisterPhoneResponse>.apiCallBack) {
        guard let service:DriverServicesDelegate = ServiceLocator.defaultLocator.service() else{
            Logger.printValue(value: "could not hit service")
            callback(nil, ValidationError(description: StringConstants.errorOccured))
            return
        }
        service.checkForUniqueNumber(number: registrationModel.phone ?? "0", callBack: { (response, error) in
            callback(response,error)
        })
    }

The most deadly multipart image upload (wink)(took a long time to make this work)
    
    func uploadImage(image:UIImage,callBack:@escaping APITypealias<String>.UploadImageCallBack) {
        PKHUD.sharedHUD.show()
        guard let unwrappedData = UIImagePNGRepresentation(image) else{
            callBack(nil,nil,ValidationError(description: StringConstants.errorOccured))
            return
        }
        let request = UploadPhotoRequest(data:unwrappedData)
        self.client.performMultipartUpload(request: request) {[weak self] (result) in
            PKHUD.sharedHUD.hide(false)
            self?.parseResponse(result: result){ (response,error) -> Void in
                callBack(response?.name,response?.path, error)
            }
        }
    }
    
    public func performMultipartUpload<T:UploadRequestDelegate>(request:T,completion:@escaping ResultCallback<T.Response>) {
        guard let url = URL(string: "\(baseEndpoint)\(request.resourceName)") else{
            print("Could not perform multipart request")
            completion(Result.failure(APIError.encoding))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = RequestMethod.POST.rawValue
        let boundary = "XXXXXX"
        urlRequest.setValue("multipart/form-data; boundary=" + boundary,
                            forHTTPHeaderField: "Content-Type")
        var tempData = Data()
        
        guard let startBoundary = "--\(boundary)\r\n".data(using: String.Encoding.utf8),
        let contentDispositionFile = "Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".data(using: String.Encoding.utf8),
        let contentDispositionType = "Content-Disposition: form-data; name=\"type\"\r\n\r\nProfileImage\r\n".data(using: String.Encoding.utf8),
        let contentType = "Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8),let padding = "\r\n".data(using: String.Encoding.utf8),
        let endBoundary = "--\(boundary)--\r\n".data(using: String.Encoding.utf8) else{
                return
        }
        
        tempData.append(startBoundary)
        tempData.append(contentDispositionType)
        
        tempData.append(startBoundary)
        tempData.append(contentDispositionFile)
        
        
        tempData.append(contentType)
        tempData.append(request.data!)
        tempData.append(padding)
        tempData.append(endBoundary)
        
        urlRequest.httpBody = tempData
        urlRequest.setValue(String(tempData.count), forHTTPHeaderField: "Content-Length")
        self.session.dataTask(with: urlRequest) { (data, response, error) in
            print(data?.count)
            if let data = data {
                do {
                    // Decode the top level response, and look up the decoded response to see
                    // if it's a success or a failure
                    let response = try JSONDecoder().decode(APIResponseBase<T.Response>.self, from: data)
                    
                    if let data = response.data {
                        DispatchQueue.main.async {
                            completion(.success(data))
                        }
                    } else if let errors = response.errors {
                        DispatchQueue.main.async {
                            // one more condition in which you get data as nil for a successful reqeust so im checking if errors count is 0
                            print(errors.count)
                            guard errors.count == 0 else{
                                completion(.failure(APIError.server(messages: errors)))
                                return
                            }
                            completion(.success(nil))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(APIError.decoding))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            }.resume()
    }


