//
//  task4_.swift
//  homework6
//
//  Created by Ivan Solomatin on 12.12.2024.
//

import Foundation

struct Node: Hashable {
    let name: String
    var dependencies: [Node] = []
}

class Graph {
    var list: [Node: [Node]] = [:]
    var doneNodes: [Node] = []
    private var dependencyCount: [Node: Int] = [:]
    private let semaphore = DispatchSemaphore(value: 1)
    
    init(nodes: [Node]) {
        build(nodes: nodes)
    }
    
    func build(nodes: [Node]) {
        for node in nodes {
            list[node] = []
            dependencyCount[node] = node.dependencies.count
        }
        
        for node in nodes {
            for dep in node.dependencies {
                list[dep]?.append(node)
            }
        }
    }

    func traverse() {
        let group = DispatchGroup()
        var executableNodes = dependencyCount.filter { $0.value == 0 }.map { $0.key }
        
        while !executableNodes.isEmpty {
            let currentNodes = executableNodes
            executableNodes = []
            
            for node in currentNodes {
                group.enter()
                executeNode(node) {
                    self.updateDependencies(for: node) { readyNodes in
                        executableNodes.append(contentsOf: readyNodes)
                    }
                    group.leave()
                }
            }
            
            group.wait()
        }
        
        print("All nodes have been executed!")
    }
    
    private func executeNode(_ node: Node, completion: @escaping () -> Void) {
        let sleepTime = Double.random(in: 1...3)
        let emojis = ["😀", "🚀", "🌟", "🔥", "💡", "🎯", "🐱", "🍀", "🪐", "🎉"]
        let randomEmoji = emojis.randomElement() ?? "✨"
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + sleepTime) {
            print("Executing node \(node.name) \(randomEmoji)")
            print("Completed node \(node.name) \(randomEmoji)")
            completion()
        }
    }
    
    private func updateDependencies(for node: Node, completion: @escaping ([Node]) -> Void) {
        var readyNodes: [Node] = []
        semaphore.wait()
        if let dependents = list[node] {
            for dependent in dependents {
                dependencyCount[dependent, default: 0] -= 1
                if dependencyCount[dependent] == 0 {
                    readyNodes.append(dependent)
                }
            }
        }
        semaphore.signal()
        completion(readyNodes)
    }
}

@main
struct Task3 {
    static func main() {
        
        print("Executing Graph 1")
        
        let nodeF = Node(name: "F")
        let nodeE = Node(name: "E", dependencies: [nodeF])
        let nodeD = Node(name: "D", dependencies: [nodeF])
        let nodeC = Node(name: "C", dependencies: [nodeE, nodeD])
        let nodeB = Node(name: "B", dependencies: [nodeD])
        let nodeA = Node(name: "A", dependencies: [nodeB, nodeC])

        let graph1 = Graph(nodes: [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF])
        graph1.traverse()
        
        print("--------------------")
        print("Executing Graph 2")
        
        let nodeJ = Node(name: "J")
                let nodeI = Node(name: "I", dependencies: [nodeJ])
                let nodeH = Node(name: "H", dependencies: [nodeI])
                let nodeG = Node(name: "G", dependencies: [nodeH])
                let nodeF2 = Node(name: "F", dependencies: [nodeG])
                let nodeE2 = Node(name: "E", dependencies: [nodeJ])
                let nodeD2 = Node(name: "D", dependencies: [nodeI])
                let nodeC2 = Node(name: "C", dependencies: [nodeH])
                let nodeB2 = Node(name: "B", dependencies: [nodeG])
                let nodeA2 = Node(name: "A", dependencies: [nodeB2, nodeC2, nodeD2, nodeE2, nodeF2])
                
                let graph2 = Graph(nodes: [nodeA2, nodeB2, nodeC2, nodeD2, nodeE2, nodeF2, nodeG, nodeH, nodeI, nodeJ])
                graph2.traverse()
    }
}
