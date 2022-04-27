//
//  DetailReciptViewController.swift
//  HealthyApp
//
//  Created by Christian Willson on 26/10/21.
//  Copyright © 2021 Christian Willson. All rights reserved.
//

import UIKit
import CoreData

protocol DeleteSelectionDelegate {
    func didDeleteSelection(index: Int)
}

//protocol ClearKeywordDelegate {
//    func clearKeyword(clear: Bool)
//}

class DetailReciptViewController: UIViewController {
    
    var data:Recipe_Struct!
    var type = 0
    
    var deleteDelegate: DeleteSelectionDelegate!
    //var clearKeywordDelegate: ClearKeywordDelegate!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var cookDurationLabel: UILabel!
    @IBOutlet weak var foodCategoryLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    var index = 0
    
    var images: [UIImage]?
    var myImagesDataArray: [Data]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodNameLabel.text = data.name
        cookDurationLabel.text = "Cook duration 🕐 : " +
            (data.cook_time ?? "0 minute")
        foodCategoryLabel.text = "Category 📄 : " + (data.category ?? "-")
        ingredientsLabel.text = "Ingredients: \n" + add(stringList: data.ingredients!, font: .boldSystemFont(ofSize: 17), bullet: "•").string
        instructionsLabel.text = "Instructions: \n" + add(stringList: data.instructions!, font: .boldSystemFont(ofSize: 17), bullet: "🥣").string
        
        images = data.images
        let randomIndex = Int.random(in: 1..<3)
        
        bigImageView.image = images?[randomIndex]

        self.title = data.name
        self.navigationItem.largeTitleDisplayMode = .never
        
        if type == 0 {
            configureBarItem(style: .trash)
        } else {
            configureBarItem(style: .bookmarks)
        }
        
    }
    
    private func configureBarItem(style: UIBarButtonItem.SystemItem) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: style,
            target: self,
            action: #selector(barButtonItemClicked))
    }
    
    @objc func barButtonItemClicked(){
        
        if type == 0 {
            
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?\nThis action can't be undone.", preferredStyle: .alert)
                   
            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.deleteDelegate.didDeleteSelection(index: self.index)
                //clearKeywordDelegate.clearKeyword(clear: true)
                _ = self.navigationController?.popViewController(animated: true)
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            
            }
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        
        } else {
            myImagesDataArray = convertImageToData(myImagesArray: images!)
            addRecipeData()
        }
        
    }
    
    
    //MARK: - CoreData Functions
    func addRecipeData() {
        // create new data into CoreData
//        let newRecipe = Recipe(context: self.context)
//        newRecipe.name = data.name
//        newRecipe.category = data.category
//        newRecipe.descriptions = data.descriptions
//        newRecipe.cook_time = data.cook_time
//        newRecipe.ingredients = data.ingredients
//        newRecipe.instructions = data.instructions
        
        let entityName =  NSEntityDescription.entity(forEntityName: "Recipe", in: context)!
        let dt = NSManagedObject(entity: entityName, insertInto: context)
        var images: Data?

        //to store array of images using encoding
        do {
            images = try NSKeyedArchiver.archivedData(withRootObject: myImagesDataArray!, requiringSecureCoding: true)
        } catch {

            //TODO: Create alert "Error save the data"
            print("ERROR 1")
        }
        dt.setValue(images, forKeyPath: "images")
        dt.setValue(data.name, forKey: "name")
        dt.setValue(data.category, forKey: "category")
        dt.setValue(data.descriptions, forKey: "descriptions")
        dt.setValue(data.cook_time, forKey: "cook_time")
        dt.setValue(data.ingredients, forKey: "ingredients")
        dt.setValue(data.instructions, forKey: "instructions")


        // Save the data
        do {
            try self.context.save()
        } catch {
            print("error")
        }
        //clearKeywordDelegate.clearKeyword(clear: true)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    func convertImageToData(myImagesArray: [UIImage]) -> [Data] {
        var myImagesDataArray = [Data]()
        myImagesArray.forEach({ (image) in
            myImagesDataArray.append(image.pngData()!)
            
        })
        return myImagesDataArray
    }
    
    
    
    // MARK: - Regular Functions
    func add(
    stringList: [String],
    font: UIFont,
    bullet: String = "\u{2022}",
    indentation: CGFloat = 20,
    lineSpacing: CGFloat = 2,
    paragraphSpacing: CGFloat = 12,
    textColor: UIColor = .black,
    bulletColor: UIColor = .black) -> NSAttributedString {
     
       let textAttributes: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
       let bulletAttributes: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
     
       let paragraphStyle = NSMutableParagraphStyle()
       let nonOptions = [NSTextTab.OptionKey: Any]()
    paragraphStyle.tabStops = [
    NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
       paragraphStyle.defaultTabInterval = indentation
       paragraphStyle.lineSpacing = lineSpacing
       paragraphStyle.paragraphSpacing = paragraphSpacing
       paragraphStyle.headIndent = indentation
     
       let bulletList = NSMutableAttributedString()
       for string in stringList {
          let formattedString = "\(bullet)\t\(string)\n"
          let attributedString = NSMutableAttributedString(string: formattedString)
     
          attributedString.addAttributes(
    [NSAttributedString.Key.paragraphStyle : paragraphStyle],
    range: NSMakeRange(0, attributedString.length))
     
          attributedString.addAttributes(
    textAttributes,
    range: NSMakeRange(0, attributedString.length))
     
          let string:NSString = NSString(string: formattedString)
          let rangeForBullet:NSRange = string.range(of: bullet)
          attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
          bulletList.append(attributedString)
       }
       return bulletList
    }


}
