//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import XCTest
@testable import EmbeddedSocial

class FeedModulePresenter_Tests: XCTestCase {
    
    var sut: FeedModulePresenter!
    private var view: FeedModuleViewInputMock!
    private var interactor: FeedModuleInteractorInputMock!
    private var router: FeedModuleRouterInputMock!
    
    override func setUp() {
        super.setUp()
        
        sut = FeedModulePresenter()
        sut.setFeed(.home)
        
        view = FeedModuleViewInputMock()
        sut.view = view
        
        interactor = FeedModuleInteractorInputMock()
        sut.interactor = interactor
        
        router = FeedModuleRouterInputMock()
        sut.router = router
    }
    
    func testThatViewModelIsCorrect() {
        
        // given
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.day = -2
        
        let creationDate = calendar.date(byAdding: comps, to: Date())
        
        var post = Post()
        
        post.topicHandle = "handle"
        post.firstName = "vasiliy"
        post.lastName = "bodia"
        post.pinned = false
        post.liked = true
        post.title = "post 1 mocked"
        post.totalLikes = 1
        post.totalComments = 2
        post.createdTime = creationDate
        
        let posts = [post]
        let feed = PostsFeed(feedType: .home, items: posts, cursor: nil)
        sut.didFetch(feed: feed)
        let path = IndexPath(row: 0, section: 0)
        
        // when
        let viewModel = sut.item(for: path)
        
        // then
        XCTAssertTrue(viewModel.isLiked == true)
        XCTAssertTrue(viewModel.isPinned == false)
        XCTAssertTrue(viewModel.userName == "vasiliy bodia")
        XCTAssertTrue(viewModel.totalLikes == "1 like")
        XCTAssertTrue(viewModel.totalComments == "2 comments")
        XCTAssertTrue(viewModel.timeCreated == "2d")
    }
    
    func testThatViewHandlesEndOfFetching() {
        
        // given
        view.setRefreshing_state_ReceivedState = true
        
        // when
        sut.didFinishFetching()
        
        // then
        XCTAssertTrue(view.setRefreshing_state_ReceivedState == false)
    }
    
    func testThatViewHandlesStartOfFetching() {
        
        // given
        view.setRefreshing_state_ReceivedState = false
        
        // when
        sut.didStartFetching()
        
        // then
        XCTAssertTrue(view.setRefreshing_state_ReceivedState == true)
    }
    
    func testThatFetchFeedProducesCorrectItems() {
        
        // given
        let initialPost = Post.mock(seed: 10)
        let initialFeed = PostsFeed(feedType: .home, items: [initialPost], cursor: nil)
        
        // when
        sut.didFetch(feed: initialFeed)
        
        // then
        XCTAssertTrue(sut.item(for: IndexPath(row: 0, section: 0)).title == "Title 10")
        XCTAssertTrue(sut.numberOfItems() == 1)
    }
    
    func testThatReFetchFeedProducesCorrectItems() {
        
        // given
        let path = IndexPath(row: 0, section: 0)
        
        let postsA = [Post.mock(seed: 1), Post.mock(seed: 2)]
        let feedA = PostsFeed(feedType: .home, items: postsA, cursor: nil)
        sut.didFetch(feed: feedA)
        
        let postsB = [Post.mock(seed: 3), Post.mock(seed: 4), Post.mock(seed: 5)]
        let feedB = PostsFeed(feedType: .home, items: postsB, cursor: nil)
        
        // when
        sut.didFetch(feed: feedB)
        
        // then
        XCTAssert(sut.numberOfItems() == 3)
        XCTAssertTrue(sut.item(for: path).title == "Title 3")
    }
    
    
    func testThatFetchMoreHandlesFeedCorrectly() {
        
        // given
        let initialPost = Post.mock(seed: 1)
        let initialFeed = PostsFeed(feedType: .home, items: [initialPost], cursor: nil)
        sut.didFetch(feed: initialFeed)
        
        let morePosts = [Post.mock(seed: 2), Post.mock(seed: 3)]
        let moreFeed = PostsFeed(feedType: .home, items: morePosts, cursor: "cursor")
        
        // when
        sut.didFetchMore(feed: moreFeed)
        
        // then
        XCTAssertTrue(sut.item(for: IndexPath(row: 0, section: 0)).title == "Title 1")
        XCTAssertTrue(sut.item(for: IndexPath(row: 1, section: 0)).title == "Title 2")
        XCTAssertTrue(sut.numberOfItems() == 3)
        XCTAssertTrue(view.reload_Called == true)
        XCTAssertTrue(view.reload_Called_Times == 2)
    }
    
    func testThatOnFeedTypeChangeFetchIsDone() {
        
        // given
        let feedType = FeedType.single(post: "handle")
        sut.setFeed(feedType)
        
        // when
        sut.refreshData()
        
        // then
        XCTAssertTrue(interactor.fetchPostsReceivedArguments?.feedType == FeedType.single(post: "handle"))
    }
    
    func testThatFetchDataTriggersViewReload() {
        
        // given
        let feed = PostsFeed(feedType: .home, items: [Post.mock(seed: 0)], cursor: "cursor")
        
        // when
        sut.didFetch(feed: feed)
        
        // then
        XCTAssertTrue(view.reload_Called == true)
    }
    
    func testThatLayoutChanges() {
        
        // given
        let layout = FeedModuleLayoutType.grid
        XCTAssertTrue(view.setLayoutReceivedType != layout)
        
        // when
        sut.layout = layout
        
        // then
        XCTAssertTrue(view.setLayoutReceivedType == layout)
    }
    
    func testThatProfileIsOpened() {
        
        // given
        var post = Post.mock(seed: 0)
        post.userHandle = "user"
        
        let feed = PostsFeed(feedType: .home, items: [post], cursor: "cursor")
        sut.didFetch(feed: feed)
        let path = IndexPath(row: 0, section: 0)
        let action = PostCellAction.profile
        let item = sut.item(for: path)
        
        // when
        item.onAction!(action, path)
        
        // then
        XCTAssertNotNil(router.open_route_feedSource_ReceivedArguments)
        if case FeedModuleRoutes.profileDetailes(user: "user") = router.open_route_feedSource_ReceivedArguments!.route {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }

}
