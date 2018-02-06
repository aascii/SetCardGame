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

    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var opponentScoreLabel: UILabel!

    var score: Int {
        if let value = game?.points {
            return value
        } else {
            return 0
        }
    }

    var opponentScore: Int {
        if let value = game?.opponentPoints {
            return value
        } else {
            return 0
        }
    }

    @IBOutlet weak var startNewSoloGameLabel: UIButton! {
        didSet {
            startNewSoloGameLabel.layer.cornerRadius = 16.0
        }
    }

    @IBOutlet weak var startNewOpponentGameLabel: UIButton! {
        didSet {
            startNewOpponentGameLabel.layer.cornerRadius = 16.0
        }
    }

    @IBAction func startNewGame(_ sender: UIButton) {
        if game != nil {
            game = nil
        }
        if sender.titleLabel?.text == "Solo Game" {
            game = SetGame()
            hintButtonLabel.isHidden = false
            opponentScoreLabel.isHidden = true
        } else {
            game = SetGame(opponent: true)
            hintButtonLabel.isHidden = true
            opponentScoreLabel.isHidden = false
            game!.opponentDelegate = self
        }
        game!.tabulaDelegate = self
        game!.points = 0
        for button in game!.tabula.indices {
            drawCardForButton(for: button, at: button)
        }
        for button in 12..<24 {
            cardButtons[button].isHidden = true
        }
        drawCardsLabel.isHidden = false
        updateViewFromModel()
    }

    @IBOutlet weak var drawCardsLabel: UIButton! {
        didSet {
            drawCardsLabel.isHidden = true
            drawCardsLabel.layer.cornerRadius = 16.0
        }
    }

    @IBAction func drawCards(_ sender: UIButton) {
        if game!.matchIdentified {
            game!.deal()
        } else {
            if cardButtons.contains(where: { $0.isHidden }) {
                game!.deal()
            }
        }
        updateViewFromModel()
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
        provideHint = false
        updateViewFromModel()
    }

    private func updateViewFromModel() {
        var buttonIndex = 0
        for card in game!.tabula.indices {
            if game!.deck.cards.isEmpty {
                drawCardsLabel.isHidden = true
            }
            drawCardForButton(for: card, at: buttonIndex)
            buttonIndex += 1
        }
        scoreLabel.text = "Score: \(score)"
        if game!.opponentMode == 1 {
            let opponentEmoji: String
            switch game!.opponentState {
            case .waiting: opponentEmoji = "🤔"
            case .warning: opponentEmoji = "😁"
            case .winner: opponentEmoji = "😎"
            case .loser: opponentEmoji = "😭"
            }
            opponentScoreLabel.text = "Vs \(opponentEmoji): \(game!.opponentPoints)"
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

    private let cardShaders = [Shader.one.rawValue: -3.0, Shader.two.rawValue: -3.0,
                       Shader.three.rawValue: 5.0]

    private let cardShaderHatchAlpha = CGFloat(0.15)

    private var provideHint = false

    @IBAction func hintButton(_ sender: UIButton) {
        if provideHint == false, game!.matchPossible {
            provideHint = true
            game!.points -= 10
            updateViewFromModel()
        }
    }

    @IBOutlet weak var hintButtonLabel: UIButton! {
        didSet {
            hintButtonLabel.isHidden = true
            hintButtonLabel.layer.cornerRadius = 16.0
        }
    }

    private func drawCardForButton(for card: Array<Card>.Index, at button: Array<UIButton>.Index) {
        cardButtons[button].isHidden = false

        // determine and set background based on set "match" possibilities or hinting
        let matchExists = game!.matchIdentified
        let selection: [Card]?  = game!.selectedCards

        if matchExists, selection!.contains(game!.tabula[card]) {
            cardButtons[button].backgroundColor = UIColor.yellow
        } else {
            if selection != nil, selection!.count == 3, !matchExists, selection!.contains(game!.tabula[card]) {
                cardButtons[button].backgroundColor = UIColor.orange
            } else {
                cardButtons[button].backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            }
        }
        if provideHint, game!.matchPossible {
            for _ in game!.hintCards!.indices where game!.hintCards!.contains(game!.tabula[card]) {
                if game!.selectedCards == nil {
                    cardButtons[button].backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                    provideHint = false
                    break
                } else {
                    if !game!.selectedCards!.contains(game!.tabula[card]) {
                        cardButtons[button].backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                        provideHint = false
                        break
                    }
                }
            }
        }

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

// conform to tabula radio station
extension ViewController: TabulaDelegate {
    func didReceiveTabulaUpdate(endPosition: Array<Card>.Index) {
        cardButtons[endPosition].isHidden = true
        updateViewFromModel()
    }
}

// conform to opponent radio station
extension ViewController: OpponentDelegate {
    func didReceiveOpponentUpdate(status: SetGame.OpponentState) {
        updateViewFromModel()
    }
}

// extension used in model as well
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
