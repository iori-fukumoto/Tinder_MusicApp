//
//  SaveProfile.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import Foundation
import Firebase
import PKHUD

class SaveProfile {
    
    //サーバーに値を飛ばす
    var userID:String = ""
    var userName:String = ""
    var ref:DatabaseReference!
    
    init(userID: String,userName: String){
        
        self.userID = userID
        self.userName = userName
        
        
        //ログインのときに拾えるuidを先頭につけて送信する。受信する時もuidから引っ張ってくる。
        //保存先を指定する。（まだ保存はされてない）、保存はsetValueで。メモで記載した登録ID①の下に作ってくださいねという意味。
        ref = Database.database().reference().child("profile").childByAutoId()
    }
    
    //受信のときに使う。
    init(snapShot:DataSnapshot) {
        
        ref = snapShot.ref
        
        //もしvalueが空じゃない場合の指定
        //ここ動画では！ではなく？
        if let value = snapShot.value as? [String:Any]{
            
            userID = value["userID"] as! String
            userName = value["userName"] as! String
            
        }
        
    }
    
    func toContents() -> [String:Any]{
        
        return ["userID":userID,"userName":userName as Any]
        
    }
    
    //メモで記載した登録ID①の下にtoContents()で返された値を保存してくださいね、という意味。
    func saveProfile(){
        
        //refの中にtoContentsをsetValue（DBへ保存）する。toContentsにはキー値"userID","userName"が値として入っている。
        ref.setValue(toContents())
        //メモの登録ID①の部分を保存した。
        UserDefaults.standard.set(ref.key, forKey: "autoID")
        
    }
    
}


