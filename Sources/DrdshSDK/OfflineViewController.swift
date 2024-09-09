//
//  OfflineViewController.swift
//  DrdshSDK
//
//  Created by Gaurav Gudaliya R on 20/03/20.
//

import UIKit

class OfflineViewController: UIViewController {

   @IBOutlet weak var btnStart: GGButton!
   @IBOutlet weak var txtFullName: UITextField!
   @IBOutlet weak var txtEmailAddress: UITextField!
   @IBOutlet weak var txtMobile: UITextField!
   @IBOutlet weak var txtTypeYourQuestion: UITextField!
   @IBOutlet weak var txtSubject: UITextField!
   
   @IBOutlet weak var viewFullName: GGView!
   @IBOutlet weak var viewEmailAddress: GGView!
   @IBOutlet weak var viewMobile: GGView!
   @IBOutlet weak var viewTypeYourQuestion: GGView!
   @IBOutlet weak var viewSubject: GGView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DrdshSDK.shared.localizedString(stringKey:"offline")
        self.view.backgroundColor = DrdshSDK.shared.config.bgColor.Color()
        self.txtFullName.text = GGUserSessionDetail.shared.name
        self.txtMobile.text = GGUserSessionDetail.shared.mobile
        self.txtEmailAddress.text = GGUserSessionDetail.shared.email
    
        if DrdshSDK.shared.config.local == "ar"{
            self.txtFullName.textAlignment = .right
            self.txtMobile.textAlignment = .right
            self.txtEmailAddress.textAlignment = .right
            self.txtSubject.textAlignment = .right
            self.txtTypeYourQuestion.textAlignment = .right
        }
        self.btnStart.setTitle(DrdshSDK.shared.localizedString(stringKey:"sendMessage"), for: .normal)
        var backImage = DrdshSDK.shared.config.backImage
        if DrdshSDK.shared.config.local == "ar"{
            backImage = backImage.rotate(radians: .pi)
        }
        let barItem = UIBarButtonItem(image:  backImage, style: .plain, target: self, action: #selector(dissmissView))
        navigationItem.leftBarButtonItem = barItem
        self.setupData()
        btnStart.action = {
           self.SendOfflineMsg()
       }
        // Do any additional setup after loading the view.
    }
    func setupData(){
        DispatchQueue.main.async {
            self.viewEmailAddress.isHidden = false
            self.viewMobile.isHidden = !DrdshSDK.shared.AllDetails.embeddedChat.offlineMsgShowMobileBox
            self.viewSubject.isHidden = !DrdshSDK.shared.AllDetails.embeddedChat.offlineMsgShowSubjectBox
            self.btnStart.backgroundColor = DrdshSDK.shared.config.topBarBgColor.Color()
            self.txtFullName.placeholder = DrdshSDK.shared.config.fieldPlaceholderName.Local()
            self.txtMobile.placeholder = DrdshSDK.shared.config.fieldPlaceholderMobile.Local()
            self.txtEmailAddress.placeholder = DrdshSDK.shared.config.fieldPlaceholderEmail.Local()
            self.txtTypeYourQuestion.placeholder = DrdshSDK.shared.config.fieldPlaceholderMessage.Local()
            self.btnStart.backgroundColor = DrdshSDK.shared.config.buttonColor.Color()
        }
    }
    @objc func dissmissView(){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MainLoadViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        //self.dismiss(animated: true, completion: nil)
    }
    func SendOfflineMsg() {
        if self.txtFullName.text == ""{
            self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterName)
            return
        }else if self.txtEmailAddress.text == ""{
            self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterEmailAddress)
            return
        }else if !self.txtEmailAddress.text!.isValidEmail{
            self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterValidEmail)
            return
        }else if self.txtMobile.text == "" && DrdshSDK.shared.AllDetails.embeddedChat.offlineMsgShowMobileBox{
            self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterMobile)
            return
        }else if self.txtSubject.text == "" && DrdshSDK.shared.AllDetails.embeddedChat.offlineMsgShowSubjectBox{
            self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterSubject)
            return
        }else if self.txtTypeYourQuestion.text == ""{
            self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterMessage)
            return
        }
        
      let newTodo: [String: Any] = [
            "appSid" : DrdshSDK.shared.config.appSid,
            "locale" : DrdshSDK.shared.config.local,
            "_id":DrdshSDK.shared.AllDetails.visitorID,
            "subject" : self.txtSubject.text!,
            "name": self.txtFullName.text!,
            "mobile": self.txtMobile.text!,
            "email": self.txtEmailAddress.text!,
            "message": self.txtTypeYourQuestion.text!
        ]
        CommonSocket.shared.CommanEmitSokect(command: .submitOfflineMessage,data: [newTodo]) { receivedTodo in
            self.txtTypeYourQuestion.text = ""
            self.showAlertView(str: receivedTodo["message"] as? String ?? "")
        }
    }
    func showAlertView(str:String){
         let alert = UIAlertController(title: nil, message: str.Local(), preferredStyle: UIAlertController.Style.alert)
         alert.addAction(UIAlertAction(title: DrdshSDK.shared.config.ok.Local(), style: UIAlertAction.Style.default, handler: nil))
         DrdshSDK.shared.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
