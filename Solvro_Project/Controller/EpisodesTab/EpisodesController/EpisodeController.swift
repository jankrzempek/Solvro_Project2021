//
//  TableViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/10/2020.
//

import UIKit
import rick_morty_swift_api

class TableEpisodeViewController: UITableViewController, UISearchResultsUpdating {
    var resultSearchController = UISearchController()
    var filteredArray = [String]()
    var episodesArray = [String]()
    var charactersArray = [String]()
    var outsourcedEpisodesArray = [String]()
    var episodesArrayElements = [String.Element]()
    var compleatedDataArray = [ModelOfRickAndMortyData]()
    var extractedArray = [ModelOfRickAndMortyData]()
    let rickAndMortyClient = Client()
    var isSorting = false
    var episodeNumberInString = ""
    // ViewDiDLoad and Getting data from Api
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = (NSLocalizedString("EpisodesControllerNavigationItemTitle", comment: ""))
        self.rickAndMortyClient.episode().getAllEpisodes { result in
            switch result {
            case .success(let episodes):
                episodes.forEach { episode in
                    self.episodesArray.append(episode.name)
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
                        self.charactersArray.append(person.name)
                        var getCharacter = ModelOfRickAndMortyData(
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
                                    self.episodesArrayElements.append(currentEpisodeURLArray[items])
                                }
                            }
                            for items in 0...self.episodesArrayElements.count-1 {
                                self.episodeNumberInString += String(self.episodesArrayElements[items])
                            }
                            let episodeNumberInInt = Int(self.episodeNumberInString)!
                            self.outsourcedEpisodesArray.append(self.episodesArray[episodeNumberInInt-1])
                            self.episodesArrayElements = []
                            self.episodeNumberInString = ""
                            currentEpisodeURLArray = []
                        }
                        getCharacter.episode = self.outsourcedEpisodesArray
                        self.compleatedDataArray.append(getCharacter)
                        self.outsourcedEpisodesArray = []
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
            return filteredArray.count
        } else {
            return episodesArray.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseEpisodeCell")! as UITableViewCell
        if resultSearchController.isActive == true {
            cell.textLabel?.text = filteredArray[indexPath.row]
        } else {
            cell.textLabel?.text = episodesArray[indexPath.row]
        }
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .systemBackground
        }
        return cell
    }
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentTitle = episodesArray[indexPath.row]
        for index in 0...compleatedDataArray.count-1 {
            let currentCharacter = compleatedDataArray[index]
            for indexInter in 0...currentCharacter.episode.count-1
            where currentCharacter.episode[indexInter] == currentTitle {
                extractedArray.append(currentCharacter)
            }
        }
        let viewController = DetailEpisodeTableViewController(items: extractedArray)
        viewController.title = "Characters"
        navigationController?.pushViewController(viewController, animated: true)
        extractedArray = []
    }
    // MARK: - Search Field Logic
    func updateSearchResults(for searchController: UISearchController) {
        filteredArray.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (episodesArray as NSArray).filtered(using: searchPredicate)
        filteredArray = (array as? [String])!
        self.tableView.reloadData()
    }
}
