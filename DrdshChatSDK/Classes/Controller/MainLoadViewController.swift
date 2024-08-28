//
//  MainLoadViewController.swift
//  DrdshSDK
//
//  Created by Gaurav Gudaliya R on 14/03/20.
//

import UIKit
import IQKeyboardManagerSwift
class MainLoadViewController: UIViewController {
    @IBOutlet weak var btnStart: GGButton!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtTypeYourQuestion: UITextField!
    
    @IBOutlet weak var viewFullName: GGView!
    @IBOutlet weak var viewEmailAddress: GGView!
    @IBOutlet weak var viewMobile: GGView!
    @IBOutlet weak var viewTypeYourQuestion: GGView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "chat".Local()
        
        self.txtFullName.text = GGUserSessionDetail.shared.name
        self.txtMobile.text = GGUserSessionDetail.shared.mobile
        self.txtEmailAddress.text = GGUserSessionDetail.shared.email
        //        txtFullName.placeholder = DrdshSDK.shared.localizedString(stringKey: "Full Name")
        //        txtMobile.placeholder = DrdshSDK.shared.localizedString(stringKey: "Mobile")
        //        txtEmailAddress.placeholder = DrdshSDK.shared.localizedString(stringKey: "Email Address")
        //        txtTypeYourQuestion.placeholder = DrdshSDK.shared.localizedString(stringKey: "Type your Question or message")
        //        btnStart.setTitle(DrdshSDK.shared.localizedString(stringKey: "Start Chat"), for: .normal)
        if DrdshSDK.shared.config.local == "ar"{
            self.txtFullName.textAlignment = .right
            self.txtMobile.textAlignment = .right
            self.txtEmailAddress.textAlignment = .right
            self.txtTypeYourQuestion.textAlignment = .right
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = DrdshSDK.shared.config.done.Local()
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatViewController.self]
        btnStart.action = {
            self.startChat()
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : DrdshSDK.shared.config.titleTextColor.Color(),.font : UIFont.boldSystemFont(ofSize: 17)]
        var backImage = DrdshSDK.shared.config.backImage
        if DrdshSDK.shared.config.local == "ar"{
            backImage = backImage.rotate(radians: .pi)
        }
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = DrdshSDK.shared.config.topBarBgColor.Color()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        let barItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(dissmissView))
        barItem.title = DrdshSDK.shared.localizedString(stringKey:"Chat")
        navigationItem.leftBarButtonItem = barItem
        self.btnStart.backgroundColor = DrdshSDK.shared.config.topBarBgColor.Color()
        makePostCall()
        CommonSocket.shared.inviteVisitorListener { data in
            DrdshSDK.shared.AllDetails.visitorConnectedStatus = 2
            DrdshSDK.shared.AgentDetail <= data
            DrdshSDK.shared.AllDetails.agentId = data["agent_id"] as? String ?? ""
            DrdshSDK.shared.AgentDetail.agent_name = data["agent_name"] as? String ?? ""
            DrdshSDK.shared.AgentDetail.visitor_message_id = data["visitor_message_id"] as? String ?? ""
            DrdshSDK.shared.AllDetails.agentOnline = data["agentOnline"] as? Int ?? 0
            DrdshSDK.shared.AllDetails.messageID = data["visitor_message_id"] as? String ?? ""
            
            var newTodo: [String: Any] =  DrdshSDK.shared.AllDetails.toDict
            newTodo["embeddedChat"] = DrdshSDK.shared.AllDetails.embeddedChat.toDict
            UserDefaults.standard.setValue(newTodo, forKey: "AllDetails")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            self.navigationController?.pushViewController(vc, animated: true)
            CommonSocket.shared.CommanEmitSokect(command: .joinAgentRoom,data: [[
                "agent_id":DrdshSDK.shared.AllDetails.agentId]]) { receivedTodo in
                    
            }
        }
    }
    func setupData(){
        DispatchQueue.main.async {
            
            self.viewEmailAddress.isHidden = DrdshSDK.shared.AllDetails.embeddedChat.emailRequired == 0
            self.viewMobile.isHidden = DrdshSDK.shared.AllDetails.embeddedChat.mobileRequired == 0
            self.viewTypeYourQuestion.isHidden = DrdshSDK.shared.AllDetails.embeddedChat.messageRequired == 0
            self.txtFullName.placeholder = DrdshSDK.shared.config.fieldPlaceholderName.Local()
            self.txtMobile.placeholder = DrdshSDK.shared.config.fieldPlaceholderMobile.Local()
            self.txtEmailAddress.placeholder = DrdshSDK.shared.config.fieldPlaceholderEmail.Local()
            self.txtTypeYourQuestion.placeholder = DrdshSDK.shared.config.fieldPlaceholderMessage.Local()
            self.btnStart.setTitle( DrdshSDK.shared.config.startChatButtonTxt.Local(), for: .normal)
            self.view.backgroundColor = DrdshSDK.shared.config.bgColor.Color()
            self.navigationController?.navigationBar.barTintColor = DrdshSDK.shared.config.topBarBgColor.Color()
            self.btnStart.backgroundColor = DrdshSDK.shared.config.buttonColor.Color()
        }
    }
    func makePostCall() {
        let validateIdentityAPI: String = DrdshSDK.shared.APIbaseURL + "validate-identity"
        var todosUrlRequest = URLRequest(url: URL(string: validateIdentityAPI)!)
        todosUrlRequest.httpMethod = "POST"
        
        let browser = Bundle.main.bundleIdentifier!+",AppVersion:"+"\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"+",BuildVersion:"+"\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "")"
        var newTodo: [String: Any] = [
            "appSid" : DrdshSDK.shared.config.appSid,
            "locale" : DrdshSDK.shared.config.local,
            "expandWidth": self.view.frame.width.description,
            "expendHeight": self.view.frame.height.description,
            "deviceID": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "ipAddress": "192.168.1.2",
            "device": "ios",
            "timeZone" : TimeZone.current.identifier,
            "browser": browser,
            "name":self.txtFullName.text!,
            "email":self.txtEmailAddress.text!,
            "mobile":self.txtMobile.text!,
            "fcmKey":DrdshSDK.shared.config.FCM_Token,
            "legacyServerKey":DrdshSDK.shared.config.FCM_Auth_Key,
            "domain": "www.drdsh.live"
        ]
        if DrdshSDK.shared.AllDetails.visitorID != ""{
            newTodo["visitorID"] = DrdshSDK.shared.AllDetails.visitorID
            newTodo["name"] = GGUserSessionDetail.shared.name
            newTodo["email"] = GGUserSessionDetail.shared.email
            newTodo["mobile"] = GGUserSessionDetail.shared.mobile
        }
        if getIFAddresses().count > 0{
            newTodo["ipAddress"] = getIFAddresses()[0]
        }
        let jsonTodo: Data
        do {
            jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
            todosUrlRequest.httpBody = jsonTodo
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
        todosUrlRequest.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        todosUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        todosUrlRequest.setValue(DrdshSDK.shared.config.local, forHTTPHeaderField: "locale")
        let session = URLSession.shared
        GGProgress.shared.showProgress()
        let task = session.dataTask(with: todosUrlRequest) {
            (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        
                    }
                }
                return
            }
            DispatchQueue.main.async {
                GGProgress.shared.hideProgress()
            }
            guard error == nil else {
                print("error calling POST on /todos/1",error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let receivedTodo = try JSONSerialization.jsonObject(with: responseData,
                                                                          options: []) as? [String: Any] else {
                                                                            print("Could not get JSON from responseData as dictionary")
                                                                            return
                }
                if httpResponse.statusCode == 200{
                    if let d = receivedTodo["data"] as? [String:AnyObject]{
                        print("Response : " + receivedTodo.description)
                        DrdshSDK.shared.AllDetails <= d
                        var newTodo: [String: Any] =  DrdshSDK.shared.AllDetails.toDict
                        DrdshSDK.shared.config.mapServerData(to: DrdshSDK.shared.AllDetails.embeddedChat.toDict)
                        self.setupData()
                        newTodo["embeddedChat"] = DrdshSDK.shared.AllDetails.embeddedChat.toDict
                        UserDefaults.standard.setValue(newTodo, forKey: "AllDetails")
                        
                        if DrdshSDK.shared.AllDetails.visitorConnectedStatus == 1 || DrdshSDK.shared.AllDetails.visitorConnectedStatus == 2{
//                            if DrdshSDKTest.shared.AllDetails.visitorConnectedStatus == 1{
//
//                            }
                            DispatchQueue.main.async {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                                self.navigationController?.pushViewController(vc, animated: false)
                            }
                        }else{
                            if !DrdshSDK.shared.AllDetails.embeddedChat.displayForm{
                                self.startChat(isDirect: true)
                                return
                            }
                        }
                        CommonSocket.shared.initSocket { (status) in
                            CommonSocket.shared.CommanEmitSokect(command: .joinVisitorsRoom,data:[["dc_vid":DrdshSDK.shared.AllDetails.visitorID]]){ data in
                                if DrdshSDK.shared.AllDetails.visitorConnectedStatus == 2{
                                    DrdshSDK.shared.AgentDetail <= data
                                    DrdshSDK.shared.AllDetails.agentId = data["agent_id"] as? String ?? ""
                                    DrdshSDK.shared.AgentDetail.agent_name = data["agent_name"] as? String ?? ""
                                    DrdshSDK.shared.AgentDetail.visitor_message_id = data["visitor_message_id"] as! String
                                }
                                debugPrint(data)
                            }
                        }
                    }
                }else{
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            let alert = UIAlertController(title: "Error", message: receivedTodo["message"] as? String ?? "", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            DrdshSDK.shared.topViewController()?.present(alert, animated: true, completion: nil)
                        }
                    }
                    print("Response : " + receivedTodo.description)
                }
            } catch  {
                print("error parsing response from POST on /todos")
                return
            }
        }
        task.resume()
    }
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        if address.count <= 16{
                            addresses.append(address)
                        }
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }
    func startChat(isDirect:Bool = false) {
        if !isDirect{
            if self.txtFullName.text == ""{
                self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterName)
                return
            }else if self.txtEmailAddress.text == "" && DrdshSDK.shared.AllDetails.embeddedChat.emailRequired == 2{
                self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterEmailAddress)
                return
            }else if DrdshSDK.shared.AllDetails.embeddedChat.emailRequired == 2 && !self.txtEmailAddress.text!.isValidEmail{
                self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterValidEmail)
                return
            }else if self.txtMobile.text == "" && DrdshSDK.shared.AllDetails.embeddedChat.mobileRequired == 2{
                self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterMobile)
                return
            }
            else if self.txtTypeYourQuestion.text == "" && DrdshSDK.shared.AllDetails.embeddedChat.mobileRequired == 2{
                self.showAlertView(str: DrdshSDK.shared.config.pleaseEnterMessage)
                return
            }
        }
        let newTodo: [String: Any] = [
            "locale" : DrdshSDK.shared.config.local,
            "_id":DrdshSDK.shared.AllDetails.visitorID,
            "name": self.txtFullName.text != "" ? self.txtFullName.text! : "Guest",
            "mobile": self.txtMobile.text!,
            "email": self.txtEmailAddress.text!,
            "message": self.txtTypeYourQuestion.text!
        ]
        CommonSocket.shared.CommanEmitSokect(command: .inviteChat,data: [newTodo]) { receivedTodo in
            print("Response : " + receivedTodo.description)
            DrdshSDK.shared.AllDetails.agentOnline = receivedTodo["agentOnline"] as? Int ?? 0
            DrdshSDK.shared.AllDetails.visitorConnectedStatus = 2
            DrdshSDK.shared.AllDetails.messageID = receivedTodo["visitor_message_id"] as? String ?? ""
            
            var newTodo: [String: Any] =  DrdshSDK.shared.AllDetails.toDict
            newTodo["embeddedChat"] = DrdshSDK.shared.AllDetails.embeddedChat.toDict
            UserDefaults.standard.setValue(newTodo, forKey: "AllDetails")
            DispatchQueue.main.async {
                GGUserSessionDetail.shared.name = self.txtFullName.text!
                GGUserSessionDetail.shared.mobile = self.txtMobile.text!
                GGUserSessionDetail.shared.email = self.txtEmailAddress.text!
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    func showAlertView(str:String){
        
        let alert = UIAlertController(title: DrdshSDK.shared.config.error.Local(), message: str.Local(), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: DrdshSDK.shared.config.ok.Local(), style: UIAlertAction.Style.default, handler: nil))
        DrdshSDK.shared.topViewController()?.present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupData()
        self.txtTypeYourQuestion.text = ""
    }
    @objc func dissmissView(){
        CommonSocket.shared.disConnect()
        self.dismiss(animated: true, completion: nil)
    }
}
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
