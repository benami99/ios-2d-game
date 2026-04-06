//
//  PongScene.swift
//  MyFirstGame
//

import SpriteKit

/// Bundled one-shots (sources live under `MyFirstGame/Sounds/`; copied to the app bundle root).
private enum PongSoundFile {
    static let paddleHit = "paddle_hit.wav"
    static let score = "score.wav"
}

/// SpriteKit scene: court, physics, match rules, and touch routing. Phase 6: flow state & HUD live in `PongGameBridge` + SwiftUI.
/// Court is **rotated**: paddles on **top** and **bottom**, walls on **left** and **right**. `leftScore` = top player, `rightScore` = bottom player.
final class PongScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Configuration

    private let gameMode: PongGameMode

    weak var bridge: PongGameBridge?

    /// Exponential smoothing for AI toward the ball (higher = snappier).
    private let aiTrackingLambda: CGFloat = 9

    private var lastUpdateTime: TimeInterval = 0

    /// Avoid stacked paddle contacts playing multiple times in one hit.
    private var lastPaddleSoundAt: TimeInterval = 0
    private let paddleSoundCooldown: TimeInterval = 0.07

    /// Blocks goal contacts while the ball is being reset or the match is not in rally.
    private var isBallResetting = false

    private var phase: PongMatchPhase = .rally

    /// Top player score (HUD left).
    private var leftScore = 0
    /// Bottom player score (HUD right).
    private var rightScore = 0

    /// Paddle hits during the current rally; drives per-volley speed ramp. Resets on each serve.
    private var rallyHitCount = 0

    /// Shown only when `PongRules.requireTapToServeAfterPoint` is true.
    private var serveHintLabel: SKLabelNode?

    // MARK: - Nodes

    private lazy var topPaddle: SKSpriteNode = PongPaddle.makeSprite()
    private lazy var bottomPaddle: SKSpriteNode = PongPaddle.makeSprite()

    private lazy var ball: SKShapeNode = PongBall.makeNode()

    private lazy var leftWall: SKSpriteNode = PongCourtElements.makeLeftWall()
    private lazy var rightWall: SKSpriteNode = PongCourtElements.makeRightWall()
    private lazy var centerLine: SKShapeNode = PongCourtElements.makeCenterLine()

    private lazy var topGoal: SKSpriteNode = PongGoalZones.makeTopGoal()
    private lazy var bottomGoal: SKSpriteNode = PongGoalZones.makeBottomGoal()

    // MARK: - Init

    init(gameMode: PongGameMode = .twoPlayers, bridge: PongGameBridge?) {
        self.gameMode = gameMode
        self.bridge = bridge
        super.init(size: Playfield.logicalSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        bridge?.scene = self
        configureScene()
        setupPhysicsWorld()
        addCourtNodesIfNeeded()
        layoutPaddles()
        attachAllPhysics()
        syncScoresToBridge()
        phase = .rally
        if bridge?.flowState == .menu || bridge?.flowState == .gameOver {
            isPaused = true
            ball.position = PongBall.restPosition
            ball.physicsBody?.velocity = .zero
            hideServeHint()
        } else {
            launchBall()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutPaddles()
    }

    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat
        if lastUpdateTime == 0 {
            dt = 1 / 60
        } else {
            dt = CGFloat(currentTime - lastUpdateTime)
        }
        lastUpdateTime = currentTime

        guard !isPaused else { return }
        if phase == .rally {
            nudgeBallStuckLoopsIfNeeded()
            enforceBallRallySpeed()
        }
        guard phase == .rally, gameMode == .onePlayerVsAI else { return }
        updateAIPaddle(deltaTime: dt)
    }

    private func nudgeBallStuckLoopsIfNeeded() {
        guard let v = ball.physicsBody?.velocity else { return }
        var next = v
        if let fixed = PongBallVelocitySanity.correctedVelocityIfVerticalLoop(velocity: next) {
            next = fixed
        }
        if let fixed = PongBallVelocitySanity.correctedVelocityIfHorizontalLoop(velocity: next) {
            next = fixed
        }
        ball.physicsBody?.velocity = next
    }

    /// Keeps magnitude near the rally target (score ramp + per-hit boost) so physics quirks don’t drain or inflate speed.
    private func enforceBallRallySpeed() {
        guard let body = ball.physicsBody else { return }
        let v = body.velocity
        let s = hypot(v.dx, v.dy)
        guard s > 8 else { return }
        let targetSpeed = PongRules.rallySpeed(totalPointsScored: leftScore + rightScore, rallyHits: rallyHitCount)
        let scale = targetSpeed / s
        guard abs(scale - 1.0) > 0.006 else { return }
        body.velocity = CGVector(dx: v.dx * scale, dy: v.dy * scale)
    }

    // MARK: - Scene & world

    private func configureScene() {
        size = Playfield.logicalSize
        scaleMode = .aspectFit
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.12, green: 0.28, blue: 0.55, alpha: 1)
    }

    private func setupPhysicsWorld() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    private func addCourtNodesIfNeeded() {
        guard leftWall.parent == nil else { return }

        leftWall.zPosition = 0
        rightWall.zPosition = 0
        centerLine.zPosition = 0.5
        topGoal.zPosition = 0
        bottomGoal.zPosition = 0

        addChild(leftWall)
        addChild(rightWall)
        addChild(centerLine)
        addChild(topGoal)
        addChild(bottomGoal)

        if ball.parent == nil {
            ball.zPosition = 2
            ball.position = PongBall.restPosition
            addChild(ball)
        }

        if topPaddle.parent == nil {
            topPaddle.zPosition = 1
            bottomPaddle.zPosition = 1
            addChild(topPaddle)
            addChild(bottomPaddle)
        }
    }

    private func attachAllPhysics() {
        PongPaddle.attachPhysics(to: topPaddle)
        PongPaddle.attachPhysics(to: bottomPaddle)
        PongBall.attachPhysics(to: ball)
    }

    private func syncScoresToBridge() {
        bridge?.updateScores(left: leftScore, right: rightScore)
    }

    func resetMatchForMenu() {
        removeAction(forKey: "postPointServe")
        leftScore = 0
        rightScore = 0
        syncScoresToBridge()
        phase = .rally
        isBallResetting = true
        ball.position = PongBall.restPosition
        ball.physicsBody?.velocity = .zero
        resetPaddlesToCenter()
        hideServeHint()
        isBallResetting = false
    }

    func launchBallAfterMenu() {
        launchBall()
    }

    // MARK: - Ball & serve

    /// - Parameter totalPointsForSpeed: Pass combined score when scheduling a delayed serve so speed matches the point just scored (avoids stale reads).
    private func launchBall(totalPointsForSpeed: Int? = nil) {
        hideServeHint()
        removeAction(forKey: "postPointServe")

        ball.position = PongBall.restPosition
        ball.physicsBody?.velocity = .zero
        rallyHitCount = 0
        let combined = totalPointsForSpeed ?? (leftScore + rightScore)
        let speed = PongRules.launchSpeed(totalPointsScored: combined)
        let angle = CGFloat.random(in: -CGFloat.pi / 5 ... CGFloat.pi / 5)
        let direction: CGFloat = Bool.random() ? 1 : -1
        let vx = sin(angle) * direction * speed
        let vy = cos(angle) * direction * speed

        ball.physicsBody?.velocity = CGVector(dx: vx, dy: vy)

        phase = .rally
        isBallResetting = false
    }

    private func schedulePointReset() {
        isBallResetting = true
        ball.physicsBody?.velocity = .zero
        ball.position = PongBall.restPosition
        resetPaddlesToCenter()

        if PongRules.requireTapToServeAfterPoint {
            phase = .awaitingServe
            showServeHint()
        } else {
            let combinedPoints = leftScore + rightScore
            let wait = SKAction.wait(forDuration: PongRules.postPointResetDelay)
            let fire = SKAction.run { [weak self] in
                self?.launchBall(totalPointsForSpeed: combinedPoints)
            }
            run(SKAction.sequence([wait, fire]), withKey: "postPointServe")
        }
    }

    private func showServeHint() {
        serveHintLabel?.removeFromParent()
        let label = SKLabelNode(fontNamed: "HelveticaNeue")
        label.fontSize = 24
        label.text = "Tap to serve"
        label.fontColor = SKColor(white: 1, alpha: 0.75)
        label.position = CGPoint(x: 0, y: -Playfield.halfHeight + 120)
        label.zPosition = 15
        addChild(label)
        serveHintLabel = label
    }

    private func hideServeHint() {
        serveHintLabel?.removeFromParent()
        serveHintLabel = nil
    }

    // MARK: - Game over (match end)

    private func enterGameOver(winner: PongSide) {
        removeAction(forKey: "postPointServe")
        phase = .gameOver(winner: winner)
        isBallResetting = true
        hideServeHint()

        ball.physicsBody?.velocity = .zero
        ball.position = PongBall.restPosition

        isPaused = true
        bridge?.notifyMatchEnded(winner: winner)
        syncScoresToBridge()
    }

    func restartMatchFromHUD() {
        removeAction(forKey: "postPointServe")

        leftScore = 0
        rightScore = 0
        syncScoresToBridge()

        phase = .rally
        resetPaddlesToCenter()
        launchBall()
    }

    // MARK: - Layout

    private func layoutPaddles() {
        let halfPaddleW = PongPaddle.size.width / 2
        let minX = Playfield.innerLeftX + halfPaddleW + PongPaddle.marginFromPlayfield
        let maxX = Playfield.innerRightX - halfPaddleW - PongPaddle.marginFromPlayfield

        let topY = PongPaddle.topPaddleCenterY
        let bottomY = PongPaddle.bottomPaddleCenterY

        func clampedX(for node: SKSpriteNode, defaultX: CGFloat) -> CGFloat {
            let x = node.parent == nil ? defaultX : node.position.x
            return min(max(x, minX), maxX)
        }

        topPaddle.position = CGPoint(x: clampedX(for: topPaddle, defaultX: 0), y: topY)
        bottomPaddle.position = CGPoint(x: clampedX(for: bottomPaddle, defaultX: 0), y: bottomY)
    }

    private func resetPaddlesToCenter() {
        topPaddle.position.x = 0
        bottomPaddle.position.x = 0
        layoutPaddles()
    }

    private func paddleClampRange() -> (minX: CGFloat, maxX: CGFloat) {
        let halfPaddleW = PongPaddle.size.width / 2
        let minX = Playfield.innerLeftX + halfPaddleW + PongPaddle.marginFromPlayfield
        let maxX = Playfield.innerRightX - halfPaddleW - PongPaddle.marginFromPlayfield
        return (minX, maxX)
    }

    // MARK: - AI (top paddle)

    private func updateAIPaddle(deltaTime: CGFloat) {
        let (minX, maxX) = paddleClampRange()
        let targetX = ball.position.x
        let currentX = topPaddle.position.x
        let t = 1 - exp(-Double(aiTrackingLambda) * Double(deltaTime))
        var x = currentX + (targetX - currentX) * CGFloat(t)
        x = min(max(x, minX), maxX)
        topPaddle.position.x = x
    }

    // MARK: - Touch input

    private func updatePaddle(for touch: UITouch) {
        let location = touch.location(in: self)
        let (minX, maxX) = paddleClampRange()
        let clampedX = min(max(location.x, minX), maxX)

        switch gameMode {
        case .onePlayerVsAI:
            // Only the bottom paddle is human-controlled; ignore touches on the AI (top) half.
            guard location.y < 0 else { return }
            bottomPaddle.position.x = clampedX
        case .twoPlayers:
            if location.y > 0 {
                topPaddle.position.x = clampedX
            } else {
                bottomPaddle.position.x = clampedX
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isPaused else { return }

        if phase == .awaitingServe, PongRules.requireTapToServeAfterPoint {
            launchBall()
            return
        }

        guard phase == .rally else { return }
        touches.forEach { updatePaddle(for: $0) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isPaused else { return }
        guard phase == .rally else { return }
        touches.forEach { updatePaddle(for: $0) }
    }

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        guard phase == .rally, !isBallResetting else { return }

        let bodies = [contact.bodyA, contact.bodyB]
        guard let ballBody = bodies.first(where: { $0.categoryBitMask == PhysicsCategory.ball }),
              ballBody.node === ball else { return }

        guard let other = bodies.first(where: { $0 !== ballBody }) else { return }

        if other.categoryBitMask == PhysicsCategory.paddle {
            applyPaddleBounce(paddleBody: other)
            playPaddleHitSound()
            return
        }

        guard other.categoryBitMask == PhysicsCategory.goal else { return }

        if other.node?.name == "goalTop" {
            rightScore += 1
        } else if other.node?.name == "goalBottom" {
            leftScore += 1
        } else {
            return
        }

        playScoreSound()
        syncScoresToBridge()

        let win = PongRules.pointsToWin
        if leftScore >= win {
            enterGameOver(winner: .left)
        } else if rightScore >= win {
            enterGameOver(winner: .right)
        } else {
            schedulePointReset()
        }
    }

    private func playSoundNamed(_ resource: String) {
        run(SKAction.playSoundFileNamed(resource, waitForCompletion: false))
    }

    private func playPaddleHitSound() {
        let t = ProcessInfo.processInfo.systemUptime
        guard t - lastPaddleSoundAt >= paddleSoundCooldown else { return }
        lastPaddleSoundAt = t
        playSoundNamed(PongSoundFile.paddleHit)
    }

    private func playScoreSound() {
        playSoundNamed(PongSoundFile.score)
    }

    /// Hit away from paddle center along x adds vx; each volley raises speed via `rallyHitCount`.
    private func applyPaddleBounce(paddleBody: SKPhysicsBody) {
        guard let paddleNode = paddleBody.node as? SKSpriteNode else { return }
        rallyHitCount += 1
        let speed = PongRules.rallySpeed(totalPointsScored: leftScore + rightScore, rallyHits: rallyHitCount)
        let halfW = PongPaddle.size.width / 2
        let offset = (ball.position.x - paddleNode.position.x) / halfW
        let clamped = max(-1, min(1, offset))
        let angle = clamped * PongRules.paddleMaxBounceAngle

        if paddleNode === topPaddle {
            ball.physicsBody?.velocity = CGVector(dx: sin(angle) * speed, dy: -cos(angle) * speed)
        } else if paddleNode === bottomPaddle {
            ball.physicsBody?.velocity = CGVector(dx: sin(angle) * speed, dy: cos(angle) * speed)
        }
    }
}
