import Foundation
import UIKit

protocol passUserTextDelegate: AnyObject {
    func addItemText(userText: String)
}

class CustomAlert: UIView {
    
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    weak var delegate: passUserTextDelegate?
//    let userText = UITextField()
    let userText: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Enter text here"
        textfield.borderStyle = UITextField.BorderStyle.roundedRect
        textfield.keyboardType = UIKeyboardType.default
       return textfield
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
       return label
    }()
        
    let disMissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(.red, for: .normal)
       return button
    }()
    
    let addItemButtom = UIButton()

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
    
    func showAlert(with title: String,
                   message: String,
                   on viewController: UIViewController) {
        guard let targetView = UIApplication.shared.windows.first else {return}
        backgroundView.frame = UIScreen.main.bounds
        myTargetView = targetView
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        alertView.frame = CGRect(x: 40, y: -300, width: targetView.frame.size.width-80, height: 300)
        
        // MARK: - Custom Alert titleLabel
        titleLabel.text = title
        alertView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalTo: alertView.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
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
        
        alertView.addSubview(userText)
        userText.delegate = self
        userText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userText.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            userText.centerYAnchor.constraint(equalTo: alertView.centerYAnchor),
            userText.widthAnchor.constraint(equalTo: alertView.widthAnchor, multiplier: 0.8),
            userText.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // MARK: - Custom Alert Buttom
        disMissButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(disMissButton)
        disMissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            disMissButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 15),
            disMissButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -30),
            disMissButton.widthAnchor.constraint(equalToConstant: 150),
            disMissButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addItemButtom.setTitle("Add Item", for: .normal)
        addItemButtom.setTitleColor(.link, for: .normal)
        addItemButtom.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        alertView.addSubview(addItemButtom)
        addItemButtom.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addItemButtom.leadingAnchor.constraint(equalTo: disMissButton.trailingAnchor, constant: 5),
            addItemButtom.bottomAnchor.constraint(equalTo: disMissButton.bottomAnchor),
            addItemButtom.widthAnchor.constraint(equalTo: disMissButton.widthAnchor),
            addItemButtom.heightAnchor.constraint(equalTo: disMissButton.heightAnchor)
        
        ])
        
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
        self.endEditing(true)
    }
}
