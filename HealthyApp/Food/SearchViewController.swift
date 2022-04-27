//
//  SearchViewController.swift
//  HealthyApp
//
//  Created by Christian Willson on 02/11/21.
//  Copyright © 2021 Christian Willson. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol KeywordSelectionDelegate {
    func didTapKeyword(dataSource: Int, keyword: String)
}

class SearchViewController: UIViewController {
    
    var stringSearch: String = ""
    
    private let ref = Database.database(url: "https://healthy-app-9861e-default-rtdb.firebaseio.com/").reference()
    
    var keywordDelegate: KeywordSelectionDelegate!
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["On Device", "Explore online"])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    var ds = 0

    
    @objc func handleSegmentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            data = []
            getDataFromDatabase()
            ds = 1
        } else {
            data = []
            fetchData()
            ds = 0
        }
        filteredData = data
        filterData(stringSearch: stringSearch)
        tableView.reloadData()
    }
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var data = ["Salad", "Chicken", "Almond"]
    var filteredData = [String]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var coreDataItems:[Recipe]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        fetchData()
        
        filteredData = data
        
        tableView.dataSource = self
        tableView.delegate = self
        
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange(_:)), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [
            segmentedControl, tableView
        ])
        stackView.axis = .vertical
        
        view.addSubview(stackView)

        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .zero)
        
    }
    
    // MARK: - CoreData
    func fetchData() {
        data = []
        
        do {
            self.coreDataItems = try context.fetch(Recipe.fetchRequest())
            if coreDataItems?.isEmpty == false {
                for item in coreDataItems! {
                    data.append(item.name!)
                }
                
                data = Array(Set(data))
                
            } else {
                print("No item to fetch")
            }
            
            
        } catch {
            print("Error")
        }
    }
    
    
    func updateData() {
        if stringSearch != "" {
            //print(stringSearch)
            filterData(stringSearch: stringSearch)
            tableView.reloadData()
        }
        
        
    }
    
    func filterData(stringSearch: String) {
        filteredData = []
        for data in data {
            if data.lowercased().contains(stringSearch.lowercased()){
                filteredData.append(data)
            }
        }
    }
    
    //MARK: - Firebase Database Functions
    func getDataFromDatabase() {
        data = []
        ref.child("Recipe").observeSingleEvent(of: .value) {
            (snapshot) in
            let recipes = snapshot.value as? [String: Any]
            
           
            for (key, _) in recipes! {
                guard let recipe = recipes?[key] as? [String: Any] else {
                    return
                }


                guard let name = recipe["name"] as? String else {
                    return
                }
                self.data.append(name)

            }
            
            self.data = Array(Set(self.data))
            
        }
        
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = filteredData[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        keywordDelegate.didTapKeyword(dataSource: ds, keyword: filteredData[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
}
