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

func tenka1_2017_a() {
    let S = readLine()!
    print(S.map { $0 }.filter { $0 == "1"}.count)
}

func abc178_c() {
    let N = readInt()
    let mod = 1000000007
    var w = 1
    var n = 1
    var e = 1
    for _ in 1...N {
        w *= 10
        w %= mod
        
        n *= 9
        n %= mod
        
        e *= 8
        e %= mod
        
    }
    let result = (w - e - ((n - e) * 2)) % mod
    if result >= 0 {
        print(result)
    } else {
        print(mod + result)
    }
}

func soundhound2018_a() {
    let inputs = readInts()
    if inputs[0] + inputs[1] == 15 {
        print("+")
        return
    }
    if inputs[0] * inputs[1] == 15 {
        print("*")
        return
    }
    print("x")
}

func soundhound2018_b() {
    guard let S = readLine() else {
        return
    }
    let w = readInt()
    
    var ans = S[0]
    for i in w..<S.count {
        if i % w == 0 {
            ans += S[i]
        }
    }
    print(ans)
}

func abc009_2() {
    let N = readInt()
    var As: [Int] = []
    for _ in 0..<N {
        let A = readInt()
        if As.contains(A) {
            continue
        }
        As.append(A)
    }
    print(As.sorted()[As.count-2])
}

extension String {
    mutating func swapAt(_ index1: Int, _ index2: Int) {
        var characters = Array(self)
        characters.swapAt(index1, index2)
        self = String(characters)
    }
}

func abc018_2() {
    var S = readLine()!
    let N = readInt()
    for _ in 0..<N {
        let input = readInts()
        var pre = S.prefix(input[0]-1)
        var middle = S[S.index(S.startIndex, offsetBy: input[0]-1)..<S.index(S.startIndex, offsetBy: input[1])]
        var end = S.suffix(S.count - input[1])
        S = pre + String(middle.reversed()) + end
    }
    print(S)
}

func tenka1_2018_b() {
    let input = readInts()
    var t = input[0]
    var a = input[1]
    let k = input[2]
    
    if t % 2 != 0 {
        t -= 1
        t /= 2
        a += t
    } else {
        t /= 2
        a += t
    }
    
    if k == 1 {
        print(t, a)
        return
    } else if k == 2 {
        if a % 2 != 0 {
            a -= 1
            a /= 2
            t += a
        } else {
            a /= 2
            t += a
        }
        print(t, a)
        return
    } else {
        if a % 2 != 0 {
            a -= 1
            a /= 2
            t += a
        } else {
            a /= 2
            t += a
        }
        for i in 3...input[2] {
            if i % 2 != 0 {
                if t % 2 != 0 {
                    t -= 1
                    t /= 2
                    a += t
                } else {
                    t /= 2
                    a += t
                }
            } else {
                if a % 2 != 0 {
                    a -= 1
                    a /= 2
                    t += a
                } else {
                    a /= 2
                    t += a
                }
            }
        }
    }
    print(t, a)
}


func tenka1_2019_b() {
    let N = readInt()
    let S = readLine()!
    let K = readInt()
    let target = S[K-1]
    var ans = ""
    for i in 0..<N {
        if S[i] == target {
            ans += target
        } else {
            ans += "*"
        }
    }
    print(ans)
}

func formula_2014_qualA_a() {
    let N = readInt()
    var a = 1
    while a*a*a <= N {
        if a*a*a == N {
            print("YES")
            return
        }
        a += 1
    }
    print("NO")
}

func code_festival_2015_qualA_a() {
    var S = readLine()!
    S = String(S.dropLast())
    S.append("5")
    print(S)
}

func hhkb2020_a() {
    var S = readLine()!
    var T = readLine()!
    
    if S == "Y" {
        print(T.uppercased())
    } else {
        print(T)
    }
}

func pakencamp_2019_day3_a() {
    let input = readInts()
    print(input[1]-input[0]+1)
}

func nikkei2019ex_a() {
    let S = readLine()!
    for i in 0..<S.count {
        print(i + 1)
    }
}

func iroha2019_day1_a() {
    print(readLine()![0])
}

func hitachi2020_a() {
    let S = readLine()!
    var flag1 = false
    var flag2 = false
    var count = 0
    if S.count % 2 != 0 {
        print("No")
        return
    }
    for (index, char) in S.enumerated() {
        if count == 2 {
            if flag1 && flag2 {
                count = 0
            } else {
                print("No")
                return
            }
        }
        
        if index % 2 == 0 {
            if char == "h" {
                flag1 = true
            } else {
                print("No")
                return
            }
        } else {
            if char == "i" {
                flag2 = true
            } else {
                print("No")
                return
            }
        }
        count += 1
    }
    
    print("Yes")
}

func m_solutions2019_a() {
    let N = readInt()
    print(180*(N-2))
    
}
func diverta2019_a() {
    let input = readInts()
    print(input[0] - input[1] + 1)
}

func diverta2019_2a() {
    let input = readInts()
    if input[1] == 1 {
        print(0)
        return
    }
    let amari = input[0] - input[1]
    print(amari)
}

func isPalindrome(str: String) -> Bool {
    let rev = String(str.reversed())
    
    if str == rev {
        return true
    } else {
        return false
    }
}

func arc031_1() {
    let S = readLine()!
    if isPalindrome(str: S) {
        print("YES")
    } else {
        print("NO")
    }

}
arc031_1()
//do {
//    try print(caddi2018b_a())
//} catch NumError.invalid(let errorMessage) {
//    print(errorMessage)
//}
