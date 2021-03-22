//
//  EpisodeOfCharacterTableViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/03/2021.
//
import UIKit

class EpisodeOfCharacterTableViewController: UITableViewController {
    var episodesOfCharacter = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodesOfCharacter.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = episodesOfCharacter[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black
        return cell
    }
}
