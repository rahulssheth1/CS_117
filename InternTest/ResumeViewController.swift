//
//  ResumeViewController.swift
//  InternTest
//
//  Created by Rahul Sheth on 12/22/17.
//  Copyright © 2017 Rahul Sheth. All rights reserved.
//

import UIKit
import Firebase

class ResumeViewController: UIViewController {

    var resURL = String()
    
    func GoBack() {
        dismiss(animated: true, completion: nil)
    }
    func extractResume() {
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value, with: { (snapshot) in
            if (snapshot.value as? [String:AnyObject] != nil) {
            var dict = snapshot.value as! [String: AnyObject]
            if (dict["Resume"] as? String != nil) {
                self.resURL = dict["Resume"] as! String
                print("in here")
                self.SetUpResume()
            } else {
                self.resURL = "Nil"
            }
        
        
        
            } else {
                print("NilVal")
            }
        })
    }
    func goToResume() {
        let segueController = GoogleUploadVC()
        present(segueController, animated: true, completion: nil)
    }
    
    func SetUpResume() {
        let url2 = Bundle.main.url(forResource: "NXTPitchProposal", withExtension: "pdf")
        let rect = CGRect(x: 0, y: 60, width: self.view.bounds.width, height: self.view.bounds.height - 60)
        let webView = UIWebView(frame: rect)
        if (resURL != "Nil") {
            let url = URL(string: resURL)
            let urlRequest = URLRequest(url: url!)
            
            webView.loadRequest(urlRequest)
        } else {
            let urlRequest = URLRequest(url: url2!)
            webView.loadRequest(urlRequest)
        }
        self.view.addSubview(webView)
        
    }
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        extractResume()
        let topBar = UIView()
        self.view.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        topBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let backButton = UIButton()
        topBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leftAnchor.constraint(equalTo: topBar.leftAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor(red: (79/255.0), green: (159/255.0), blue: (250/255.0), alpha: 1), for: .normal)
        backButton.addTarget(self, action: #selector(GoBack), for: .touchUpInside)
        backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        let updateResumeButton = UIButton()
        topBar.addSubview(updateResumeButton)
        updateResumeButton.translatesAutoresizingMaskIntoConstraints = false
        updateResumeButton.rightAnchor.constraint(equalTo: topBar.rightAnchor).isActive = true
        updateResumeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        updateResumeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        updateResumeButton.setTitle("Update", for: .normal)
        updateResumeButton.setTitleColor(UIColor(red: (79/255.0), green: (159/255.0), blue: (250/255.0), alpha: 1), for: .normal)
        updateResumeButton.addTarget(self, action: #selector(goToResume), for: .touchUpInside)
        updateResumeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
       
            

    }
}
