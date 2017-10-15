//
//  ViewController.swift
//  ClarifaiCam
//
//  Created by Elizabeth Siegle on 10/8/17.
//  Copyright © 2017 Elizabeth Siegle. All rights reserved.
//

import UIKit
import Clarifai_Apple_SDK
import WebKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, WKNavigationDelegate {
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var libraryButton: UIButton!
    
    @IBOutlet var spotifyLogin: UIButton!
    @IBOutlet var imgView: UIImageView!
    var concepts: [Concept] = []
    var customModel: Model!
    var model: Model!
    let CUSTOM_MODEL_SEGMENT = 1
    var webView: WKWebView
    
    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player:SPTAudioStreamingController?
    var loginUrl: URL?
    var search: SPTSearch?
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)!
        
        self.webView.navigationDelegate = self
    }
//    @IBOutlet var pTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if customModel == nil {
            // Set the model to the General Model
            // The model in the sample code below is our General Model.
            self.model = Clarifai.sharedInstance().generalModel
        } else {
            // Set the model to the Custom Trained Model
            // To learn how to train a model: TrainingController.swift
            self.model = customModel
        }
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        
    }
    @objc func updateAfterFirstLogin () {
        spotifyLogin.isHidden = true
        let userDefaults = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        }
    }
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self as! SPTAudioStreamingPlaybackDelegate
            self.player!.delegate = self as! SPTAudioStreamingDelegate
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //Button action to access the Camera and capture the image
    @IBAction func openCam(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate=self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
       
    }

    //Image PickerControl Delegate Method
    @objc func imagePickerController(_ picker: UIImagePickerController,    didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imgView?.image = image //This is where we are assigning the selected or captured image to the imageview.
            imgView?.contentMode = .scaleAspectFit
            self.dismiss(animated: true, completion: nil)
            predict()
        }
        
    }
    @IBAction func libraryPics(_ sender: Any)  {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate=self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func predict() {
        self.concepts.removeAll()
        
        // Initialize Image object from image Device
        let image = Image(image: imgView.image)
        
        let dataAsset = DataAsset.init(image: image)
        // Create Input(s) and Input(s) Array w/ the data asset, temporal information
        let input = Input.init(dataAsset:dataAsset)
        let inputs = [input]
        
        /// Use the model you want to predict on. This can be a custom trained or one of our public models.
        self.model.predict(inputs, completionHandler: {(outputs: [Output]?,error: Error?) -> Void in
            // Iterate through outputs to learn about what has been predicted
            for output in outputs! {
                // Do something with your outputs
                self.concepts.append(contentsOf: output.dataAsset.concepts!)
            }
            for (offset, _) in self.concepts.enumerated() {
                //self.modelNameLabel.text = "\u{2022} \(self.concepts[offset].name)"
                print(self.concepts[offset].name)
                print(self.concepts[offset].score)
            }
        })
    }
    
    @IBAction func spotifyLoginButtonClicked(_ sender: Any) {
        if UIApplication.shared.openURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                print("here")
                
            }
        }
    }
    func setup() {
        SPTAuth.defaultInstance().clientID = SpotifyClientID
        SPTAuth.defaultInstance().redirectURL = URL(string: "https://elizabethsiegle.github.io")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
