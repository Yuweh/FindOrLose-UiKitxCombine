//
//  GameViewController.swift
//  FindOrLose
//
//  Created by Jay Bergonia on 5/1/22.
//

import UIKit

class GameViewController: UIViewController {
  // MARK: - Variables

  var gameState: GameState = .stop {
    didSet {
      switch gameState {
        case .play:
          playGame()
        case .stop:
          stopGame()
      }
    }
  }

  var gameImages: [UIImage] = []
  var gameTimer: Timer?
  var gameLevel = 0
  var gameScore = 0

  // MARK: - Outlets

  @IBOutlet weak var gameStateButton: UIButton!

  @IBOutlet weak var gameScoreLabel: UILabel!

  @IBOutlet var gameImageView: [UIImageView]!

  @IBOutlet var gameImageButton: [UIButton]!

  @IBOutlet var gameImageLoader: [UIActivityIndicatorView]!

  // MARK: - View Controller Life Cycle

  override func viewDidLoad() {
    precondition(!UnsplashAPI.accessToken.isEmpty, "Please provide a valid Unsplash access token!")

    title = "Find or Lose"
    gameScoreLabel.text = "Score: \(gameScore)"
  }

  // MARK: - Game Actions

  @IBAction func playOrStopAction(sender: UIButton) {
    gameState = gameState == .play ? .stop : .play
  }

  @IBAction func imageButtonAction(sender: UIButton) {
    let selectedImages = gameImages.filter { $0 == gameImages[sender.tag] }
    
    if selectedImages.count == 1 {
      playGame()
    } else {
      gameState = .stop
    }
  }

  // MARK: - Game Functions

  func playGame() {
    gameTimer?.invalidate()

    gameStateButton.setTitle("Stop", for: .normal)

    gameLevel += 1
    title = "Level: \(gameLevel)"

    gameScoreLabel.text = "Score: \(gameScore)"
    gameScore += 200

    resetImages()
    startLoaders()

    UnsplashAPI.randomImage { [unowned self] randomImageResponse in
      guard let randomImageResponse = randomImageResponse else {
        DispatchQueue.main.async {
          self.gameState = .stop
        }

        return
      }

      ImageDownloader.download(url: randomImageResponse.urls.regular) { [unowned self] image in
        guard let image = image else { return }

        self.gameImages.append(image)

        UnsplashAPI.randomImage { [unowned self] randomImageResponse in
          guard let randomImageResponse = randomImageResponse else {
            DispatchQueue.main.async {
              self.gameState = .stop
            }

            return
          }

          ImageDownloader.download(url: randomImageResponse.urls.regular) { [unowned self] image in
            guard let image = image else { return }

            self.gameImages.append(contentsOf: [image, image, image])
            self.gameImages.shuffle()

            DispatchQueue.main.async {
              self.gameScoreLabel.text = "Score: \(self.gameScore)"

              self.gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
                DispatchQueue.main.async {
                  self.gameScoreLabel.text = "Score: \(self.gameScore)"
                }
                self.gameScore -= 10

                if self.gameScore <= 0 {
                  self.gameScore = 0
                  
                  timer.invalidate()
                }
              }

              self.stopLoaders()
              self.setImages()
            }
          }
        }
      }
    }
  }

  func stopGame() {
    gameTimer?.invalidate()

    gameStateButton.setTitle("Play", for: .normal)

    title = "Find or Lose"

    gameLevel = 0

    gameScore = 0
    gameScoreLabel.text = "Score: \(gameScore)"

    stopLoaders()
    resetImages()
  }

  // MARK: - UI Functions

  func setImages() {
    if gameImages.count == 4 {
      for (index, gameImage) in gameImages.enumerated() {
        gameImageView[index].image = gameImage
      }
    }
  }

  func resetImages() {
    gameImages = []

    gameImageView.forEach { $0.image = nil }
  }

  func startLoaders() {
    gameImageLoader.forEach { $0.startAnimating() }
  }

  func stopLoaders() {
    gameImageLoader.forEach { $0.stopAnimating() }
  }
}
