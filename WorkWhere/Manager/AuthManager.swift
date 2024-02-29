//
//  Firebase .swift
//  WorkWhere
//
//  Created by Onur Alan on 11.02.2024.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore


struct AuthDataResultModel{
    let uid:String
    let email:String?
    let photoUrl:String?
    
    init(user:User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}
/*
struct UserModel: Identifiable {
        let id: String
        let email: String
        let profileImage: String
        let name: String
        let posts: [String]
        
        init(id: String, email: String, profileImage: String, name: String, posts: [String]) {
            self.id = id
            self.email = email
            self.profileImage = profileImage
            self.name = name
            self.posts = posts
        }
}
 */


class AuthManager {
    
    static let shared = AuthManager()
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()


    /*
    
    func createUserWithEmail(email: String, password: String){
        firebaseAuth.createUser(withEmail: email, password: password)
       
    }
     */
     
      /*
    func signInWithEmail(email: String, password: String) async throws -> AuthDataResultModel{
        let authResult = try await firebaseAuth.signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authResult.user)
    }
     */
    
    
    
    func getUserById(id: String, completion: @escaping (UserModel?) -> Void) {
        db.collection("user").whereField("id", isEqualTo: id).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("Hata oluştu: \(error)")
                completion(nil) // Hata durumunda nil döndür
                return
            }
            
            if let doc = snapshot.documents.first {
                let userModel = UserModel(
                    id: doc["id"] as! String,
                    email: doc["email"] as! String,
                    profileImage: doc["profileImage"] as! String,
                    name: doc["name"] as! String,
                    posts: doc["posts"] as! [String]
                )
                completion(userModel)
            } else {
                print("Kullanıcı bulunamadı")
                completion(nil)
            }
        }
    }
    
    func signOut()throws{
        try firebaseAuth.signOut()
    }
    // mevcut kullanıcıyı çekmek için bu fonksyonu kullan önemli getAuthenticatedUser() ı kullanmıyacaksın
    func getUserData() async throws -> UserModel? {
        return try await getAuthenticatedUser()
    }
    // giriş yapmak için bu fonksyonu kullan
    func signWithGoogle() async throws -> UserModel? {
        let viewController = Brain.topViewController()
        if viewController != nil {
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController!)
            
            guard let IDToken = gidSignInResult.user.idToken?.tokenString else {
                throw URLError(.badServerResponse)
            }
            let accessToken = gidSignInResult.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: IDToken, accessToken: accessToken)
            
            let authDataResult = try await firebaseAuth.signIn(with: credential)
            
            if authDataResult.additionalUserInfo?.isNewUser == true {
                let authdataResultModel = AuthDataResultModel(user: authDataResult.user)
                
                let user = UserModel(id: authdataResultModel.uid, email: authdataResultModel.email, profileImage: authdataResultModel.photoUrl, name: authDataResult.user.displayName, posts: [])
                
                let data: [String: Any] = [
                    "id": user.id,
                    "email": user.email,
                    "profileImage": user.profileImage,
                    "name": user.name,
                    "posts": user.posts,
                ]
                db.collection("user").addDocument(data: data) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added successfully")
                    }
                }
            }
            
            return try await getUserData()
        }
        return nil
    }
    func getAuthenticatedUser() async throws -> UserModel? {
        guard let user = firebaseAuth.currentUser else {
            return nil
        }
        
        let snapshot = try await db.collection("user").whereField("id", isEqualTo: user.uid).getDocuments()
        
        guard let doc = snapshot.documents.first else {
            return nil
        }
        
        let userData = doc.data()
        let userModel = UserModel(
            id: user.uid,
            email: user.email,
            profileImage: userData["profileImage"] as! String,
            name: userData["name"] as! String,
            posts: userData["posts"] as! [String]
        )
        
        return userModel
    }
    
    

    
    
    
}


