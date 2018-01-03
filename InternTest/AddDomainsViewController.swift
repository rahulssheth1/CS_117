//
//  AddDomainsViewController.swift
//  InternTest
//
//  Created by Rahul Sheth on 1/1/18.
//  Copyright © 2018 Rahul Sheth. All rights reserved.
//

//How this works:

// 1. Picker View gives domains that have been previously defined.
    //a. NXTPItch Domains are those given by us
    //b. User Domains currently gives ALL of the ones defined by users
// 2. Selecting a position on the picker puts it in the textBox. The Plus Icon Button does:
    //a. Uploads to database:  Root -> users -> CurUser -> Domains
    //b. Uploads to database:  Root -> Domains -> CurUser UID
    //c. Add to tableView on the bottom
// 3. If a user does not see a domain they want, they click the button underneath textBox. This opens an alert where they can type a domain of their choosing. Clicking confirm does the following:

    //a. Uploads to Database: Root -> users -> CurUser -> Domains
    //b. Uploads to Databse: Root -> Domains -> CurUser UID
    //c. Uploads to Database: Root -> Popular Domains -> Name of Domain
    //Add to tableView

//Limitations:
    //1. Clicking user domains will give all domains previously defined by users. This will be a lot. We need some ranking or easy parsing
    //2. Redundancies in the Database. Lots of redundancies in terms of information being stored because this makes for faster searching on the feed. May need to think of a better tradeoff because rn there's potentially three copies of each piece of information. (Usually 2)
    //3. Small Check to see if a potentially new user defined domain is already in the system.
    //4. Add in more NXTPitch Domains

import UIKit
import Firebase

class AddDomainsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    let nxtPitchButton = UIButton()
    let userCreatedButton = UIButton()
    let picker = UIPickerView()
    let blueSearchBarColor = UIColor(red: 21/255, green: 126/255, blue: 251/255, alpha: 1.0)
    var nxtPitchDomains = ["SWE - Security", "SWE - Systems", "Site Reliability", "Machine Learning", "AR/VR", "Mobile App Development", "Front End Dev", "Back End Dev", "Business Administration", "Financial Analyst", "Marketing Analyst", "UI/UX Design"]
    var userDomains = [String]()
    var retDomains = [String]()
    
    var personalDomains = [String]()
    let textBox = UILabel()
    let tableView = UITableView()
    func moveToProfile() {
        let segueController = ProfilePageViewController()
        present(segueController, animated: true, completion: nil)
        
    }
    
    func deleteFromTable(deleteRow: Int) {
        
        let ref = FIRDatabase.database().reference().child("Domains").child(personalDomains[deleteRow]).child((FIRAuth.auth()?.currentUser?.uid)!)
        ref.removeValue()
        
        ref.removeAllObservers()
        
        let ref2 = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Domains").child(personalDomains[deleteRow])
        ref2.removeValue()
        ref2.removeAllObservers()
        
        
        personalDomains.remove(at: deleteRow)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func uploadExistingToDatabase() {
        
        let value = ["Used" as NSString: "Yes" as NSString]
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Domains").child(textBox.text!)
        ref.updateChildValues(value)
        personalDomains.append(textBox.text!)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func handleChangeToUser() {
        //Currently at NXTPitch. User picks User button
        //Set user background = Blue, set nxt background = white

        userCreatedButton.backgroundColor = blueSearchBarColor
        userCreatedButton.setTitleColor(UIColor.white, for: .normal)
        
        nxtPitchButton.backgroundColor = UIColor.white
        nxtPitchButton.setTitleColor(blueSearchBarColor, for: .normal)
        
        retDomains = userDomains
        picker.reloadAllComponents()
        textBox.reloadInputViews()
    }
    func handleNewForUserDomain() {
        let alert = UIAlertController(title: "New Domain", message: "Type in your own domain", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (error) in
            
            let tf = alert.textFields![0].text
            if (tf != "") {
                let ref2 = FIRDatabase.database().reference().child("Popular Domains")
                let updateVal = ["Used" as NSString: "Yes" as NSString]
                ref2.child(tf!).updateChildValues(updateVal)
                self.addToDatabase(updateString: tf!)
                
                let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Domains").child(tf!)
                ref.updateChildValues(updateVal)
            }
            self.personalDomains.append(tf!)
            self.userDomains.append(tf!)
            DispatchQueue.main.async {
                self.picker.reloadAllComponents()
                self.tableView.reloadData()
            }
            
            
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func pullFromDatabase() {
        self.userDomains.removeAll()
        let ref2 = FIRDatabase.database().reference().child("Popular Domains")
        ref2.observe(.childAdded, with: { (snapshot) in
            let keyVal = snapshot.key
            self.userDomains.append(keyVal)
            
        })
       
        
    }
    
    func pullPersonalDomains() {
        self.personalDomains.removeAll()
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Domains")
        ref.observe(.childAdded, with: { (snapshot) in
            self.personalDomains.append(snapshot.key)
            
            
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
    }
    
    func handleChangeToNXT() {
        //Currently at user. Move to NXTPItch
        //Set nxt = blue, user = white
        userCreatedButton.backgroundColor = UIColor.white
        userCreatedButton.setTitleColor(blueSearchBarColor, for: .normal)
        
        nxtPitchButton.backgroundColor = blueSearchBarColor
        nxtPitchButton.setTitleColor(UIColor.white, for: .normal)
        
        retDomains = nxtPitchDomains
        picker.reloadAllComponents()
        textBox.reloadInputViews()
    }
    override func viewDidLoad() {
        
        pullFromDatabase()
        pullPersonalDomains()
        self.view.backgroundColor = UIColor.white
        let newButton = UIButton()
        let titleLabel = UILabel()
        let backButton = UIButton()
        self.view.addSubview(newButton)
        self.view.addSubview(titleLabel)
        self.view.addSubview(backButton)
        self.view.addSubview(nxtPitchButton)
        self.view.addSubview(userCreatedButton)
        self.view.addSubview(textBox)
        self.view.addSubview(tableView)
        self.view.addSubview(picker)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.05).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: self.view.bounds.height * 0.05).isActive = true
        backButton.setImage(UIImage(named: "arrowIcon"), for: .normal)
        backButton.addTarget(self, action: #selector(moveToProfile), for: .touchUpInside)
        
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Interesting Positions"
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular" , size: 26)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.08).isActive = true
        
        
        nxtPitchButton.translatesAutoresizingMaskIntoConstraints = false
        nxtPitchButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        nxtPitchButton.rightAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        nxtPitchButton.widthAnchor.constraint(equalToConstant: self.view.bounds.width / 2.7).isActive = true
        nxtPitchButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 35).isActive = true
        nxtPitchButton.backgroundColor = blueSearchBarColor
        nxtPitchButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        nxtPitchButton.setTitle("General Domains", for: .normal)
        nxtPitchButton.setTitleColor(UIColor.white, for: .normal)
        nxtPitchButton.layer.borderColor = blueSearchBarColor.cgColor
        nxtPitchButton.addTarget(self, action: #selector(handleChangeToNXT), for: .touchUpInside)
        
        userCreatedButton.translatesAutoresizingMaskIntoConstraints = false
        userCreatedButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        userCreatedButton.leftAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        userCreatedButton.widthAnchor.constraint(equalToConstant: self.view.bounds.width / 2.7).isActive = true
        userCreatedButton.topAnchor.constraint(equalTo: nxtPitchButton.topAnchor).isActive = true
        userCreatedButton.backgroundColor = UIColor.white
        userCreatedButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        userCreatedButton.setTitle("Popular Domains", for: .normal)
        userCreatedButton.setTitleColor(blueSearchBarColor, for: .normal)
        userCreatedButton.layer.borderColor = blueSearchBarColor.cgColor
        userCreatedButton.addTarget(self, action: #selector(handleChangeToUser), for: .touchUpInside)
        
        
        
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: self.view.bounds.height / 3).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.borderWidth = 1
        retDomains = nxtPitchDomains
        
        textBox.translatesAutoresizingMaskIntoConstraints = false
        textBox.widthAnchor.constraint(equalToConstant: self.view.bounds.width / 1.5).isActive = true
        textBox.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        textBox.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10).isActive = true
        textBox.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textBox.layer.borderWidth = 1
        textBox.text = retDomains[picker.selectedRow(inComponent: 1)]
        
        let addButton = UIButton()
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(named: "AddIcon"), for: .normal)
        addButton.centerYAnchor.constraint(equalTo: textBox.centerYAnchor).isActive = true
        addButton.leftAnchor.constraint(equalTo: textBox.rightAnchor, constant: 5).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        addButton.addTarget(self, action: #selector(uploadExistingToDatabase), for: .touchUpInside)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.topAnchor.constraint(equalTo: userCreatedButton.bottomAnchor, constant: 5).isActive = true
        picker.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        picker.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        picker.bottomAnchor.constraint(equalTo: textBox.topAnchor, constant: -10).isActive = true
        picker.dataSource = self
        picker.delegate = self
        
       newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        newButton.topAnchor.constraint(equalTo: textBox.bottomAnchor).isActive = true
        newButton.widthAnchor.constraint(equalToConstant: self.view.bounds.width / 2).isActive = true
        newButton.setTitle("Don't see yours?", for: .normal)
        newButton.setTitleColor(blueSearchBarColor, for: .normal)
        newButton.addTarget(self, action: #selector(handleNewForUserDomain), for: .touchUpInside)
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return retDomains[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return retDomains.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         textBox.text = retDomains[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personalDomains.count
    }
    
    
    
    func addToDatabase(updateString: String) {
        if updateString != "" {
            let ref = FIRDatabase.database().reference().child("Domains").child(updateString).child((FIRAuth.auth()?.currentUser?.uid)!)
            let values = ["Used" as NSString: "Yes" as NSString]
            ref.updateChildValues(values)
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID")
        let titleLabel = UILabel()
        cell.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 15).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: cell.bounds.height).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: cell.bounds.width / 2).isActive = true
        titleLabel.text = personalDomains[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            deleteFromTable(deleteRow: indexPath.row)
        }
        
        
    }
}
