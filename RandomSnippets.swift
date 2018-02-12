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

    class func stringMatches(text:String,negatedRegex:String) -> [NSTextCheckingResult]? {
        guard let regExpression = try? NSRegularExpression(pattern: negatedRegex, options: NSRegularExpression.Options.caseInsensitive) else {
            return nil
        }
        let matches = regExpression.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        let arrReqdmatches = matches.filter { (match) -> Bool in
            return match.range.length > 0
        }
        return arrReqdmatches
    }

