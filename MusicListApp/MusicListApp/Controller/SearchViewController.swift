//
//  SearchViewController.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import UIKit
import PKHUD //通信中のくるくる
import Alamofire //通信を行う
import SwiftyJSON //Json解析を楽にする
import DTGradientButton //グラデーションボタン
import Firebase
import FirebaseAuth
import ChameleonFramework


class SearchViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var searchTextField: UITextField!
    //グラデーションをかけるためにつなげる
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    //配列を作る。AppleのJsonデータのキー値に合わせて配列をつくっている。
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    //音源が入った情報を入れる
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    
    var userID = String()
    var userName = String()
    var autoID = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ユーザーログインがまだの場合ログイン画面を表示
        //autoIDがあればそれを保存。
        if UserDefaults.standard.object(forKey: "autoID") != nil{
            
            autoID = UserDefaults.standard.object(forKey: "autoID") as! String
            print(autoID)
            
        }else{
            //autoIDがなければログイン画面を表示。
            //Main.storyboardをインスタンス化
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //ログイン画面をインスタンス化。"LoginViewController"をログイン画面に設定。
            let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController")
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
            
        }
        
        //autoIDと同じように,userID.userNameも保存
        if UserDefaults.standard.object(forKey: "userID") != nil &&  UserDefaults.standard.object(forKey: "userID") != nil{
            
            userID = UserDefaults.standard.object(forKey: "userID") as! String
            userName = UserDefaults.standard.object(forKey: "userName") as! String
            
        }
        
        //search画面にきた瞬間にキーボードを出してあげる
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
        
        //お気に入りボタンとみんなのリストボタンをオシャンに
        favButton.setGradientBackgroundColors([UIColor(hex:"E21F70"),UIColor(hex:"FF4D2C")], direction: .toBottom, for: .normal)
        
        listButton.setGradientBackgroundColors([UIColor(hex:"FF8960"),UIColor(hex:"FF62A5")], direction: .toBottom, for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    //viewDidRoadの後に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ナビゲーションバーのBackButtonを消す
        //バーの色を設定
        self.navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor.flatRed()
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    
    //キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Searchを行う
        
        //下記はtextFieldのデリゲートが設定されているtextFieldを指す
        textField.resignFirstResponder()
        return true
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        searchTextField.resignFirstResponder()
        
    }
    
    
    
    //カードスワイプ画面へ遷移
    @IBAction func moveToSelectCardView(_ sender: Any) {
        
        //パース（Json解析）を行ってから画面遷移
        startParse(keyword: searchTextField.text!)
        
    }
    
    
    
    //カード画面へ遷移メソッド
    func moveToCard(){
        
        performSegue(withIdentifier: "selectVC", sender: nil)
    }
    
    
    
    //遷移のときに値を渡す！これを書くだけで値がわたる！！
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //"selectVC"と記載してこの遷移で値を渡すことを明示
        if searchTextField.text! != nil && segue.identifier == "selectVC"{
            
            let selectVC = segue.destination as! SelectViewController
            selectVC.artistNameArray = self.artistNameArray
            selectVC.imageStringArray = self.imageStringArray
            selectVC.musicNameArray = self.musicNameArray
            selectVC.previewURLArray = self.previewURLArray
            selectVC.userID = self.userID
            selectVC.userName = self.userName
        }
    }
    
    

    //パース（Json解析）を行う
    func startParse(keyword: String){
        
        HUD.show(.progress) //PKHUD
        
        //配列を初期化していく。（何回も検索するときに配列に値が入ったままになりエラーになる）
        imageStringArray = [String]()
        previewURLArray = [String]()
        artistNameArray = [String]()
        musicNameArray = [String]()
        
        //どのURLで表示されているJsonファイルをパースするのかって話。
        let urlString = "https://itunes.apple.com/search?term=\(keyword)&country=jp"
        //keywordをエンコードしてあげる
        let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //Alamofireを使ってリクエストを投げる。これはクロージャ。.parametersは上で指定したのでnil。.getとは？データリストをリクエストし、サーバーはリクエストされたデータを返します(responseにデータ型で返ってくる)
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{
            (response)in
            
            print(response)
            //Switch文でJsonのデータ(response)を取得する
            switch response.result{
            
            case .success:
                let json:JSON = JSON(response.data as Any)
                print(json)
                //"resultCount"というデータが取得できる。
                var resultCount:Int = json["resultCount"].int!
                
                //resultCountの数だけfor文を回して曲をとってくる。例）アリアナグランデと検索したらそのリクエストデータが返ってきて、その数だけ曲を表示する."results"は検索結果,"artworkUrl60"は60*60の画像のこと。
                for i in 0 ..< resultCount{
                    
                    var artWorkUrl = json["results"][i]["artworkUrl60"].string
                    //"previewUrl"には再生する音源が入っているurlの在り処が入っている
                    let previewUrl = json["results"][i]["previewUrl"].string
                    //アーティスト名
                    let artistName = json["results"][i]["artistName"].string
                    //"trackCensoredName"は曲名が入っている
                    let trackCensoredName = json["results"][i]["trackCensoredName"].string
                    
                    //"artworkUrl60"の画像を大きくする処理
                    if let range = artWorkUrl!.range(of: "60x60bb"){
                        
                        artWorkUrl?.replaceSubrange(range, with: "320x320bb")
                    }
                    
                    //配列に入れていく
                    self.imageStringArray.append(artWorkUrl!)
                    self.previewURLArray.append(previewUrl!)
                    self.artistNameArray.append(artistName!)
                    self.musicNameArray.append(trackCensoredName!)
                    
                    if self.musicNameArray.count == resultCount{
                        
                        //カード画面へ遷移
                        self.moveToCard()
                        
                    }
                    
                }
                //データ取得と画面遷移が終わったらくるくるを閉じる
                HUD.hide()
                
            case .failure(let error):
                
                print(error)
                
            }
            
        }
        
        //ここ
        
    }
    
    
    //お気に入りボタンで遷移
    @IBAction func muveToFav(_ sender: Any) {
        
        let favVC = storyboard?.instantiateViewController(identifier: "fav") as! FavoriteViewController
        self.navigationController?.pushViewController(favVC, animated: true)
    }
    
    
    //みんなのリストボタンで遷移
    @IBAction func moveToList(_ sender: Any) {
        
        let listVC = storyboard?.instantiateViewController(identifier: "list") as! ListTableViewController
        self.navigationController?.pushViewController(listVC, animated: true)
        
        
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
