//
//  Card.swift
//  SetCardGame
//
//  Created by Jason Hayes on 1/29/18.
//  Copyright © 2018 aasciiworks. All rights reserved.
//

import Foundation

struct Card: CustomStringConvertible {
    var description: String {
        return "Number:\(number), Symbol:\(symbol), Color:\(color), Shade:\(shade)"
    }

    let number: Int
    let symbol: Symbol
    let color: Color
    let shade: Shade

    static let allNumbers = [1, 2, 3]

    enum Symbol: Int {
        case one = 1
        case two = 2
        case three = 3

        static let all = [Symbol.one, .two, .three]
    }

    enum Color: Int {
        case one = 1
        case two = 2
        case three = 3

        static let all = [Color.one, .two, .three]
    }

    enum Shade: Int {
        case one = 1
        case two = 2
        case three = 3

        static let all = [Shade.one, .two, .three]
    }
}

extension Card: Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        let allElementsEqual = (lhs.number == rhs.number) && (lhs.symbol == rhs.symbol) &&
                    (lhs.color == rhs.color) && (lhs.shade == rhs.shade)
        return allElementsEqual ? true : false
    }

}
