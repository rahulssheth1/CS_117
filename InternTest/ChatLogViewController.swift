//
//  ChatLogViewController.swift
//  InternTest
//
//  Created by Rahul Sheth on 9/22/17.
//  Copyright © 2017 Rahul Sheth. All rights reserved.
//

import UIKit
import Firebase



class ChatLogViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    
    var messagesArray = [Messages]()
    var nameString = String()
    var profileImageURLString = String()
    
    var user = User()
    
    func retrieveCurrentNameAndURL() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("users").child(uid!)
        ref.observe(.value, with:  { (snapshot) in
            
            let dictionary = snapshot.value as? [String: AnyObject]
            if (dictionary?["name"] as? String != nil) {
                self.nameString = dictionary?["name"] as! String
            }
            if (dictionary?["profileImageURL"] as? String != nil) {
                self.profileImageURLString = dictionary?["profileImageURL"] as! String
            }
            
        })
    }
    
    //Retrieve all of the messages to display
    func fetchMessages() {
        
        let sendingID = (FIRAuth.auth()?.currentUser?.uid)! as NSString
        let receivingID = NSString(string: (user.uid))
        var string1 = sendingID as String
        string1.append(" and ")
        string1.append(receivingID as String)
        var string2 = receivingID as String
        string2.append(" and ")
        string2.append(sendingID as String)
        let ref = FIRDatabase.database().reference().child("Relationships")
        ref.observe(.value, with: {  (snapshot) in
            self.messagesArray.removeAll()
            
            if let topDictionary = snapshot.value as?  [String: AnyObject] {
                
                var inString = String()
                if (topDictionary[string1] != nil) {
                    inString = string1
                } else if (topDictionary[string2] != nil) {
                    inString = string2
                } else {
                    inString = "false"
                }
                
                if (inString != "false") {
                    
                    let dict = topDictionary[inString] as! [String: AnyObject]
                    if (dict["messages"] != nil) {
                        let messagesDict = dict["messages"] as! [String: AnyObject]
                        let count = messagesDict.count
                        for i in 0..<count {
                            let key  = messagesDict[messagesDict.index(messagesDict.startIndex, offsetBy: i)].key
                            let dictionary = messagesDict[key] as! [String: AnyObject]
                            
                            let message = Messages()
                            if (dictionary["ReceivingID"] as! NSString == receivingID && dictionary["SendingID"] as! NSString == sendingID) {
                                message.message = dictionary["message"] as! String?
                                if (dictionary["timeStamp"] != nil) {
                                    message.timeStamp = Int(dictionary["timeStamp"] as! Double)
                                }
                                message.length = (message.message?.characters.count)! * 5 + 10
                                
                                message.height = message.length / 5
                                message.ReceivingID = receivingID as String
                                message.SendingID = sendingID as String
                                message.type = 1
                                
                                self.messagesArray.append(message)
                                self.messagesArray.sort(by:  ({$0.timeStamp > $1.timeStamp}))
                                
                                
                                
                            } else if (dictionary["ReceivingID"] as! NSString == sendingID && dictionary["SendingID"] as! NSString == receivingID) {
                                message.message = dictionary["message"] as! String?
                                if (dictionary["timeStamp"] != nil) {
                                    message.timeStamp = Int(dictionary["timeStamp"] as! Double)
                                }
                                message.ReceivingID = sendingID as String
                                message.SendingID = receivingID as String
                                message.type = 2
                                self.messagesArray.append(message)
                                self.messagesArray.sort(by:  ({$0.timeStamp > $1.timeStamp}))
                                
                            }
                            
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                                
                                
                            }
                            DispatchQueue.main.async {
                                
                                var height1 = CGFloat()
                                var height2 = CGFloat()
                                height1 = (self.collectionView?.contentSize.height)!
                                height2 = (self.collectionView?.frame.size.height)!
                                
                                
                                if (height1 > height2) {
                                    self.collectionView?.setContentOffset(CGPoint(x: 0, y: (self.collectionView?.contentSize.height)! - (self.collectionView?.frame.size.height)!), animated: false)
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
        })
        
        
    }


    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
