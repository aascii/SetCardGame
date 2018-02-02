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
    }

    @IBAction func startNewGame(_ sender: UIButton) {
        if game != nil {
            game = nil
        }
        game = SetGame()
        for button in game!.tabula.indices {
            drawCardButton(for: button, at: button)
        }
        for button in 12..<24 {
            cardButtons[button].isHidden = true
        }
    }

    @IBOutlet var cardButtons: [UIButton]! {
        didSet {
            for button in cardButtons.indices {
                cardButtons[button].isHidden = true
            }
        }
    }

    @IBAction func cardButtonSelect(_ sender: UIButton) {
        game?.select(card: game!.tabula[cardButtons.index(of: sender)!])
        updateViewFromModel()
    }

    private func updateViewFromModel() {
        var buttonIndex = 0
        for card in game!.tabula.indices {
            let endGame = game!.matchedCards?.contains(game!.tabula[card])
            if endGame != nil, endGame == true {
                cardButtons[buttonIndex].isHidden = true
            } else {
                drawCardButton(for: card, at: buttonIndex)
            }
            buttonIndex += 1
        }
    }

    enum Symbol: String {
        case one = "▲"
        case two = "●"
        case three = "■"
    }

    enum Color {
        case one
        case two
        case three
        case four
    }

    enum Shader: Int {
        case one = 1
        case two = 2
        case three = 3
    }

    let cardShaders = [Shader.one.rawValue: -3.0, Shader.two.rawValue: -3.0,
                       Shader.three.rawValue: 5.0]

    let cardShaderHatchAlpha = CGFloat(0.15)

    private func drawCardButton(for card: Array<Card>.Index, at button: Array<UIButton>.Index) {
        cardButtons[button].isHidden = false
        cardButtons[button].backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        cardButtons[button].layer.cornerRadius = 8.0
        var buttonTitle: String
        var buttonTitleAttributes = [NSAttributedStringKey: Any]()

        // build the symbol string for the button
        switch game?.tabula[card].symbol {
        case .one?: buttonTitle = Symbol.one.rawValue
        case .two?: buttonTitle = Symbol.two.rawValue
        case .three?: buttonTitle = Symbol.three.rawValue
        default: buttonTitle = "!"  // must be a bug!
        }
        if game!.tabula[card].number > 1 {
            let repeatingSymbol = buttonTitle
            for _ in 2...game!.tabula[card].number {
                buttonTitle += repeatingSymbol
            }
        }

        // prepare the symbol color for the button
        let commonColor: UIColor
        switch game!.tabula[card].color {
        case .one: commonColor = Color.one.rawValue
        case .two: commonColor = Color.two.rawValue
        case .three: commonColor = Color.three.rawValue
        }
        buttonTitleAttributes[.strokeColor] = commonColor

        // prepare the symbol shading for the button
        switch game!.tabula[card].shade {
        case .one:
            buttonTitleAttributes[.strokeWidth] = cardShaders[Shader.one.rawValue]!
            buttonTitleAttributes[.foregroundColor] = commonColor.withAlphaComponent(1.0)
        case .two:
            buttonTitleAttributes[.strokeWidth] = cardShaders[Shader.two.rawValue]!
            buttonTitleAttributes[.foregroundColor] = commonColor.withAlphaComponent(cardShaderHatchAlpha)
        case .three:
            buttonTitleAttributes[.strokeWidth] = cardShaders[Shader.three.rawValue]!
        }
        let buttonAttributedString = NSAttributedString(string: buttonTitle, attributes: buttonTitleAttributes)

        // apply the mapped card to this button view
        cardButtons[button].setAttributedTitle(buttonAttributedString, for: UIControlState.normal)

        // apply button outline if this is a selected card
        cardButtons[button].layer.borderWidth = 3.0
        let cardSelected = game!.selectedCards?.contains(game!.tabula[card])
        if cardSelected != nil, cardSelected == true {
            cardButtons[button].layer.borderColor = UIColor.yellow.cgColor
        } else {
            cardButtons[button].layer.borderColor = UIColor.white.cgColor
        }
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

// here we allow our display Color enum to retrieve UIColor rawValues
// this is where to customize the card colors
extension ViewController.Color: RawRepresentable {
    typealias RawValue = UIColor

    init?(rawValue: RawValue) {
        switch rawValue {
        case UIColor.green: self = .one
        case UIColor.purple: self = .two
        case UIColor.red: self = .three
        default: self = .four     // would indicate a bug
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .one: return UIColor.green
        case .two: return UIColor.purple
        case .three: return UIColor.red
        default: return UIColor.black    // only used as an error condition
        }
    }
}
