//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import UIKit

class ReplyCell: UICollectionViewCell {

    static let defaultHeight: CGFloat = 120

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var totalLikesButton: UIButton!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var replyView: ReplyViewModel!
    
    private var formatter = DateFormatterTool()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(replyView: ReplyViewModel) {
        self.replyView = replyView
        
        
        if replyView.userImageUrl == nil {
            userPhoto.image = UIImage(asset: Asset.userPhotoPlaceholder)
        } else {
            userPhoto.setPhotoWithCaching(Photo(url: replyView.userImageUrl), placeholder: UIImage(asset: Asset.userPhotoPlaceholder))
        }

        totalLikesButton.setTitle(replyView.totalLikes, for: .normal)
        replyLabel.text = replyView.text
        userName.text = replyView.userName
        
        postTimeLabel.text = replyView.timeCreated
        likeButton.isSelected = replyView.isLiked
        contentView.layoutIfNeeded()
    }
    
    func cellSize() -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: self.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
    }
    
    @IBAction func like(_ sender: Any) {
        replyView.onAction?(.like, tag)
    }

    @IBAction func toLikes(_ sender: Any) {
        replyView.onAction?(.toLikes, tag)
    }
    
    @IBAction func actionsPressed(_ sender: Any) {
        replyView.onAction?(.extra, tag)
    }
    
    @IBAction func toProfile(_ sender: Any) {
        replyView.onAction?(.profile, tag)
    }

}
