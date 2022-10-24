import UIKit

public final class ErrorView: UIButton {

    public var onHide: (() -> Void)?

    public var message: String? {
        get { return isVisible ? title(for: .normal) : nil }
        set { setMessageAnimated(newValue) }
    }

    private var isVisible: Bool {
        return alpha > 0
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func show(message: String) {
        setTitle(message, for: .normal)
        contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { [weak self] completed in
                if completed {
                    self?.hideMessage()
                }
            })
    }

    private func configure() {
        setTitleColor(.white, for: .normal)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)

        setTitle(nil, for: .normal)
        titleLabel?.textAlignment = .center
        backgroundColor = #colorLiteral(red: 0.9995140433, green: 0.4175926149, blue: 0.4154433012, alpha: 1)
        alpha = 0
    }

    private func hideMessage() {
        setTitle(nil, for: .normal)
        alpha = 0
        contentEdgeInsets = .init(top: -2.5, left: 0, bottom: -2.5, right: 0)
        onHide?()
    }

    private func setMessageAnimated(_ message: String?) {
         if let message = message {
             show(message: message)
         } else {
             hideMessageAnimated()
         }
    }

}
