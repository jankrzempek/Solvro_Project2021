//
//  TableViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/10/2020.
//
import UIKit
import rick_morty_swift_api
import Kingfisher
import CoreData
protocol LikedDelegate {
    func likedIsMade(data: Int)
}
class TableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, MyCellDelegate {
    @IBOutlet weak var epioseNameInCharactersSearching: UILabel!
    @IBOutlet weak var showLikedOutlet: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    let rickAndMortyClient = Client()
    var delegate: LikedDelegate?
    var resultSearchController = UISearchController()
    var filteredTableData = [String]()
    var arrayCollectionWithEpisodes = [String]()
    var arrayCollectionWithCharacters = [String]()
    var arrayWithFullData = [ModelOfRickAndMortyCharacterData]()
    var sortedArray = [ModelOfRickAndMortyCharacterData]()
    var likedArray = [ModelOfRickAndMortyCharacterData]()
    var finishSearching = [ModelOfRickAndMortyCharacterData]()
    var isSorting = false
    var isLikedButtonClicked = false
    var episodeNumber = [String.Element]()
    var episodeNumberInString = ""
    var takenArrayWithEpisodes = [String]()
    var solvroEpisode: [NSManagedObject] = []
    var sortTitle = NSLocalizedString("DefaultTitle", comment: "")
    // Core decides if it is the first time we use the app
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            if let viewController = (storyboard?.instantiateViewController(identifier: "welcome") as? WelcomeViewController) {
                present(viewController, animated: true)
                Core.shared.setIsNotNewUser()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Getting Data"
        self.rickAndMortyClient.episode().getAllEpisodes { result in
            switch result {
            case .success(let episodes):
                episodes.forEach { episode in
                    self.arrayCollectionWithEpisodes.append(episode.name)
                }
            case.failure(let error):
                print(error)
            }
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
                            data: person.species,
                            gender: person.gender,
                            episode: person.episode,
                            like: false)
                        // Saving to Core Data to able to read if internet were lost
                        self.saveDateF(identifier: person.id, name: person.name, status: person.status, like: false)
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
                            self.takenArrayWithEpisodes.append(self.arrayCollectionWithEpisodes[episodeNumberInInt-1])
                            self.episodeNumber = []
                            self.episodeNumberInString = ""
                            currentEpisodeURLArray = []
                        }
                        getCharacter.episode = self.takenArrayWithEpisodes
                        self.arrayWithFullData.append(getCharacter)
                        self.takenArrayWithEpisodes = []
                    }
                case.failure(let error):
                    // here if the internet is lost Core Data comes with help
                    if self.solvroEpisode.count > 0 {
                    for items in 0...self.solvroEpisode.count-1 {
                        let data = ModelOfRickAndMortyCharacterData(
                            name: self.solvroEpisode[items].value(forKey: "name") as? String ?? "null",
                            identifier: self.solvroEpisode[items].value(forKey: "id") as? Int ?? 0, status: self.solvroEpisode[items].value(forKey: "status") as? String ?? "null",
                            imageURL: "",
                            data: "",
                            gender: "",
                            episode: [],
                            like: false)
                        self.arrayWithFullData.append(data)
                    }
                    print(error)
                }
                }
                self.navigationItem.title = (NSLocalizedString("DefaultTitleOfMainScreen", comment: ""))
                self.tableView.reloadData()
            }
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.placeholder = (NSLocalizedString("ResultSearchControllerPlaceholder", comment: ""))
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = controller.searchBar
            return controller
        })()
    }
    // MARK: - Table view data source
    // Number of rows depend of the current state of the app, mainly there are four cases
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var takeNumber = 0
        switch (isSorting, isLikedButtonClicked, resultSearchController.isActive) {
        case (true, false, false):
            takeNumber = sortedArray.count
        case (true, true, false), (false, true, false):
            takeNumber = likedArray.count
        case (true, false, true), (true, true, true), (false, false, true), (false, true, true) :
            takeNumber = finishSearching.count
        case (false, false, false):
            takeNumber = arrayWithFullData.count
        }
        return takeNumber
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell") as! CharacterTableViewCell
        switch (isSorting, isLikedButtonClicked, resultSearchController.isActive) {
        case (true, false, false):
            cell.nameLabelOfCharacter.text = sortedArray[indexPath.row].name
            cell.imageCellView.layer.masksToBounds = true
            cell.imageCellView.layer.borderWidth = 5
            cell.imageCellView.layer.cornerRadius = cell.imageCellView.frame.size.height/2
            if sortedArray[indexPath.row].like == true {
                cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
            } else {
                cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
            }
            let url = URL(string: sortedArray[indexPath.row].imageURL)
            cell.imageCellView.kf.setImage(with: url)
        case (true, true, false), (false, true, false):
            cell.nameLabelOfCharacter.text = likedArray[indexPath.row].name
            cell.imageCellView.layer.masksToBounds = true
            cell.imageCellView.layer.borderWidth = 5
            cell.imageCellView.layer.cornerRadius = cell.imageCellView.frame.size.height/2
            if likedArray[indexPath.row].like == true {
                cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
            } else {
                cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
            }
            let url = URL(string: likedArray[indexPath.row].imageURL)
            cell.imageCellView.kf.setImage(with: url)
        case (true, false, true), (true, true, true), (false, false, true), (false, true, true) :
            cell.nameLabelOfCharacter.text = finishSearching[indexPath.row].name
            cell.imageCellView.layer.masksToBounds = true
            cell.imageCellView.layer.borderWidth = 5
            cell.imageCellView.layer.cornerRadius = cell.imageCellView.frame.size.height/2
            if finishSearching[indexPath.row].like == true {
                cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
            } else {
                cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
            }
            let url = URL(string: finishSearching[indexPath.row].imageURL)
            cell.imageCellView.kf.setImage(with: url)
        case (false, false, false):
            cell.nameLabelOfCharacter.text = arrayWithFullData[indexPath.row].name
            cell.imageCellView.layer.masksToBounds = true
            cell.imageCellView.layer.borderWidth = 5
            cell.imageCellView.layer.cornerRadius = cell.imageCellView.frame.size.height/2
            if arrayWithFullData[indexPath.row].like == true {
                cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
            } else {
                cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
            }
            let url = URL(string: arrayWithFullData[indexPath.row].imageURL)
            cell.imageCellView.kf.setImage(with: url)
        }
        cell.delegate = self
        return cell
    }
    // MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        print(arrayWithFullData[indexPath.row].name)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        switch (isSorting, isLikedButtonClicked, resultSearchController.isActive) {
        case (true, false, false):
            detailViewController.textWithName = sortedArray[indexPath.row].name
            detailViewController.indexOfCurrentChoice = sortedArray[indexPath.row].identifier
            detailViewController.statusOfCurrentCharacter = sortedArray[indexPath.row].status
            detailViewController.currentCharacterImage = sortedArray[indexPath.row].imageURL
            detailViewController.dataOfCreation = sortedArray[indexPath.row].data
            detailViewController.genderOfCurrentCharacter = sortedArray[indexPath.row].gender
            detailViewController.isLiked = sortedArray[indexPath.row].like
            detailViewController.episodesHeIn = sortedArray[indexPath.row].episode
        case (true, true, false), (false, true, false):
            detailViewController.textWithName = likedArray[indexPath.row].name
            detailViewController.indexOfCurrentChoice = likedArray[indexPath.row].identifier
            detailViewController.statusOfCurrentCharacter = likedArray[indexPath.row].status
            detailViewController.currentCharacterImage = likedArray[indexPath.row].imageURL
            detailViewController.dataOfCreation = likedArray[indexPath.row].data
            detailViewController.genderOfCurrentCharacter = likedArray[indexPath.row].gender
            detailViewController.isLiked = likedArray[indexPath.row].like
            detailViewController.episodesHeIn = likedArray[indexPath.row].episode
        case (true, false, true), (true, true, true), (false, false, true), (false, true, true) :
            detailViewController.textWithName = finishSearching[indexPath.row].name
            detailViewController.indexOfCurrentChoice = finishSearching[indexPath.row].identifier
            detailViewController.statusOfCurrentCharacter = finishSearching[indexPath.row].status
            detailViewController.currentCharacterImage = finishSearching[indexPath.row].imageURL
            detailViewController.dataOfCreation = finishSearching[indexPath.row].data
            detailViewController.genderOfCurrentCharacter = finishSearching[indexPath.row].gender
            detailViewController.isLiked = finishSearching[indexPath.row].like
            detailViewController.episodesHeIn = finishSearching[indexPath.row].episode
        case (false, false, false):
            detailViewController.textWithName = arrayWithFullData[indexPath.row].name
            detailViewController.indexOfCurrentChoice = arrayWithFullData[indexPath.row].identifier
            detailViewController.statusOfCurrentCharacter = arrayWithFullData[indexPath.row].status
            detailViewController.currentCharacterImage = arrayWithFullData[indexPath.row].imageURL
            detailViewController.dataOfCreation = arrayWithFullData[indexPath.row].data
            detailViewController.genderOfCurrentCharacter = arrayWithFullData[indexPath.row].gender
            detailViewController.isLiked = arrayWithFullData[indexPath.row].like
            detailViewController.episodesHeIn = arrayWithFullData[indexPath.row].episode
        }
        self.present(detailViewController, animated: true, completion: nil)
    }
    // MARK: - Core Data
    // Saves data to CoreData
    func saveDateF(identifier: Int, name: String, status: String, like: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(
            forEntityName: (NSLocalizedString("CoreDataEntityName", comment: "")), in: managedContext)!
        let solvro = NSManagedObject(entity: entity, insertInto: managedContext)
        solvro.setValue(identifier, forKeyPath: "id")
        solvro.setValue(name, forKeyPath: "name")
        solvro.setValue(status, forKeyPath: "status")
        solvro.setValue(like, forKeyPath: "like")
        do {
            try managedContext.save()
            solvroEpisode.append(solvro)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    // Function which updates data in Core Data
    func update() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: (NSLocalizedString("CoreDataEntityName", comment: "")))
        do {
            solvroEpisode = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    // MARK: - WelcomeScreen Class
    // Function which tells if it is the first start (if it is, then show Welcome Screen)
    class Core {
        static let shared = Core()
        func isNewUser() -> Bool {
            return !UserDefaults.standard.bool(forKey: "isNewUser")
        }
        func setIsNotNewUser() {
            UserDefaults.standard.set(true, forKey: "isNewUser")
        }
    }
    // MARK: - Star Button Clicked
    @IBAction func showLikedItemsButton(_ sender: Any) {
        isLikedButtonClicked = !isLikedButtonClicked
        likedArray = []
        if isLikedButtonClicked == true {
            showLikedOutlet.image = UIImage.init(systemName: "star.fill")
            switch isSorting {
                case false:
                    for item in 0...arrayWithFullData.count-1 where arrayWithFullData[item].like == true {
                        likedArray.append(arrayWithFullData[item])
                    }
                case true:
                    if sortedArray.count > 0 {
                        for item in 0...sortedArray.count-1 where sortedArray[item].like == true {
                            likedArray.append(sortedArray[item])
                        }
                    }
            }
        } else {
            showLikedOutlet.image = UIImage.init(systemName: "star")
            switch navigationItem.title {
            case(NSLocalizedString("DefaultTitle", comment: "")):
                self.isSorting = false
            case((NSLocalizedString("DeadTitle", comment: ""))):
                sortedArray = []
                for index in 0...self.arrayWithFullData.count-1 where self.arrayWithFullData[index].status == (NSLocalizedString("DeadTitle", comment: "")) {
                    self.sortedArray.append(self.arrayWithFullData[index])
                }
            case((NSLocalizedString("AliveTitle", comment: ""))):
                sortedArray = []
                for index in 0...self.arrayWithFullData.count-1 where self.arrayWithFullData[index].status == (NSLocalizedString("AliveTitle", comment: "")) {
                    self.sortedArray.append(self.arrayWithFullData[index])
                }
            case((NSLocalizedString("UnknownTitle", comment: ""))):
                sortedArray = []
                for index in 0...self.arrayWithFullData.count-1 where self.arrayWithFullData[index].status == (NSLocalizedString("UnknownTitle", comment: "")) {
                    self.sortedArray.append(self.arrayWithFullData[index])
                }
            default:
                break
            }
            self.tableView.reloadData()
        }
        tableView.reloadData()
    }
    // MARK: - Sort Button Action
    @IBAction func sortButtonAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sort Option's", message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "by Alive", style: .default, handler: { (UIAlertAction)in
            self.sortedArray = []
            self.navigationItem.title = (NSLocalizedString("AliveTitle", comment: ""))
            switch self.isLikedButtonClicked {
                case true:
                    self.likedArray = []
                    for index in 0...self.arrayWithFullData.count-1 {
                        if self.arrayWithFullData[index].status == (NSLocalizedString("AliveTitle", comment: "")) && self.arrayWithFullData[index].like == true {
                            self.sortedArray.append(self.arrayWithFullData[index])
                            self.likedArray.append(self.arrayWithFullData[index])
                        }
                    }
                case false:
                    for index in 0...self.arrayWithFullData.count-1 {
                        if self.arrayWithFullData[index].status == (NSLocalizedString("AliveTitle", comment: "")) {
                            self.sortedArray.append(self.arrayWithFullData[index])
                        }
                    }
            }
            self.isSorting = true
            self.tableView.reloadData()
            self.sortTitle = (NSLocalizedString("AliveTitle", comment: ""))
        }))
        alert.addAction(UIAlertAction(title: "by Dead", style: .default , handler: { (UIAlertAction) in
            self.sortedArray = []
            self.navigationItem.title = (NSLocalizedString("DeadTitle", comment: ""))
            switch self.isLikedButtonClicked {
                case true:
                    self.likedArray = []
                    for index in 0...self.arrayWithFullData.count-1 {
                        if self.arrayWithFullData[index].status == (NSLocalizedString("DeadTitle", comment: "")) && self.arrayWithFullData[index].like == true {
                            self.sortedArray.append(self.arrayWithFullData[index])
                            self.likedArray.append(self.arrayWithFullData[index])
                        }
                    }
                case false:
                    for index in 0...self.arrayWithFullData.count-1 {
                        if self.arrayWithFullData[index].status == (NSLocalizedString("DeadTitle", comment: "")) {
                            self.sortedArray.append(self.arrayWithFullData[index])
                        }
                    }
            }
            self.isSorting = true
            self.tableView.reloadData()
            self.sortTitle = (NSLocalizedString("DeadTitle", comment: ""))
        }))
        alert.addAction(UIAlertAction(title: "by Unknown", style: .default, handler: { (_)in
            self.sortedArray = []
            self.navigationItem.title = "Unknown"
            switch self.isLikedButtonClicked {
                case true:
                    self.likedArray = []
                    for index in 0...self.arrayWithFullData.count-1 where self.arrayWithFullData[index].status == (NSLocalizedString("UnknownTitle", comment: "")) && self.arrayWithFullData[index].like == true {
                        self.sortedArray.append(self.arrayWithFullData[index])
                        self.likedArray.append(self.arrayWithFullData[index])
                    }
                case false:
                    for index in 0...self.arrayWithFullData.count-1 where self.arrayWithFullData[index].status == (NSLocalizedString("UnknownTitle", comment: "")) {
                        self.sortedArray.append(self.arrayWithFullData[index])
                    }
                }
            self.isSorting = true
            self.tableView.reloadData()
            self.sortTitle = (NSLocalizedString("UnknownTitle", comment: ""))
        }))
        alert.addAction(UIAlertAction(title: "by Default", style: .default, handler: { (_) in
            self.sortedArray = []
            self.navigationItem.title = (NSLocalizedString("DefaultTitle", comment: ""))
            switch self.isLikedButtonClicked {
                case true:
                    self.likedArray = []
                    for index in 0...self.arrayWithFullData.count-1 where self.arrayWithFullData[index].like == true {
                        self.sortedArray.append(self.arrayWithFullData[index])
                        self.likedArray.append(self.arrayWithFullData[index])
                    }
                case false:
                    break
            }
            self.isSorting = false
            self.tableView.reloadData()
            self.sortTitle = (NSLocalizedString("DefaultTitle", comment: ""))
        }))
        let cancelAction = UIAlertAction(title: (NSLocalizedString("TitleOfCancelAlertInAction", comment: "")), style: .cancel, handler: { (_: UIAlertAction!) -> Void in })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        tableView.reloadData()
    }

// MARK: - SearchField Action's
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (arrayCollectionWithEpisodes as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        finishSearching = []
        if filteredTableData.count == 0 && searchController.searchBar.text == "" {
            navigationItem.title = sortTitle
        }
        if filteredTableData.count > 0 {
            for items in 0...arrayWithFullData.count-1 {
                // DEAD
                switch(sortTitle, isLikedButtonClicked) {
                case("Dead", false):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        if arrayWithFullData[items].status == (NSLocalizedString("DeadTitle", comment: "")) {
                            finishSearching.append(arrayWithFullData[items])
                        }
                    }
                case("Dead", true):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        finishSearching.append(arrayWithFullData[items])
                    }
                case("Default", false):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        finishSearching.append(arrayWithFullData[items])
                    }
                case("Default", true):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        finishSearching.append(arrayWithFullData[items])
                    }
                case("Alive", false):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        finishSearching.append(arrayWithFullData[items])
                    }
                case("Alive", true):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        finishSearching.append(arrayWithFullData[items])
                    }
                case("unknown", false):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        finishSearching.append(arrayWithFullData[items])
                    }
                case("unknown", true):
                    if arrayWithFullData[items].episode.contains(filteredTableData[0]) {
                        finishSearching.append(arrayWithFullData[items])
                    }
                default:
                    break
                }
            }
            navigationItem.title = "Searching: \(filteredTableData[0])"
        }
        self.tableView.reloadData()
    }
// MARK: - LikedButtonTapped
    func buttonTapped(cell: CharacterTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        switch (isSorting, isLikedButtonClicked, resultSearchController.isActive) {
        case (true, false, false):
            sortedArray[indexPath!.row].like = !sortedArray[indexPath!.row].like
            if arrayWithFullData.count > 0 {
                for index in 0...arrayWithFullData.count-1 where sortedArray[indexPath!.row].identifier == arrayWithFullData[index].identifier {
                    arrayWithFullData[index].like = sortedArray[indexPath!.row].like
                }
            }
            tableView.reloadData()
        case (true, true, false), (false, true, false):
            likedArray[indexPath!.row].like = !likedArray[indexPath!.row].like
            if sortedArray.count > 0 {
                for index in 0...sortedArray.count-1 where likedArray[indexPath!.row].identifier == sortedArray[index].identifier {
                    sortedArray[index].like = likedArray[indexPath!.row].like
                }
            }
            if arrayWithFullData.count > 0 {
                for index in 0...arrayWithFullData.count-1 where likedArray[indexPath!.row].identifier == arrayWithFullData[index].identifier {
                    arrayWithFullData[index].like = likedArray[indexPath!.row].like
                }
            }
            likedArray.remove(at: indexPath!.row)
            tableView.reloadData()
        case (true, false, true), (true, true, true), (false, false, true), (false, true, true) :
            if finishSearching.count > 0 {
                finishSearching[indexPath!.row].like = !finishSearching[indexPath!.row].like
                for index in 0...arrayWithFullData.count-1 where finishSearching[indexPath!.row].identifier == arrayWithFullData[index].identifier {
                    arrayWithFullData[index].like = finishSearching[indexPath!.row].like
                }
                if sortedArray.count > 0 {
                    for index in 0...sortedArray.count-1 where finishSearching[indexPath!.row].identifier == sortedArray[index].identifier {
                        sortedArray[index].like = finishSearching[indexPath!.row].like
                    }
                }
                if likedArray.count > 0 {
                    for index in 0...likedArray.count-1 where finishSearching[indexPath!.row].identifier == likedArray[index].identifier {
                        likedArray[index].like = finishSearching[indexPath!.row].like
                        likedArray.remove(at: index)
                        break
                    }
                }
                if finishSearching[indexPath!.row].like == true {
                    cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
                } else {
                    cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
                }
            }
            tableView.reloadData()
        case (false, false, false):
            arrayWithFullData[indexPath!.row].like = !arrayWithFullData[indexPath!.row].like
            tableView.reloadData()
        }
    }
}
