//
//  MyFoodTableViewController.swift
//  HealthyApp
//
//  Created by Christian Willson on 26/10/21.
//  Copyright © 2021 Christian Willson. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase

class MyFoodTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var keyword: String = ""
    private var imagesDataArray = [[Data]]()

    @IBAction func populateBtn(_ sender: UIButton) {
//        addRecipeData()
//        fetchRecipe()
//        tableView.reloadData()
    }
    
    @IBOutlet weak var plusBtnOutlet: UIButton!
    
    //firebase ref
    let ref = Database.database(url: "https://healthy-app-9861e-default-rtdb.firebaseio.com/").reference()
    
    let searchController = UISearchController(searchResultsController: SearchViewController())
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items:[Recipe]?
    
    var items_from_db = [Recipe_Struct]()
    var ds = 0
    
    //LOADING
    let loadingView = UIView()

    // Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()

    // Text shown during load the TableView
    let loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        setLoadingScreen()
        DispatchQueue.main.async() {
            self.fetchRecipe()
            self.removeLoadingScreen()
        }
        
        //plusBtnOutlet.isHidden = true
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        if text == "" {
            fetchRecipe()
            tableView.reloadData()
        } else {
            let vc = searchController.searchResultsController as? SearchViewController
            vc?.keywordDelegate = self
            vc?.stringSearch = text
            vc?.updateData()
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            print("UISearchBar.text cleared!")
        }
    }
    
    // MARK: - Loading Screen
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        self.tableView.separatorStyle = .none
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)

        // Sets spinner
        spinner.style = .medium
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()

        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)

        tableView.addSubview(loadingView)

    }

    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        self.tableView.separatorStyle = .singleLine
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true

    }
    
    
    // MARK: - Firebase Functions
    
    
    func getDataFromDatabase() {
        items_from_db = []
        self.tableView.reloadData()
        ref.child("Recipe").observeSingleEvent(of: .value) {
            (snapshot) in
            let recipes = snapshot.value as? [String: Any]
            var uiImages = [UIImage]()
            
            for (key, _) in recipes! {
                guard let recipe = recipes?[key] as? [String: Any] else {
                    print("error 1")
                    return
                }
                
                guard let name = recipe["name"] as? String else {
                    return
                }
                
                if name.contains(self.keyword) {
                    
                    guard let images = recipe["images"] as? [String] else {return}

                    guard let ingredients = recipe["ingredients"] as? [String] else {return}

                    guard let instructions = recipe["instructions"] as? [String] else {return}
                    var a = 0
                    
                    for i in 0..<images.count {

                        guard let url = URL(string: images[i]) else {return}
                        
                        URLSession.shared.dataTask(with: url, completionHandler: { img_data, _, error in
                            
                            guard let img_data = img_data, error == nil else {return}
                            
                            //TODO = Replace with 'unknown' picture
                            uiImages.append((UIImage(data: img_data) ?? UIImage(named: "salad"))!)
                            
                            
                            if a == 3 {
                                
                                self.items_from_db.append(Recipe_Struct(name: recipe["name"] as? String, descriptions: recipe["descriptions"] as? String, category: recipe["category"] as? String, cook_time: recipe["cook_time"] as? String, ingredients: ingredients, instructions: instructions, images: uiImages))
                                
                                DispatchQueue.main.async {
                                    //self.removeLoadingScreen()
                                    self.tableView.reloadData()
                                }
                            }
                            
                            a = a+1
                            
                            
                        }).resume()

                    }
                    
                    
                }
            }
            
        }
        
        
    }
    
    
    
    // MARK: - Core Data Functions
    
    func fetchImages() {
        imagesDataArray = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recipe")
        var tmp = [Data]()
        do {
            items = try context.fetch(fetchRequest) as? [Recipe]
            for data in items! {
                tmp.append(data.value(forKey: "images") as! Data)
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }

        //fetch image using decoding
        tmp.forEach { (imageData) in
          var dataArray = [Data]()
          do {
            dataArray = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: imageData) as! [Data]

            imagesDataArray.append(dataArray)

          } catch {
            print("could not unarchive array: \(error)")
          }
        }
    }
    
    func fetchRecipe() {
        ds = 0
        do {
            self.items = try context.fetch(Recipe.fetchRequest())
            if items?.isEmpty == false {
                fetchImages()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("No item to fetch")
            }
            
            
        } catch {
            print("Error")
        }
        
    }
    
    func fetchRecipeWithCondition(condition: String) {
        ds = 0
        
        var indexes = [Int]()
        var co = 0
        for item in items! {
            if item.name! == condition {
                indexes.append(co)
            }
            co += 1
        }
        
        do {
            
            let request = Recipe.fetchRequest() as NSFetchRequest<Recipe>
            
            let pred = NSPredicate(format: "name CONTAINS %@", condition)
            request.predicate = pred
            
            self.items = try context.fetch(request)
            
            
        } catch {
            print("Error")
        }

        let imagesDataArrayTmp = imagesDataArray
        imagesDataArray = []
        
        for index in indexes {
            imagesDataArray.append(imagesDataArrayTmp[index])
        }
        
        
        
    }
    
    func deleteRecipe(index: Int) {
        ds = 0
        let recipeToDelete = items![index]

        self.context.delete(recipeToDelete)

        do {
            try self.context.save()
        } catch {
            //TODO: Alert an error(s)
        }
        
        self.fetchRecipe()
            
    }
    
    
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ds == 1 {
            return items_from_db.count
        } else {
            return items?.count ?? 0
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFoodTableViewCell", for: indexPath) as! MyFoodTableViewCell
        
        if ds == 1 {
            cell.smallImage.image = items_from_db[indexPath.row].images![0]
            cell.largeImage1.image = items_from_db[indexPath.row].images![1]
            cell.largeImage2.image = items_from_db[indexPath.row].images![2]
            cell.largeImage3.image = items_from_db[indexPath.row].images![3]
            cell.foodNameLabel.text = items_from_db[indexPath.row].name!
            cell.cookDurationLabel.text = "Cook time: " + items_from_db[indexPath.row].cook_time!
        } else {
            
            cell.smallImage.image = UIImage(data: imagesDataArray[indexPath.row][0])
            cell.largeImage1.image = UIImage(data: imagesDataArray[indexPath.row][1])
            cell.largeImage2.image = UIImage(data: imagesDataArray[indexPath.row][2])
            cell.largeImage3.image = UIImage(data: imagesDataArray[indexPath.row][3])
            
            cell.foodNameLabel.text = items![indexPath.row].name!
            cell.cookDurationLabel.text = "Cook time: " + items![indexPath.row].cook_time!
        }
        

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(identifier: "DetailReciptViewController") as! DetailReciptViewController
        
        var data: Recipe_Struct
        if ds == 1 {
            data = Recipe_Struct(name: items_from_db[indexPath.row].name!, descriptions: items_from_db[indexPath.row].descriptions!, category: items_from_db[indexPath.row].category!, cook_time: items_from_db[indexPath.row].cook_time!, ingredients: items_from_db[indexPath.row].ingredients!, instructions: items_from_db[indexPath.row].instructions!, images: items_from_db[indexPath.row].images!)
            detailVC.type = 1
        } else {
            data = Recipe_Struct(name: items![indexPath.row].name!, descriptions: items![indexPath.row].descriptions!, category: items![indexPath.row].category!, cook_time: items![indexPath.row].cook_time!, ingredients: items![indexPath.row].ingredients!, instructions: items![indexPath.row].instructions!, images: [UIImage(data: imagesDataArray[indexPath.row][0])!, UIImage(data: imagesDataArray[indexPath.row][1])!, UIImage(data: imagesDataArray[indexPath.row][2])!, UIImage(data: imagesDataArray[indexPath.row][3])!])
            detailVC.type = 0
            detailVC.deleteDelegate = self
            detailVC.index = indexPath.row
        }
        detailVC.data = data
        navigationController?.pushViewController(detailVC, animated: true)
    }

}

//my delegate
extension MyFoodTableViewController: KeywordSelectionDelegate {
    func didTapKeyword(dataSource: Int, keyword: String) {
        searchController.searchBar.text = keyword
        self.keyword = keyword
        if dataSource == 0 {
            fetchRecipeWithCondition(condition: keyword)
            ds = 0
            self.tableView.reloadData()
        } else {
            ds = 1
            self.tableView.reloadData()
            //self.setLoadingScreen()
            self.getDataFromDatabase()
            
        }
    }
    
    
}

extension MyFoodTableViewController: DeleteSelectionDelegate {
    func didDeleteSelection(index: Int) {
        deleteRecipe(index: index)
        searchController.searchBar.text = ""
        self.tableView.reloadData()
    }
}
