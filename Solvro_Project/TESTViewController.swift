//
//  TESTViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 23/10/2020.
//

import UIKit

class TESTViewController: UIViewController {

    @IBOutlet weak var testTextLabel: UILabel!
    var testValue = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        TestTextLabel.text = testValue
        // Do any additional setup after loading the view.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
