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

