//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

enum PostCellAction {
    case like, pin, comment, extra
}

struct PostViewModel {
    
    typealias ActionHandler = (PostCellAction, IndexPath) -> Void
    
    var userName: String = ""
    var title: String = ""
    var text: String = ""
    var likedBy: String = ""
    var totalLikes: String = ""
    var totalComments: String = ""
    var timeCreated: String = ""
    var userImageUrl: String? = nil
    var postImageUrl: String? = nil
    
    var cellType: String = TopicCell.reuseID
    var onAction: ActionHandler?
}

class HomePresenter: HomeModuleInput, HomeViewOutput, HomeInteractorOutput {
    
    weak var view: HomeViewInput!
    var interactor: HomeInteractorInput!
    var router: HomeRouterInput!

    var layout: HomeLayoutType = .list
    let limit = 3
    var items = [Post]()
    
    func didTapChangeLayout() {
        flip(layout: &layout)
        view.setLayout(type: layout)
    }
    
    private func flip(layout: inout HomeLayoutType) {
        layout = HomeLayoutType(rawValue: layout.rawValue ^ 1)!
    }
    
    // MARK: Private
    private func viewModel(with post: Post) -> PostViewModel {
        
        var viewModel = PostViewModel()
        viewModel.userName = String(format: "%@ %@", (post.firstName ?? ""), (post.lastName ?? ""))
        viewModel.title = post.title ?? ""
        viewModel.text = post.text ?? ""
        viewModel.likedBy = "" // TODO: uncomfirmed
        
        viewModel.totalLikes = String(format: "%d likes", post.totalLikes)
        viewModel.totalComments = String(format: "%d comments", post.totalComments)
        viewModel.timeCreated =  post.lastUpdatedTime == nil ? "" : dateFormatter.string(from: post.lastUpdatedTime!)
        viewModel.userImageUrl = post.photoUrl
        viewModel.postImageUrl = post.imageUrl
        
        viewModel.cellType = layout.cellType
        viewModel.onAction = { [weak self] action, path in
            self?.handle(action: action, path: path)
        }
        
        return viewModel
    }

    lazy var dateFormatter: DateFormatter = {
        var dateFormat = "hh:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    // MARK: HomeViewOutput
    func item(for path: IndexPath) -> PostViewModel {
        return viewModel(with: items[path.row])
    }
    
    private func itemIndex(with postHandle:PostHandle) -> Int? {
        return items.index(where: { $0.topicHandle == postHandle } )
    }
    
    private func handle(action: PostCellAction, path: IndexPath) {
        switch action {
        case .comment:
            didTapComment(with: path)
        case .extra:
            Logger.log("Extra did tap")
        case .like:
            didTapLike(with: path)
        case .pin:
            didTapPin(with: path)
        }
    }
  
    func numberOfItems() -> Int {
        return items.count
    }
    
    func viewIsReady() {
        view.setupInitialState()
        view.setLayout(type: layout)
        
        didPullRefresh()
    }
    
    func didPullRefresh() {
        view.setRefreshing(state: true)
        interactor.fetchPosts(with: limit)
    }
    
    func didFetch(feed: PostsFeed) {
        view.setRefreshing(state: false)
        items = feed.items
        view.reload()
    }
    
    func didFetchMore(feed: PostsFeed) {
        view.setRefreshing(state: false)
        items.insert(contentsOf:feed.items, at: 0)
        view.reload()
    }
    
    func didFail(error: FeedServiceError) {
        Logger.log(error)
    }
    
    func didUnpin(post id: PostHandle) {
        if let index = itemIndex(with: id) {
            items[index].pinned = false
            view.reload(with: index)
        }
    }
    
    func didUnlike(post id: PostHandle) {
        if let index = itemIndex(with: id) {
            items[index].liked = false
            view.reload(with: index)
        }
    }
    
    func didLike(post id: PostHandle) {
        
        if let index = itemIndex(with: id) {
            items[index].liked = true
            items[index].totalLikes += Int64(1)
            view.reload(with: index)
        }
    }
    
    func didPin(post id: PostHandle) {
        if let index = itemIndex(with: id) {
            items[index].pinned = true
            view.reload(with: index)
        }
    }
    
    func didTapComment(with path: IndexPath) {
        // TODO: figure out what to do
    }
    
    func didTapLike(with path: IndexPath) {
        let item = items[path.row]
        
        if item.liked {
            interactor.unlike(with: item.topicHandle)
        } else {
            interactor.like(with: item.topicHandle)
        }
    }
    
    func didTapPin(with path: IndexPath) {
        let item = items[path.row]
    
        if item.pinned {
            interactor.unpin(with: item.topicHandle)
        } else {
            interactor.pin(with: item.topicHandle)
        }
    }
    
}
