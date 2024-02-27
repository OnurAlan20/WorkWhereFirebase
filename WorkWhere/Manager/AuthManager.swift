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

class AuthManager {
    
    static let shared = AuthManager()
    let firebaseAuth = Auth.auth()

    
    
    func createUserWithEmail(email: String, password: String){
        firebaseAuth.createUser(withEmail: email, password: password)
       
    }
    func getAuthenticatedUser()throws -> AuthDataResultModel{
        guard let user = firebaseAuth.currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    func signInWithEmail(email: String, password: String) async throws -> AuthDataResultModel{
        let authResult = try await firebaseAuth.signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authResult.user)
    }
    
    func signOut()throws{
        try firebaseAuth.signOut()
    }
    
    func signWithGoogle() async throws -> AuthDataResultModel?{
        let viewController = Brain.topViewController()
        if viewController != nil {
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController!)
            
            guard let IDToken = gidSignInResult.user.idToken?.tokenString else{
                throw URLError(.badServerResponse)
            }
            let accessToken = gidSignInResult.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: IDToken, accessToken: accessToken)
            
            let authDataResult = try await firebaseAuth.signIn(with: credential)
            
            return AuthDataResultModel(user: authDataResult.user)
            
        }
        return nil
        
    }
    
    
    
}
