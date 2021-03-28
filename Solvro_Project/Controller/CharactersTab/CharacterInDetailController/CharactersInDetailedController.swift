//
//  DetailViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/10/2020.
//

import UIKit
import rick_morty_swift_api
import Kingfisher
class DetailViewController: UIViewController {
    @IBOutlet weak var currentStatusImage: UIImageView!
    @IBOutlet weak var imageForCurrentCharacter: UIImageView!
    @IBOutlet weak var dataOfCreationLabel: UILabel!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameOfCharacterInDetail: UILabel!
    @IBOutlet weak var getEpisodesButton: UIButton!
    let rickAndMortyClient = Client()
    var characterName = ""
    var indexOfCurrentCharacter = 0
    var currentCharacterImage = ""
    var dataOfCreation = ""
    var genderOfCurrentCharacter = ""
    var statusOfCurrentCharacter = ""
    var characterEpisodesArray = [String]()
    var isLiked = false
    override func viewDidLoad() {
        super.viewDidLoad()
        getEpisodesButton.setTitleColor(UIColor.white, for: .normal)
        getEpisodesButton.layer.cornerRadius = 8
        imageForCurrentCharacter.layer.masksToBounds = true
        imageForCurrentCharacter.layer.borderWidth = 5
        imageForCurrentCharacter.layer.cornerRadius = imageForCurrentCharacter.frame.size.height/2
        if self.isLiked == true {
            imageForCurrentCharacter.layer.borderColor = UIColor(named: "likeColour" )?.cgColor
        } else {
            imageForCurrentCharacter.layer.borderColor = UIColor(named: "dislikeColour" )?.cgColor
        }
        self.nameOfCharacterInDetail.text = self.characterName
        self.genderLabel.text = self.genderOfCurrentCharacter
        self.currentStatusLabel.text = self.statusOfCurrentCharacter
        self.dataOfCreationLabel.text = self.dataOfCreation
        if currentCharacterImage != "" {
            let url = URL(string: currentCharacterImage)
            self.imageForCurrentCharacter.kf.setImage(with: url)
        } else {
            self.imageForCurrentCharacter.image = UIImage(systemName: "person")
        }
        switch statusOfCurrentCharacter {
        case "Alive":
            currentStatusImage.image = #imageLiteral(resourceName: "green_dot")
        case "Dead":
            currentStatusImage.image = #imageLiteral(resourceName: "red_dot")
        case "unknown":
            currentStatusImage.image = #imageLiteral(resourceName: "grey_dot")
        default:
            break
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EpisodeOfCharacterTableViewController {
            let viewController = segue.destination as? EpisodeOfCharacterTableViewController
            viewController?.episodesOfCharacterArray = characterEpisodesArray
        }
    }
}
