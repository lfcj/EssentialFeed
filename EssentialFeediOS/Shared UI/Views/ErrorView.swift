import UIKit

public final class ErrorView: UIButton {

    public var message: String? {
        get { return isVisible ? title(for: .normal) : nil }
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

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc func hideMessage() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { [weak self] completed in
                if completed {
                    self?.setTitle(nil, for: .normal)
                }
            })
    }

    private func configure() {
        setTitleColor(.white, for: .normal)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .systemFont(ofSize: 17)
        addTarget(self, action: #selector(hideMessage), for: .touchUpInside)

        setTitle(nil, for: .normal)
        titleLabel?.textAlignment = .center
        backgroundColor = #colorLiteral(red: 0.9995140433, green: 0.4175926149, blue: 0.4154433012, alpha: 1)
        alpha = 0
    }

}
