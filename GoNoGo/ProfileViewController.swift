//
//  ProfileViewController.swift
//  GoNoGo
//
//  Created by Jeel on 7/28/16.
//  Copyright © 2016 Ismael. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseAuth
import SwiftCompressor
import FBSDKLoginKit

class ProfileViewController: UIViewController, UICollectionViewDataSource{

    @IBOutlet weak var FBLogIn: FBSDKLoginButton!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    var myArray = [AnyObject]()
    var scoreArray = [AnyObject]()
    let reuseIdentifier = "cell"
    
    let database = FIRDatabase.database().reference()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
            FIRAuth.auth()?.addAuthStateDidChangeListener(
                {
                    (auth, user) in
                    if let currentUsr  = user
                    {
                        
                        self.database.child("Users").child(currentUsr.uid).child("Images").observeEventType(.Value, withBlock: { snapshot in
                            self.myArray = []
                         
                            
                                for (_, imageKey) in  snapshot.children.enumerate()
                                {

                                   self.myArray.append(imageKey)
                                    
                                }
                            
                            
                            self.myCollectionView.reloadData()
                        })
                        
                        self.database.child("Opinions").observeEventType(.ChildAdded, withBlock: { snapshot in
                            self.scoreArray = []
                            
                            for(_, imageScoreKey) in snapshot.children.enumerate()
                            {
                                self.scoreArray.append(imageScoreKey)
                            }
                        })
                    }
            })
        
    }
    
    @IBAction func LogOut(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainViewController")
        self.navigationController!.pushViewController(mainViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myArray.count
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell

        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        let images = myArray[indexPath.row]

            var lines = ""
            for i in images.children
            {
                lines.appendContentsOf(i.value!!)
                
            }
   
            do
            {
                
                let imageData = try NSData(base64EncodedString: lines ,
                                             options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)?.decompress()
                
                let decodedImage = UIImage(data:imageData!)

                cell.myImageView.image = decodedImage

            }
            
            catch{}
        
        return cell
        
        
    }

}
