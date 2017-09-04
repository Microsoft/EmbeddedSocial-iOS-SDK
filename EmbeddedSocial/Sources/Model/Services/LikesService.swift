//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation

protocol LikesServiceProtocol {

    typealias CompletionHandler = (_ postHandle: PostHandle, _ error: Error?) -> Void
    typealias CommentCompletionHandler = (_ commentHandle: String, _ error: Error?) -> Void
    typealias ReplyLikeCompletionHandler = (_ commentHandle: String, _ error: Error?) -> Void
    
    
    func postPin(postHandle: PostHandle, completion: @escaping CompletionHandler)
    func deletePin(postHandle: PostHandle, completion: @escaping CompletionHandler)
    func postLike(postHandle: PostHandle, completion: @escaping CompletionHandler)
    func deleteLike(postHandle: PostHandle, completion: @escaping CompletionHandler)
    func likeComment(commentHandle: String, completion: @escaping CommentCompletionHandler)
    func unlikeComment(commentHandle: String, completion: @escaping CompletionHandler)
    func likeReply(replyHandle: String, completion: @escaping ReplyLikeCompletionHandler)
    func unlikeReply(replyHandle: String, completion: @escaping ReplyLikeCompletionHandler)
    func getPostLikes(postHandle: String, cursor: String?, limit: Int,
                      completion: @escaping (Result<UsersListResponse>) -> Void)
}

//MARK: - Optional methods

extension LikesServiceProtocol {
    
    func postLike(postHandle: PostHandle, completion: @escaping CompletionHandler) { }
    
    func deleteLike(postHandle: PostHandle, completion: @escaping CompletionHandler) { }
    
    func likeComment(commentHandle: String, completion: @escaping CommentCompletionHandler) { }
    
    func unlikeComment(commentHandle: String, completion: @escaping CompletionHandler) { }
    
    func likeReply(replyHandle: String, completion: @escaping ReplyLikeCompletionHandler) { }
    
    func unlikeReply(replyHandle: String, completion: @escaping ReplyLikeCompletionHandler) { }
    
    func getPostLikes(postHandle: String, cursor: String?, limit: Int,
                      completion: @escaping (Result<UsersListResponse>) -> Void) { }
}

class LikesService: BaseService, LikesServiceProtocol {
    
    typealias UsersFeedRequestExecutor = CacheRequestExecutionStrategy<FeedResponseUserCompactView, UsersListResponse>

    private let requestExecutor: UsersFeedRequestExecutor
    
    init(requestExecutor: UsersFeedRequestExecutor = UsersFeedRequestExecutionStrategy()) {
        self.requestExecutor = requestExecutor
        
        super.init()
        
        self.requestExecutor.cache = cache
        self.requestExecutor.errorHandler = errorHandler
    }
    
    private lazy var socialActionsCache: SocialActionsCache = { [unowned self] in
        return SocialActionsCache(cache: self.cache)
    }()
    
    func postLike(postHandle: PostHandle, completion: @escaping CompletionHandler) {
        
        let request:RequestBuilder<Object> = LikesAPI.topicLikesPostLikeWithRequestBuilder(topicHandle: postHandle,
                                                                                           authorization: authorization)
        
        guard isNetworkReachable == true else {
            
            let action = SocialActionRequestBuilder.build(
                method: request.method,
                handle: postHandle,
                action: .like)
            
            socialActionsCache.cache(action)
            completion(postHandle, nil)
            return
        }
        
        request.execute { (response, error) in
            if self.errorHandler.canHandle(error) {
                self.errorHandler.handle(error)
            } else {
                completion(postHandle, error)
            }
        }
    }
    
    func deleteLike(postHandle: PostHandle, completion: @escaping CompletionHandler) {
        
        let request:RequestBuilder<Object> = LikesAPI.topicLikesDeleteLikeWithRequestBuilder(
            topicHandle: postHandle,
            authorization: authorization)
        
        guard isNetworkReachable == true else {
            
            let action = SocialActionRequestBuilder.build(method: request.method,
                                                          handle: postHandle,
                                                          action: .like)
            
            socialActionsCache.cache(action)
            completion(postHandle, nil)
            return
        }
        
        request.execute { (response, error) in
            if self.errorHandler.canHandle(error) {
                self.errorHandler.handle(error)
            } else {
                completion(postHandle, error)
            }
        }
    }
    
    func likeComment(commentHandle: String, completion: @escaping CommentCompletionHandler) {
        
        let request:RequestBuilder<Object> = LikesAPI.commentLikesPostLikeWithRequestBuilder(commentHandle: commentHandle, authorization: authorization)

        request.execute { (response, error) in
            completion(commentHandle, error)
        }
    }
    
    func unlikeComment(commentHandle: String, completion: @escaping CommentCompletionHandler) {
        
        let request:RequestBuilder<Object> = LikesAPI.commentLikesDeleteLikeWithRequestBuilder(
            commentHandle: commentHandle,
            authorization: authorization)
        
        request.execute { (response, error) in
            completion(commentHandle, error)
        }
    }
    
    func likeReply(replyHandle: String, completion: @escaping ReplyLikeCompletionHandler) {
        LikesAPI.replyLikesPostLike(replyHandle: replyHandle, authorization: authorization) { (object, error) in
            completion(replyHandle, error)
        }
    }
    
    func unlikeReply(replyHandle: String, completion: @escaping ReplyLikeCompletionHandler) {
        LikesAPI.replyLikesDeleteLike(replyHandle: replyHandle, authorization: authorization) { (object, error) in
            completion(replyHandle, error)
        }
    }
    
    func getPostLikes(postHandle: String, cursor: String?, limit: Int,
                      completion: @escaping (Result<UsersListResponse>) -> Void) {
        
        let builder = LikesAPI.topicLikesGetLikesWithRequestBuilder(
            topicHandle: postHandle,
            authorization: authorization,
            cursor: cursor,
            limit: Int32(limit))
        
        requestExecutor.execute(with: builder, completion: completion)
    }
    
    private func process(_ requestBuilder: RequestBuilder<Object>,
                         handle: String,
                         completion: @escaping CompletionHandler) {
        
        // If no connection, cache request
        guard isNetworkReachable == true else {
            
            let action = SocialActionRequestBuilder.build(
                method: requestBuilder.method,
                handle: handle,
                action: .pin)
            
            socialActionsCache.cache(action)
            completion(handle, nil)
            return
        }
        
        requestBuilder.execute { (response, error) in
            if self.errorHandler.canHandle(error) {
                self.errorHandler.handle(error)
            } else {
                completion(handle, error)
            }
        }
    }
    
    func postPin(postHandle: PostHandle, completion: @escaping CompletionHandler) {
        
        let request = PostPinRequest()
        request.topicHandle = postHandle
        let builder = PinsAPI.myPinsPostPinWithRequestBuilder(request: request, authorization: authorization)
        
        process(builder, handle: postHandle, completion: completion)
    }
    
    func deletePin(postHandle: PostHandle, completion: @escaping CompletionHandler) {
        
        let builder = PinsAPI.myPinsDeletePinWithRequestBuilder(topicHandle: postHandle, authorization: authorization)
        
        process(builder, handle: postHandle, completion: completion)
    }

}

