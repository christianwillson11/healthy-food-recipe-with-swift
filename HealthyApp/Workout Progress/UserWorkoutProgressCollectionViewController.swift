import UIKit
import CoreData

class UserWorkoutProgressCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Variables
    private var items = [WorkoutProgress]()
    private var imagesDataArray = [[Data]]()
    
    //date
    let date = Date()
    // Create Date Formatter
    let dateFormatter = DateFormatter()

    
    @IBAction func addBtn(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
//        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImagesData()
    }
    
    //MARK:- Workout Progress (CoreData)
    
    func convertImageToData(myImagesArray: [UIImage]) -> [Data] {
        var myImagesDataArray = [Data]()
        myImagesArray.forEach({ (image) in
            myImagesDataArray.append(image.pngData()!)
            
        })
        return myImagesDataArray
    }
    
    func saveImagesToCoreData(myImagesDataArray: [Data]) {
        dateFormatter.dateStyle = .long
        let entityName =  NSEntityDescription.entity(forEntityName: "WorkoutProgress", in: context)!
        let image = NSManagedObject(entity: entityName, insertInto: context)
        var images: Data?

        //to store array of images using encoding
        do {
            images = try NSKeyedArchiver.archivedData(withRootObject: myImagesDataArray, requiringSecureCoding: true)
        } catch {
            
            //TODO: Create alert "Error save the data"
            print("ERROR 1")
        }
        image.setValue(images, forKeyPath: "images")
        image.setValue(dateFormatter.string(from: date), forKey: "date")
        
        do {
          try context.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchImagesData() {
        imagesDataArray = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WorkoutProgress")
        var tmp = [Data]()
        do {
            items = try context.fetch(fetchRequest) as! [WorkoutProgress]
            for data in items {
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
    
    func removeImageData(index: Int) {
        
        self.context.delete(items[index])
        if !imagesDataArray.isEmpty {
            imagesDataArray.remove(at: index)
        }
        
        do {
            try self.context.save()
        } catch {
            print("ERROR")
        }
        
    }
    
    


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return items.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imagesDataArray[section].count
    }
    
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
    
        cell.mainImage.image = UIImage(data: imagesDataArray[indexPath.section][indexPath.row])
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ImageHeaderCollectionReusableView", for: indexPath) as! ImageHeaderCollectionReusableView
        

        sectionHeaderView.date = items[indexPath.section].date

        return sectionHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3.2,
                      height: view.frame.size.width/3.2)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(identifier: "DetailPhotoViewController") as! DetailPhotoViewController
        detailVC.image = UIImage(data: imagesDataArray[indexPath.section][indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let delete = UIAction(title: "Delete",
                                image: UIImage(systemName: "trash"),
                                identifier: nil,
                                discoverabilityTitle: nil,
                                attributes: .destructive,
                                state: .off)
            { _ in
                print("Tapped delete at index  \(indexPath.row)")
                self.removeImageData(index: indexPath.row)
                self.collectionView.reloadData()
            }
            
            return UIMenu(title: "",
                          image: nil,
                          identifier: nil,
                          options: UIMenu.Options.displayInline,
                          children: [delete]
            )
        }
        return config
    }
    

}

extension UserWorkoutProgressCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        var tmp = [Data]()
        
        dateFormatter.dateStyle = .long
        if (!imagesDataArray.isEmpty && items[items.count - 1].date! == dateFormatter.string(from: date)) {
            for i in 0..<imagesDataArray[items.count - 1].count {
                tmp.append(imagesDataArray[items.count - 1][i])
            }
            removeImageData(index: items.count - 1)
        }

        tmp.append(convertImageToData(myImagesArray: [image])[0])
        saveImagesToCoreData(myImagesDataArray: tmp)
        fetchImagesData()
        collectionView.reloadData()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
