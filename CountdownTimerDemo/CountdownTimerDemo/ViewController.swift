//
//  ViewController.swift
//  CountdownTimerDemo
//
//  Created by 吴浩 on 2019/10/27.
//  Copyright © 2019 wuhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var countdownLabel1: UILabel!
    @IBOutlet private weak var countdownLabel2: UILabel!
 
    @IBAction private func didClickStartTimer1Button(_ sender: Any) {
        CountdownTimer.startTimer(key: .test1, count: 60) { (count, finish) in
            print(count) // 倒计时数字
            print(finish) // 是否完成倒计时
        }
        
        CountdownTimer.stopTimer(key: .test1)
        
        CountdownTimer.continueTimer(key: .test1) { (count, finish) in
            print(count) // 倒计时数字
            print(finish) // 是否完成倒计时
        }
    }
    
    @IBAction private func didClickStartTimer2Button(_ sender: Any) {
        CountdownTimer.startTimer(key: .test2, count: 100) { [weak self] (count, finish) in
            self?.countdownLabel2.text = finish ? "Finished" : "\(count)"
        }
    }
}

