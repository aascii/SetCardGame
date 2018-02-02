//
//  ViewController.swift
//  SetCardGame
//
//  Created by Jason Hayes on 1/29/18.
//  Copyright © 2018 aasciiworks. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private lazy var game: SetGame? = SetGame()

    override func viewDidLoad() {
        super.viewDidLoad()

        // model tests - remember to set deck back to private in SetGame
//        let testgame = SetGame()
//        for _ in 1...4 {
//            print("\(testgame.tabula[testgame.tabula.count.arc4random])")
//        }
//        print("Deck: \(testgame.deck.cards.count), Table: \(testgame.tabula.count)")
//        testgame.deal()
//        print("Deck: \(testgame.deck.cards.count), Table: \(testgame.tabula.count)")
//        print("Selected: \(testgame.selectedCards), Matched: \(testgame.matchedCards)")
//        let testCard = testgame.tabula[testgame.tabula.count.arc4random]
//        print("Testcard: \(testCard)")
//        testgame.select(card: testCard)
//        print("Selected: \(testgame.selectedCards), Matched: \(testgame.matchedCards)")
//        testgame.select(card: testCard)
//        print("Selected: \(testgame.selectedCards), Matched: \(testgame.matchedCards)")
    }

    @IBAction func startNewGame(_ sender: UIButton) {
        if game != nil {
            game = nil
        }
        game = SetGame()
        for button in game!.tabula.indices {
            drawNewCardButton(for: button)
        }
//        updateViewFromModel()
    }

    @IBOutlet var cardButtons: [UIButton]!

//    private func updateViewFromModel() {
//        for card in cardButtons.indices {
//            
//        }
//    }

    enum Symbol: String {
        case one = "▲"
        case two = "●"
        case three = "■"
    }

    enum Color: Int {
        case one = 1
        case two = 2
        case three = 3
    }

    let cardColors = [Color.one.rawValue: UIColor.green, Color.two.rawValue: UIColor.purple,
                      Color.three.rawValue: UIColor.red]

    enum Shader: Int {
        case one = 1
        case two = 2
        case three = 3
    }

    let cardShaders = [Shader.one.rawValue: -3.0, Shader.two.rawValue: -3.0,
                       Shader.three.rawValue: 5.0]

    let cardShaderHatchAlpha = CGFloat(0.15)

    private func drawNewCardButton(for button: Array<Card>.Index) {
        cardButtons[button].backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        cardButtons[button].layer.cornerRadius = 8.0
        var buttonTitle: String
        var buttonTitleAttributes = [NSAttributedStringKey: Any]()

        // build the symbol string for the button
        switch game?.tabula[button].symbol {
        case .one?: buttonTitle = Symbol.one.rawValue
        case .two?: buttonTitle = Symbol.two.rawValue
        case .three?: buttonTitle = Symbol.three.rawValue
        default: buttonTitle = "!"  // must be a bug!
        }
        if game!.tabula[button].number > 1 {
            let repeatingSymbol = buttonTitle
            for _ in 2...game!.tabula[button].number {
                buttonTitle += repeatingSymbol
            }
        }

        // prepare the symbol color for the button
        let commonColor: UIColor
        switch game?.tabula[button].color {
        case .one?:
            commonColor = cardColors[Color.one.rawValue]!
        case .two?:
            commonColor = cardColors[Color.two.rawValue]!
        case .three?:
            commonColor = cardColors[Color.three.rawValue]!
        default: commonColor = UIColor.black  // bug
        }
        buttonTitleAttributes[.strokeColor] = commonColor

        // prepare the symbol shading for the button
        switch game?.tabula[button].shade {
        case .one?:
            buttonTitleAttributes[.strokeWidth] = cardShaders[Shader.one.rawValue]!
            buttonTitleAttributes[.foregroundColor] = commonColor.withAlphaComponent(1.0)
        case .two?:
            buttonTitleAttributes[.strokeWidth] = cardShaders[Shader.two.rawValue]!
            buttonTitleAttributes[.foregroundColor] = commonColor.withAlphaComponent(cardShaderHatchAlpha)
        case .three?: buttonTitleAttributes[.strokeWidth] = cardShaders[Shader.three.rawValue]!
        default: buttonTitleAttributes[.strokeWidth] = 15.0  // bug
        }
        let buttonAttributedString = NSAttributedString(string: buttonTitle, attributes: buttonTitleAttributes)
        cardButtons[button].setAttributedTitle(buttonAttributedString, for: UIControlState.normal)
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
