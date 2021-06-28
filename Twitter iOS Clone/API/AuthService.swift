//
//  AuthService.swift
//  Twitter iOS Clone
//
//  Created by Henrique Silva on 28/06/21.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
    
}

struct AuthService {
    static let shared = AuthService()
    
    func registerUser(credencials: AuthCredentials, completion: @escaping(Error? , DatabaseReference) -> Void) {
        
        let email = credencials.email
        let password = credencials.password
        let username = credencials.username
        let fullname = credencials.fullname
        
        guard let imageData = credencials.profileImage.jpegData(compressionQuality: 0.3) else {return}
        
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print("DEBUG: Error is\(error.localizedDescription)")
                        return
                    }
                    guard let uid = result?.user.uid else { return }
                    
                    let values = ["email": email, "username": username, "fullnamed": fullname]
                    
                    REF_USER.child(uid).updateChildValues(values) { (error, ref) in
                        print("DEBUG: Succesffully update user information...")
                    }
                }
            }
        }
    }
}
