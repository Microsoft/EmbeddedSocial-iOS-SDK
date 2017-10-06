//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import XCTest
import Nimble
@testable import EmbeddedSocial

class MyFollowersResponseProcessorTests: UsersListResponseProcessorTests {
    private var sut: MyFollowersResponseProcessor!
    
    override func setUp() {
        super.setUp()
        sut = MyFollowersResponseProcessor(cache: cache)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testThatItAddsAcceptedPendingRequestsToTheList() {
        // given
        let usersToAdd = [User(), User(), User()]
        let commands = usersToAdd.map(AcceptPendingCommand.init)
        
        let initialUsers = [User(), User()]
        let response = UsersListResponse(items: initialUsers, cursor: nil, isFromCache: true)
        
        cache.fetchOutgoing_with_ReturnValue = commands
        
        // when
        let processedResponse = sut.apply(commands: commands, to: response)
        
        // then
        let userIDs = processedResponse.items.map { $0.uid }
        let userIDsToAdd = usersToAdd.map { $0.uid }
        expect(userIDs).to(contain(userIDsToAdd))
        expect(processedResponse.items).to(haveCount(usersToAdd.count + initialUsers.count))
    }
    
    func testThatItDoesNotAddDuplicatedUsers() {
        // given
        let commonUser = User()
        let usersToAdd = [commonUser, User(), User()]
        let commands = usersToAdd.map(AcceptPendingCommand.init)
        
        let initialUsers = [commonUser, User()]
        let response = UsersListResponse(items: initialUsers, cursor: nil, isFromCache: true)
        
        cache.fetchOutgoing_with_ReturnValue = commands
        
        // when
        let processedResponse = sut.apply(commands: commands, to: response)
        
        // then
        let userIDs = processedResponse.items.map { $0.uid }
        let userIDsToAdd = usersToAdd.map { $0.uid }
        expect(userIDs).to(contain(userIDsToAdd))
        expect(processedResponse.items).to(haveCount(usersToAdd.count + initialUsers.count - 1))
    }
}
