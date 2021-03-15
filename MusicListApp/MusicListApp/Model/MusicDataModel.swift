//
//  MusicDataModel.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import Foundation
import Firebase
import PKHUD

//SaveProfileモデルと同じ要領でやっていく
class MusicDataModel {
    
    var artistName:String = ""
    var musicName:String = ""
    var preViewURL:String = ""
    var imageString:String = ""
    var userID:String = ""
    var userName:String = ""
    var artistViewURL:String = ""
    let ref:DatabaseReference!
    
    var key:String! = ""
    
    init(artistName:String,musicName:String,preViewURL:String,imageString:String,userID:String,userName:String){
        
        self.artistName = artistName
        self.musicName = musicName
        self.preViewURL = preViewURL
        self.imageString = imageString
        self.userID = userID
        self.userName = userName
        
        //ログインのときに拾えるuidを先頭につけて送信、受信する時もuidから引っ張ってくる
        //usersのuserIDの下に保存してくださいね、という意味。
        ref = Database.database().reference().child("users").child(userID).childByAutoId()
        
    }
    
    //これいつ使う？受信の時に使うらしい。
    init(snapshot:DataSnapshot) {
        
        
        ref = snapshot.ref
        if let value = snapshot.value as? [String:Any]{
            
            artistName = (value["artistName"] as? String)!
            musicName = (value["musicName"] as? String)!
            preViewURL = (value["preViewURL"] as? String)!
            imageString = (value["imageString"] as? String)!
            userID = (value["userID"] as? String)!
            userName = (value["userName"] as? String)!
            
        }
        
    }
    
    func toContents() -> [String:Any]{
        
        //イニシャライザで入ってきた値を辞書型にする。
        return ["artistName":artistName,"musicName":musicName,"preViewURL":preViewURL,"imageString":imageString,"userID":userID,"userName":userName]
        
    }
    
    //usersのuserIDの下にtoContents()で返された値を保存してくださいね、という意味。toContentsを一緒に書くこともできるがわかりやすいようにあえて分けている。
    func save(){
        
        //setValueでfireBaseに保存する。
        ref.setValue(toContents())
        
    }
    
    
}

