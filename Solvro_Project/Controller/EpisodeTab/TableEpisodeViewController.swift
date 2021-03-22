//
//  TableViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/10/2020.
//

import UIKit
import rick_morty_swift_api

class TableEpisodeViewController: UITableViewController, UISearchResultsUpdating {
    // vars and lets
    var resultSearchController = UISearchController()
    let rickAndMortyClient = Client()
    var filteredTableData = [String]()
    var arrayCollectionWithEpisodes = [String]()
    var arrayCollectionWithEpisodesCharacters = [String]()
    var arrayCollectionWithCharacters = [String]()
    var episodeNumber = [String.Element]()
    var episodeNumberInString = ""
    var takenArrayWithEpi = [String]()
    var arrayWithFullData = [ModelOfRickAndMortyCharacterData]()
    var extractArray = [ModelOfRickAndMortyCharacterData]()
    var isSorting = false
    // ViewDiDLoad and Getting data from Api
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Episodes"
        self.rickAndMortyClient.episode().getAllEpisodes { result in
            switch result {
            case .success(let episodes):
                episodes.forEach { episode in
                    self.arrayCollectionWithEpisodes.append(episode.name)
                }
            case.failure(let error):
                print(error)
            }
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
            self.rickAndMortyClient.character().getAllCharacters { result in
                switch result {
                case .success(let persons):
                    persons.forEach { person in
                        self.arrayCollectionWithCharacters.append(person.name)
                        var getCharacter = ModelOfRickAndMortyCharacterData(
                            name: person.name,
                            identifier: person.id,
                            status: person.status,
                            imageURL: person.image,
                            data: person.created,
                            gender: person.gender,
                            episode: person.episode,
                            like: false
                        )
                        for episodesIndex in 0...person.episode.count-1 {
                            let currentEpisodeUrl = person.episode[episodesIndex]
                            var currentEpisodeURLArray = Array(currentEpisodeUrl)
                            // https://rickandmortyapi.com/api/episode/39
                            for items in 0...currentEpisodeURLArray.count-1 {
                                let identifier = currentEpisodeURLArray[items].wholeNumberValue
                                if 0...9 ~= identifier ?? -1 {
                                    self.episodeNumber.append(currentEpisodeURLArray[items])
                                }
                            }
                            for items in 0...self.episodeNumber.count-1 {
                                self.episodeNumberInString += String(self.episodeNumber[items])
                            }
                            let episodeNumberInInt = Int(self.episodeNumberInString)!
                            self.takenArrayWithEpi.append(self.arrayCollectionWithEpisodes[episodeNumberInInt-1])
                            self.episodeNumber = []
                            self.episodeNumberInString = ""
                            currentEpisodeURLArray = []
                        }
                        getCharacter.episode = self.takenArrayWithEpi
                        self.arrayWithFullData.append(getCharacter)
                        self.takenArrayWithEpi = []
                    }
                case.failure(let error):
                    // if getting data from Api fails
                    print(error)
                }
                self.tableView.reloadData()
            }
        }
        // Configuring our search Controller
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            tableView.tableHeaderView = controller.searchBar
            return controller
        })()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive {
            return filteredTableData.count
        } else {
            return arrayCollectionWithEpisodes.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseEpisodeCell")! as UITableViewCell
        if resultSearchController.isActive == true {
            cell.textLabel?.text = filteredTableData[indexPath.row]
        } else {
            cell.textLabel?.text = arrayCollectionWithEpisodes[indexPath.row]
        }
        return cell
    }
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentTitle = arrayCollectionWithEpisodes[indexPath.row]
        for index in 0...arrayWithFullData.count-1 {
            let currentCharacter = arrayWithFullData[index]
            for indexInter in 0...currentCharacter.episode.count-1 where currentCharacter.episode[indexInter] == currentTitle {
                    extractArray.append(currentCharacter)
                }
            }
        let viewController = DetailEpisodeTableViewController(items: extractArray)
        viewController.title = "Characters"
        navigationController?.pushViewController(viewController, animated: true)
        extractArray = []
    }
// MARK: - Search Field Logic
func updateSearchResults(for searchController: UISearchController) {
    filteredTableData.removeAll(keepingCapacity: false)
    let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
    let array = (arrayCollectionWithEpisodes as NSArray).filtered(using: searchPredicate)
    filteredTableData = (array as? [String])!
    self.tableView.reloadData()
}
}
