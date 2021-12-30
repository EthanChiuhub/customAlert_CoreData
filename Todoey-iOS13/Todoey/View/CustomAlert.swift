import Foundation
import UIKit

protocol passUserTextDelegate: AnyObject {
    func addItemText(userText: String)
}

class CustomAlert: UIViewController {
    
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    weak var delegate: passUserTextDelegate?
    
    var userText: UITextField!
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        return alert
    }()
    private var myTargetView: UIView?
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlert(with title: String,
                   message: String,
//                   actionHandler: ((_ text: String?) -> Void)? ,
                   on viewController: UIViewController) {
        guard let targetView = UIApplication.shared.windows.first else {return}
        backgroundView.frame = UIScreen.main.bounds
        myTargetView = targetView
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        alertView.frame = CGRect(x: 40,
                                 y: -300,
                                 width: targetView.frame.size.width-80,
                                 height: 300)
        
        // MARK: - Custom Alert titleLabel
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: alertView.frame.size.width,
                                               height: 80))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        
        // MARK: - Custom Alert MessageLabel
        //        let messageLabel = UILabel(frame: CGRect(x: 0,
        //                                                 y: 80,
        //                                                 width: alertView.frame.size.width,
        //                                                 height: 170))
        //        messageLabel.numberOfLines = 0
        //        messageLabel.text = message
        //        messageLabel.textAlignment = .center
        //        alertView.addSubview(messageLabel)
        // MARK: - Cusstom Alert TextField
        userText = UITextField(frame: CGRect(x: alertView.frame.width/4,
                                             y: alertView.frame.height/2.5,
                                                       width: alertView.frame.size.width/2,
                                                       height: 50))
        userText.placeholder = "Enter text here"
        userText.borderStyle = UITextField.BorderStyle.roundedRect
        userText.keyboardType = UIKeyboardType.default
        userText.delegate = self
        alertView.addSubview(userText)
        
        
        // MARK: - Custom Alert Buttom
        let disMissButton = UIButton(frame: CGRect(x: 0,
                                                   y: alertView.frame.size.height-80,
                                                   width: alertView.frame.size.width/2,
                                                   height: 50))
        disMissButton.setTitle("Dismiss", for: .normal)
        disMissButton.setTitleColor(.red, for: .normal)
        disMissButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(disMissButton)
        
        let addItemButtom = UIButton(frame: CGRect(x: 100,
                                                   y: alertView.frame.size.height-80,
                                                   width: alertView.frame.size.width/2,
                                                   height: 50))
        
        addItemButtom.setTitle("Add Item", for: .normal)
        addItemButtom.setTitleColor(.link, for: .normal)
        addItemButtom.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        alertView.addSubview(addItemButtom)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25,animations: {
                    self.alertView.center = targetView.center
                })
            }
        })
    }
    
    @objc func addItem() {
        guard let targetView = myTargetView else {return}
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(x: 40,
                                          y: targetView.frame.size.height,
                                          width: targetView.frame.size.width-80,
                                          height: 300)
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25,animations: {
                    self.backgroundView.alpha = 0
                }) { done in
                    if done {
                        print(self.userText.text)
                        self.delegate?.addItemText(userText: self.userText.text ?? "")
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                }
            }
        })
    }
    
    @objc func dismissAlert() {
        guard let targetView = myTargetView else {return}
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(x: 40,
                                          y: targetView.frame.size.height,
                                          width: targetView.frame.size.width-80,
                                          height: 300)
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25,animations: {
                    self.backgroundView.alpha = 0
                }) { done in
                    if done {
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                }
            }
        })
    }
}

extension CustomAlert: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
