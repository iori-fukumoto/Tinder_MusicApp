//
//  SelectViewController.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import UIKit
import VerticalCardSwiper //Tinder風に.TableViewと使い方が似ている。
import SDWebImage  //DBから画像のurlをとってきてimageviewに表示するためのキャッシュを取れるもの
import PKHUD  //くるくる
import Firebase //右にスワイプしたときにDBへ
import ChameleonFramework //色をつかさどる


class SelectViewController: UIViewController,VerticalCardSwiperDelegate,VerticalCardSwiperDatasource {
    

    //SearchViewControllerからの値を受け取るための配列
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    var userID = String()
    var userName = String()
    
    //以下受取り用とはまた別の箱
    var indexNumber = Int()
    
    //右にスワイプしたときに入れる配列。（お気に入り）
    var likeArtistNameArray = [String]()
    var likeMusicNameArray = [String]()
    var likePreviewURLArray = [String]()
    var likeImageStringArray = [String]()
    var likeArtistViewUrlArray = [String]()
    
    @IBOutlet weak var cardSwiper: VerticalCardSwiper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        
        //カスタムセルの登録
        cardSwiper.register(nib:UINib(nibName: "CardViewCell", bundle: nil), forCellWithReuseIdentifier: "CardViewCell")
        
        //reloadData()をすることでnumberOfCards,cardForItemAtが呼ばれる
        cardSwiper.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    //カードの数。必須
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return artistNameArray.count
        
    }
    
    
    //カードのセルの中身。カードの数だけここが呼ばれる。必須
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        
        //CardViewCellがあるかどうかの確認。（if文ではない）あるならセルの中に入れる。
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewCell", for: index) as? CardViewCell{
            
            //カードの後ろもランダムで色を変える
            verticalCardSwiperView.backgroundColor = UIColor.randomFlat()
            view.backgroundColor = verticalCardSwiperView.backgroundColor
            
            //セル（カード）に配列を表示させる
            let artistName = artistNameArray[index]
            let musicName = musicNameArray[index]
            cardCell.setRandomBackgroundColor()
            cardCell.artistNameLabel.text = artistName
            cardCell.artistNameLabel.textColor = UIColor.white
            cardCell.musicNameLabel.text = musicName
            cardCell.musicNameLabel.textColor = UIColor.white
            
            //セル（カード）の画像表示。imageViewにURLを貼っていく
            cardCell.artWorkImageView.sd_setImage(with: URL(string: imageStringArray[index]), completed: nil)
            
            return cardCell
            
        }
        //カードセルがない場合も空のカードセルを返す
        return CardCell()
    }
    
    
    
    //スワイプしたときに配列の中を消さないといけない。値が残ったままだとインデックスが崩れるから。このコードがない場合とある場合で何が違うのか、配列の中身の数を追って確かめてください、とのこと。
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        
        indexNumber = index
        
        if swipeDirection == .Right {
            
            likeArtistNameArray.append(artistNameArray[indexNumber])
            
            likeMusicNameArray.append(musicNameArray[indexNumber])
            
            likePreviewURLArray.append(previewURLArray[indexNumber])
            
            likeImageStringArray.append(imageStringArray[indexNumber])
            
            if likeArtistNameArray.count != 0 && likeMusicNameArray.count != 0 && likePreviewURLArray.count != 0 && likeImageStringArray.count != 0 {
                
                let musicDataModel = MusicDataModel(artistName: artistNameArray[indexNumber], musicName: musicNameArray[indexNumber], preViewURL: previewURLArray[indexNumber], imageString: imageStringArray[indexNumber], userID: userID, userName: userName)
                
                musicDataModel.save()
                
            }
            
        }

            artistNameArray.remove(at: index)
            musicNameArray.remove(at: index)
            previewURLArray.remove(at: index)
            imageStringArray.remove(at: index)

        }
    
    
    
    
    
    
    
    
    //スワイプの設定。デリゲートメソッドを使う。スワイプする方向、カード、インデックスを決めることができる。
    func didSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        
        //何番目がスワイプされたものかを検知する。検知したものを上で作った変数indexNumberへ入れる
        indexNumber = index
        
        //右にスワイプしたときに呼ばれる
        if swipeDirection == .Right{
            
            //右にスワイプしたときに配列に入れていく。（後に入れなくていいことが判明）
            likeArtistNameArray.append(artistNameArray[indexNumber])
            likeMusicNameArray.append(musicNameArray[indexNumber])
            likePreviewURLArray.append(previewURLArray[indexNumber])
            likeImageStringArray.append(imageStringArray[indexNumber])
            
            //全ての配列が０じゃない場合、firebaseの中に値を保存したい。（お気に入りとして保存する）。Modelを使って保存する。
            if likeArtistNameArray.count != 0 && likeMusicNameArray.count != 0 && likePreviewURLArray.count != 0 && likeImageStringArray.count != 0{
                
                //MusicDataModelのインスタンス化＆値を入れ込む。
                let musicDataModel = MusicDataModel(artistName: artistNameArray[indexNumber], musicName: musicNameArray[indexNumber], preViewURL: previewURLArray[indexNumber], imageString: imageStringArray[indexNumber], userID: userID, userName: userName)
                //DBへ保存完了
                musicDataModel.save()
                
            }
            
        }
        
    }
    
    //戻るボタン
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
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
