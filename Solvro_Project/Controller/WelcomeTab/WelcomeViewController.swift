//
//  WelcomeViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 29/10/2020.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var instructionHowToUseLabel: UILabel!
    // View that pop ups only ones at the start
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionHowToUseLabel.text = (NSLocalizedString("WelcomeText", comment: ""))
    }
}
