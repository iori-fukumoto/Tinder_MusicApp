//
//  CardViewCell.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import UIKit
import VerticalCardSwiper

//VerticalCardSwiperのインポート＋親クラスをUIViewControllerからCardCellへ変更
class CardViewCell: CardCell {

    @IBOutlet weak var artWorkImageView:UIImageView!
    @IBOutlet weak var musicNameLabel:UILabel!
    @IBOutlet weak var artistNameLabel:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //CardCellが持っているメソッドを使う。オーバーライドする
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
    
    //スワイプするごとにランダムでセルの背景色を変えられる。ライブラリに書いてある通りにやればOK（コピペ）
    public func setRandomBackgroundColor() {
        
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

    
    //セルの角丸を決める
    override func layoutSubviews() {
        
        self.layer.cornerRadius = 12
        super.layoutSubviews()
        
    }
    
    
    
    
    
    
}
