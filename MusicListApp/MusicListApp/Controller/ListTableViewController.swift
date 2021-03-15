//
//  ListTableViewController.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/10.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseAuth
import PKHUD



class ListTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var listRef = Database.database().reference()
    var indexNumber = Int()
    
    //空の配列
    var getUserIDModelArray = [GetUserIDModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ナビゲーションバーを表示する
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        HUD.show(.success)
        //コンテンツを取得する。FavoriteViewでやったのと同じ感じ。受信をするだけのModelを作る。
        //profileから下全てをとってくるように指定
        listRef.child("profile").observe(.value) { (snapshot) in
            
            HUD.hide()
            //何回も検索できるように、for文を回す前に配列の中身を空にする。
            self.getUserIDModelArray.removeAll()
            
            //snapshotというのはオートID以下のこと。オートIDにはID,nameが付いている。
            for child in snapshot.children{
                
                //MusicDataModelのイニシャライザに入れるためにDataSnapshot型に変換している。
                let childSnapshot = child as! DataSnapshot
                let listData = GetUserIDModel(snapshot: childSnapshot)
                self.getUserIDModelArray.insert(listData, at: 0)
                self.tableView.reloadData()
                
                
            }
            
            
        }
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getUserIDModelArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 225
    }
    
    
    //セルの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        //灰色になっちゃうから？ビルドで確認
        cell?.selectionStyle = .none
        
        //numberOfRowsInSectionの数だけ呼ばれるのでindexpath.row
        let listDataModel = getUserIDModelArray[indexPath.row]
        let userNameLabel = cell?.contentView.viewWithTag(1) as! UILabel
        userNameLabel.text = "\(String(describing: listDataModel.userName!))'s List"
        
        return cell!
        
    }
    
    
    //セルがタップされたときの挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //userIDとuserNameを渡して、渡されたControllerでIDからusers.idで全部値を取得して、userNameのListとして表示させるための準備。
        
        //タップされたら、userName,userIDを渡す。これだけで渡し完了。
        let otherVC = self.storyboard?.instantiateViewController(identifier: "otherList") as! OtherPersonListViewController
        
        let listDataModel = getUserIDModelArray[indexPath.row]
        
        otherVC.userName = listDataModel.userName
        otherVC.userID = listDataModel.userID
        
        self.navigationController?.pushViewController(otherVC, animated: true)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
