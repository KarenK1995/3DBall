import UIKit

protocol GameViewControllerDelegate: AnyObject {
    func gameViewController(_ controller: GameViewController, didEndGameWithScore score: Int)
}

class StartViewController: UIViewController, GameViewControllerDelegate {

    private let highScoreLabel = UILabel()
    private let startButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        updateHighScoreLabel()
    }

    private func setupUI() {
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        highScoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        highScoreLabel.textAlignment = .center

        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)

        view.addSubview(highScoreLabel)
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            highScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            startButton.topAnchor.constraint(equalTo: highScoreLabel.bottomAnchor, constant: 20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func updateHighScoreLabel() {
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        highScoreLabel.text = "High Score: \(highScore)"
    }

    @objc private func startGame() {
        let gameVC = GameViewController()
        gameVC.gameDelegate = self
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }

    // MARK: - GameViewControllerDelegate
    func gameViewController(_ controller: GameViewController, didEndGameWithScore score: Int) {
        let currentHigh = UserDefaults.standard.integer(forKey: "HighScore")
        if score > currentHigh {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        dismiss(animated: true) { [weak self] in
            self?.updateHighScoreLabel()
        }
    }
}
