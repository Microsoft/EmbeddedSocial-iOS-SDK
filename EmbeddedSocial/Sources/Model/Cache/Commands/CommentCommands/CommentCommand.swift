//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation

class CommentCommand: OutgoingCommand {
    let comment: Comment
    private(set) var relatedHandle: String?
    
    required init?(json: [String: Any]) {
        guard let commentJSON = json["comment"] as? [String: Any],
            let comment = Comment(json: commentJSON) else {
                return nil
        }
        
        self.comment = comment
        
        super.init(json: json)
    }
    
    required init(comment: Comment) {
        self.comment = comment
        self.relatedHandle = comment.topicHandle
        super.init(json: [:])!
    }
    
    func apply(to comment: inout Comment) {
        
    }
    
    override func encodeToJSON() -> Any {
        return [
            "comment": comment.encodeToJSON(),
            "type": typeIdentifier
        ]
    }
    
    override func getRelatedHandle() -> String? {
        return relatedHandle
    }
    
    override func setRelatedHandle(_ relatedHandle: String?) {
        self.relatedHandle = relatedHandle
    }
    
    override func getHandle() -> String? {
        return comment.commentHandle
    }
}