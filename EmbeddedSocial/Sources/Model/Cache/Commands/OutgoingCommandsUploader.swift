//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation

final class OutgoingCommandsUploader: Daemon, NetworkStatusListener {
    
    private let networkTracker: NetworkStatusMulticast
    private let cache: CacheType
    private let executionQueue: OperationQueue = {
       let q = OperationQueue()
        q.name = "OutgoingCommandsUploader-executionQueue"
        q.qualityOfService = .background
        return q
    }()
    private let operationsBuilderType: OutgoingCommandOperationsBuilderType.Type
    
    init(networkTracker: NetworkStatusMulticast,
         cache: CacheType,
         jsonDecoderType: JSONDecoder.Type,
         operationsBuilderType: OutgoingCommandOperationsBuilderType.Type) {
        
        self.networkTracker = networkTracker
        self.cache = cache
        self.operationsBuilderType = operationsBuilderType
        jsonDecoderType.setupDecoders()
    }
    
    func start() {
        networkTracker.addListener(self)
    }
    
    func stop() {
        networkTracker.removeListener(self)
    }
    
    func networkStatusDidChange(_ isReachable: Bool) {
        guard isReachable else { return }
        executionQueue.cancelAllOperations()
        executePendingCommands()
    }
    
    private func executePendingCommands() {
        let fetchOperation = FetchAllOutgoingCommandsOperation(cache: cache)
        
        fetchOperation.completionBlock = { [weak self] in
            guard !fetchOperation.isCancelled else { return }
            self?.executeCommandsOperations(fetchOperation.commands)
        }
        
        executionQueue.addOperation(fetchOperation)
    }
    
    private func executeCommandsOperations(_ commands: [OutgoingCommand]) {
        let operations = makeActionOperations(from: commands)
        executionQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func makeActionOperations(from commands: [OutgoingCommand]) -> [Operation] {
        
        let operations = commands.flatMap { [weak self] command -> Operation? in
            let op = self?.operationsBuilderType.operation(for: command)
            op?.completionBlock = {
                guard op?.isCancelled != true else { return }
                let predicate = PredicateBuilder.predicate(for: command)
                self?.cache.deleteOutgoing(with: predicate)
            }
            return op
        }
        
        return operations
    }
}