//
//  ViewController.swift
//  PayFort
//
//  Created by Kerolos Fahem on 7/5/19.
//  Copyright © 2019 devloop. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var amountTxtField: UITextField!
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var modeLbl: UILabel!
    
    //MARK: - Properties
    var payFortModel = PayFortModel()
    let order_id = 344
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTappedView(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    //MARK: - APIs
    
    // prepare request
    func createApiRequestForInitPayment(bodyParameter: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyParameter, options: .prettyPrinted)
            let request = payFortModel.request(body: jsonData, method: "POST")
            
            Alamofire.request(request).responseJSON(completionHandler: { (response: DataResponse<Any>) -> () in
                print("response", response)
                if response.error?.localizedDescription.isEmpty ?? true {
                    self.paymentApiRequest(response: response.result.value)
                    
                    return
                }
                
                print("Error ", response.error?.localizedDescription ?? "")
            })
            
        } catch let error as NSError {
            print("Error ",error.localizedDescription)
        }
        
    }
    
    // PayFort Request
    func paymentApiRequest(response: Any?) {
        if (response != nil) {
            guard let responseDict = response as? NSDictionary else { return }
            
            let tokenStr = responseDict["sdk_token"] as? String
            let amount = "\(Int(amountTxtField.text ?? "") ?? 0 * 100)"
            
            let payloadDict = NSMutableDictionary.init()
            payloadDict.setValue(tokenStr, forKey: "sdk_token")
            payloadDict.setValue(amount, forKey: "amount")
            payloadDict.setValue("PURCHASE", forKey: "command")
            payloadDict.setValue("USD", forKey: "currency")
            payloadDict.setValue("test@test.com", forKey: "customer_email")
            payloadDict.setValue(payFortModel.language, forKey: "language")
            payloadDict.setValue(order_id, forKey: "merchant_reference")
            
            var paycontroller: PayFortController?
            
            if payFortModel.payFortMode == .test {
                paycontroller = PayFortController.init(enviroment: KPayFortEnviromentSandBox)
                
            }else {
                paycontroller = PayFortController.init(enviroment: KPayFortEnviromentProduction)
            }
            
            paycontroller?.isShowResponsePage = true
            paycontroller?.callPayFort(withRequest: payloadDict, currentViewController: self, success: { (requestDic, responeDic) in
                self.showAlert(with: "Successful Payment")
                
            }, canceled: { (requestDic, responeDic) in
                self.showAlert(with: "Current payment session has been canceled.")
                
            }, faild: { (requestDic, responeDic, message) in
                self.showAlert(with: "Current payment session has been failure.")
            })
            
        }
    }
    
    //MARK: - Actions
    @IBAction func onActionButtonPressed(_ sender: Any) {
        createApiRequestForInitPayment(bodyParameter: payFortModel.getBodyParameters())
    }
    
    @IBAction func onSwitch(_ sender: UISwitch) {
        if modeSwitch.isOn {
            payFortModel.payFortMode = .live
            modeLbl.text = "Live mode"
            
        }else {
            payFortModel.payFortMode = .test
            modeLbl.text = "Test mode"
        }
    }
    
    
    //MARK: - Helper
    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onTappedView(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}

