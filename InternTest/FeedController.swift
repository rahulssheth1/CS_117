//
//  FeedController.swift
//  InternTest
//
//  Created by Rahul Sheth on 1/16/17.
//  Copyright © 2017 Rahul Sheth. All rights reserved.
//


//Some information for the Domain Based feed Portion

//1. This currently checks only if the user does not search and return to feed.
//2. Currently, there is extra storage inside the Firebase database. The Root -> Domains is not utilized in this portion so as of Iteration V1.0 of Domain-Based Feed, it serves no purpose. However, it's still being saved because it may be useful and I'm too lazy to delete it
//3. The workflow is that:
    //a. We scan for all of the domains of the curUser and them into the array named personalDomains.
    //b. Then we check to see if
        //a. There is any overlap
        //b. The personal Domains array is empty
    //c. If either of the above conditions are true, we show the candidate/recruiter to the user
//4. In addition, we present three of the domains the user is into. In addition, we prioritize the matched domains above general domains of the user.


import Foundation
import UIKit
import AVKit
import AVFoundation
import Firebase


//The full user feed 
var globalFeedString = String()
var globalCurrentName = String()
var globalProfilePictureImageURL = String()
var firstGreenArrowBool = Bool()
var firstRedCrossBool = Bool()
var firstTimeCalendar = Bool()
var firstTimeSearch = Bool()

class FeedController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //Initialization of variables
    var personalDomains = [String]()
    let uid = FIRAuth.auth()?.currentUser?.uid
    var tableView = UITableView()
  var ref = FIRDatabase.database().reference()
    var userList = [User]()
    let cellID = "cellID"
    var profileImageURL: String?
    var passedInString: String?
    var passedUniversityList = [String]()
    var passedSkillsList = [String]()
    var passedMajorList = [String]()
    var passedInInt: Int?
    var refreshControl: UIRefreshControl!
    var searchBool: Bool?
    var previousController: UIViewController?
    let blueSearchBarColor = UIColor(red: 21/255, green: 126/255, blue: 251/255, alpha: 0.75)

    var helpView = UIView()
    var helpLabel = UILabel()
    
    var helpTitleLabel = UILabel()
    var firstSignUpBool = false
    
    var dict2 = [String: AnyObject]()
    var isArchived = Bool()
    var isRequests = Bool()
    
    var recruiterOrAll = true

    deinit {
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    //--------------------------------------------------------------------------------
    
    
    //HELPER FUNCTIONS  and Buttons
    
    class GenericCellButton: UIButton  {
        var user = User()
    }
    
    
    class NoButton: UIButton {
        var value = Int()
        var userID = String()
    }
    
    
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func greenArrow(sender: GenericCellButton) {
        helpTitleLabel.text = "Connecting Feature"
        helpLabel.text = "This is when you want to connect with a user. Similar to LinkedIn's connection feature, this will give you access to their profile, showing all of their supplemental videos and links or job postings if they're a recruiter, the ability to message them. An added feature for recruiters is that they can check the times student's are available and set meetings!"
        setUpHelpView(sender: sender)
        dict2["FirstTimeConnect"] = NSString(string: "false")
        self.ref.child("users").child(self.uid!).child("HelpViews").updateChildValues(dict2)
    }
    func redCross(row: Int, uid: String) {
        helpTitleLabel.text = "Rejection Feature"
        helpLabel.text = "This is when you don't want a certain user to appear on your feed (even if you search for them). If you still want to see this user, there will be a special archive in your settings that displays all users you've rejected."
        let button = GenericCellButton()
        button.tag = row
        button.user.uid = uid
        setUpHelpView(sender: button)
        dict2["FirstTimeReject"] = NSString(string: "false")
        self.ref.child("users").child(self.uid!).child("HelpViews").updateChildValues(dict2)
    }
    
    func feed() {
        
        helpTitleLabel.text = "Welcome to Feed"
        helpLabel.text = "This is where you can connect with other users (Company Recruiters if you're Students and vice versa). Click on the red cross or green arrow to learn more about the kinds of ways you can interact with users and click the user's name to see a quick screenshot! Check out settings to figure out how to further customize your feed!"
        setUpHelpView(sender: nil)
        dict2["FirstTimeSignUp"] = NSString(string: "false")
        self.ref.child("users").child(self.uid!).child("HelpViews").updateChildValues(dict2)

    }
    
    func setUpHelpView(sender: GenericCellButton?) {
        self.view.addSubview(helpView)
        helpView.translatesAutoresizingMaskIntoConstraints = false
        helpView.heightAnchor.constraint(equalToConstant: self.view.bounds.height / 2.3).isActive = true
        helpView.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.8).isActive = true
        helpView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        helpView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        helpView.backgroundColor = UIColor.white
        helpView.layer.borderColor = UIColor.black.cgColor
        helpView.layer.borderWidth = 1
        helpView.layer.cornerRadius = 5
        
        helpView.addSubview(helpTitleLabel)
        helpTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        helpTitleLabel.centerXAnchor.constraint(equalTo: helpView.centerXAnchor).isActive = true
        helpTitleLabel.topAnchor.constraint(equalTo: helpView.topAnchor, constant: 10).isActive = true
        helpTitleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 30)
        
        
        helpView.addSubview(helpLabel)
        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        
        helpLabel.numberOfLines = 0
        helpLabel.lineBreakMode = .byWordWrapping
        helpLabel.centerXAnchor.constraint(equalTo: helpView.centerXAnchor).isActive = true
        helpLabel.centerYAnchor.constraint(equalTo: helpView.centerYAnchor).isActive = true
        helpLabel.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.7).isActive = true
        helpLabel.textAlignment = .center
        helpLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        tableView.alpha = 0.8
        
        let continueButton = GenericCellButton()
        helpView.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.centerXAnchor.constraint(equalTo: helpView.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.5).isActive = true
        continueButton.topAnchor.constraint(equalTo: helpLabel.bottomAnchor, constant: 20).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.05).isActive = true
        continueButton.setTitle("Get Started", for: .normal)
        continueButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        if (sender != nil) {
        continueButton.user = (sender?.user)!
        }
        continueButton.layer.cornerRadius = 10
        if (sender?.tag != nil) {
        continueButton.tag = (sender?.tag)!
        }
        continueButton.backgroundColor = UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1)
        continueButton.addTarget(self, action: #selector(removeHelpView), for: .touchUpInside)
        

        
    }
    func movePastGreenArrow(sender: GenericCellButton) {
        if (sender.user.occupation == "Employer") {
            let segueController = EmployerViewController(nibName: nil, bundle: nil)
            segueController.user = (sender.user)
            present(segueController, animated: true, completion: nil)
        } else {
            let segueController = StudentViewController(user: (sender.user))
            present(segueController, animated: true, completion: nil)
        }

    }
    
    func movePastRedCross(sender: GenericCellButton) {
        
        let value = sender.tag
        
        userList.remove(at: value)
        ref.child("users").child(uid!).child("Archived").child((sender.user.uid)).updateChildValues(["Archived?": "Yes" as NSString])
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
    
    func removeHelpView(sender: GenericCellButton) {
        helpView.removeFromSuperview()
        tableView.alpha = 1
        if (helpTitleLabel.text == "Connecting Feature") {
            movePastGreenArrow(sender: sender)
        } else if (helpTitleLabel.text == "Rejection Feature") {
            movePastRedCross(sender: sender)
        }
    }
    
    //Call this so you can load up your messenger users before you start up
    
    
    func fetchMessengerUsers() {
        let ref = FIRDatabase.database().reference().child("users")
        let childRef = ref.child(uid!).child("friends")
        
        ref.observe(.childAdded, with:  { (snapshot) in
            childRef.observe(.value, with: { (snapshot2) in
                for rest in snapshot2.children.allObjects as! [FIRDataSnapshot] {
                    if (snapshot.key == rest.key as! String) {
                        
                        
                        let user = User()
                        user.uid = snapshot.key
                        let dictionary2 = snapshot.value as! [String:AnyObject]
                        
                        
                        if (dictionary2["profileImageURL"] as? String != nil) {
                            let profileImageURL = dictionary2["profileImageURL"] as! String
                            let imageView = UIImageView()
                            imageView.loadIntoCache(urlString: profileImageURL)
                            
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                }
                
            })
            
        })
        
    }

    
    
    //Move to your Calendar with the reminders
    func handleMoveToRecruiter() {
        
        //Global feed string is the opposite of what the actual position is fml rahul
        if (globalFeedString == "Student") {
            
        let segueController = CalendarViewController()
            segueController.modalTransitionStyle = .flipHorizontal
            segueController.modalPresentationStyle = .popover
        present(segueController, animated: false, completion: nil)
        } else {
            let segueController = SetUpFreeTimeViewController()
            present(segueController, animated: false, completion: nil)
        }
    }
    
    func handleMoveToMessages() {
        let segueController = MessagesController()
        present(segueController, animated: false, completion: nil)
    }
    
    
    //Go to search
    func handleMoveToSearch() {
        let segueController = SearchViewController(nibName: nil, bundle: nil)
        segueController.previousController = FeedController()
        present(segueController, animated: false, completion: nil)
    }
    func moveToProfile(sender: UIButton) {
        
        let segueController = ProfilePageViewController()
        present(segueController, animated: false, completion: nil)
    }
    func handleNotifications() {
        let segueController = NotificationCenterViewController()
        present(segueController, animated: false, completion: nil)
    }

    
    
    
    //Get your personal Profile Image. This is useful for displaying your profile Picture in notifications
    func getProfileImageURL() {
        
        
        ref.child("users").child(uid!).observe(.value, with: { (snapshot) in
            
            if (snapshot.value as? [String: AnyObject] != nil) {
            let dictionary = snapshot.value as! [String: AnyObject]
            
            if (dictionary["profileImageURL"] as? String != nil) {
                globalProfilePictureImageURL = (dictionary["profileImageURL"] as! String?)!

            }
            }
            
            
        })
    }
    
    
    
    //Move back to your profile
   
    
    //When you press Yes, this is what happens. Registers as friend, uploads Notification and moves to their view controller 
    func handleYesButton(sender: AnyObject? ) {
        if (globalFeedString == "Employer") {
            let childRef = ref.child("users").child(uid!).child("Pending").child((sender?.user.uid)!)
            let values = ["Friends?": "Yes"]
            childRef.updateChildValues(values)
            
            let otherRef = ref.child("users").child((sender?.user.uid)!).child("Requests").child(uid!)
            otherRef.updateChildValues(values)
            
        } else {
            let childRef = ref.child("users").child(uid!).child("friends").child((sender?.user.uid)!)
            let values = ["Friends?": "Yes"]
            childRef.updateChildValues(values)
            
            let otherRef = ref.child("users").child((sender?.user.uid)!).child("friends").child(uid!)
            otherRef.updateChildValues(values)
            
        }
        let childRef = ref.child("users").child(uid!).child("friends").child((sender?.user.uid)!)
        let values = ["Friends?": "Yes"]
        childRef.updateChildValues(values)
        
        let otherRef = ref.child("users").child((sender?.user.uid)!).child("friends").child(uid!)
        otherRef.updateChildValues(values)
        
        let userReference = ref.child("users").child((sender?.user.uid)!).child("Notifications").childByAutoId()
        
        
        var updateString = globalCurrentName
        updateString.append(" wants to be connect")
        let realUpdate = NSString(string: updateString)
        let updateUID = NSString(string: uid!)
        
        let url = NSString(string: (globalProfilePictureImageURL))
        
        let readString = "false" as NSString
        var positionString = NSString()
        
        if (globalFeedString == "Student") {
            positionString = NSString(string: "Employer")
        } else {
            positionString = NSString(string: "Student")
        }
        let value = ["Message": realUpdate, "Type": "Friend", "OtherUID": updateUID, "profileImageURL": url, "read": readString, "Occupation": positionString]
        
        userReference.updateChildValues(value)
        if (firstGreenArrowBool) {
            greenArrow(sender: sender as! FeedController.GenericCellButton)
            firstGreenArrowBool = false
        } else {
        if (sender?.user.occupation == "Employer") {
            let segueController = EmployerViewController(nibName: nil, bundle: nil)
            segueController.user = (sender?.user)!
            present(segueController, animated: true, completion: nil)
        } else {
            let segueController = StudentViewController(user: (sender?.user)!)
            present(segueController, animated: true, completion: nil)
        }
        }
        
//
        
        
       
        
    }
    func handleScreenshot(sender: GenericCellButton) {
        let segueController = StudentScreenshotViewController(nibName: nil, bundle: nil)
        segueController.user = (sender.user)
        if (self.passedInString != nil) {
        segueController.passedInString = self.passedInString!
        } else {
            segueController.passedInString = ""
        }
        if (self.passedInInt != nil) {
        segueController.passedInInt = self.passedInInt!
        }
        segueController.searchBool = true
        present(segueController, animated: true, completion: nil)
    }
    
    //When you press no, it moves to the next person
    func handleNoButton(sender: AnyObject? ) {
        if (firstRedCrossBool) {
            redCross(row: (sender?.value)!, uid: (sender?.userID)!)
            firstRedCrossBool = false
        } else {
        
            
            userList.remove(at: (sender?.value)!)

            if ((sender?.value)!  > userList.count) {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            } else {
                let indexPath = IndexPath(row: (sender?.value)! + 1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
            }
        
        ref.child("users").child(uid!).child("Archived").child((sender?.userID)!).updateChildValues(["Archived?": "Yes" as NSString])

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        }
       
        
    }
    
   //When you press play, this is what's called
    
    func handleVideo(sender: GenericCellButton) {
        
        let url = URL(string: sender.user.videoURL)
        
        
        
        if (url != nil) {
            let player = AVPlayer(url: (url! as URL))
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true, completion: {
                playerViewController.player?.play()
            })
        } else {
            let alert = UIAlertController(title: "Failure", message: "No Video Available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func fetchRequests() {
        self.userList.removeAll()
        
        ref.child("users").child(self.uid!).child("Requests").observe(.childAdded, with: { (snapshot) in
            if (snapshot.hasChildren()) {
                let user = User()
                user.uid = snapshot.key
                
                self.ref.child("users").child(user.uid).observe(.value, with: { (snapshot2) in
                    let dictionary = snapshot2.value as! [String: AnyObject]
                    if ((dictionary["name"] as? String) != nil) {
                        user.name = (dictionary["name"] as? String)!
                    } else {
                        user.name = "Placeholder"
                    }
                    if ((dictionary["userVideoURL"] as? String) != nil) {
                        
                        user.videoURL = dictionary["userVideoURL"] as! String
                    }
                    
                    if ((dictionary["Occupation"] as? String) != nil) {
                        user.occupation = (dictionary["Occupation"] as? String)!
                        user.companyLabel = (dictionary["Occupation"] as? String)!
                        if (user.occupation == "Employer" && dictionary["Company"] as? String != nil) {
                            user.companyLabel = (dictionary["Company"] as? String)!
                        } else if (user.occupation == "Student" && dictionary["Unversity"] as? String != nil) {
                            user.companyLabel = (dictionary["Unversity"] as? String)!
                        }
                    }
                    
                    if (dictionary["thumbnailImageURL"] as! String?) != nil {
                        user.thumbnailImageURL = (dictionary["thumbnailImageURL"] as! String?)!
                        
                        
                        
                    }
                    if ((dictionary["profileImageURL"] as! String?) != nil) {
                        user.profileImageURL = (dictionary["profileImageURL"] as! String?)!
                    } else {
                        user.profileImageURL = "NIL"
                    }
                    
                    
                    self.userList.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                    }
                    
                    

                
                
                
                })
            }
        
        
        
        
        
        })
    }
    
    func fetchArchive() {
        self.userList.removeAll()
        
        ref.child("users").child(self.uid!).child("Archived").observe(.childAdded, with: { (snapshot) in
            if (snapshot.hasChildren()) {
            let user = User()
            user.uid = snapshot.key
            
                self.ref.child("users").child(user.uid).observe(.value, with: { (snapshot2) in
                let dictionary = snapshot2.value as! [String: AnyObject]
                if ((dictionary["name"] as? String) != nil) {
                    user.name = (dictionary["name"] as? String)!
                } else {
                    user.name = "Placeholder"
                }
                if ((dictionary["userVideoURL"] as? String) != nil) {
                    
                    user.videoURL = dictionary["userVideoURL"] as! String
                }
                
                if ((dictionary["Occupation"] as? String) != nil) {
                    user.occupation = (dictionary["Occupation"] as? String)!
                    user.companyLabel = (dictionary["Occupation"] as? String)!
                    if (user.occupation == "Employer" && dictionary["Company"] as? String != nil) {
                        user.companyLabel = (dictionary["Company"] as? String)!
                    } else if (user.occupation == "Student" && dictionary["Unversity"] as? String != nil) {
                        user.companyLabel = (dictionary["Unversity"] as? String)!
                    }
                }
                
                if (dictionary["thumbnailImageURL"] as! String?) != nil {
                    user.thumbnailImageURL = (dictionary["thumbnailImageURL"] as! String?)!
                    
                    
                    
                }
                if ((dictionary["profileImageURL"] as! String?) != nil) {
                    user.profileImageURL = (dictionary["profileImageURL"] as! String?)!
                } else {
                    user.profileImageURL = "NIL"
                }
                
                
                self.userList.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }

            
                })
            
            }
            
        })
        
    }

    
    
    func fetchUsers() {
        self.userList.removeAll()
        var checkBool = true
        var dict3 = [String: AnyObject]()
        var keys = [String]()
        ref.child("users").observe(.value, with: {  (snapshot) in
            if (snapshot.value as? [String: AnyObject]  != nil) {
            let topDict = snapshot.value as! [String: AnyObject]
                
                let dict2 = topDict[self.uid!]
            if (dict2?["Archived"] as? [String: AnyObject] != nil) {
                    dict3 = dict2?["Archived"] as! [String: AnyObject]
                    
                    //Extract all the keys
                    keys = dict3.flatMap(){ $0.0 as? String }
                    
                   
                    
                }
                if (dict2!["Domains"] as? [String: AnyObject] != nil) {
                    let dict4 = dict2!["Domains"] as! [String: AnyObject]
                    let keyVals = dict4.flatMap(){ $0.0 as? String}
                    
                    self.personalDomains = keyVals
                }

            
            for i in 0..<topDict.count {
                if (topDict[topDict.index(topDict.startIndex, offsetBy: i)].value as? [String: AnyObject] != nil) {
                let dictionary = topDict[topDict.index(topDict.startIndex, offsetBy: i)].value as! [String: AnyObject]
                    var userDomains = [String]()
                    var matchedDomains = [String]()
                    if (dictionary["Domains"] as? [String: AnyObject] != nil)  {
                        let dictVal = dictionary["Domains"] as! [String: AnyObject]
                        let keys = dictVal.flatMap(){ $0.0 as? String }
                        userDomains = keys
                    }
                    if ((dictionary["Occupation"] as? String) != globalFeedString) {
                        self.recruiterOrAll = false
                    } else {
                        self.recruiterOrAll = true
                    }
                    if (self.recruiterOrAll) {
                        if (self.passedInInt == nil) {
                            self.passedInInt = 6
                        }
                        switch self.passedInInt! {
                        case 0:
                            if (dictionary["Major"] as? String != self.passedInString!) {
                                checkBool = false
                                break
                            }
                            checkBool = true
                            break
                        case 1:
                            if (dictionary["Unversity"] as? String != self.passedInString!) {
                                checkBool = false
                                
                                break
                            }
                            checkBool = true
                            break
                            
                            
                        case 2:
                            if (dictionary["Company"] as? String != self.passedInString!) {
                                checkBool = false
                                
                                break
                            }
                            checkBool = true
                            break
                            
                            
                        case 3:
                            if (topDict[topDict.index(topDict.startIndex, offsetBy: i)].key != self.passedInString!) {
                                checkBool = false
                                break
                            }
                            checkBool = true
                            break
                        case 4:
                            if (dictionary["Skill 1"] as? String != self.passedInString! && dictionary["Skill 2"] as? String != self.passedInString! && dictionary["Skill 3"] as? String != self.passedInString! && dictionary["Skill 4"] as? String != self.passedInString) {
                                checkBool = false
                                break
                                
                            }
                            checkBool = true
                            break
                        case 5:
                            
                            if (self.passedMajorList.count != 0) {
                                if (dictionary["Major"] as? String != nil) {
                                if (self.passedMajorList.contains((dictionary["Major"] as? String)!)) {
                                    checkBool = true
                                } else {
                                    checkBool = false
                                    break
                                }
                                } else {
                                    checkBool = false
                                    break
                                }
                            }
                            if (self.passedUniversityList.count != 0) {
                                if (dictionary["Unversity"] as? String != nil) {
                                if (!self.passedUniversityList.contains((dictionary["Unversity"] as? String)!)) {
                                    checkBool = false
                                    break
                                }
                                } else {
                                    checkBool = false
                                    break
                                    
                                }
                            }
                            if (self.passedSkillsList.count != 0) {
                                if (dictionary["Skill 1"] as? String != nil && (self.passedSkillsList.contains(dictionary["Skill 1"] as! String))) {
                                    checkBool = true
                                    break
                                    } else if (dictionary["Skill 2"] as? String != nil && (self.passedSkillsList.contains(dictionary["Skill 2"] as! String))) {
                                    checkBool = true
                                    break
                                    } else if (dictionary["Skill 3"] as? String != nil && (self.passedSkillsList.contains(dictionary["Skill 3"] as! String))) {
                                    checkBool = true
                                    break
                                    } else if (dictionary["Skill 4"] as? String != nil && (self.passedSkillsList.contains(dictionary["Skill 4"] as! String))) {
                                    checkBool = true
                                    break
                                    }
                                checkBool = false
                                break
                            }
                            
                        default:
                            checkBool = false
                            if (self.personalDomains.count == 0) {
                                checkBool = true
                            }
                            for curString in 0..<userDomains.count {
                                if self.personalDomains.contains(userDomains[curString]) {
                                    matchedDomains.append(userDomains[curString])
                                    checkBool = true
                                }
                            }
                            
                            break
                            
                        }
                        if (checkBool) {
                            let user = User()
                            user.uid = topDict[topDict.index(topDict.startIndex, offsetBy: i)].key
                            user.domains = userDomains
                            user.matchedDomains = matchedDomains
                            if (!keys.contains(user.uid)) {
                            if ((dictionary["name"] as? String) != nil) {
                                user.name = (dictionary["name"] as? String)!
                            } else {
                                user.name = "Placeholder"
                            }
                            if ((dictionary["userVideoURL"] as? String) != nil) {
                                
                                user.videoURL = dictionary["userVideoURL"] as! String
                            }
                            
                            if ((dictionary["Occupation"] as? String) != nil) {
                                user.occupation = (dictionary["Occupation"] as? String)!
                                user.companyLabel = (dictionary["Occupation"] as? String)!
                                if (user.occupation == "Employer" && dictionary["Company"] as? String != nil) {
                                    user.companyLabel = (dictionary["Company"] as? String)!
                                } else if (user.occupation == "Student" && dictionary["Unversity"] as? String != nil) {
                                    user.companyLabel = (dictionary["Unversity"] as? String)!
                                }
                            }
                            
                            if (dictionary["thumbnailImageURL"] as! String?) != nil {
                                user.thumbnailImageURL = (dictionary["thumbnailImageURL"] as! String?)!
                                
                                
                                
                            }
                            if ((dictionary["profileImageURL"] as! String?) != nil) {
                                user.profileImageURL = (dictionary["profileImageURL"] as! String?)!
                            } else {
                                user.profileImageURL = "NIL"
                            }
                            
                            if ((dictionary["logoImageURL"] as! String?) != nil) {
                                user.logoImageURL = (dictionary["logoImageURL"] as! String?)!
                                    
                            } else {
                                user.logoImageURL = "NIL"
                            }
                                
                                if ((dictionary["Company Mission"] as! String?) != nil) {
                                    user.companyDesc = (dictionary["Company Mission"] as! String)
                                } else {
                                    user.companyDesc = "No Description Available"
                                }
                                
                            
                            
                            self.userList.append(user)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                            }
                            
                            }
                        }
                    }
                    }
                    
                }
            }
            
        })
        refreshControl.endRefreshing()
        
    }
    
    
    
    func createMastHead() {
        
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: (107/255.0), green: (202/255.0), blue: (253/255.0), alpha: 1 )
        let bottomColor = UIColor(red: (105/255.0), green: (160/255.0), blue: (252/255.0), alpha: 0.7 )
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)
        view.layer.addSublayer(gradientLayer)
        
        let titleLabel = UILabel()
        self.view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 30)
        titleLabel.text = "NXTPitch"
        titleLabel.textColor = UIColor.white
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10).isActive = true
        
        let searchIcon = UIButton()
        self.view.addSubview(searchIcon)
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        searchIcon.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        searchIcon.addTarget(self, action: #selector(handleMoveToSearch), for: .touchUpInside)
        let searchImage = UIImage(named: "searchIcon")
        let searchTinted = searchImage?.withRenderingMode(.alwaysTemplate)
        searchIcon.setBackgroundImage(searchTinted, for: .normal)
        searchIcon.tintColor = UIColor.white
        
        searchIcon.centerXAnchor.constraint(equalTo: self.view.leftAnchor, constant: (self.view.bounds.width / 2 - titleLabel.intrinsicContentSize.width / 2) / 2).isActive = true
        searchIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        let notificationIcon = UIButton()
        self.view.addSubview(notificationIcon)
        notificationIcon.translatesAutoresizingMaskIntoConstraints = false
        notificationIcon.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        notificationIcon.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        notificationIcon.centerXAnchor.constraint(equalTo: self.view.rightAnchor, constant: (titleLabel.intrinsicContentSize.width / 2 - self.view.bounds.width / 2) / 2).isActive = true
        notificationIcon.widthAnchor.constraint(equalToConstant: 32).isActive = true
        notificationIcon.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)
        let notificationImage = UIImage(named: "notificationIcon")
        let notificationTinted = notificationImage?.withRenderingMode(.alwaysTemplate)
        notificationIcon.setBackgroundImage(notificationTinted, for: .normal)
        notificationIcon.tintColor = UIColor.white
        
        
        let containerView = UIView()
        self.view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        containerView.backgroundColor = UIColor.white
        containerView.layer.borderColor = UIColor.darkGray.cgColor
        containerView.layer.borderWidth = 0.5
        
        
        
        let width = self.view.bounds.width / 8
        let feedIcon = UIButton()
        self.view.addSubview(feedIcon)
        feedIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        feedIcon.translatesAutoresizingMaskIntoConstraints = false
        feedIcon.widthAnchor.constraint(equalToConstant: width / 1.5).isActive = true
        feedIcon.centerXAnchor.constraint(equalTo: self.view.leftAnchor, constant: width).isActive = true
        feedIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        let feedImage = UIImage(named: "HomeIcon")
        let feedTinted = feedImage?.withRenderingMode(.alwaysTemplate)
        feedIcon.setBackgroundImage(feedTinted, for: .normal)
        feedIcon.tintColor = UIColor(red: 100/255, green: 149/255, blue: 245/255, alpha: 1)

        
        let calendarIcon = UIButton()
        self.view.addSubview(calendarIcon)
        calendarIcon.translatesAutoresizingMaskIntoConstraints = false
        calendarIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        calendarIcon.widthAnchor.constraint(equalToConstant: width / 1.5).isActive = true
        calendarIcon.centerXAnchor.constraint(equalTo: self.view.leftAnchor, constant: 3 * width).isActive = true
        calendarIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        calendarIcon.setBackgroundImage(UIImage(named: "CalendarIcon"), for: .normal)
        calendarIcon.addTarget(self, action: #selector(handleMoveToRecruiter), for: .touchUpInside)
        let messageIcon = UIButton()
        self.view.addSubview(messageIcon)
        messageIcon.translatesAutoresizingMaskIntoConstraints = false
        messageIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        messageIcon.widthAnchor.constraint(equalToConstant: width / 1.5).isActive = true
        messageIcon.centerXAnchor.constraint(equalTo: self.view.rightAnchor, constant: -3 * width).isActive = true
        messageIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageIcon.setBackgroundImage(UIImage(named: "MessageIcon-1"), for: .normal)
        messageIcon.addTarget(self, action: #selector(handleMoveToMessages), for: .touchUpInside)
        
        let profileIcon = UIButton()
        self.view.addSubview(profileIcon)
        profileIcon.translatesAutoresizingMaskIntoConstraints = false
        profileIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        profileIcon.widthAnchor.constraint(equalToConstant: width / 1.5).isActive = true
        profileIcon.centerXAnchor.constraint(equalTo: self.view.rightAnchor, constant: -width).isActive = true
        profileIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        let profileIconImage = UIImage(named: "ProfileImage")
        profileIcon.setBackgroundImage(profileIconImage, for: .normal)
        profileIcon.addTarget(self, action: #selector(moveToProfile), for: .touchUpInside)
        
        
        
        
        
        
    }

    
    func handleSearchForOccupation(sender: GenericCellButton) {
        
        
        
        if (sender.user.companyLabel == "Employer" || sender.user.companyLabel == "Student") {
            let alert = UIAlertController(title: "Cannot Search", message: "User has not provided company or university", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        } else {
            let segueController = FeedController(nibName: nil, bundle: nil)
            segueController.passedInString = sender.user.companyLabel
            segueController.searchBool = true
            if (sender.user.occupation == "Employer") {
               segueController.passedInInt = 2
                
            } else {
               segueController.passedInInt = 1
            }
            present(segueController, animated: true, completion: nil)
        }
        
        
        
    }

    
    
    //ViewDid Load 
    
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: (0/255.0), green: (204/255.0), blue: (255/255.0), alpha: 1)
        
        
        getProfileImageURL()
        
        fetchMessengerUsers()
        
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with:
            { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]  {
                    if (dictionary["name"] as? String != nil) {
                    globalCurrentName = (dictionary["name"] as? String)!

                    }
                    if ((dictionary["Occupation"] as? String) == "Employer") {
                        globalFeedString = "Student"
                        
                    }
                    else {
                        globalFeedString = "Employer"
                    }
                    if (dictionary["HelpViews"] != nil) {
                    self.dict2 = (dictionary["HelpViews"] as? [String: AnyObject])!
                    if (self.dict2["FirstTimeSignUp"] as? String != nil) {
                        if (self.dict2["FirstTimeSignUp"] as? String == "true") {
                        self.feed()
                            
                        }
                    }
                    if (self.dict2["FirstTimeConnect"] as? String != nil) {
                        if (self.dict2["FirstTimeConnect"] as? String == "true") {
                            firstGreenArrowBool = true
                        } else {
                            firstGreenArrowBool = false
                        }
                    }
                    if (self.dict2["FirstTimeReject"] as? String != nil) {
                        if (self.dict2["FirstTimeReject"] as? String == "true") {
                            firstRedCrossBool = true
                        }
                    } else {
                        firstRedCrossBool = false

                    }
                        if (self.dict2["FirstTimeCalendar"] as? String != nil) {
                            if (self.dict2["FirstTimeCalendar"] as? String == "true") {
                                firstTimeCalendar = true
                            }
                        } else {
                            firstTimeCalendar = false
                        }
                        if (self.dict2["FirstTimeSearch"] as? String != nil) {
                            if (self.dict2["FirstTimeSearch"] as? String == "true") {
                                firstTimeSearch = true
                            }
                        } else {
                            firstTimeSearch = false
                        }
                    
                }
                }
        })
        self.view.addSubview(tableView)
        
        
        
        //Refresh and fetch more users. 
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(fetchUsers), for: UIControlEvents.valueChanged)
        
        if (isArchived) {
            fetchArchive()
        } else if (isRequests) {
            fetchRequests()
        } else {
        fetchUsers()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
        tableView.separatorStyle = .none
        
        
        
        
        let ProfileButton = UIButton()
        let MessageButton = UIButton()
        let LogoutButton = UIButton()
       
        let profileText = UILabel()
        let messageText = UILabel()
        let logoutText = UILabel()
        
        self.view.addSubview(ProfileButton)
        self.view.addSubview(MessageButton)
        self.view.addSubview(LogoutButton)
        self.view.addSubview(profileText)
        self.view.addSubview(messageText)
        self.view.addSubview(logoutText)
        
        
        MessageButton.setImage(UIImage(named: "Chat"), for: .normal)
        LogoutButton.setImage(UIImage(named: "images"), for: .normal)
        ProfileButton.setImage(UIImage(named: "ProfileImage"), for: .normal)
        
        MessageButton.setTitle("Chat", for: .normal)
        LogoutButton.setTitle("Logout", for: .normal)
        ProfileButton.setTitle("Profile", for: .normal)
        
        
        LogoutButton.translatesAutoresizingMaskIntoConstraints = false
        LogoutButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        LogoutButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        LogoutButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        LogoutButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -13).isActive = true
        LogoutButton.tintColor = UIColor.clear
        LogoutButton.contentEdgeInsets = UIEdgeInsetsMake( 10, 10, 10, 10)
        LogoutButton.transform = LogoutButton.transform.rotated(by: CGFloat(M_PI))
        LogoutButton.addTarget(self, action: #selector(handleMoveToRecruiter), for: .touchUpInside)
        
        ProfileButton.translatesAutoresizingMaskIntoConstraints = false
        ProfileButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ProfileButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        ProfileButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        ProfileButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        ProfileButton.tintColor = UIColor.clear
        ProfileButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        ProfileButton.addTarget(self, action: #selector(moveToProfile), for: .touchUpInside)
        
        profileText.translatesAutoresizingMaskIntoConstraints = false
        profileText.text = "Profile"
        profileText.font = UIFont(name: "Didot", size: 10)
        profileText.textColor = UIColor.black
        profileText.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -7).isActive = true
        profileText.widthAnchor.constraint(equalTo: ProfileButton.widthAnchor).isActive = true
        profileText.heightAnchor.constraint(equalToConstant: 10).isActive = true
        profileText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 25).isActive = true
        
      
        MessageButton.translatesAutoresizingMaskIntoConstraints = false
        MessageButton.bottomAnchor.constraint(equalTo: ProfileButton.bottomAnchor).isActive = true
        MessageButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        MessageButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        MessageButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -35).isActive = true
        
        MessageButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        
        createMastHead()

        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        
        view.addGestureRecognizer(tap)
      
    }
    class Cell: UITableViewCell {
        var cellButton = UIButton()
        var cellLabel = UILabel()
        
    }
    
    func handleGiveAdvice(sender: GenericCellButton) {
        
    }
    
    
    
    
    //-------------------------------------------------------------------------------------------------------
    
      

    
    //SET UP YOUR TABLE VIEW 
    
    
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (userList.count == 0) {
            return 1
        }
        return userList.count
    }
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!recruiterOrAll) {
        var cell = FeedTableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        if (userList.count == 0) {
            tableView.backgroundColor = UIColor.lightGray
            cell.backgroundColor = UIColor.lightGray
            let errorLabel = UILabel()
            cell.addSubview(errorLabel)
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            errorLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            errorLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            errorLabel.text = "No Users"
            errorLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 24)
            errorLabel.textColor = UIColor.darkGray
        } else {
        let border = CALayer()
        let borderWidth = CGFloat(5.0)
        border.borderColor = UIColor.lightGray.cgColor
        let height = (view.frame.size.height - 120)
        border.frame = CGRect(x: 0, y: height - borderWidth, width:  view.frame.size.width , height: height)
        border.borderWidth = borderWidth
        cell.layer.addSublayer(border)
        
       let view2 = UIView()
            cell.addSubview(view2)

        cell.selectionStyle = .none
        let cellWidth = cell.bounds.width
        cell.layer.masksToBounds = true
        let curUser = userList[indexPath.row] as User
        cell.activityIndicator = UIActivityIndicatorView()
        cell.object = curUser
        let cellLabel = GenericCellButton()
        cell.addSubview(cellLabel)
        let width  = self.view.bounds.width - 40
        let cellButton = GenericCellButton()
        cell.addSubview(cellButton)
        let cellNoButton = NoButton()
        cell.addSubview(cellNoButton)
        cell.addSubview((cell.object?.imageView)!)
        let cellCheckButton = GenericCellButton()
        cell.addSubview(cellCheckButton)
        
        
        let cellImageView = UIImageView()
        cell.addSubview(cellImageView)
        cellImageView.loadImageUsingCacheWithURLString(urlString: curUser.profileImageURL)
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 30).isActive = true
        cellImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        cellImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        cellImageView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30).isActive = true
        cellImageView.layer.borderWidth = 1
        cellImageView.layer.borderColor = UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1).cgColor
        cellImageView.layer.cornerRadius = 17.5
        cellImageView.layer.masksToBounds = true
        cellNoButton.value = indexPath.row
        cellNoButton.userID = curUser.uid
        cellNoButton.setBackgroundImage(UIImage(named: "RedCross"), for: .normal)
        cellNoButton.addTarget(self, action: #selector(handleNoButton), for: .touchUpInside)
        cellNoButton.translatesAutoresizingMaskIntoConstraints = false
        cellNoButton.bottomAnchor.constraint(equalTo: cellButton.bottomAnchor).isActive = true
        cellNoButton.widthAnchor.constraint(equalToConstant: width / 8).isActive = true
        cellNoButton.heightAnchor.constraint(equalToConstant: width / 8).isActive = true
        cellNoButton.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: width / 6).isActive = true
        cellNoButton.isUserInteractionEnabled = true

        
        
        cellNoButton.backgroundColor = UIColor.white
        cellNoButton.setTitleColor(UIColor.black, for: .normal)
        
        cellCheckButton.user = curUser
        
        cellCheckButton.translatesAutoresizingMaskIntoConstraints = false
        cellCheckButton.setBackgroundImage(UIImage(named: "playIcon"), for: .normal)
        cellCheckButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -15).isActive = true
        cellCheckButton.widthAnchor.constraint(equalToConstant: width / 4).isActive = true
        cellCheckButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cellCheckButton.isUserInteractionEnabled = true
        cellCheckButton.setTitleColor(UIColor.black, for: .normal)
        cellCheckButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        cellCheckButton.addTarget(self, action: #selector(handleVideo), for: .touchUpInside)
        cellCheckButton.alpha = 0.3
       

        cellButton.backgroundColor = UIColor.white
        cellButton.translatesAutoresizingMaskIntoConstraints = false
        cellButton.setBackgroundImage(UIImage(named: "GreenArrow"), for: .normal)
        cellButton.bottomAnchor.constraint(equalTo: cellCheckButton.bottomAnchor, constant: -15).isActive = true
        cellButton.heightAnchor.constraint(equalTo: cellNoButton.heightAnchor, constant: 1.2).isActive = true
        cellButton.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -1 * width / 6 ).isActive = true
        cellButton.isUserInteractionEnabled = true
        cellButton.user = curUser
        cellButton.addTarget(self, action: #selector(handleYesButton), for: .touchUpInside)
        cellButton.widthAnchor.constraint(equalTo: cellNoButton.widthAnchor).isActive = true
        view2.backgroundColor = UIColor.black
        view2.translatesAutoresizingMaskIntoConstraints = false
        view2.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        view2.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3.5).isActive = true
        view2.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        view2.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: -50).isActive = true
        cell.object?.imageView?.loadImageUsingCacheWithURLString(urlString: curUser.thumbnailImageURL)
            if (cell.object?.imageView?.image?.size.height != nil && cell.object?.imageView?.image?.size.width != nil) {
                if (cell.object?.imageView?.image?.size.height.isLess(than: (cell.object?.imageView?.image?.size.width)!))! {
                    cell.object?.imageView?.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
                } else {
                    cell.object?.imageView?.widthAnchor.constraint(equalToConstant: cell.bounds.width / 3 ).isActive = true
                }
            } else {
                cell.object?.imageView?.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
            }
        cell.object?.imageView?.translatesAutoresizingMaskIntoConstraints = false
        cell.object?.imageView?.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3.5).isActive = true
        cell.object?.imageView?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.object?.imageView?.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: -50).isActive = true
        
        
        

        cell.addSubview(cell.activityIndicator)
        cell.activityIndicator.color = UIColor.gray
        cell.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        cell.activityIndicator.leftAnchor.constraint(equalTo: (cell.object?.imageView?.leftAnchor)!).isActive = true
        cell.activityIndicator.rightAnchor.constraint(equalTo: (cell.object?.imageView?.rightAnchor)!).isActive = true
        cell.activityIndicator.topAnchor.constraint(equalTo: (cell.object?.imageView?.topAnchor)!).isActive = true
        cell.activityIndicator.bottomAnchor.constraint(equalTo: (cell.object?.imageView?.bottomAnchor)!).isActive = true
        
       
       
        


        
        let cellLabelOccupy = GenericCellButton()
        cell.addSubview(cellLabelOccupy)
        cellLabelOccupy.translatesAutoresizingMaskIntoConstraints = false
        cellLabelOccupy.setTitle(curUser.companyLabel, for: .normal)
        cellLabelOccupy.leftAnchor.constraint(equalTo: cellImageView.rightAnchor, constant: 5).isActive = true
        cellLabelOccupy.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: 10).isActive = true
        cellLabelOccupy.setTitleColor(UIColor.black, for: .normal)
        cellLabelOccupy.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 20)
        cellLabelOccupy.user = curUser
        cellLabelOccupy.addTarget(self, action: #selector(handleSearchForOccupation), for: .touchUpInside)
        
        cellLabel.translatesAutoresizingMaskIntoConstraints = false

        cellLabel.leftAnchor.constraint(equalTo: cellLabelOccupy.leftAnchor).isActive = true
        cellLabel.bottomAnchor.constraint(equalTo: cellImageView.topAnchor, constant: 20).isActive = true
        
       
        cellLabel.setTitle(curUser.name, for: .normal)
        cellLabel.setTitleColor(UIColor.black, for: .normal)
        cellLabel.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)

        cellLabel.user = curUser
        cellLabel.addTarget(self, action: #selector(handleScreenshot), for: .touchUpInside)
        
        
        
        let messageButton = GenericCellButton()
        cell.addSubview(messageButton)
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        messageButton.setBackgroundImage(UIImage(named: "informationIcon"), for: .normal)
        messageButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 20).isActive = true
        messageButton.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
        messageButton.addTarget(self, action: #selector(handleGiveAdvice), for: .touchUpInside)
        if (globalFeedString == "Employer") {
            messageButton.isHidden = true
        }
        
            
        let domainView1 = UIView()
        let domainView2 = UIView()
        let domainView3 = UIView()
        let domainLabel1 = UILabel()
        let domainLabel2 = UILabel()
        let domainLabel3 = UILabel()
        
        cell.addSubview(domainView1)
        cell.addSubview(domainView2)
        cell.addSubview(domainView3)
            
        domainView1.addSubview(domainLabel1)
        domainView2.addSubview(domainLabel2)
        domainView3.addSubview(domainLabel3)
            
            domainView1.translatesAutoresizingMaskIntoConstraints = false
            
            domainView1.leftAnchor.constraint(equalTo: cellImageView.leftAnchor).isActive = true
            domainView1.topAnchor.constraint(equalTo: (cell.object?.imageView?.bottomAnchor)!, constant: 10).isActive = true
            domainView1.rightAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            domainView1.heightAnchor.constraint(equalToConstant: 30).isActive = true
            domainView1.backgroundColor = blueSearchBarColor
            domainView1.layer.cornerRadius = 15
            domainView1.layer.masksToBounds = true
            
            
            if (curUser.matchedDomains.count > 0) {
                domainLabel1.text = curUser.matchedDomains[0]
            }
            else if (curUser.domains.count > 0) {
            domainLabel1.text = curUser.domains[0]
            }
            domainLabel1.textColor = UIColor.white
            domainLabel1.translatesAutoresizingMaskIntoConstraints = false
            domainLabel1.centerXAnchor.constraint(equalTo: domainView1.centerXAnchor).isActive = true
            domainLabel1.centerYAnchor.constraint(equalTo: domainView1.centerYAnchor).isActive = true
            domainLabel1.widthAnchor.constraint(equalTo: domainView1.widthAnchor, multiplier: 0.9).isActive = true
            domainLabel1.heightAnchor.constraint(equalTo: domainView1.heightAnchor, multiplier: 0.9).isActive = true
            
            domainView2.translatesAutoresizingMaskIntoConstraints = false
            domainView2.topAnchor.constraint(equalTo: domainView1.bottomAnchor, constant: 10).isActive = true
            domainView2.leftAnchor.constraint(equalTo: domainView1.leftAnchor).isActive = true
            domainView2.rightAnchor.constraint(equalTo: domainView1.rightAnchor).isActive = true
            domainView2.heightAnchor.constraint(equalTo: domainView1.heightAnchor).isActive = true
            domainView2.backgroundColor = blueSearchBarColor
            domainView2.layer.cornerRadius = 15
            domainView2.layer.masksToBounds = true
            
            if (curUser.matchedDomains.count > 1) {
                domainLabel2.text = curUser.matchedDomains[1]
            }
            else if (curUser.domains.count > 1) {
            domainLabel2.text = curUser.domains[1]
            }
            domainLabel2.translatesAutoresizingMaskIntoConstraints = false
            domainLabel2.textColor = UIColor.white
            domainLabel2.centerYAnchor.constraint(equalTo: domainView2.centerYAnchor).isActive = true
            domainLabel2.centerXAnchor.constraint(equalTo: domainView2.centerXAnchor).isActive = true
            domainLabel2.widthAnchor.constraint(equalTo: domainView2.widthAnchor, multiplier: 0.9).isActive = true
            domainLabel2.heightAnchor.constraint(equalTo: domainView2.heightAnchor, multiplier: 0.9).isActive = true
            
            
            domainView3.translatesAutoresizingMaskIntoConstraints = false
            domainView3.topAnchor.constraint(equalTo: domainView2.bottomAnchor, constant: 10).isActive = true
            domainView3.leftAnchor.constraint(equalTo: domainView1.leftAnchor).isActive = true
            domainView3.rightAnchor.constraint(equalTo: domainView1.rightAnchor).isActive = true
            domainView3.heightAnchor.constraint(equalTo: domainView1.heightAnchor).isActive = true
            domainView3.backgroundColor = blueSearchBarColor
            domainView3.layer.cornerRadius = 15
            domainView3.layer.masksToBounds = true
            
            if (curUser.matchedDomains.count > 2) {
                domainLabel3.text = curUser.matchedDomains[2]
            }
            else if (curUser.domains.count > 2) {
            domainLabel3.text = curUser.domains[2]
            }
            domainLabel3.translatesAutoresizingMaskIntoConstraints = false
            domainLabel3.textColor = UIColor.white
            domainLabel3.centerYAnchor.constraint(equalTo: domainView3.centerYAnchor).isActive = true
            domainLabel3.centerXAnchor.constraint(equalTo: domainView3.centerXAnchor).isActive = true
            domainLabel3.widthAnchor.constraint(equalTo: domainView3.widthAnchor, multiplier: 0.9).isActive = true
            domainLabel3.heightAnchor.constraint(equalTo: domainView3.heightAnchor, multiplier: 0.9).isActive = true
            
            
            
        
        }
       
        return cell
        } else {
            let cell = RecruiterFeedTableViewCell(style: .subtitle, reuseIdentifier: cellID, pWidth: Int(self.view.bounds.width), pHeight: Int(self.view.bounds.height * 0.4))
            if (userList.count == 0) {
                tableView.backgroundColor = UIColor.lightGray
                cell.backgroundColor = UIColor.lightGray
                let errorLabel = UILabel()
                cell.addSubview(errorLabel)
                errorLabel.translatesAutoresizingMaskIntoConstraints = false
                errorLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                errorLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                errorLabel.text = "No Users"
                errorLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 24)
                errorLabel.textColor = UIColor.darkGray
            } else {
                let border = CALayer()
                let borderWidth = CGFloat(5.0)
                border.borderColor = UIColor.lightGray.cgColor
                let height = (view.frame.size.height - 120)
                border.frame = CGRect(x: 0, y: height - borderWidth, width:  view.frame.size.width , height: height)
                border.borderWidth = borderWidth
                cell.layer.addSublayer(border)
                
                let view2 = UIView()
                cell.addSubview(view2)
                
                cell.selectionStyle = .none
                let cellWidth = cell.bounds.width
                cell.layer.masksToBounds = true
                let curUser = userList[indexPath.row] as User
                cell.activityIndicator = UIActivityIndicatorView()
                cell.object = curUser
                let cellLabel = GenericCellButton()
                cell.addSubview(cellLabel)
                let width  = self.view.bounds.width - 40
                let cellButton = GenericCellButton()
                cell.addSubview(cellButton)
                let cellNoButton = NoButton()
                cell.addSubview(cellNoButton)
                let cellCheckButton = GenericCellButton()
                cell.object?.imageView?.loadImageUsingCacheWithURLString(urlString: curUser.logoImageURL)

                cell.addSubview(cellCheckButton)
                var cellImageView = UIImageView()
                cell.addSubview(cellImageView)
                cellImageView.loadImageUsingCacheWithURLString(urlString: curUser.profileImageURL)
                cellImageView.translatesAutoresizingMaskIntoConstraints = false
                cellImageView.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 30).isActive = true
                cellImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
                cellImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
                cellImageView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30).isActive = true
                cellImageView.layer.borderWidth = 1
                cellImageView.layer.borderColor = UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1).cgColor
                cellImageView.layer.cornerRadius = 17.5
                cellImageView.layer.masksToBounds = true
                cellNoButton.value = indexPath.row
                cellNoButton.userID = curUser.uid
                cellNoButton.setBackgroundImage(UIImage(named: "RedCross"), for: .normal)
                cellNoButton.addTarget(self, action: #selector(handleNoButton), for: .touchUpInside)
                cellNoButton.translatesAutoresizingMaskIntoConstraints = false
                cellNoButton.bottomAnchor.constraint(equalTo: cellButton.bottomAnchor).isActive = true
                cellNoButton.widthAnchor.constraint(equalToConstant: width / 8).isActive = true
                cellNoButton.heightAnchor.constraint(equalToConstant: width / 8).isActive = true
                cellNoButton.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: width / 6).isActive = true
                cellNoButton.isUserInteractionEnabled = true
                
                
                
                cellNoButton.backgroundColor = UIColor.white
                cellNoButton.setTitleColor(UIColor.black, for: .normal)
                
                cellCheckButton.user = curUser
                
                cellCheckButton.translatesAutoresizingMaskIntoConstraints = false
                cellCheckButton.setBackgroundImage(UIImage(named: "playIcon"), for: .normal)
                cellCheckButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -15).isActive = true
                cellCheckButton.widthAnchor.constraint(equalToConstant: width / 4).isActive = true
                cellCheckButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                cellCheckButton.isUserInteractionEnabled = true
                cellCheckButton.setTitleColor(UIColor.black, for: .normal)
                cellCheckButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
                cellCheckButton.addTarget(self, action: #selector(handleVideo), for: .touchUpInside)
                cellCheckButton.alpha = 0.3
                
                
                cellButton.backgroundColor = UIColor.white
                cellButton.translatesAutoresizingMaskIntoConstraints = false
                cellButton.setBackgroundImage(UIImage(named: "GreenArrow"), for: .normal)
                cellButton.bottomAnchor.constraint(equalTo: cellCheckButton.bottomAnchor, constant: -15).isActive = true
                cellButton.heightAnchor.constraint(equalTo: cellNoButton.heightAnchor, constant: 1.2).isActive = true
                cellButton.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -1 * width / 6 ).isActive = true
                cellButton.isUserInteractionEnabled = true
                cellButton.user = curUser
                cellButton.addTarget(self, action: #selector(handleYesButton), for: .touchUpInside)
                cellButton.widthAnchor.constraint(equalTo: cellNoButton.widthAnchor).isActive = true

                
                
                
                let cellLabelOccupy = GenericCellButton()
                cell.addSubview(cellLabelOccupy)
                cellLabelOccupy.translatesAutoresizingMaskIntoConstraints = false
                cellLabelOccupy.setTitle(curUser.companyLabel, for: .normal)
                cellLabelOccupy.leftAnchor.constraint(equalTo: cellImageView.rightAnchor, constant: 5).isActive = true
                cellLabelOccupy.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: 10).isActive = true
                cellLabelOccupy.setTitleColor(UIColor.black, for: .normal)
                cellLabelOccupy.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 20)
                cellLabelOccupy.user = curUser
                cellLabelOccupy.addTarget(self, action: #selector(handleSearchForOccupation), for: .touchUpInside)
                
                cellLabel.translatesAutoresizingMaskIntoConstraints = false
                
                cellLabel.leftAnchor.constraint(equalTo: cellLabelOccupy.leftAnchor).isActive = true
                cellLabel.bottomAnchor.constraint(equalTo: cellImageView.topAnchor, constant: 20).isActive = true
                
                
                cellLabel.setTitle(curUser.name, for: .normal)
                cellLabel.setTitleColor(UIColor.black, for: .normal)
                cellLabel.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
                
                cellLabel.user = curUser
                cellLabel.addTarget(self, action: #selector(handleScreenshot), for: .touchUpInside)
                
                
                
                let messageButton = GenericCellButton()
                cell.addSubview(messageButton)
                messageButton.translatesAutoresizingMaskIntoConstraints = false
                messageButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
                messageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
                messageButton.setBackgroundImage(UIImage(named: "informationIcon"), for: .normal)
                messageButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 20).isActive = true
                messageButton.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
                messageButton.addTarget(self, action: #selector(handleGiveAdvice), for: .touchUpInside)
                if (globalFeedString == "Employer") {
                    messageButton.isHidden = true
                }
                
                
                let domainView1 = UIView()
                let domainView2 = UIView()
                let domainView3 = UIView()
                let domainLabel1 = UILabel()
                let domainLabel2 = UILabel()
                let domainLabel3 = UILabel()
                
                cell.addSubview(domainView1)
                cell.addSubview(domainView2)
                cell.addSubview(domainView3)
                
                domainView1.addSubview(domainLabel1)
                domainView2.addSubview(domainLabel2)
                domainView3.addSubview(domainLabel3)
                
                domainView1.translatesAutoresizingMaskIntoConstraints = false
                
                domainView1.leftAnchor.constraint(equalTo: cellImageView.leftAnchor).isActive = true
                domainView1.bottomAnchor.constraint(equalTo: domainView2.topAnchor, constant: -10).isActive = true
                domainView1.rightAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                domainView1.heightAnchor.constraint(equalToConstant: 30).isActive = true
                domainView1.backgroundColor = blueSearchBarColor
                domainView1.layer.cornerRadius = 15
                domainView1.layer.masksToBounds = true
                
                
                if (curUser.matchedDomains.count > 0) {
                    domainLabel1.text = curUser.matchedDomains[0]
                }
                else if (curUser.domains.count > 0) {
                    domainLabel1.text = curUser.domains[0]
                }
                domainLabel1.textColor = UIColor.white
                domainLabel1.translatesAutoresizingMaskIntoConstraints = false
                domainLabel1.centerXAnchor.constraint(equalTo: domainView1.centerXAnchor).isActive = true
                domainLabel1.centerYAnchor.constraint(equalTo: domainView1.centerYAnchor).isActive = true
                domainLabel1.widthAnchor.constraint(equalTo: domainView1.widthAnchor, multiplier: 0.9).isActive = true
                domainLabel1.heightAnchor.constraint(equalTo: domainView1.heightAnchor, multiplier: 0.9).isActive = true
                
                domainView2.translatesAutoresizingMaskIntoConstraints = false
                domainView2.bottomAnchor.constraint(equalTo: domainView3.topAnchor, constant: -10).isActive = true
                domainView2.leftAnchor.constraint(equalTo: domainView1.leftAnchor).isActive = true
                domainView2.rightAnchor.constraint(equalTo: domainView1.rightAnchor).isActive = true
                domainView2.heightAnchor.constraint(equalTo: domainView1.heightAnchor).isActive = true
                domainView2.backgroundColor = blueSearchBarColor
                domainView2.layer.cornerRadius = 15
                domainView2.layer.masksToBounds = true
                
                if (curUser.matchedDomains.count > 1) {
                    domainLabel2.text = curUser.matchedDomains[1]
                }
                else if (curUser.domains.count > 1) {
                    domainLabel2.text = curUser.domains[1]
                }
                domainLabel2.translatesAutoresizingMaskIntoConstraints = false
                domainLabel2.textColor = UIColor.white
                domainLabel2.centerYAnchor.constraint(equalTo: domainView2.centerYAnchor).isActive = true
                domainLabel2.centerXAnchor.constraint(equalTo: domainView2.centerXAnchor).isActive = true
                domainLabel2.widthAnchor.constraint(equalTo: domainView2.widthAnchor, multiplier: 0.9).isActive = true
                domainLabel2.heightAnchor.constraint(equalTo: domainView2.heightAnchor, multiplier: 0.9).isActive = true
                
                
                domainView3.translatesAutoresizingMaskIntoConstraints = false
                domainView3.leftAnchor.constraint(equalTo: domainView1.leftAnchor).isActive = true
                domainView3.rightAnchor.constraint(equalTo: domainView1.rightAnchor).isActive = true
                domainView3.heightAnchor.constraint(equalTo: domainView1.heightAnchor).isActive = true
                domainView3.backgroundColor = blueSearchBarColor
                domainView3.layer.cornerRadius = 15
                domainView3.layer.masksToBounds = true
                domainView3.bottomAnchor.constraint(equalTo: cellNoButton.topAnchor, constant: -10).isActive = true
                if (curUser.matchedDomains.count > 2) {
                    domainLabel3.text = curUser.matchedDomains[2]
                }
                else if (curUser.domains.count > 2) {
                    domainLabel3.text = curUser.domains[2]
                }
                domainLabel3.translatesAutoresizingMaskIntoConstraints = false
                domainLabel3.textColor = UIColor.white
                domainLabel3.centerYAnchor.constraint(equalTo: domainView3.centerYAnchor).isActive = true
                domainLabel3.centerXAnchor.constraint(equalTo: domainView3.centerXAnchor).isActive = true
                domainLabel3.widthAnchor.constraint(equalTo: domainView3.widthAnchor, multiplier: 0.9).isActive = true
                domainLabel3.heightAnchor.constraint(equalTo: domainView3.heightAnchor, multiplier: 0.9).isActive = true
                
                cell.addSubview(cell.collectionView)
                cell.collectionView.translatesAutoresizingMaskIntoConstraints = false
                cell.collectionView.bottomAnchor.constraint(equalTo: domainView1.topAnchor, constant: -10).isActive = true
                cell.collectionView.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                cell.collectionView.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
                cell.collectionView.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 0.4).isActive = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = view.frame.size.height - 120
        
        return height
    }


}



