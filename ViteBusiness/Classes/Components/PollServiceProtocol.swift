//
//  PollServiceProtocol.swift
//  APIKit
//
//  Created by Stone on 2018/12/11.
//

import Foundation



public protocol PollService: class {

    associatedtype Ret

    var taskId: String { get set }
    var isPolling: Bool { get set }
    var interval: TimeInterval { get set }
    var completion: ((Ret) -> ())? { get set }

    func handle(completion: @escaping (Ret) -> ())
}

private struct PollServiceStruct {
    static let queue = DispatchQueue(label: "net.vite.file.poll.service")
}

extension PollService {

    private func run(taskId: String) {
        PollServiceStruct.queue.sync {
            guard self.taskId == taskId else {
                // printLog("exit 1 taskId invalid")
                return
            }
            // printLog("start")
            DispatchQueue.main.async {
                self.handle(completion: { [weak self] r in
                    PollServiceStruct.queue.sync {
                        guard let `self` = self else { return }
                        guard self.taskId == taskId else {
                            // printLog("exit 2 taskId invalid")
                            return
                        }
                        // printLog("end")
                        if let c = self.completion { DispatchQueue.main.async { c(r) } }
                        guard self.isPolling else { return }
                        // printLog("will run again after \(self.interval)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.interval, execute: { self.run(taskId: taskId) })
                    }
                })
            }
        }
    }

    public func startPoll() {
        PollServiceStruct.queue.sync {
            // printLog("")
            guard self.isPolling == false else { return }
            self.isPolling = true
            self.taskId = UUID().uuidString
            DispatchQueue.main.async { self.run(taskId: self.taskId) }
        }
    }

    public func stopPoll() {
        PollServiceStruct.queue.sync {
            // printLog("")
            self.isPolling = false
        }
    }
}
