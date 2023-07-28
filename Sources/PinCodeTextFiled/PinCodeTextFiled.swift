import Foundation
import UIKit

@IBDesignable
public class PinCodeTextField: UITextField {
    
    static let padding: CGFloat = 20
    static let digitToBorderSpace: CGFloat = 10
    
    static let defaultDigitsCount: UInt = 4
    static let defaultBorderHeight: CGFloat = 4
    static let defaultBordersSpacing: CGFloat = 10

    @IBInspectable var digitsCount: UInt = 4 {
        didSet {
            clearText()
            setupBorders()
        }
    }

    @IBInspectable var borderHeight: CGFloat = 4 {
        didSet {
            clearText()
            setupBorders()
        }
    }

    @IBInspectable var bordersSpacing: CGFloat = 10 {
        didSet {
            clearText()
            layoutIfNeeded()
        }
    }

    @IBInspectable var filledDigitBorderColor: UIColor = .lightGray {
        didSet {
            configureBorderColors()
        }
    }

    @IBInspectable var emptyDigitBorderColor: UIColor = .red {
        didSet {
            configureBorderColors()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        setupBorders()
        configureDefaultValues()
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private var borders: [CALayer] = []

    private func setupBorders() {
        borders.forEach { $0.removeFromSuperlayer() }
        borders.removeAll()

        for _ in 0..<Int(digitsCount) {
            let border = CALayer()
            border.borderColor = emptyDigitBorderColor.cgColor
            border.borderWidth = borderHeight

            borders.append(border)
            layer.addSublayer(border)
        }
    }

    private func configureDefaultValues() {
        delegate = self
        adjustsFontSizeToFitWidth = false
        keyboardType = .numberPad
        textAlignment = .left
        borderStyle = .none
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        for (index, border) in borders.enumerated() {
            let xPos = (borderWidth() + bordersSpacing) * CGFloat(index) + PinCodeTextField.padding
            border.frame = CGRect(x: xPos, y: frame.height - borderHeight, width: borderWidth(), height: borderHeight)
        }
    }

    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height += borderHeight * 2 + PinCodeTextField.digitToBorderSpace
        return size
    }

    public override func becomeFirstResponder() -> Bool {
        configureInitialSpacing(at: text?.count ?? 0)
        return super.becomeFirstResponder()
    }

    func clearText() {
        text = nil
        borders.forEach { $0.borderColor = emptyDigitBorderColor.cgColor }
        configureInitialSpacing(at: 0)
    }

    @objc private func textFieldDidChange(_ sender: UITextField) {
        guard let length = sender.text?.count else { return }
        configureBorderColor(at: length)
        configureInitialSpacing(at: length)
        addSpacingToText(with: length)
    }

    private func configureBorderColor(at index: Int) {
        if index == 0 {
            borders[0].borderColor = emptyDigitBorderColor.cgColor
        } else if index == Int(digitsCount) {
            borders[Int(digitsCount) - 1].borderColor = filledDigitBorderColor.cgColor
        } else {
            borders[index].borderColor = emptyDigitBorderColor.cgColor
            borders[index - 1].borderColor = filledDigitBorderColor.cgColor
        }
    }

    private func configureInitialSpacing(at index: Int) {
        if index == 0 {
            addInitialSpacing(PinCodeTextField.padding)
        } else if index == 1 {
            let userAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font as Any]
            let textWidth = (text as NSString?)?.size(withAttributes: userAttributes).width ?? 0
            let spacing = (borderWidth() - textWidth) / 2 + PinCodeTextField.padding
            addInitialSpacing(spacing)
        }
    }

    private func addSpacingToText(with length: Int) {
        if length == 0 {
            return
        }

        guard let attributedString = attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return
        }

        let isLastDigit = length == Int(digitsCount)
        let nextBorderSpacing = isLastDigit ? 0 : bordersSpacing

        let lastSpacing = spacingToDigit(at: length - 1, attributedText: attributedString)
        let spacing = lastSpacing + nextBorderSpacing
        attributedString.addAttribute(.kern, value: spacing, range: NSRange(location: length - 1, length: 1))

        if length > 1 {
            let preLastSpacing = spacingToDigit(at: length - 2, attributedText: attributedString)
            let spacing = preLastSpacing + lastSpacing + bordersSpacing
            attributedString.addAttribute(.kern, value: spacing, range: NSRange(location: length - 2, length: 1))
        }

        self.attributedText = attributedString
    }

    private func spacingToDigit(at index: Int, attributedText: NSMutableAttributedString) -> CGFloat {
        let userAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font as Any]

        guard let text = (attributedText.string as NSString?)?.substring(with: NSRange(location: index, length: 1)),
            let textWidth = (text as NSString).size(withAttributes: userAttributes).width as CGFloat? else {
                return 0
        }

        return (borderWidth() - textWidth) / 2
    }

    private func borderWidth() -> CGFloat {
        let totalSpacing = CGFloat(digitsCount - 1) * bordersSpacing
        return (frame.width - PinCodeTextField.padding * 2 - totalSpacing) / CGFloat(digitsCount)
    }

    private func addInitialSpacing(_ width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        leftViewMode = .always
        leftView = paddingView
    }

    private func isOnlyNumbersString(_ string: String?) -> Bool {
        let notDigits = CharacterSet.decimalDigits.inverted
        return string?.rangeOfCharacter(from: notDigits) == nil
    }

    private func configureBorderColors() {
        for (index, border) in borders.enumerated() {
            let isFilled = text?.count ?? 0 > index
            border.borderColor = isFilled ? filledDigitBorderColor.cgColor : emptyDigitBorderColor.cgColor
        }
    }
}

extension PinCodeTextField: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            return false
        }

        let length = currentString.count

        if !isOnlyNumbersString(string) {
            return false
        }

        if length > digitsCount {
            return false
        }

        return true
    }
}
