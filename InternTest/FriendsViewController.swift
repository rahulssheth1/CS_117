//
//  MessagesController.swift
//  InternTest
//
//  Created by Rahul Sheth on 2/15/17.
//  Copyright © 2017 Rahul Sheth. All rights reserved.
//

import UIKit
import Foundation
import Firebase


//This is where all of the people you can message show up. You're friends list per say. A table View with a view controller in the root view
class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating {
    var startHour : Int?
    var startMinute : Int?
    var endHour : Int?
    var endMinute : Int?
    var startDay : String? 
    var bottomView = UIView()
    //Initialization of variables.
    var tableView = UITableView()
    var bottomTableView = UITableView()
    let uid = FIRAuth.auth()?.currentUser?.uid
    var userList = [User]()
    let cellID = "cellID"
    var curName: String?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUserList = [User]()
    var acceptedUserList = [User]()
    //Logout button takes you to beginning
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            
        }
        let segueController = LandingPageViewController()
        present(segueController, animated: true, completion: nil)
    }
    
    class actionPress: UILongPressGestureRecognizer {
        var row = Int()
    }
    //Go back to the profile page
    func handlePrevious() {
        killSearch()
        let segueController = ProfilePageViewController()
        present(segueController, animated: true, completion: nil)
        
    }
    
    
    
    //Search
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchText(searchText: searchController.searchBar.text!)
    }
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    
    
    func filterSearchText (searchText: String, scope: String = "All") {
        filteredUserList = userList.filter { user in
            return user.name.lowercased().contains(searchText.lowercased())
        }
        
        
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchController.isActive == true {
            searchController.isActive = false
        }
    }
    //Fetch Current name
    
    func fetchName() {
        let ref = FIRDatabase.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            if (dictionary?["name"] != nil) {
                self.curName = dictionary?["name"] as! String?
            }
        })
    }
    
    func handleNotifications() {
        killSearch()
        let segueController = NotificationCenterViewController()
        present(segueController, animated: false, completion: nil)
    }
    //Go to search
    func handleMoveToSearch() {
        killSearch()
        let segueController = SearchViewController(nibName: nil, bundle: nil)
        segueController.previousController = MessagesController()
        present(segueController, animated: false, completion: nil)
    }
    func moveToProfile(sender: UIButton) {
        killSearch()
        let segueController = ProfilePageViewController()
        present(segueController, animated: false, completion: nil)
    }
    func handleMoveToFeed() {
        killSearch()
        let segueController = FeedController()
        present(segueController, animated: false, completion: nil)
        
    }
    func handleMoveToRecruiter() {
        killSearch()
        if (globalFeedString == "Student") {
            
            let segueController = CalendarViewController()
            present(segueController, animated: false, completion: nil)
        } else {
            let segueController = SetUpFreeTimeViewController()
            present(segueController, animated: false, completion: nil)
        }
        
    }
    
    
    func createBottomHead() {
        bottomView.backgroundColor = UIColor.white
        self.view.addSubview(bottomView)
        bottomView.topAnchor.constraint(equalTo: bottomTableView.bottomAnchor).isActive = true
        bottomView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        let button = UIButton()
        bottomView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -5).isActive = true
        button.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitle("Create", for: .normal)
        
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor(red: (0/255.0), green: (153/255.0), blue: (204/255.0), alpha: 1)
    }
    
    
   
    
    
    
    //What runs when the view pops up
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchName()
        
        fetchMessengerUsers()
        

        
        
        
        
        //Table View boiler plate code. Write this whenever you need a table View and have delegate and data source
        
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -400).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        self.view.addSubview(bottomTableView)
        bottomTableView.delegate = self
        bottomTableView.dataSource = self
        bottomTableView.translatesAutoresizingMaskIntoConstraints = false
        bottomTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        bottomTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        bottomTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bottomTableView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor).isActive = true
        createBottomHead()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func killSearch() {
        if (searchController.isActive == true) {
            searchController.isActive = false
        }
    }
    
    //Move to messages and make sure the back button works
    func HandleSendToMessages(sender: AnyObject? ) {
        killSearch()
        let time = NSNumber(value: (sender?.user.timeStamp)!)
        let updateValue = ["Last Message": sender!.user.lastMessage as AnyObject, "Sending Name": sender!.user.lastSender as AnyObject, "Read": "True" as AnyObject, "timeStamp": time] as [String : AnyObject]
        
        let ref3 = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("friends").child((sender!.user.uid)).child("lastMessage")
        let ref4 = FIRDatabase.database().reference().child("users").child((sender!.user.uid)).child("friends").child((FIRAuth.auth()?.currentUser?.uid)!).child("lastMessage")
        ref3.setValue(updateValue)
        ref4.setValue(updateValue)
        sender?.user.previousController = MessagesController()
        let segueController = ChatController(user: (sender?.user)! )
        present(segueController, animated: true, completion: nil)
        
    }
    //Cell button with user information to make sure we can put the name and profile picture
    class GenericCellButton: UIButton {
        var user = User()
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableView) {
        return userList.count + 1
        } else {
            return acceptedUserList.count + 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 75
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func handleSubmit() {
        
        
                let ref = FIRDatabase.database().reference().child("users").child(uid!).child("Personal Reminders").childByAutoId()
        let startHour_ = NSNumber(value: startHour!)
        let startMinute_ = NSNumber(value: startMinute!)
        let endHour_ = NSNumber(value: endHour!)
        let endMinute_ = NSNumber(value: endMinute!)
        
                let dayString = startDay
        
        var values = ["StartHour": startHour_, "StartMinute": startMinute_, "EndHour": endHour_, "EndMinute": endMinute_, "Day": NSString(string: dayString!)]
        var count = 0;
            for user in acceptedUserList {
                var cur_key = "User " + String(count)
                count = count + 1
                values[cur_key] = NSString(string: user.uid)
            }
        print(values, "This is the VALUES")
                ref.setValue(values)
        
        
                let segueController = SetUpFreeTimeViewController()
                present(segueController, animated: true, completion: nil)
    }
    

    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.tableView) {
            let user = userList[indexPath.row-1]
            userList.remove(at: indexPath.row-1)
            acceptedUserList.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.bottomTableView.reloadData()
            }

        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == self.tableView) {
        if (indexPath.row == 0) {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID2")
            let messagesLabel = UILabel()
            cell.addSubview(messagesLabel)
            messagesLabel.translatesAutoresizingMaskIntoConstraints = false
            messagesLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            messagesLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            messagesLabel.text = "Invite your friends!"
            messagesLabel.font = UIFont(name: "AppleSDGothicNeo", size: 20)
            cell.selectionStyle = .none
            return cell
        }  else {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
            let cellLabel = UILabel()
            let cellImageView = UIImageView()
            let cellButton = GenericCellButton()
            let lastMessage = UILabel()
            let timeStamp = UILabel()
            cell.selectionStyle = .none
            
            cell.addSubview(cellButton)
            cell.addSubview(cellLabel)
            cell.addSubview(cellImageView)
            cell.addSubview(lastMessage)
            cell.addSubview(timeStamp)
            
            //This is the profilePicture image view
            var list = [User]()
            if (searchController.isActive == true && searchController.searchBar.text != "") {
                list = filteredUserList
            } else {
                list = userList
            }
            if (list.count != 0) {
                
                
                cellImageView.translatesAutoresizingMaskIntoConstraints = false
                cellImageView.centerXAnchor.constraint(equalTo: cell.leftAnchor, constant: 40).isActive = true
                cellImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                cellImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                cellImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                
                cellImageView.image = list[indexPath.row - 1].imageView?.image
                cellImageView.layer.cornerRadius = 20
                cellImageView.layer.masksToBounds = true
                
                //This is the name of the user
                
                cellLabel.text = list[indexPath.row - 1].name
                cellLabel.translatesAutoresizingMaskIntoConstraints = false
                cellLabel.topAnchor.constraint(equalTo: cellImageView.topAnchor).isActive = true
                cellLabel.leftAnchor.constraint(equalTo: cellImageView.rightAnchor, constant: 10).isActive = true
                cellLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
                
            }
            
            return cell
            }
        } else {
            if (indexPath.row == 0 ) {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID2")
                let messagesLabel = UILabel()
                cell.addSubview(messagesLabel)
                messagesLabel.translatesAutoresizingMaskIntoConstraints = false
                messagesLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                messagesLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                messagesLabel.text = "Invited Friends!"
                messagesLabel.font = UIFont(name: "AppleSDGothicNeo", size: 20)
                cell.selectionStyle = .none
                return cell
            } else if (indexPath.row == 1) {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID2")
                let button = UIButton()
                cell.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                button.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                button.widthAnchor.constraint(equalToConstant: 100).isActive = true
                button.heightAnchor.constraint(equalToConstant: 50).isActive = true
                button.setTitle("Send Invite!", for: .normal)
                button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
                button.layer.cornerRadius = 5
                button.backgroundColor = UIColor(red: (0/255.0), green: (153/255.0), blue: (204/255.0), alpha: 1)
                cell.selectionStyle = .none
                return cell
            } else {
                
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.cellID)
                let cellLabel = UILabel()
                let cellImageView = UIImageView()
                let cellButton = GenericCellButton()
                let lastMessage = UILabel()
                let timeStamp = UILabel()
                cell.selectionStyle = .none
                
                cell.addSubview(cellButton)
                cell.addSubview(cellLabel)
                cell.addSubview(cellImageView)
                cell.addSubview(lastMessage)
                cell.addSubview(timeStamp)
                
                //This is the profilePicture image view
                var list = [User]()
                list = acceptedUserList
                if (list.count != 0 || indexPath.row > list.count) {
                    
                    
                    cellImageView.translatesAutoresizingMaskIntoConstraints = false
                    cellImageView.centerXAnchor.constraint(equalTo: cell.leftAnchor, constant: 40).isActive = true
                    cellImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                    cellImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    cellImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                    print(indexPath.row, "This is the row")
                    cellImageView.image = list[indexPath.row - 2].imageView?.image
                    cellImageView.layer.cornerRadius = 20
                    cellImageView.layer.masksToBounds = true
                    
                    //This is the name of the user
                    
                    cellLabel.text = list[indexPath.row - 2].name
                    cellLabel.translatesAutoresizingMaskIntoConstraints = false
                    cellLabel.topAnchor.constraint(equalTo: cellImageView.topAnchor).isActive = true
                    cellLabel.leftAnchor.constraint(equalTo: cellImageView.rightAnchor, constant: 10).isActive = true
                    cellLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
                    
                }
                
                return cell
            }
        }
    }
    
    
    
    //This finds all of your friends for the tableView
    func fetchMessengerUsers() {
        let ref = FIRDatabase.database().reference().child("users")
        let childRef = ref.child(uid!).child("friends")
        
        ref.observe(.childAdded, with:  { (snapshot) in
            childRef.observe(.value, with: { (snapshot2) in
                for rest in snapshot2.children.allObjects as! [FIRDataSnapshot] {
                    if (snapshot.key == rest.key) {
                        
                        
                        let dictionary = snapshot2.childSnapshot(forPath: snapshot.key).value as! [String: AnyObject]
                        
                        
                        let user = User()
                        if (dictionary["lastMessage"] != nil) {
                            let dict2 = dictionary["lastMessage"] as! [String: AnyObject]
                            
                            if (dict2["Last Message"] as? String != nil) {
                                user.lastMessage = dict2["Last Message"] as! String
                                user.lastSender = dict2["Sending Name"] as! String
                                if (dict2["timeStamp"] as? Double != nil) {
                                    user.timeStamp = dict2["timeStamp"] as! Double
                                } else {
                                    user.timeStamp = Double.greatestFiniteMagnitude
                                }
                                if (dict2["Read"] as? String == "False" && dict2["Sending Name"] as? String != self.uid) {
                                    user.read = false
                                }
                            }
                        } else {
                            user.timeStamp = Double.greatestFiniteMagnitude
                        }
                        
                        
                        user.uid = snapshot.key
                        let dictionary2 = snapshot.value as! [String:AnyObject]
                        
                        if (dictionary2["name"] != nil) {
                            user.name = dictionary2["name"] as! String
                            
                            
                        }
                        if (dictionary2["profileImageURL"] as? String != nil) {
                            let profileImageURL = dictionary2["profileImageURL"] as! String
                            user.imageView?.loadImageUsingCacheWithURLString(urlString: profileImageURL)
                        }
                        
                        
                        self.userList.append(user)
                        
                        
                    }
                    DispatchQueue.main.async {
                        self.userList.sort(by:  ({$0.timeStamp < $1.timeStamp}))
                        
                        self.tableView.reloadData()
                        
                    }
                    
                    
                    
                    
                    
                }
                
                
                
                
                
                
                
                
            })
            
        })
        
        
    }
}
