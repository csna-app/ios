//
//  Controller.swift
//  CSNA
//
//  Created by Wilhelm Thieme on 06/11/2020.
//

import SpriteKit

class Controller: UIViewController, SettingsDelegate, SceneTransactionDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private let statusBarView = UIView()
    private let navBarView = UIView()
    private let titleLabel = UILabel()
    private let pauseButton = UIButton()
    private let moreButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView()
    private let mainView = SKView()
    private let scene = Scene()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.backgroundColor = UIColor.accentColor
        view.addSubview(statusBarView)
        statusBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        statusBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        statusBarView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        statusBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        navBarView.backgroundColor = UIColor.accentColor
        view.addSubview(navBarView)
        navBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        navBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        navBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        navBarView.heightAnchor.constraint(equalToConstant: 55).activate()
        
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.tintColor = UIColor.white
        pauseButton.addTarget(self, action: #selector(pauseButtonPressed), for: .touchUpInside)
        pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        navBarView.addSubview(pauseButton)
        pauseButton.topAnchor.constraint(equalTo: navBarView.topAnchor).activate()
        pauseButton.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor).activate()
        pauseButton.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor).activate()
        pauseButton.heightAnchor.constraint(equalTo: pauseButton.widthAnchor).activate()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.white
        titleLabel.text = "00:00"
        titleLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.labelFontSize*2, weight: .bold)
        navBarView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: navBarView.topAnchor).activate()
        titleLabel.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor).activate()
        titleLabel.centerXAnchor.constraint(equalTo: navBarView.centerXAnchor).activate()
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.tintColor = UIColor.white
        moreButton.addTarget(self, action: #selector(moreButtonPressed), for: .touchUpInside)
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        navBarView.addSubview(moreButton)
        moreButton.topAnchor.constraint(equalTo: navBarView.topAnchor).activate()
        moreButton.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor).activate()
        moreButton.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor).activate()
        moreButton.heightAnchor.constraint(equalTo: moreButton.widthAnchor).activate()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor.white
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.alpha = 0
        navBarView.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: navBarView.topAnchor).activate()
        activityIndicator.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor).activate()
        activityIndicator.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor).activate()
        activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor).activate()
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        mainView.topAnchor.constraint(equalTo: navBarView.bottomAnchor).activate()
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        
        scene.transactionDelegate = self
        mainView.presentScene(scene)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scene.size = mainView.frame.size
        scene.reloadActors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
        NotificationCenter.default.addObserver(self, selector: #selector(stopListening), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startListening), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        scene.traitCollectionsDidChange(to: traitCollection)
    }
    
    @objc private func startListening() {
        NotificationCenter.default.addObserver(self, selector: #selector(tickerDidTick), name: Service.tickerDidTickNotification, object: nil)
        tickerDidTick()
    }
    
    @objc private func stopListening() {
        NotificationCenter.default.removeObserver(self, name: Service.tickerDidTickNotification, object: nil)
        Service.isPaused = true
        pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    @objc private func tickerDidTick() {
        titleLabel.text = formattedTime(Service.ticks)
    }
    
    
    @objc private func moreButtonPressed() {
        let settings = Settings()
        settings.delegate = self
        settings.popoverPresentationController?.sourceView = moreButton
        present(settings, animated: true, completion: nil)
    }
    
    @objc private func pauseButtonPressed() {
        Service.isPaused = !Service.isPaused
        pauseButton.setImage(UIImage(systemName: Service.isPaused ? "play.fill" : "pause.fill"), for: .normal)
    }
    
    
    func settings(didPressReset settings: Settings) {
        Service.isPaused = true
        pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        Service.reset()
        scene.reloadActors()
        tickerDidTick()
        dismiss(animated: true, completion: nil)
    }
    
    func settings(_ settings: Settings, didPressExportWith options: ExportType) {
        startLoading()
        Service.export(options) { [self] result in
            switch result {
            case .success(let url):
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                settings.push(controller: activity, animated: true)
            case .failure(let error):
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: localizedString("ok"), style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
            stopLoading()
        }
    }
    
    func settings(didEditSettings settings: Settings) {
        scene.reloadActors()
    }
    
    func scene(_ scene: Scene, didChange groups: [[Actor]]) {
        Service.addTransaction(groups)
    }
    
    
    private func startLoading() {
        activityIndicator.startAnimating()
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) { [self] in
                moreButton.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) { [self] in
                activityIndicator.alpha = 1
            }
        }
    }
    
    private func stopLoading() {

        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) { [self] in
                activityIndicator.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) { [self] in
                moreButton.alpha = 1
            }
        } completion: { [self] _ in
            activityIndicator.stopAnimating()
        }
        
    }

}

