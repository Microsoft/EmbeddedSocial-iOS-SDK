//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//
import Foundation
import Alamofire

typealias TopicPosted = (PostTopicRequest) -> Void
typealias Failure = (Error) -> Void

class TopicService: PostServiceProtocol {
    
    private var success: TopicPosted?
    private var failure: Failure?
    
    private var cache: Cachable!
    
    init(cache: Cachable) {
        self.cache = cache
    }
    
    func postTopic(topic: PostTopicRequest, photo: Photo?, success: @escaping TopicPosted, failure: @escaping Failure) {
        self.success = success
        self.failure = failure
        
        guard let network = NetworkReachabilityManager() else {
            return
        }
        
        if network.isReachable {
            guard let image = photo?.image else {
                sendPostTopicRequest(request: topic)
                return
            }
                
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
                return
            }
            
            ImagesAPI.imagesPostImage(imageType: ImagesAPI.ImageType_imagesPostImage.contentBlob,
                                      image: imageData) { [weak self] (response, error) in
                                        guard let blobHandle = response?.blobHandle else {
                                            if let unwrappedError = error {
                                                failure(unwrappedError)
                                            }
                                            return
                                        }
                                        
                                        topic.blobHandle = blobHandle
                                        self?.sendPostTopicRequest(request: topic)
            }
            
        } else {
            if photo != nil {
                cache?.cacheOutgoing(object: photo!)
                topic.blobHandle = photo?.url
            }
            
            cache?.cacheOutgoing(object: topic)
        }
    }
    
    private func sendPostTopicRequest(request: PostTopicRequest) {
        TopicsAPI.topicsPostTopic(request: request) { [weak self] (response, error) in
            guard let response = response else {
                self?.failure!(error!)
                return
            }
            
            print(response.topicHandle!)
            self?.success!(request)
        }
    }

    func fetchPosts(offset: String?, limit: Int, resultHandler: @escaping FetchResultHandler) {
        
        TopicsAPI.topicsGetTopics(cursor: offset, limit: Int32(limit)) { (response, error) in

            var result = PostFetchResult()
            
            guard error == nil else {
                result.error = FeedServiceError.failedToFetch(message: error!.localizedDescription)
                resultHandler(result)
                return
            }
            
            guard let data = response?.data else {
                result.error = FeedServiceError.failedToFetch(message: "No Items Received")
                resultHandler(result)
                return
            }
            
            result.posts = self.convert(data: data)
            result.cursor = response?.cursor
            
            resultHandler(result)
        }
    }
    
    private func convert(data: [TopicView]) -> [Post] {
        
        var posts = [Post]()
        for item in data {
            var post = Post()
            post.firstName = item.user?.firstName
            post.lastName = item.user?.lastName
            post.photoUrl = item.user?.photoUrl
            post.userHandle = item.user?.userHandle
            
            post.createdTime = item.createdTime
            post.imageUrl = item.blobUrl
            post.title = item.title
            post.text = item.text
            post.pinned = item.pinned
            post.liked = item.liked
            post.topicHandle = item.topicHandle
            post.totalLikes = item.totalLikes ?? 0
            post.totalComments = item.totalLikes ?? 0
            // TODO: fullfill mapping
            posts.append(post)
        }
        return posts
    }
    
}