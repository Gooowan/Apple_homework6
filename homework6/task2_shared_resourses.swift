//
//  task2_shared_resourses.swift
//  homework6
//
//  Created by Ivan Solomatin on 12.12.2024.
//

import Foundation

class BankAccount {
    var balance: Double = 0
    let serialQueue = DispatchQueue(label: "queue")
    
    func deposit(amount: Double) {
        serialQueue.sync {
            balance += amount
        }
    }
    
    func withdraw(amount: Double) {
        serialQueue.sync {
            if balance - amount >= 0 {
                balance -= amount
            }
        }
    }
    
    func getBalance() -> Double {
        var result: Double = 0
        serialQueue.sync {
            result = balance
        }
        return result
    }
}

func testBankAccount() {
    let account = BankAccount()
    let group = DispatchGroup()
    let concurrentQueue = DispatchQueue.global(qos: .userInitiated)
    
    account.deposit(amount: 100)
    
    for _ in 1...100 {
        group.enter()
        concurrentQueue.async {
            account.deposit(amount: 1)
            group.leave()
        }
    }
    
    for _ in 1...100 {
        group.enter()
        concurrentQueue.async {
            account.withdraw(amount: 1)
            group.leave()
        }
    }
    
    group.wait()
    
    // should be 100
    print("Final balance - \(account.getBalance())")
}

//@main
//struct Task2 {
//    static func main() {
//        testBankAccount()
//    }
//}
