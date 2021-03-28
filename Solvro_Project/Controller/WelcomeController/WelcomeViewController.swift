//
//  WelcomeViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 29/10/2020.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var instructionLabel: UILabel!
    // View that pop ups only ones at the start
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionLabel.text = (NSLocalizedString("WelcomeText", comment: ""))
    }
}
