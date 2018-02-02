//
//  Deck.swift
//  SetCardGame
//
//  Created by Jason Hayes on 1/29/18.
//  Copyright © 2018 aasciiworks. All rights reserved.
//

import Foundation

struct Deck {
    private(set) var cards = [Card]()

    init() {
        for symbol in Card.Symbol.all {
            for color in Card.Color.all {
                for shade in Card.Shade.all {
                    for number in 1...3 {
                        cards.append(Card(number: number, symbol: symbol, color: color, shade: shade))
                    }
                }
            }
        }
    }

    mutating func draw() -> Card? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}
