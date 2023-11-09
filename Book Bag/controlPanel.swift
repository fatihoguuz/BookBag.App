//
//  controlPanel.swift
//  Book Bag
//
//  Created by Fatih Oğuz on 8.11.2023.
//

import UIKit
import CoreData

class controlPanel: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bookName: UITextField!
    @IBOutlet weak var authorName: UITextField!
    @IBOutlet weak var pageTextField: UITextField!
    @IBOutlet weak var pointTexField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            //Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let boName = result.value(forKey: "bName") as? String {
                           bookName.text = boName
                        }
                        
                        if let auName = result.value(forKey: "aName") as? String {
                           authorName.text = auName
                        }
                        
                        if let page = result.value(forKey: "page") as? Int {
                            pageTextField.text = String(page)
                        }
                        
                        if let point = result.value(forKey: "point") as? Int {
                            pointTexField.text = String(point)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                    }
                }
                
            } catch{
                print("error")
            }
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            bookName.text = ""
            authorName.text = ""
            pageTextField.text = ""
            pointTexField.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
    @IBAction func button(_ sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        newPainting.setValue(bookName.text!, forKey: "bName")
        newPainting.setValue(authorName.text!, forKey: "aName")
        
        if let page = Int(pageTextField.text!) {
            newPainting.setValue(page, forKey: "page")
        }
        if let point = Int(pointTexField.text!) {
            newPainting.setValue(point, forKey: "point")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
