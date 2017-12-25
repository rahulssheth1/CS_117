//
//  File.swift
//  InternTest
//
//  Created by Rahul Sheth on 7/3/17.
//  Copyright © 2017 Rahul Sheth. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//This is where you search for users.
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating {
    
    
    
    
    
    //INITIALIZATION OF VARIABLES
    
    let ref = FIRDatabase.database().reference().child("users")
    var majorList = [String]()
    var universityList = [String]()
    var companyList = [String]()
    var peopleList = [User]()
    var skillList = [String]()
    var filteredMajorList = [String]()
    var filteredUniversityList = [String]()
    var filteredCompanyList = [String]()
    var filteredPeopleList = [User]()
    var filteredSkillList = [String]()
    var tableView = UITableView()
    var previousController = UIViewController()
    let searchController = UISearchController(searchResultsController: nil)
    let backButton = UIButton()

    var helpBool = false
    
    var genericList = ["Companies", "Find a person with a specific skill", "Find a person from a specific University"]
    
    let advancedSearchButton = UIButton()

    
    var helpView = UIView()
    
    deinit {
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class genericCellButton: UIButton {
        
        var typeString: String = ""
        var user = User()
        var typeInt: Int = 5
    }
    
    
    
    
    
    
    //-------------------------------------------------------------------------------------------
    //HELPER FUNCTIONS AND VIEW DID LOAD
    
    
    func setUpHelpView() {
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
        let titleLabel = UILabel()
        helpView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Welcome to Search"
        titleLabel.centerXAnchor.constraint(equalTo: helpView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: helpView.topAnchor, constant: 10).isActive = true
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 30)
        
        
        let helpLabel = UILabel()
        helpView.addSubview(helpLabel)
        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        
        helpLabel.text = "This is where you can search for the other user. As a recruiter, you can search based on Major, University, Skillset, or for particular people. As a student, you can search for a company (which will give you a list of all recruiters from said company) or individual people. Clicking the button to the top right will take you to advanced search, where you can give keywords for all categories."
        helpLabel.numberOfLines = 0
        helpLabel.lineBreakMode = .byWordWrapping
        helpLabel.centerXAnchor.constraint(equalTo: helpView.centerXAnchor).isActive = true
        helpLabel.centerYAnchor.constraint(equalTo: helpView.centerYAnchor).isActive = true
        helpLabel.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.7).isActive = true
        helpLabel.textAlignment = .center
        helpLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        tableView.alpha = 0.2
        
        let continueButton = UIButton()
        helpView.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.centerXAnchor.constraint(equalTo: helpView.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.5).isActive = true
        continueButton.topAnchor.constraint(equalTo: helpLabel.bottomAnchor, constant: 20).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.05).isActive = true
        continueButton.setTitle("Get Started", for: .normal)
        continueButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.layer.cornerRadius = 10
        continueButton.backgroundColor = UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1)
        continueButton.addTarget(self, action: #selector(removeHelpView), for: .touchUpInside)
        
        
        
    }
    
    
    func removeHelpView() {
        helpView.removeFromSuperview()
        tableView.alpha = 1
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("HelpViews")
        firstTimeSearch = false
        let value = ["FirstTimeSearch": "false" as NSString]
        ref.updateChildValues(value)
    }

    
    
    //First find all the students, then find all of the majors that start with that
    func fetchMajors() {
        ref.observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? [String: AnyObject] != nil) {
            let dictionary = snapshot.value as! [String: AnyObject]
            let user = User()
            if (dictionary["name"] as? String != nil) {
                user.name = dictionary["name"] as! String
            }
            user.uid = snapshot.key
            self.peopleList.append(user)
            
            if (dictionary["Occupation"] as? String == "Student") {
                if let majorString = dictionary["Major"] as? String {
                    
                    if (!self.majorList.contains((majorString as? String)!)) {
                        self.majorList.append((majorString as? String)!)
                    }
                }
                if let universityString = dictionary["Unversity"] as? String {
                    if (!self.universityList.contains((universityString as? String)!)) {
                        self.universityList.append(universityString)
                        
                    }
                }
                if let skill1 = dictionary["Skill 1"] as? String {
                    if (!self.skillList.contains(skill1)) {

                        self.skillList.append(skill1)
                    }
                }
                if let skill2 = dictionary["Skill 2"] as? String {
                    if (!self.skillList.contains(skill2)) {
                        self.skillList.append(skill2)
                    }
                }
                if let skill3 = dictionary["Skill 3"] as? String {
                    if (!self.skillList.contains(skill3)) {

                        self.skillList.append(skill3)
                    }
                }
                if let skill4 = dictionary["Skill 4"] as? String {
                    if (!self.skillList.contains(skill4)) {

                        self.skillList.append(skill4)
                    }
                }
            } else {
                if let companyString = dictionary["Company"] as? String {
                    if (!self.companyList.contains((companyString as? String)!)) {
                        self.companyList.append(companyString)
                    }
                }
                
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            }
        })
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    
    func filterSearchText (searchText: String, scope: String = "All") {
        filteredMajorList = majorList.filter { major in
            return major.lowercased().contains(searchText.lowercased())
            
        }
        filteredUniversityList = universityList.filter { university in
            return university.lowercased().contains(searchText.lowercased())
        }
        
        filteredCompanyList = companyList.filter { company in
            return company.lowercased().contains(searchText.lowercased())
        }
        filteredPeopleList = peopleList.filter { people in
            return people.name.lowercased().contains(searchText.lowercased())
        }
        filteredSkillList = skillList.filter { skills in
            return skills.lowercased().contains(searchText.lowercased())
        }
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
    }
    
    
    
    
    func killSearch() {
        if (searchController.isActive == true) {
            searchController.isActive = false
        }
    }
    
    func handleMoveBackToFeed(sender: genericCellButton) {
        killSearch()
        
        let segueController = FeedController(nibName: nil, bundle: nil)
        segueController.passedInString = sender.typeString
        segueController.passedInInt = sender.typeInt
        segueController.searchBool = true
        present(segueController, animated: true, completion: nil)
    }
    
    
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        backButton.isHidden = true
        return true
    }
  
    
    func handleAdvancedSearch() {
        killSearch()
        let segueController = AdvancedSearchViewController(nibName: nil, bundle: nil)
        segueController.universityList = self.universityList
        segueController.majorList = self.majorList
        segueController.skillList = self.skillList
        
        present(segueController, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)

        
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .default
        
        self.searchController.searchBar.frame.size.width = self.view.frame.size.width * 0.85
        searchController.isActive = false
        searchController.searchBar.barTintColor = UIColor.white
        if (globalFeedString == "Employer") {
        searchController.searchBar.scopeButtonTitles = ["Company", "People"]

        } else {
        searchController.searchBar.scopeButtonTitles = ["Major", "University", "People", "Skill"]
        }
        searchController.searchBar.delegate = self
        let containerView = UIView()
        self.view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        containerView.isUserInteractionEnabled = true
        containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: self.view.bounds.width * 0.1).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 50 ).isActive = true
        containerView.addSubview(searchController.searchBar)
        
        self.view.addSubview(advancedSearchButton)
        advancedSearchButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 50).isActive = true
        advancedSearchButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        advancedSearchButton.setTitleColor(UIColor.blue, for: .normal)
        advancedSearchButton.setTitle("Advanced Search", for: .normal)
        advancedSearchButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        advancedSearchButton.translatesAutoresizingMaskIntoConstraints = false
        advancedSearchButton.addTarget(self, action: #selector(handleAdvancedSearch), for: .touchUpInside)
        view.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 3).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: self.view.bounds.height * 0.05).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: self.view.bounds.height * 0.05).isActive = true
        backButton.setImage(UIImage(named: "arrowIcon"), for: .normal)
        
        backButton.addTarget(self, action: #selector(handleMoveBack), for: .touchUpInside)
        fetchMajors()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.separatorStyle = .none
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        if (firstTimeSearch) {
        setUpHelpView()
        }
        
        
        
        
        view.addGestureRecognizer(tap)
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
    
    
    func handleMoveBack() {
        present(previousController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    //-------------------------------------------------------------------------------------------
    //TABLE VIEW AND ALL
    //Major = 0, Uni = 1, Co = 2, People = 3, Skills = 4
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let segueController = FeedController(nibName: nil, bundle: nil)
        
        if (searchController.isActive == true && searchController.searchBar.text != "") {
            segueController.searchBool = true 
            if (globalFeedString == "Employer") {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    segueController.passedInInt = 2
                    segueController.passedInString = filteredCompanyList[indexPath.row]
                    break
                default:
                    segueController.passedInInt = 3
                    segueController.passedInString = filteredPeopleList[indexPath.row].uid
                    break
                }
            } else {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    segueController.passedInInt = 0
                    segueController.passedInString = filteredMajorList[indexPath.row]
                    break
                case 1:
                    segueController.passedInInt = 1
                    segueController.passedInString = filteredUniversityList[indexPath.row]
                    break
                case 2:
                    segueController.passedInInt = 3
                    segueController.passedInString = filteredPeopleList[indexPath.row].uid
                    break
                default:
                    segueController.passedInInt = 4
                    segueController.passedInString = filteredSkillList[indexPath.row]
                    break
                    
                }
            }
            killSearch()
            present(segueController, animated: true, completion: nil)
        }
       

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive == true && searchController.searchBar.text != "") {
            if (globalFeedString == "Employer") {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    return filteredCompanyList.count
                default:
                   return filteredPeopleList.count
                }
            } else {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    return filteredMajorList.count
                case 1:
                    return filteredUniversityList.count
                case 2:

                    return filteredPeopleList.count
                default:

                    return filteredSkillList.count
                }
            }
        } else {
            return genericList.count
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (searchController.isActive == true && searchController.searchBar.text != "") {
            if (globalFeedString == "Employer") {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    return "Companies"
                default:
                    return "Recruiters"
                }
            } else {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    return "Majors"
                case 1:
                    return "Universities"
                case 2:
                    return "Students"
                default:
                    return "Skills"
                }
            }
        } else {
            return "Try Searching For:"
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID")
        if (searchController.isActive && globalFeedString == "Student") {
            advancedSearchButton.isHidden = false
        } else {
            advancedSearchButton.isHidden = true
        }
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        let textLabel = UILabel()
                if (searchController.isActive == true) {
                    backButton.isHidden = true
        
                } else {
                    backButton.isHidden = false
        
                }
        
        cell.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        textLabel.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 15).isActive = true
        textLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
        
        if (searchController.isActive == false || searchController.searchBar.text == "") {
            textLabel.text = genericList[indexPath.row]
        } else {
            if (globalFeedString == "Employer") {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    textLabel.text = filteredCompanyList[indexPath.row]
                    break
                default:
                    textLabel.text = filteredPeopleList[indexPath.row].name
                }
            } else {
                switch searchController.searchBar.selectedScopeButtonIndex {
                case 0:
                    textLabel.text = filteredMajorList[indexPath.row ]
                    break
                case 1:
                    textLabel.text = filteredUniversityList[indexPath.row]
                    break
                case 2:
                    textLabel.text = filteredPeopleList[indexPath.row].name
                    break
                default:
                    textLabel.text = filteredSkillList[indexPath.row]
                    break
                }
            }
        }
        
        return cell
    }
    
    
    
    
    func rowCount(genericList: [AnyObject], filteredList: [AnyObject], searchBool: Bool) -> Int {
        if (searchBool) {
            if (filteredList.count < 5) {
                return filteredList.count + 1
            } else {
                return 6
            }
            
            
        }
        if (genericList.count < 5) {
            return genericList.count + 1
        }
        return 6
        
    }

   
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    
    
    
    
    
    
    
}
