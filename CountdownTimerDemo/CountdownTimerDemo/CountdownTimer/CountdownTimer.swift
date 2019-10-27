//
//  CountdownTimer.swift
//  CountdownTimerDemo
//
//  Created by 吴浩 on 2019/10/27.
//  Copyright © 2019 wuhao. All rights reserved.
//

import UIKit

class CountdownTimer {
    
    enum CountDownKey: CaseIterable {
        case test1
        case test2
        // 当需要一个倒计时的时候就在这里加一个key
    }

    static private let shared = CountdownTimer()
    typealias CountDownCallback = (_ count: Int, _ finished: Bool) -> Void
    private var countDowns = [CountDownKey: CountDownInfo]()
    private let lock = NSLock()
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    private struct CountDownInfo {
        var timer: DispatchSourceTimer?
        var endTime: TimeInterval?
        var callBack: CountDownCallback?
    }
    
    /// 开启某个倒计时
    ///
    /// - Parameters:
    ///   - key: 倒计时key
    ///   - count: 倒计时长
    ///   - callBack: 回调
    static func startTimer(key: CountDownKey, count: Int, callBack: @escaping CountDownCallback) {
        let endTime = TimeInterval(count) + Date().timeIntervalSince1970
        CountdownTimer.shared.startCountDown(key: key, endTime: endTime, callBack: callBack)
    }
    
    /// 停止一个倒计时
    ///
    /// - Parameter key: 倒计时key
    static func stopTimer(key: CountDownKey) {
        CountdownTimer.shared.removeCountDown(key: key)
    }
    
    /// 继续某个倒计时
    ///
    /// - Parameters:
    ///   - key: 倒计时key
    ///   - callBack: 回调
    static func continueTimer(key: CountDownKey, callBack: @escaping CountDownCallback) {
        CountdownTimer.shared.continueCountDown(key: key, callBack: callBack)
    }
    
    /// 判断某个倒计时是否已经完成
    ///
    /// - Parameter key: 倒计时key
    /// - Returns: 倒计时是否完成
    static func isFinishedTimer(key: CountDownKey) -> Bool {
        return CountdownTimer.shared.isFinished(key: key)
    }
}

// MARK: - Timer operation
// MARK: -

extension CountdownTimer {

    private func startCountDown(key: CountDownKey, endTime: TimeInterval, callBack: @escaping CountDownCallback) {
        let countDownInfo = CountDownInfo(timer: nil, endTime: endTime, callBack: callBack)
        addCountDown(key: key, countDownInfo: countDownInfo)
        launchTimer(key: key, countDownInfo: countDownInfo)
    }

    private func continueCountDown(key: CountDownKey, callBack: @escaping CountDownCallback) {
        guard let endTime = countDowns[key]?.endTime else {
            callBack(0, true)
            return
        }
        removeCountDown(key: key)
        startCountDown(key: key, endTime: endTime, callBack: callBack)
    }
    
    private func isFinished(key: CountDownKey) -> Bool {
        lock.lock()
        let finished = countDowns[key]?.timer?.isCancelled ?? true
        lock.unlock()
        return finished
    }
    
    @objc
    private func willEnterForegroundNotification() {
        for key in CountDownKey.allCases {
            guard let callBack = countDowns[key]?.callBack else {
                continue
            }
            CountdownTimer.shared.continueCountDown(key: key, callBack: callBack)
        }
    }
}

// MARK: - Helper
// MARK: -

extension CountdownTimer {
    private func launchTimer(key: CountDownKey, countDownInfo: CountDownInfo) {
        var info = countDownInfo
        let timer = createCountDownTimer(key: key)
        info.timer = timer
        addCountDown(key: key, countDownInfo: info)
        timer?.resume()
    }

    private func addCountDown(key: CountDownKey, countDownInfo: CountDownInfo) {
        lock.lock()
        countDowns[key] = countDownInfo
        lock.unlock()
    }

    private func removeCountDown(key: CountDownKey) {
        lock.lock()
        countDowns[key]?.timer?.cancel()
        countDowns.removeValue(forKey: key)
        lock.unlock()
    }

    private func createCountDownTimer(key: CountDownKey) -> DispatchSourceTimer? {
        lock.lock()
        let countDownCallBack = countDowns[key]?.callBack
        let countEndTime = self.countDowns[key]?.endTime
        lock.unlock()
        guard let callBack = countDownCallBack, let endTime = countEndTime else {
            return nil
        }
        let currentTime = Date().timeIntervalSince1970
        if currentTime >= endTime {
            callBack(0, true)
            return nil
        }
        let countdownTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        countdownTimer.schedule(wallDeadline: .now(), repeating: 1)
        var countDown = Int(round(endTime - currentTime)) + 1
        countdownTimer.setEventHandler(handler: {
            countDown -= 1
            let finished = countDown <= 0
            DispatchQueue.main.async {
                callBack(countDown, finished)
            }
            if finished {
                self.removeCountDown(key: key)
            }
        })
        return countdownTimer
    }
}
