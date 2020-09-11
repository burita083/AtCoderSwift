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

func abc073_b () {
    var ans = 0
    let N = readInt()
    for _ in 0..<N {
        let inputs = readInts()
        ans += inputs[1] - inputs[0] + 1
    }
    print(ans)
}

func abc026_b () {
    var evens: [Int] = []
    var odds: [Int] = []
    var all: [Int] = []
    let N = readInt()
    for _ in 0..<N {
        let R = readInt()
        all.append(R)
    }

    for (i, e) in all.sorted(by: >).enumerated() {
        if i % 2 == 0 {
            evens.append(e)
        } else {
            odds.append(e)
        }
    }
    let ans = evens.map { $0 * $0 }.reduce(0, +) - odds.map { $0 * $0 }.reduce(0, +)
    print(Double(ans) * Double.pi)
}

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased()  + self.lowercased().dropFirst()
    }
}

func abc012_b () {
    print(readLine()!.firstUppercased)

}

func abc007_b () {
    print(readLine()! == "a" ? -1 : "a")
}

func abc028_b () {
    let S = readLine()!
    let A = String(S.filter { $0 == "A" }.count)
    let B = String(S.filter { $0 == "B" }.count)
    let C = String(S.filter { $0 == "C" }.count)
    let D = String(S.filter { $0 == "D" }.count)
    let E = String(S.filter { $0 == "E" }.count)
    let F = String(S.filter { $0 == "F" }.count)
    print(A + " " + B + " " + C + " " + D + " " + E + " " + F)
}

func abc097_b () {
    let x = Double(Int(readLine()!)!)
    var ans: Double = 1
    for b in 2..<32 {
        var p: Double = 2
        while pow(Double(b), p) <= x {
            ans = max(ans, pow(Double(b), p))
            p += 1
        }
    }
    print(Int(ans))
}

func abc093_b () {
    var ans: [Int] = []
    let inputs = readInts()
    for x in inputs[0]..<inputs[0]+inputs[2] {
        ans.append(x)
    }
    
    for x in inputs[1]-inputs[2]+1...inputs[1] {
        if !ans.contains(x) {
            ans.append(x)
        }
    }
    ans.filter { $0 >= inputs[0] && $0 <= inputs[1] }.forEach { print($0) }
        

}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

func abc071_b () {
    let S = readLine()!
    let T = readLine()!
    if S == T {
        print("Yes")
        return
    }
    
    var ans = 0
    var count: Int
    for i in 1..<T.count {
        count = 0
        for k in i..<T.count {
            if S[k] == T[k] {
                count += 1
            }
        }
        print(count)
        
        for k in (0..<i).reversed() {
            print(S[T.count-1-k])
            if S[T.count-1-k] == T[k] {
                count += 1
            }
                print(count)
        }
        ans = max(ans, count)
    }
    
    if ans == T.count {
        print("Yes")
    } else {
        print("No")
    }
    

}


func abc094_b () {
    let inputs = readInts()
    let A = readInts()
    var ans = 1000007
    var count = 0
    for i in inputs[2]...inputs[0] {
        if A.contains(i) {
            count += 1
        }
    }
    ans = min(count, ans)
    count = 0
    for i in 0...inputs[2] {
        if A.contains(i) {
            count += 1
        }
    }
    ans = min(count, ans)
    print(ans)
}

func tenka1_2019_a() {
    let inputs = readInts()
    
    if inputs[0] < inputs[2] && inputs[2] < inputs[1] && inputs[0] < inputs[1] {
        print("Yes")
        return
    }
    
    if inputs[0] > inputs[2] && inputs[2] > inputs[1] && inputs[0] > inputs[1] {
        print("Yes")
        return
    }
    print("No")
}

enum NumError: Error {
    case invalid(String)
}

extension NumError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalid(let errorMessage):
            return errorMessage
        }
    }
}

func caddi2018b_aa() throws -> Int {
    let N = readInt()
    
    if N < 999 {
        throw NumError.invalid("1000から9999の値を入れてください")
    }
    
    if N >= 10000 {
        throw NumError.invalid("1000から9999の値を入れてください")
    }
    
    return String(N).map {$0}.filter {$0 == "2"}.count
}

func caddi2018b_a() -> Result<Int, NumError> {
    let N = readInt()
    
    if N < 999 {
        return .failure(.invalid("1000から9999の値を入れてください"))
    }
    
    if N >= 10000 {
        return .failure(.invalid("1000から9999の値を入れてください"))
    }
    
    return .success(String(N).map {$0}.filter {$0 == "2"}.count)
}

func tenka1_2018_a() {
    let S = readLine()!
    var reversedString = ""
    for char in S {
        reversedString = "\(char)" + reversedString
    }
    print(reversedString)
}

tenka1_2018_a()
//do {
//    try print(caddi2018b_a())
//} catch NumError.invalid(let errorMessage) {
//    print(errorMessage)
//}
