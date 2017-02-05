//
//  ViewController.swift
//  Crazyflie client
//
//  Created by Martin Eberl on 23.01.17.
//  Copyright © 2017 Bitcraze. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    private var leftJoystick: BCJoystick?
    private var rightJoystick: BCJoystick?
    
    weak var viewModel: ViewModel?
    private var settingsViewController: SettingsViewController?
    
    @IBOutlet weak var unlockLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var connectProgress: UIProgressView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil {
            viewModel = ViewModel()
            viewModel?.delegate = self
        }
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.loadSettings()
        updateUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - IBActions
    
    @IBAction func connectClicked(_ sender: Any) {
        viewModel?.connect()
    }
    
    @IBAction func settingsClicked(_ sender: Any) {
        performSegue(withIdentifier: "settings", sender: nil)
    }
    
    //MARK: - Private
    
    private func setupUI() {
        guard let viewModel = viewModel else { return }
        connectProgress.progress = 0
        
        connectButton.layer.borderColor = connectButton.tintColor.cgColor
        settingsButton.layer.borderColor = settingsButton.tintColor.cgColor
        
        //Init joysticks
        let frame = UIScreen.main.bounds
        
        let leftViewModel = BCJoystickViewModel()
        let leftJoystick = BCJoystick(frame: frame, viewModel: leftViewModel)
        leftViewModel.delegate = leftJoystick
        leftViewModel.add(observer: viewModel)
        leftView.addSubview(leftJoystick)
        self.leftJoystick = leftJoystick
        viewModel.leftJoystickProvider = leftViewModel
        
        let rightViewModel = BCJoystickViewModel(deadbandX: 0.1, vLabelLeft: true)
        let rightJoystick = BCJoystick(frame: frame, viewModel: rightViewModel)
        rightViewModel.delegate = rightJoystick
        rightViewModel.add(observer: viewModel)
        rightView.addSubview(rightJoystick)
        self.rightJoystick = rightJoystick
        viewModel.rightJoystickProvider = rightViewModel
    }
    
    fileprivate func updateUI() {
        guard let viewModel = viewModel else {
            return
        }
        unlockLabel.isHidden = viewModel.bothThumbsOnJoystick
        
        leftJoystick?.hLabel.text = viewModel.leftJoystickHorizontalTitle
        leftJoystick?.vLabel.text = viewModel.leftJoystickVerticalTitle
        rightJoystick?.hLabel.text = viewModel.rightJoystickHorizontalTitle
        rightJoystick?.vLabel.text = viewModel.rightJoystickVerticalTitle
        
        connectProgress.setProgress(viewModel.progress, animated: true)
        connectButton.setTitle(viewModel.topButtonTitle, for: .normal)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            guard let viewController = segue.destination as? SettingsViewController else {
                return
            }
            
            viewController.viewModel = viewModel?.settingsViewModel
        }
    }

}

extension ViewController: ViewModelDelegate {
    func signalUpdate() {
        updateUI()
    }
}
/*
                    
                    - (void) updateSettings: (NSUserDefaults*) defaults
{
    controlMode = [defaults doubleForKey:@];
    NSLog(@"controlMode %d", controlMode);
    sensitivities = (NSMutableDictionary*)[defaults dictionaryForKey:@"sensitivities"];
    sensitivitySetting = [defaults stringForKey:@"sensitivitySettings"];
    
    NSDictionary *sensitivity = (NSDictionary*)[sensitivities valueForKey:sensitivitySetting];
    pitchRate = [(NSNumber*)[sensitivity valueForKey:@"pitchRate"] floatValue];
    yawRate = [(NSNumber*)[sensitivity valueForKey:@"yawRate"] floatValue];
    maxThrust = [(NSNumber*)[sensitivity valueForKey:@"maxThrust"] floatValue];
    
    if ([MotionLink new].canAccessMotion) {
        if (controlMode == 5) {
            [self startMotionUpdate];
        }
        else {
            [self stopMotionUpdate];
        }
        
            }
    else {
        
    }
    
    leftJoystick.deadbandX = 0;
    rightJoystick.deadbandX = 0;
    if ([leftJoystick.hLabel.text isEqualToString:@"Yaw"]) {
        leftJoystick.deadbandX = 0.1;
    } else {
        rightJoystick.deadbandX = 0.1;
    }
    
    leftJoystick.thrustControl = NO;
    rightJoystick.thrustControl = NO;
    if ([leftJoystick.vLabel.text isEqualToString:@"Thrust"]) {
        leftJoystick.thrustControl = YES;
    } else {
        rightJoystick.thrustControl = YES;
    }
    }



@end*/
