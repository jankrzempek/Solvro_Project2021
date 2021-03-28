//
//  EpisodeOfCharacterTableViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/03/2021.
//
import UIKit

class EpisodeOfCharacterTableViewController: UITableViewController {
    var episodesOfCharacterArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodesOfCharacterArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = episodesOfCharacterArray[indexPath.row]
        cell.textLabel?.textColor = .black
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .systemBackground
        }
        return cell
    }
}
