//
//  PongScene.swift
//  MyFirstGame
//

import SpriteKit

/// SpriteKit scene: court, physics, scoring, AI, match rules (Phase 5), and touch routing by `PongGameMode`.
final class PongScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Configuration

    private let gameMode: PongGameMode

    /// Exponential smoothing for AI toward the ball (higher = snappier).
    private let aiTrackingLambda: CGFloat = 9

    private var lastUpdateTime: TimeInterval = 0

    /// Blocks goal contacts while the ball is being reset or the match is not in rally.
    private var isBallResetting = false

    private var phase: PongMatchPhase = .rally

    private var leftScore = 0
    private var rightScore = 0

    private var gameOverRoot: SKNode?

    /// Shown only when `PongRules.requireTapToServeAfterPoint` is true.
    private var serveHintLabel: SKLabelNode?

    // MARK: - Nodes

    private lazy var leftPaddle: SKSpriteNode = PongPaddle.makeSprite()
    private lazy var rightPaddle: SKSpriteNode = PongPaddle.makeSprite()

    private lazy var ball: SKShapeNode = PongBall.makeNode()

    private lazy var topWall: SKSpriteNode = PongCourtElements.makeTopWall()
    private lazy var bottomWall: SKSpriteNode = PongCourtElements.makeBottomWall()
    private lazy var centerLine: SKShapeNode = PongCourtElements.makeCenterLine()

    private lazy var leftGoal: SKSpriteNode = PongGoalZones.makeLeftGoal()
    private lazy var rightGoal: SKSpriteNode = PongGoalZones.makeRightGoal()

    private lazy var leftScoreLabel: SKLabelNode = makeScoreLabel(horizontalAlignment: .left)
    private lazy var rightScoreLabel: SKLabelNode = makeScoreLabel(horizontalAlignment: .right)

    // MARK: - Init

    init(gameMode: PongGameMode = .twoPlayers) {
        self.gameMode = gameMode
        super.init(size: Playfield.logicalSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        configureScene()
        setupPhysicsWorld()
        addCourtNodesIfNeeded()
        layoutPaddles()
        attachAllPhysics()
        configureScoreLabels()
        phase = .rally
        launchBall()
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

        guard phase == .rally, gameMode == .onePlayerVsAI else { return }
        updateAIPaddle(deltaTime: dt)
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

    /// Builds node tree once: walls, goals, line, ball, paddles, HUD.
    private func addCourtNodesIfNeeded() {
        guard bottomWall.parent == nil else { return }

        bottomWall.zPosition = 0
        topWall.zPosition = 0
        centerLine.zPosition = 0.5
        leftGoal.zPosition = 0
        rightGoal.zPosition = 0

        addChild(bottomWall)
        addChild(topWall)
        addChild(centerLine)
        addChild(leftGoal)
        addChild(rightGoal)

        if ball.parent == nil {
            ball.zPosition = 2
            ball.position = PongBall.restPosition
            addChild(ball)
        }

        if leftPaddle.parent == nil {
            leftPaddle.zPosition = 1
            rightPaddle.zPosition = 1
            addChild(leftPaddle)
            addChild(rightPaddle)
        }

        if leftScoreLabel.parent == nil {
            leftScoreLabel.zPosition = 10
            rightScoreLabel.zPosition = 10
            addChild(leftScoreLabel)
            addChild(rightScoreLabel)
        }
    }

    private func attachAllPhysics() {
        PongPaddle.attachPhysics(to: leftPaddle)
        PongPaddle.attachPhysics(to: rightPaddle)
        PongBall.attachPhysics(to: ball)
    }

    // MARK: - Score HUD

    private func makeScoreLabel(horizontalAlignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.fontSize = 36
        label.fontColor = SKColor(white: 1, alpha: 0.85)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = horizontalAlignment
        label.text = "0"
        return label
    }

    private func configureScoreLabels() {
        let inset: CGFloat = 48
        let topY = Playfield.halfHeight - 56
        leftScoreLabel.position = CGPoint(x: -Playfield.halfWidth + inset, y: topY)
        rightScoreLabel.position = CGPoint(x: Playfield.halfWidth - inset, y: topY)
        refreshScoreLabels()
    }

    private func refreshScoreLabels() {
        leftScoreLabel.text = "\(leftScore)"
        rightScoreLabel.text = "\(rightScore)"
    }

    // MARK: - Ball & serve

    /// Puts the ball in play from center with a random direction (used after points and on match restart).
    private func launchBall() {
        hideServeHint()
        removeAction(forKey: "postPointServe")

        ball.position = PongBall.restPosition
        ball.physicsBody?.velocity = .zero
        let angle = CGFloat.random(in: -CGFloat.pi / 5 ... CGFloat.pi / 5)
        let direction: CGFloat = Bool.random() ? 1 : -1
        let vx = cos(angle) * direction * PongBall.launchSpeed
        let vy = sin(angle) * PongBall.launchSpeed
        ball.physicsBody?.velocity = CGVector(dx: vx, dy: vy)

        phase = .rally
        isBallResetting = false
    }

    /// After a point (not match end): delay auto-serve or wait for tap per `PongRules`.
    private func schedulePointReset() {
        isBallResetting = true
        ball.physicsBody?.velocity = .zero
        ball.position = PongBall.restPosition

        if PongRules.requireTapToServeAfterPoint {
            phase = .awaitingServe
            showServeHint()
        } else {
            let wait = SKAction.wait(forDuration: PongRules.postPointResetDelay)
            let fire = SKAction.run { [weak self] in
                self?.launchBall()
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

    // MARK: - Game over (Phase 5)

    private func enterGameOver(winner: PongSide) {
        removeAction(forKey: "postPointServe")
        phase = .gameOver(winner: winner)
        isBallResetting = true
        hideServeHint()

        ball.physicsBody?.velocity = .zero
        ball.position = PongBall.restPosition

        gameOverRoot?.removeFromParent()

        let root = SKNode()
        root.zPosition = 25
        root.name = "gameOver"

        let title = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        title.fontSize = 40
        title.fontColor = SKColor(white: 1, alpha: 1)
        title.text = "GAME OVER"
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = .zero

        let subtitle = SKLabelNode(fontNamed: "HelveticaNeue")
        subtitle.fontSize = 28
        subtitle.fontColor = SKColor(white: 1, alpha: 0.9)
        subtitle.text = winnerMessage(for: winner)
        subtitle.verticalAlignmentMode = .center
        subtitle.horizontalAlignmentMode = .center
        subtitle.position = CGPoint(x: 0, y: -52)

        let hint = SKLabelNode(fontNamed: "HelveticaNeue")
        hint.fontSize = 20
        hint.fontColor = SKColor(white: 1, alpha: 0.65)
        hint.text = "Tap to play again"
        hint.verticalAlignmentMode = .center
        hint.horizontalAlignmentMode = .center
        hint.position = CGPoint(x: 0, y: -100)

        root.addChild(title)
        root.addChild(subtitle)
        root.addChild(hint)
        addChild(root)
        gameOverRoot = root
    }

    private func winnerMessage(for winner: PongSide) -> String {
        switch (gameMode, winner) {
        case (.onePlayerVsAI, .left):
            return "AI wins"
        case (.onePlayerVsAI, .right):
            return "You win"
        case (.twoPlayers, .left):
            return "Left player wins"
        case (.twoPlayers, .right):
            return "Right player wins"
        }
    }

    /// Full reset: scores, HUD, removes overlay, serves a new first ball.
    private func restartMatch() {
        gameOverRoot?.removeFromParent()
        gameOverRoot = nil

        leftScore = 0
        rightScore = 0
        refreshScoreLabels()

        phase = .rally
        launchBall()
    }

    // MARK: - Layout

    private func layoutPaddles() {
        let halfW = Playfield.halfWidth
        let halfPaddleH = PongPaddle.size.height / 2

        let minY = Playfield.innerBottomY + halfPaddleH + PongPaddle.marginFromPlayfield
        let maxY = Playfield.innerTopY - halfPaddleH - PongPaddle.marginFromPlayfield

        let leftX = -halfW + PongPaddle.marginFromPlayfield + PongPaddle.size.width / 2
        let rightX = halfW - PongPaddle.marginFromPlayfield - PongPaddle.size.width / 2

        func clampedY(for node: SKSpriteNode, defaultY: CGFloat) -> CGFloat {
            let y = node.parent == nil ? defaultY : node.position.y
            return min(max(y, minY), maxY)
        }

        leftPaddle.position = CGPoint(x: leftX, y: clampedY(for: leftPaddle, defaultY: 0))
        rightPaddle.position = CGPoint(x: rightX, y: clampedY(for: rightPaddle, defaultY: 0))
    }

    private func paddleClampRange() -> (minY: CGFloat, maxY: CGFloat) {
        let halfPaddleH = PongPaddle.size.height / 2
        let minY = Playfield.innerBottomY + halfPaddleH + PongPaddle.marginFromPlayfield
        let maxY = Playfield.innerTopY - halfPaddleH - PongPaddle.marginFromPlayfield
        return (minY, maxY)
    }

    // MARK: - AI

    private func updateAIPaddle(deltaTime: CGFloat) {
        let (minY, maxY) = paddleClampRange()
        let targetY = ball.position.y
        let currentY = leftPaddle.position.y
        let t = 1 - exp(-Double(aiTrackingLambda) * Double(deltaTime))
        var y = currentY + (targetY - currentY) * CGFloat(t)
        y = min(max(y, minY), maxY)
        leftPaddle.position.y = y
    }

    // MARK: - Touch input

    private func updatePaddle(for touch: UITouch) {
        let location = touch.location(in: self)
        let (minY, maxY) = paddleClampRange()
        let clampedY = min(max(location.y, minY), maxY)

        switch gameMode {
        case .onePlayerVsAI:
            rightPaddle.position.y = clampedY
        case .twoPlayers:
            if location.x < 0 {
                leftPaddle.position.y = clampedY
            } else {
                rightPaddle.position.y = clampedY
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .gameOver = phase {
            restartMatch()
            return
        }

        if phase == .awaitingServe, PongRules.requireTapToServeAfterPoint {
            launchBall()
            return
        }

        guard phase == .rally else { return }
        touches.forEach { updatePaddle(for: $0) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard phase == .rally else { return }
        touches.forEach { updatePaddle(for: $0) }
    }

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        guard phase == .rally, !isBallResetting else { return }

        let bodies = [contact.bodyA, contact.bodyB]
        guard let ballBody = bodies.first(where: { $0.categoryBitMask == PhysicsCategory.ball }),
              ballBody.node === ball else { return }

        guard let other = bodies.first(where: { $0 !== ballBody }),
              other.categoryBitMask == PhysicsCategory.goal else { return }

        if other.node?.name == "goalLeft" {
            rightScore += 1
        } else if other.node?.name == "goalRight" {
            leftScore += 1
        } else {
            return
        }

        refreshScoreLabels()

        let win = PongRules.pointsToWin
        if leftScore >= win {
            enterGameOver(winner: .left)
        } else if rightScore >= win {
            enterGameOver(winner: .right)
        } else {
            schedulePointReset()
        }
    }
}
