//
//  ProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 4/29/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage
import Foundation
import Lottie
class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var lottieView: UIView!
    static var assignedStringColor: String = UIColor.toHexString(UIColor.random)()
    var handle: AuthStateDidChangeListenerHandle?
    let animationView = AnimationView()
    let user: User? = Auth.auth().currentUser
    var userInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "",color: "")
    var otherUserID: String = ""
    
    // MARK: - VC Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.animation = Animation.named("4414-bouncy-basketball")
        
        animationView.frame.size = lottieView.frame.size
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        lottieView.addSubview(animationView)
        animationView.play()
        
        if !otherUserID.isEmpty {
            loadUserProfile(userID: otherUserID)
        }
        else if let userID = user?.uid {
            loadUserProfile(userID: userID)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard self.user == user else {
                print("Not logged in")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(identifier: "SignUpViewController")
                self.view.window?.rootViewController = loginVC
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if handle != nil {
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Profile Loading
    
    func loadUserProfile(userID: String) {
        FirebaseReferences.usersRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let name = value?["name"] as? String
            let username = value?["username"] as? String
            let bio = value?["bio"] as? String
            let photoURLString = value?["photoURL"] as? String
            let age = value?["age"] as? String
            
            if let _ = URL(string: photoURLString ?? "") {
                self.loadProfilePicture(userID: userID)
            }
            else {
                self.editButton.isEnabled = true
            }
            self.userInfo = UserInfo(username: username, name: name, bio: bio, age:age, photoURL: photoURLString, color: ProfileViewController.self.assignedStringColor) // here
            
            if self.userInfo.name.isEmpty {
                self.nameLabel.text = "No name"
            }
            else {
                self.nameLabel.text = self.userInfo.name
            }
            if self.userInfo.username.isEmpty {
                self.usernameLabel.text = "No username"
            }
            else {
                self.usernameLabel.text = self.userInfo.username
            }
            if self.userInfo.bio.isEmpty {
                self.bioTextView.text = "No bio"
            }
            else {
                self.bioTextView.text = self.userInfo.bio
            }
            if self.userInfo.age.isEmpty {
                self.ageLabel.text = "No Age"
            }
            else {
                self.ageLabel.text = "Age: \(self.userInfo.age)"
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadProfilePicture(userID: String) {
        FirebaseReferences.imagesRef.child(userID).getData(maxSize: 5 * 1024 * 1024) { (data, error) in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            self.profilePicture.image = UIImage(data: data)
            self.profilePicture.layer.cornerRadius = 10
            self.profilePicture.layer.borderWidth = 4
            self.profilePicture.layer.borderColor = UIColor.systemGray.cgColor
            self.editButton.isEnabled = true
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfile" {
            let editProfileVC = segue.destination as! EditProfileViewController
            editProfileVC.userInfo = self.userInfo
            editProfileVC.initialPhoto = self.profilePicture.image
        }
    }
    
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
}
