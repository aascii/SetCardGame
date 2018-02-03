//
//  SetGame.swift
//  SetCardGame
//
//  Created by Jason Hayes on 1/30/18.
//  Copyright © 2018 aasciiworks. All rights reserved.
//

import Foundation

class SetGame {

    private(set) var deck = Deck()

    private(set) var tabula = [Card]()

    var points = 0

    private var startTime: Date?

    var selectedCards: [Card]?

    var matchedCards: [Card]?

    var matchIdentified: Bool {
        if selectedCards?.count == 3 {
            if (selectedCards?[0].number == selectedCards?[1].number &&  // are all the card numbers the same?
                selectedCards?[1].number == selectedCards?[2].number) ||
                (selectedCards?[0].number != selectedCards?[1].number &&  // or are they all different?
                    selectedCards?[1].number != selectedCards?[2].number &&
                    selectedCards?[2].number != selectedCards?[0].number) {
                if (selectedCards?[0].symbol == selectedCards?[1].symbol &&  // are all the card symbols the same?
                    selectedCards?[1].symbol  == selectedCards?[2].symbol) ||
                    (selectedCards?[0].symbol != selectedCards?[1].symbol &&  // or are they all different?
                        selectedCards?[1].symbol != selectedCards?[2].symbol &&
                        selectedCards?[2].symbol != selectedCards?[0].symbol) {
                    if (selectedCards?[0].color == selectedCards?[1].color &&  // are all the card colors the same?
                        selectedCards?[1].color  == selectedCards?[2].color) ||
                        (selectedCards?[0].color != selectedCards?[1].color &&  // or are they all different?
                            selectedCards?[1].color != selectedCards?[2].color &&
                            selectedCards?[2].color != selectedCards?[0].color) {
                        if (selectedCards?[0].shade == selectedCards?[1].shade &&  // are all the card shades the same?
                            selectedCards?[1].shade  == selectedCards?[2].shade) ||
                            (selectedCards?[0].shade != selectedCards?[1].shade &&  // or are they all different?
                                selectedCards?[1].shade != selectedCards?[2].shade &&
                                selectedCards?[2].shade != selectedCards?[0].shade) {
                            // this player is incredible!  smart and probably funny too - they found a match!
                            return true
                        }
                    }
                }
            }
        }
        return false
    }

    init() {
        for _ in 1...12 {
            tabula.append(deck.draw()!)
        }
        points = 0
        startTime = Date()
    }

    func deal() {
        if selectedCards?.count == 3 {
            performMatchOperations()
            selectedCards = nil
        } else {
            for remaining in 1...3 {
                if let card = deck.draw() {
                    tabula.append(card)
                } else {
                    if remaining > 1 {
                        print("ERROR - deck count is mismanaged in deal()")
                    } else {
                        // remove next line after testing
                        print("DEBUG - empty deck in deal()")
                        break
                    }
                }
            }
        }
    }

    func select(card: Card) {
        if selectedCards == nil {
            selectedCards = [Card]()
            selectedCards!.append(card)
        } else {
            switch selectedCards!.count {
            case 1..<3:
                if self.selectedCards!.contains(card) {
                    let cardToUnselect = self.selectedCards!.index(of: card)
                    self.selectedCards!.remove(at: cardToUnselect!)
                    points -= 1
                } else {
                    self.selectedCards!.append(card)
                }
                let currentTime = Date()
                let turnTime = currentTime.timeIntervalSince(startTime!)
                var scoreFactor: Int
                if self.matchIdentified {
                    switch turnTime {
                    case 0..<5.0: scoreFactor = 8
                    case 5.0..<15.0: scoreFactor = 4
                    case 15.0..<25.0: scoreFactor = 2
                    default: scoreFactor = 1
                    }
                    points += (5 * scoreFactor)
                } else {
                    if selectedCards!.count == 3 {
                        switch turnTime {
                        case 0..<0.05: scoreFactor = 8
                        case 0.05..<15.0: scoreFactor = 1
                        default: scoreFactor = 2
                        }
                        points -= (8 * scoreFactor)
                    }
                }
            case 3:
                performMatchOperations()
                // swiftlint:disable:next fallthrough
                fallthrough
            default:
                selectedCards = nil
                selectedCards = [Card]()
                selectedCards?.append(card)
                startTime = Date()
            }
        }
    }

    private func performMatchOperations() {
        if matchIdentified {
            if matchedCards == nil {
                matchedCards = [Card]()
            }
            for index in selectedCards!.indices {
                matchedCards?.append(selectedCards![index])
                let cardToRemoveFromPlay = tabula.index(of: selectedCards![index])
                if let cardToAdd = deck.draw() {
                    tabula[cardToRemoveFromPlay!] = cardToAdd
                }
            }
        }
    }
}
