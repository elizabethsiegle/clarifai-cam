//
//  ViewController.swift
//  ClarifaiCam
//
//  Created by Elizabeth Siegle on 10/8/17.
//  Copyright © 2017 Elizabeth Siegle. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    @IBOutlet var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    //Button action to access the Camera and capture the image
    @IBAction func openCam(_ sender: UIButton) {
        if UIImagePickerController
            .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate=self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self .present(imagePicker, animated: true, completion: nil)
        }
    }

    //Image PickerControl Delegate Method
    func imagePickerController(_ picker: UIImagePickerController,    didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imgView?.image = image //This is where we are assigning the selected or captured image to the imageview.
            imgView?.contentMode = .scaleAspectFit
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func libraryPics(_ sender: Any) {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate=self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self .present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

