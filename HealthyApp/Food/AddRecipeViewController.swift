//
//  AddRecipeViewController.swift
//  HealthyApp
//
//  Created by Christian Willson on 06/11/21.
//  Copyright © 2021 Christian Willson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import PhotosUI

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let ref = Database.database(url: "https://healthy-app-9861e-default-rtdb.firebaseio.com/").reference()
    
    private let storage = Storage.storage().reference()

    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var foodCategotyTextField: UITextField!
    @IBOutlet weak var cookDurationTextField: UITextField!
    
    @IBOutlet weak var foodDesc: UITextView!
    @IBOutlet weak var foodIngredients: UITextView!
    @IBOutlet weak var cookInstructions: UITextView!
    var ingredients: [String] = []
    var instructions: [String] = []
    
    var images = [UIImage]()
    private var imagesData = [Data]()
    private var imagesName = [String]()
    var test: Data!
    
    @IBAction func chooseImageBtn(_ sender: UIButton) {
        askPermission()
    }
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBOutlet weak var submitBtnOutlet: UIButton!
    
    @IBAction func submitBtn(_ sender: UIButton) {
        
        if foodNameTextField.text == "" || foodCategotyTextField.text == "" || cookDurationTextField.text == "" || foodDesc.text == "" || foodIngredients.text == "" || cookInstructions.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please fill all blank data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            foodIngredients.text.enumerateLines { line, _ in
                self.ingredients.append(line)
            }
            
            cookInstructions.text.enumerateLines { line, _ in
                self.instructions.append(line)
            }
            
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to upload this data?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { [self] (action) -> Void in
                
                var counter = 0
                
                let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating();

                alert.view.addSubview(loadingIndicator)
                present(alert, animated: true, completion: nil)
        
                for i in 0..<self.imagesData.count {
                    
                    let randomThumbnailImageFileName = self.randomString(length: 8)
                    self.storage.child("recipe_img/\(randomThumbnailImageFileName).png").putData(imagesData[i], metadata: nil, completion: { _, error in
                        guard error == nil else {
                            let alert = UIAlertController(title: "Error", message: "Failed to upload thumbnail.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
            
                        self.storage.child("recipe_img/\(randomThumbnailImageFileName).png").downloadURL(completion: { url, error in
                            guard let url = url, error == nil else {
                                let alert = UIAlertController(title: "Error", message: "Something went wrong when fetching the url data", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
            
                            let urlString = url.absoluteString
                            
                            self.imagesName.append(urlString)
                            counter += 1
                            
                            DispatchQueue.main.async {
                                if counter == 4 {
                                    self.setDataToDatabase(imagesName: self.imagesName)
                                    dismiss(animated: false, completion: nil)
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
                            }
                        
            
                        })
            
                    })
                }
                
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            
            }
            
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            self.present(dialogMessage, animated: true, completion: nil)
            
            
        }
    
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollection.delegate = self
        imageCollection.dataSource = self
        
        submitBtnOutlet.isEnabled = false
        
    }
    
    func askPermission() {
        PHPhotoLibrary.requestAuthorization({(status) in
            if status == PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    self.showPhotoLibrary()
                }
            } else {
                print("No Photo Access")
            }
        })
    }
    
    func showPhotoLibrary() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            
            config.selectionLimit = 4
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            
            present(picker, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
    // MARK: - Firebase Functions
 
    func setDataToDatabase(imagesName: [String]) {
        ref.child("Recipe").childByAutoId().setValue(
            ["author": UserDefaults.standard.string(forKey: "email")!,
             "name": "\(String(describing: foodNameTextField.text!))",
             "cook_time": "\(String(describing: cookDurationTextField.text!)) minutes",
             "category": "\(String(describing: foodCategotyTextField.text!))",
             "descriptions": "\(String(describing: foodDesc.text!))",
             "images": imagesName,
             "ingredients": ingredients,
             "instructions": instructions
            ]
        )
    }

}

extension AddRecipeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewImageCollectionViewCell", for: indexPath) as! PreviewImageCollectionViewCell
        
        cell.previewImage.image = images[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width/3.2, height: view.frame.size.width/3.2)
    }
    
    
}

extension AddRecipeViewController: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        let itemProviders = results.map(\.itemProvider)
        
        self.imagesData = []
        self.images = []
        imageCollection.reloadData()
        
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async { [self] in
                        if let image = image as? UIImage {
                            //Access your image
                            self.images.append(image)
                            
                            guard let _imageData = image.pngData() else {return}
                            self.imagesData.append(_imageData)
                            
                            test = _imageData
                            
                            self.imageCollection.reloadData()
                            
                            if self.images.count == 4 {
                                submitBtnOutlet.isEnabled = true
                            }
                            
                            self.thumbnailImageView.image = nil
                            self.thumbnailImageView.image = self.images[0]
                        }
                    }
                }
            }
        }
    }
}
