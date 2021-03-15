//
//  FavoriteViewController.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import UIKit
import Firebase
import SDWebImage
import AVFoundation //音を流すために必要
import PKHUD


//再生ボタンのクラス
class PlayMusicButton:UIButton{
    
    var params:Dictionary<String,Any>
    override init(frame:CGRect){
        
        
        self.params = [:]
        //親クラス（UIButton）のinitを使ってくださいという意味
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.params = [:]
        super.init(coder: aDecoder)
        
    }
    
}



//ここでやりたいこと：自分のIDを探してその下にあるお気に入りリストをとってくる。
class FavoriteViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,URLSessionDownloadDelegate {
    

    
    @IBOutlet weak var favTableView: UITableView!
    
    //MusicDataModelが持つプロパティを入れる配列をつくる
    var musicDataModelArray = [MusicDataModel]()
    var artWorkUrl = ""
    var previewUrl = ""
    var artistName = ""
    var trackCensoredName = ""
    var imageString = ""
    var userID = ""
    //データベースを初期化
    var favRef = Database.database().reference()
    var userName = ""
    
    var player:AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //allowsSelectionをtrueにすることでセルを選択できるようなる。
        favTableView.allowsSelection = true
        
        //userIDとuserNameをとってくる
        if UserDefaults.standard.object(forKey: "userID") != nil{
            userID = UserDefaults.standard.object(forKey: "userID") as! String
        }
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
            //NavigationBarのタイトルの部分。（NabigationControllerを継承しているから使える）
            self.title = "\(userName)'s MusicList"
            
        }
        
        
        favTableView.delegate = self
        favTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.title = "\(userName)'s MusicList"
        //ナビゲーションコントローラーの色を指定する
        self.navigationController?.navigationBar.tintColor = .white
        //ナビゲーションバーを表示する（隠さない）
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    
    //ここでsnapshotを使って値をとってくる。難しい。。。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //インディケーター（くるくる）を回す
        HUD.show(.progress)
        
        //値を取得する → usersの自分のIDの下にあるお気に入りにしたコンテンツ全て
        favRef.child("users").child(userID).observe(.value){
            (snapshot) in
            
            //何回も検索できるように、for文を回す前に配列の中身を空にする。
            self.musicDataModelArray.removeAll()
            
            //for文で値を取得していく.snapshot.childrenはuserIDの下のオートIDを指している。childはsnapshot.childrenの数のこと。
            for child in snapshot.children{
                
                //MusicDataModelのイニシャライザに入れるためにDataSnapshot型に変換している。
                let childSnapshot = child as! DataSnapshot
                //DataModelの2つ目のinitを使って値をとる.インスタンス化して値をとってくる。
                let musicData = MusicDataModel(snapshot: childSnapshot)
                //配列の一番上に入れていく（appendと一緒）
                self.musicDataModelArray.insert(musicData, at: 0)
                //リロードデータでnumberOfRowsInSection,cellForRowAtが呼ばれる
                self.favTableView.reloadData()
                
            }
            
            //データをとったらインディケータを消す。
            HUD.hide()
        }
        //ここが呼ばれる。snapshotにデータが入ったら、上の{}内が呼ばれる
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicDataModelArray.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 225
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //引数がtableViewなのでfavではなくtableViewでOK
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        let musicDataModel = musicDataModelArray[indexPath.row]
        
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let label1 = cell.contentView.viewWithTag(2) as! UILabel
        let label2 = cell.contentView.viewWithTag(3) as! UILabel
        label1.text = musicDataModel.artistName
        label2.text = musicDataModel.musicName
        
        //imageはimageString（String型）で返ってくる。SDWebImageを使う。placeholderImageは表示されるまでの画像。
        imageView.sd_setImage(with: URL(string: musicDataModel.imageString), placeholderImage: UIImage(named: "noimage"),options:.continueInBackground, context: nil, progress: nil, completed: nil)
        
        
        //再生ボタン（クラスをつくる）previewUrlをダウンロードして音を再生しないといけない。
        let playButton = PlayMusicButton(frame: CGRect(x: view.frame.size.width - 60, y: 50, width: 60, height: 60))
        playButton.setImage(UIImage(named: "play"), for: .normal)
        //ボタンが押されるという挙動
        playButton.addTarget(self, action: #selector(playButtonTap(_ :)), for: .touchUpInside)
        playButton.params["value"] = indexPath.row
        cell.accessoryView = playButton
        
        
        return cell
        
    }

    
    //ボタンが押されたときに呼ばれる。addTargetのactionで。
    @objc func playButtonTap(_ sender:PlayMusicButton){
        
        //音楽を止める
        if player?.isPlaying == true{
          
            player!.stop()
        }
        
        //senderとは押されたボタン(playButton)のこと
        let indexNumber:Int = sender.params["value"] as! Int
        let urlString = musicDataModelArray[indexNumber].preViewURL
        let url = URL(string: urlString)
        
        print(url!)
        
        //ダウンロード(メソッドを利用)
        downLoadMusicURL(url: url!)
        
    }
    
    
    //戻ると同時に音楽を止める
    @IBAction func back(_ sender: Any) {
        
        //音楽を止める
        if player?.isPlaying == true{
          
            player!.stop()
        }
        
        //戻る遷移
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    //playButtonTapで使うメソッド
    func downLoadMusicURL(url:URL){
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            
            //再生(メソッドを利用)
            self.play(url: url!)
            
        })
        
        //クロージャでここにきたときに処理を止めないように
        downloadTask.resume()
        
    }
    
    //downLoadMusicURLで使うメソッド
    func play(url:URL){
        
        do {
            
            self.player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
            
        } catch let error as NSError{
            
            print(error.localizedDescription)
            
        }
        
        
    }
    
    

    //URLSessionDownloadDelegateを入れたときのイニシャライザ。ダウンロードが終わった後に行われる
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("DONE")
        
    }
    
    
    

}
