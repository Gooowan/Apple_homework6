//
//  main.swift
//  homework6
//
//  Created by Ivan Solomatin on 05.12.2024.
//

import Foundation

class Numbers {
    var numbers: [Int] = []
    var chunkSize: Int = 50
    let lock = NSLock()
    let queue = DispatchQueue(label: "queue", attributes: .concurrent)
    
    public init(numbers: [Int]) {
        self.numbers = numbers
    }
    
    func isPrime(_ number: Int) -> Bool {
        if number <= 3 {
            return number > 1
        }
        
        let countLimit = number / 2
        
        for iter in 2...countLimit where number % iter == 0 {
            return false
        }
        
        return true
    }
    
    func сoncurrentPrimeNumbers() {
        let total = numbers.count
        var primeResults = Array(repeating: false, count: total)
        let group = DispatchGroup()
        
        // https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
        let chunks = stride(from: 0, to: total, by: chunkSize).map {
            ($0, min($0 + chunkSize, total))
        }
        
        for (start, end) in chunks {
            group.enter()
            queue.async {
                for iter in start..<end {
                    let number = self.numbers[iter]
                    let isPrime = self.isPrime(number)
                    
                    self.lock.lock()
                    primeResults[iter] = isPrime
                    self.lock.unlock()
                }
                group.leave()
            }
        }
        
        group.wait()
        
        for (index, isPrime) in primeResults.enumerated() where isPrime {
            print(self.numbers[index])
        }
    }
}

//@main
//struct Task1 {
//    static func main() {
//        let nums = Numbers(numbers: Array(1...100000))
//        nums.сoncurrentPrimeNumbers()
//    }
//}
