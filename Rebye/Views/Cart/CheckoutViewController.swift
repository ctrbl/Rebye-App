//
//  CheckoutViewController.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/21/22.
//

import SwiftUI
import UIKit
import Stripe
import PassKit
import FirebaseFunctions

struct CheckoutViewController: UIViewControllerRepresentable {
    let userAuth = UserAuthModel.shared

    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainView")
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
}

class CheckOutViewController: UIViewController, STPPaymentContextDelegate {
    
    let userAuth = UserAuthModel.shared
    var subtotal: Double = 0.0
    var shipping: Double = 0.0
    var total: Double = 0.0
    var paymentContext: STPPaymentContext!
    var paymentIntent: STPPaymentIntent!
    
    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var shippingCostLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var shippingMethodButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStripeConfig()
        subtotal = DB_Manager().getCartTotal(accIDValue: userAuth.accID)
        total = subtotal
        subtotalLabel.text = subtotal.penniesToFormattedCurrent()
        totalLabel.text = total.penniesToFormattedCurrent()
        shippingCostLabel.text = shipping.penniesToFormattedCurrent()
    }
    
    func setupStripeConfig() {
        let config = STPPaymentConfiguration.shared
        config.applePayEnabled = true
        config.requiredBillingAddressFields = .full
        config.requiredShippingAddressFields = [.postalAddress]
        
        let customerContext = STPCustomerContext(keyProvider: StripeAPI)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .defaultTheme)
        paymentContext.paymentAmount = Int(subtotal * 100)
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    @IBAction func paymentMethodClicked(_ sender: Any) {
        paymentContext.presentPaymentOptionsViewController()
    }
    
    @IBAction func shippingMethodClicked(_ sender: Any) {
        paymentContext.presentShippingViewController()
    }
    
    @IBAction func placeOrderClicked(_ sender: Any) {
        paymentContext.requestPayment()
        activityIndicator.startAnimating()
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        let retry = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.paymentContext.retryLoading()
        }
        alertController.addAction(cancel)
        alertController.addAction(retry)
        present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        if let paymentMethod = paymentContext.selectedPaymentOption {
            paymentMethodButton.setTitle(paymentMethod.label, for: .normal)
        } else {
            paymentMethodButton.setTitle("Select Method", for: .normal)
        }
        if let shippingMethod = paymentContext.selectedShippingMethod {
            shippingMethodButton.setTitle(shippingMethod.label, for: .normal)
            shipping = Double(truncating: shippingMethod.amount)
            shippingCostLabel.text = shipping.penniesToFormattedCurrent()
            total = subtotal + shipping
            totalLabel.text = total.penniesToFormattedCurrent()
        } else {
            shippingMethodButton.setTitle("Select Method", for: .normal)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        let idempotency = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let paymentMethod: STPPaymentMethod = paymentContext.selectedPaymentOption as! STPPaymentMethod
        let paymentStripeID = paymentMethod.stripeId
        print(paymentStripeID)
        
        let data : [String: Any] = [
            "total" : total * 100,
            "customerID" : userAuth.customerID,
            "paymentStripeID" : paymentStripeID,
            "idempotency" : idempotency
        ]
        
        Functions.functions().httpsCallable("createCharge").call(data) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            print("YAY")
        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        var title: String
        var message: String
        
        switch status {
        case .error:
            activityIndicator.stopAnimating()
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            activityIndicator.stopAnimating()
            title = "Success!"
            message = "Thank you for your purchase."
        case .userCancellation:
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        
        let fedEx = PKShippingMethod()
        fedEx.amount = 6.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"
        
        if address.country == "US" {
            completion(.valid, nil, [upsGround, fedEx], fedEx)
        } else {
            completion(.invalid, nil, nil, nil)
        }
    }
}

extension Double {
    func penniesToFormattedCurrent() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let dollarString = formatter.string(from: self as NSNumber) {
            return dollarString
        }
        return "$0.00"
    }
}
