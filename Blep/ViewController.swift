//
//  ViewController.swift
//  Blep
//
//  Created by Jayden Garrick on 9/5/18.
//  Copyright © 2018 Jayden Garrick. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    // Locations
    var touchPoint: CGPoint?
    var bullets: [Bullet] = []
    var isReloading = false
    var angroSpeed: Double = 8
    var leftRight = false
    var currentAngro: UIImageView?
    var score = 0

    // UI
    let blepImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "xcaBlep")
        return imageView
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Score: 0"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    let reloadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Reloading..."
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        generateAngros()
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (_) in
            let bulletPresentationLayers: [CGRect] = self.bullets.compactMap { $0.view.layer.presentation()?.frame }
            guard let angroPresentationLayer = self.currentAngro?.layer.presentation()?.frame else { return }
            let blepLayer = self.blepImageView.frame
            
            for rect in bulletPresentationLayers {
                if rect.intersects(angroPresentationLayer) {
                    guard let index = bulletPresentationLayers.index(of: rect) else { return }
                    let bullet = self.bullets[index]
                    bullet.view.removeFromSuperview()
                    self.currentAngro?.removeFromSuperview()
                    self.score += 1
                    self.scoreLabel.text = "Score: \(self.score)"
                    self.angroSpeed -= 0.05
                }
            }
            
            if blepLayer.intersects(angroPresentationLayer) {
                self.score = 0
                self.scoreLabel.text = "Score: \(self.score)"
                self.view.backgroundColor = .red
                self.angroSpeed = 8
            }
        }
    }
    
    // MARK: - Setup
    func setupViews() {
        view.backgroundColor = .black
        // Adding subviews
        view.addSubview(blepImageView)
        view.addSubview(scoreLabel)
        view.addSubview(reloadingLabel)
        reloadingLabel.isHidden = true
        
        // Blep ImageView
        blepImageView.translatesAutoresizingMaskIntoConstraints = false
        blepImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        blepImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        blepImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        blepImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Score Label
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        scoreLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        
        // Reloading Label
        reloadingLabel.translatesAutoresizingMaskIntoConstraints = false
        reloadingLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        reloadingLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    // MARK: - Actions
    func shoot() {
        let bullet = createBullet()
        guard let touchPoint = touchPoint else { return }
        
        if isReloading == false {
            view.addSubview(bullet.view)
            UIView.animate(withDuration: 2, delay: 0, options: [.allowAnimatedContent, .preferredFramesPerSecond60], animations: {
                let startPoint = bullet.view.center
                let bulletPoint = lerp(start: startPoint, end: CGPoint(x: touchPoint.x, y: touchPoint.y), t: 3)
                bullet.view.frame = CGRect(x: bulletPoint.x, y: bulletPoint.y, width: 20, height: 20)
                self.reload()
                self.bullets.append(bullet)
            }) { (success) in
                if success {
                    guard let bulletIndex = self.bullets.index(of: bullet) else { return }
                    self.bullets.remove(at: bulletIndex)
                    bullet.view.removeFromSuperview()
                    
                    UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
                        bullet.view.backgroundColor = .black
                    }, completion: { (success) in
                        bullet.view.isHidden = true
                    })
                }
            }
        }
    }
    
    func generateAngros() {
        let angro = createAngroImageView()
        currentAngro = angro
        view.addSubview(angro)
        let randomY = randomNumberInRange(min: view.frame.minY, max: view.frame.maxY)
        let randomHeightAndWidth = randomNumberInRange(min: 10, max: 50)
        angro.frame = CGRect(x: leftRight ? view.frame.minX - 15 : view.frame.maxX - 15, y: randomY, width: randomHeightAndWidth, height: randomHeightAndWidth)
        
        UIView.animate(withDuration: angroSpeed, delay: 0, options: [.allowAnimatedContent, .preferredFramesPerSecond60], animations: {
            let startPoint = angro.center
            let endPoint = lerp(start: startPoint, end: self.view.center, t: 3)
            angro.frame = CGRect(x: endPoint.x, y: endPoint.y, width: randomHeightAndWidth, height: randomHeightAndWidth)
        }) { (success) in
            self.leftRight = !self.leftRight
            angro.removeFromSuperview()
            self.generateAngros()
        }
    }
    
    func reload() {
        self.isReloading = true
        reloadingLabel.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            self.isReloading = false
            self.reloadingLabel.isHidden = true
        }
    }
    
    // MARK: - Helpers
    func createBullet() -> Bullet {
        let bullet = UIView()
        bullet.backgroundColor = .white
        bullet.frame = CGRect(x: view.center.x, y: view.center.y, width: 20, height: 20)
        bullet.layer.cornerRadius = 20 / 2
        return Bullet(view: bullet)
    }
    
    func createAngroImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "xcaAngro")
        return imageView
    }
    
    func randomNumberInRange(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(max - min + 1))) + min
    }

}

// MARK: - Touches
extension ViewController {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!.location(in: view)
        touchPoint = touch
        shoot()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!.location(in: view)
        touchPoint = touch
        shoot()
        print(touch)
    }
}

