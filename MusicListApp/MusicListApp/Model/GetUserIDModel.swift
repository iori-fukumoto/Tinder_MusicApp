//
//  GetUserIDModel.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/10.
//

import Foundation
import Firebase
import PKHUD


class GetUserIDModel {
    
    var userID:String! = ""
    var userName:String! = ""
    var ref:DatabaseReference! = Database.database().reference().child("profile")
    
    init(snapshot:DataSnapshot){
        
        ref = snapshot.ref
        
        //valueに値があるかの確認
        if let value = snapshot.value as? [String:Any]{
            
            //valueの"userID"というキー値をString型でとってくる
            userID = value["userID"] as? String
            userName = value["userName"] as? String
            
        }
        
    }
    
}
