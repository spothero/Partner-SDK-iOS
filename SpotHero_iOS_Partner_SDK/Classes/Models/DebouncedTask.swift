//
//  DebouncedTask.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 12/27/16.
//
//

import Foundation

/// Abstracts scheduling of a debounced (ie, performed only if it has not been cancelled) task
/// on the main thread in Swift 3.
class DebouncedTask {
    typealias Task = () -> Void
    
    /// The task to perform
    let task: Task
    
    /// Set to true if this task should not be performed after the delay.
    var isCancelled = false
    
    init(task: @escaping Task) {
        self.task = task
    }
    
    /// Starts the timer on the task with the given delay
    ///
    /// - Parameter delayInSeconds: The delay, in seconds, to wait before attempting to perform the task.
    func schedule(withDelay delayInSeconds: TimeInterval) {
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + delayInSeconds,
                        execute: self.performIfNotCancelled)
    }
    
    private func performIfNotCancelled() {
        guard !self.isCancelled else {
            return
        }
        
        self.task()
    }
}
