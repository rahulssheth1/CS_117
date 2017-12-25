//
//  GoogleUploadVC.swift
//  InternTest
//
//  Created by Rahul Sheth on 12/23/17.
//  Copyright © 2017 Rahul Sheth. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import Google
import Firebase

class GoogleUploadVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, UITableViewDelegate, UITableViewDataSource {
    
        let storageReference = FIRStorage.storage().reference()
        var tableView = UITableView()
    
        var topFiles = [GTLRDrive_File]()
        // If modifying these scopes, delete your previously saved credentials by
        // resetting the iOS simulator or uninstall the app.
        let scopes = [kGTLRAuthScopeDriveReadonly]
        
        let service = GTLRDriveService()
        let signInButton = GIDSignInButton()
        let output = UITextView()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = UIColor.white
            // Configure Google Sign-in.
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().scopes = scopes
            GIDSignIn.sharedInstance().signInSilently()
            
            // Add the sign-in button.
            view.addSubview(signInButton)
            signInButton.translatesAutoresizingMaskIntoConstraints = false
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            // Add a UITextView to display output.
            self.view.addSubview(tableView)
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150).isActive = true
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            tableView.separatorStyle = .none
            
    }
        
        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                  withError error: Error!) {
            if let error = error {
                showAlert(title: "Authentication Error", message: error.localizedDescription)
                self.service.authorizer = nil
            } else {
                self.signInButton.isHidden = true
                self.output.isHidden = false
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                listFiles()
            }
        }
        
        func listFiles() {
            let query = GTLRDriveQuery_FilesList.query()
            service.executeQuery(query,
                                 delegate: self,
                                 didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
            )
        }
        
        // Process the response and display output
        func displayResultWithTicket(ticket: GTLRServiceTicket,
                                     finishedWithObject result : GTLRDrive_FileList,
                                     error : NSError?) {
            
            if let error = error {
                showAlert(title: "Error", message: error.localizedDescription)
                return
            }
        
            if let files = result.files, !files.isEmpty {

                topFiles = files
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            } else {
                showAlert(title: "Error", message: "No Files Found")
            }
            
        }
        
        
        // Helper for showing an alert
        func showAlert(title : String, message: String) {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            let ok = UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil
            )
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    
    
    func extractResume(sender: downloadButton) {

        var query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: sender.id)
        service.executeQuery(query, completionHandler: { (ticket, file, error) in
            if (error == nil) {
                var file2: GTLRDataObject

                print("Congratulations. Download Complete")
                if (file as? GTLRDataObject != nil) {
                    file2 = file as! GTLRDataObject
                    self.storageReference.child((FIRAuth.auth()?.currentUser?.uid)!).child("Resume").put(file2.data, metadata: nil, completion: { (metadata, error) in
                        
                        
                        if (error != nil) {
                            self.showAlert(title: "Error", message: (error?.localizedDescription)!)
                        } else {
                            if let storageURL = metadata?.downloadURL()?.absoluteString {
                                let value = ["Resume": storageURL ]
                                let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
                                ref.updateChildValues(value)
                            }
                        }
                    })
                }
                
                
            } else {
                print("Error, here is your error", error)
            }
            
        })
        dismiss(animated: true, completion: nil)
    }
    
    
    //Set up the TableView
    
    class downloadButton: UIButton {
        var id = String()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topFiles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID")
        cell.selectionStyle = .none
        
        let title = UILabel()
        cell.addSubview(title)
        
        title.text = topFiles[indexPath.row].name!
        title.translatesAutoresizingMaskIntoConstraints = false
        title.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 40).isActive = true
        title.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        title.widthAnchor.constraint(equalToConstant: 100).isActive = true
        title.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let dButton = downloadButton()
        cell.addSubview(dButton)
        dButton.id = topFiles[indexPath.row].identifier!
        dButton.translatesAutoresizingMaskIntoConstraints = false
        dButton.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -40).isActive = true
        dButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        dButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        dButton.setTitle("Use", for: .normal)
        dButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        dButton.setTitleColor(UIColor.white, for: .normal)
        dButton.layer.cornerRadius = 10
        dButton.backgroundColor = UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1)
        dButton.addTarget(self, action: #selector(extractResume), for: .touchUpInside)
        return cell
    }
    
    

}
