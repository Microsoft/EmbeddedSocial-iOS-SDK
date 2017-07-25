//
//  SessionStoreTests.swift
//  MSGP
//
//  Created by Vadim Bulavin on 7/24/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import XCTest
@testable import MSGP

class SessionStoreTests: XCTestCase {
    private var database: MockSessionStoreDatabase!
    private var sut: SessionStore!
    
    override func setUp() {
        super.setUp()
        database = MockSessionStoreDatabase()
        sut = SessionStore(database: database)
    }
    
    override func tearDown() {
        super.tearDown()
        database = nil
        sut = nil
    }
    
    func testThatSessionIsLoaded() {
        // given
        let sessionToken = UUID().uuidString
        let credentials = CredentialsList(provider: .facebook, accessToken: UUID().uuidString, socialUID: UUID().uuidString)
        let user = User(uid: UUID().uuidString, firstName: UUID().uuidString, lastName: UUID().uuidString,
                        email: UUID().uuidString, bio: UUID().uuidString, photo: Photo(), credentials: credentials)
        
        // when
        database.sessionTokenToReturn = sessionToken
        database.userToReturn = user
        
        do {
            try sut.loadLastSession()
            XCTAssertEqual(sut.user, user)
            XCTAssertEqual(sut.sessionToken, sessionToken)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertEqual(database.loadUserCount, 1)
        XCTAssertEqual(database.loadSessionTokenCount, 1)
    }
    
    func testThatIsThrowsWhenNoSessionIsLoaded() {
        XCTAssertThrows(expression: try sut.loadLastSession(), error: SessionStore.Error.lastSessionNotAvailable)
    }
    
    func testThatItIsNotLoggedIn() {
        XCTAssertFalse(sut.isLoggedIn)
    }
    
    func testThatItIsLoggedIn() {
        // given
        let sessionToken = UUID().uuidString
        let credentials = CredentialsList(provider: .facebook, accessToken: UUID().uuidString, socialUID: UUID().uuidString)
        let user = User(uid: UUID().uuidString, firstName: UUID().uuidString, lastName: UUID().uuidString,
                        email: UUID().uuidString, bio: UUID().uuidString, photo: Photo(), credentials: credentials)
        
        // when
        database.sessionTokenToReturn = sessionToken
        database.userToReturn = user
        XCTAssertNoThrow(try sut.loadLastSession())
        
        // then
        XCTAssertTrue(sut.isLoggedIn)
    }
    
    func testThatItThrowsWhenSavingSessionBeingNotLoggedIn() {
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertThrows(expression: try sut.saveCurrentSession(), error: SessionStore.Error.notLoggedIn)
    }
    
    func testThatItSavesSession() {
        // given
        let sessionToken = UUID().uuidString
        let credentials = CredentialsList(provider: .facebook, accessToken: UUID().uuidString, socialUID: UUID().uuidString)
        let user = User(uid: UUID().uuidString, firstName: UUID().uuidString, lastName: UUID().uuidString,
                        email: UUID().uuidString, bio: UUID().uuidString, photo: Photo(), credentials: credentials)
        
        // when
        database.sessionTokenToReturn = sessionToken
        database.userToReturn = user
        XCTAssertNoThrow(try sut.loadLastSession())

        // then
        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertNoThrow(try sut.saveCurrentSession())
    }
    
    func testErrorDescriptionExists() {
        // given
        let errors: [SessionStore.Error] = [.notLoggedIn, .lastSessionNotAvailable]
        
        // when
        let descriptions = errors.flatMap { $0.errorDescription }
        
        // then
        XCTAssertEqual(errors.count, descriptions.count)
    }
}
