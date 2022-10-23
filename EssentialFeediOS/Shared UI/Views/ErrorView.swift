import UIKit

public final class ErrorView: UIView {
    private(set) lazy var button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(hideMessage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public var message: String? {
        get { return isVisible ? button.title(for: .normal) : nil }
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
        button.setTitle(message, for: .normal)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc func hideMessage() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed {
                    self.button.setTitle(nil, for: .normal)
                }
            })
    }

    private func configure() {
        button.setTitle(nil, for: .normal)
        button.titleLabel?.textAlignment = .center
        backgroundColor = #colorLiteral(red: 0.9995140433, green: 0.4175926149, blue: 0.4154433012, alpha: 1)
        alpha = 0

        addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}
