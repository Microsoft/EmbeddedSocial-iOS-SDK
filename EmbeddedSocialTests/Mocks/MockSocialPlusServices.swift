//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
@testable import EmbeddedSocial

class MockSocialPlusServices: SocialPlusServicesType {
    
    //MARK: - getURLSchemeService
    
    var getURLSchemeServiceCalled = false
    var getURLSchemeServiceReturnValue: URLSchemeServiceType!
    
    func getURLSchemeService() -> URLSchemeServiceType {
        getURLSchemeServiceCalled = true
        return getURLSchemeServiceReturnValue
    }
    
    //MARK: - getSessionStoreRepositoriesProvider
    
    var getSessionStoreRepositoriesProviderCalled = false
    var getSessionStoreRepositoriesProviderReturnValue: SessionStoreRepositoryProviderType!
    
    func getSessionStoreRepositoriesProvider() -> SessionStoreRepositoryProviderType {
        getSessionStoreRepositoriesProviderCalled = true
        return getSessionStoreRepositoriesProviderReturnValue
    }
    
    //MARK: - getThirdPartyConfigurator
    
    var getThirdPartyConfiguratorCalled = false
    var getThirdPartyConfiguratorReturnValue: ThirdPartyConfiguratorType!
    
    func getThirdPartyConfigurator() -> ThirdPartyConfiguratorType {
        getThirdPartyConfiguratorCalled = true
        return getThirdPartyConfiguratorReturnValue
    }
    
    //MARK: - getCoreDataStack
    
    var getCoreDataStackCalled = false
    var getCoreDataStackReturnValue: CoreDataStack!
    
    func getCoreDataStack() -> CoreDataStack {
        getCoreDataStackCalled = true
        return getCoreDataStackReturnValue
    }
    
    //MARK: - getCache
    
    var getCacheCoreDataStackCalled = false
    var getCacheCoreDataStackReceivedCoreDataStack: CoreDataStack?
    var getCacheCoreDataStackReturnValue: CacheType!
    
    func getCache(coreDataStack: CoreDataStack) -> CacheType {
        getCacheCoreDataStackCalled = true
        getCacheCoreDataStackReceivedCoreDataStack = coreDataStack
        return getCacheCoreDataStackReturnValue
    }
    
    //MARK: - getNetworkTracker
    
    var getNetworkTrackerCalled = false
    var getNetworkTrackerReturnValue: NetworkTrackerType!
    
    func getNetworkTracker() -> NetworkTrackerType {
        getNetworkTrackerCalled = true
        return getNetworkTrackerReturnValue
    }
    
    //MARK: - getAuthorizationMulticast
    
    var getAuthorizationMulticastCalled = false
    var getAuthorizationMulticastReturnValue: AuthorizationMulticastType!
    
    func getAuthorizationMulticast() -> AuthorizationMulticastType {
        getAuthorizationMulticastCalled = true
        return getAuthorizationMulticastReturnValue
    }
    
    //MARK: - getDaemonsController
    
    var getDaemonsControllerCacheCalled = false
    var getDaemonsControllerCacheReceivedCache: CacheType?
    var getDaemonsControllerCacheReturnValue: Daemon!
    
    func getDaemonsController(cache: CacheType) -> Daemon {
        getDaemonsControllerCacheCalled = true
        getDaemonsControllerCacheReceivedCache = cache
        return getDaemonsControllerCacheReturnValue
    }
    
    //MARK: - getStartupCommands

    var getStartupCommandsCalled = false
    var getStartupCommandsReceivedLaunchArgs: LaunchArguments?
    var getStartupCommandsReturnValue: [Command]!
    
    func getStartupCommands(launchArgs: LaunchArguments) -> [Command] {
        getStartupCommandsCalled = true
        getStartupCommandsReceivedLaunchArgs = launchArgs
        return getStartupCommandsReturnValue
    }
    
    //MARK: - getAppConfiguration
    
    var getAppConfigurationCalled = false
    var getAppConfigurationReceivedConfigFilename: String?
    var getAppConfigurationReturnValue: AppConfigurationType!

    func getAppConfiguration(configFilename: String) -> AppConfigurationType {
        getAppConfigurationCalled = true
        getAppConfigurationReceivedConfigFilename = configFilename
        return getAppConfigurationReturnValue
    }
}
