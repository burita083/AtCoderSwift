//
//  main.swift
//  AtCoderSwift
//
//  Created by burita083 on 2020/08/25.
//  Copyright © 2020 burita083. All rights reserved.
//

import Foundation
func readInt() -> Int {
    return Int(readLine()!)!
}
 
func readInts() -> [Int] {
    return readLine()!.split(separator: " ").map { Int($0)! }
}
 
func readTwoInts() -> (a: Int, b: Int) {
    let ints = readLine()!.split(separator: " ").map { Int($0)! }
    return (a: ints[0], b: ints[1])
}

func abc080_b() {
    let N = readLine()!
    let sum = N.map { Int(String($0))! }.reduce(0, +)
    print(Int(N)! % sum == 0 ? "Yes" : "No")
}

//abc080_b()

func abc078_b() {
    let input = readInts()
    var X = input[0]
    let Y = input[1]
    let Z = input[2]
    var ans = 0
    X -= Y+Z*2
    ans += 1
    ans += X/(Y+Z)
    
    print(ans)
}

func abc085_b() {
    let N = readInt()
    var l: [Int] = []
    for _ in 0..<N {
        let d = readInt()
        l.append(d)
    }
    print(l.reduce([], { $0.contains($1) ? $0 : $0 + [$1] }).count)
}

func isSquare(n: Double) -> Bool {
    let sqrt = floor(n.squareRoot())
    return sqrt * sqrt == n
}

func abc077_b() {
    let N = readInt()
    for n in (1...N).reversed() {
        if isSquare(n: Double(n)) {
            print(n)
            return
        }
    }
}

func abc020_b () {
    let inputs = readInts()
    print(Int(String(inputs[0]) + String(inputs[1]))! * 2)
}

abc020_b()

