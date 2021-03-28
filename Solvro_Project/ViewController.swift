//
//  ViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/10/2020.
//

import UIKit
import rick_morty_swift_api

class ViewController: UIViewController {
let rickAndMortyClient1 = Client()
    override func viewDidLoad() {
        super.viewDidLoad()
        rickAndMortyClient1.character().getAllCharacters {
                switch $0 {
                case .success(let characters):
                    characters.forEach { print($0.name) }
                case.failure(let error):
                    print(error)
                    }
                }
    }
}
