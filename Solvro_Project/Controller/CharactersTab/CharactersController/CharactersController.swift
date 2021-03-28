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
protocol LikedDelegate: AnyObject {
    func likedIsMade(data: Int)
}
class TableViewController: UITableViewController,
                           UISearchBarDelegate,
                           UISearchControllerDelegate,
                           UISearchResultsUpdating,
                           MyCellDelegate {
    @IBOutlet weak var showLikedButton: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    var resultSearchController = UISearchController()
    let rickAndMortyClient = Client()
    weak var delegate: LikedDelegate?
    var filteredDataArray = [String]()
    var episodesArray = [String]()
    var charactersArray = [String]()
    var outsourcedEpisodeArray = [String]()
    var arrayWithFullData = [ModelOfRickAndMortyData]()
    var sortedArray = [ModelOfRickAndMortyData]()
    var likedArray = [ModelOfRickAndMortyData]()
    var searchedArray = [ModelOfRickAndMortyData]()
    var isSorting = false
    var isLikedButtonClicked = false
    var episodeNumber = [String.Element]()
    var coreDataArray: [NSManagedObject] = []
    var episodeNumberInString = ""
    var sortTitle = NSLocalizedString("DefaultTitle", comment: "")
    // Core decides if it is the first time we use the app
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            if let viewController = (storyboard?.instantiateViewController(identifier: "welcome")
                                        as? WelcomeViewController) {
                present(viewController, animated: true)
                Core.shared.setIsNotNewUser()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = (NSLocalizedString("NavigationItemTitle", comment: ""))
        self.rickAndMortyClient.episode().getAllEpisodes { result in
            switch result {
            case .success(let episodes):
                episodes.forEach { episode in
                    self.episodesArray.append(episode.name)
                }
            case.failure(let error):
                print(error)
            }
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
                            self.outsourcedEpisodeArray.append(self.episodesArray[episodeNumberInInt-1])
                            self.episodeNumber = []
                            self.episodeNumberInString = ""
                            currentEpisodeURLArray = []
                        }
                        getCharacter.episode = self.outsourcedEpisodeArray
                        self.arrayWithFullData.append(getCharacter)
                        self.outsourcedEpisodeArray = []
                    }
                case.failure(let error):
                    // here if the internet is lost Core Data comes with help
                    if self.coreDataArray.count > 0 {
                        for items in 0...self.coreDataArray.count-1 {
                            let data = ModelOfRickAndMortyData(
                                name: self.coreDataArray[items].value(forKey: "name") as? String ?? "null",
                                identifier: self.coreDataArray[items].value(forKey: "id") as? Int ?? 0,
                                status: self.coreDataArray[items].value(forKey: "status") as? String ?? "null",
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
            takeNumber = searchedArray.count
        case (false, false, false):
            takeNumber = arrayWithFullData.count
        }
        return takeNumber
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell") as! CharacterTableViewCell
        switch (isSorting, isLikedButtonClicked, resultSearchController.isActive) {
        case (true, false, false):
            cell.nameOfCharacterLabel.text = sortedArray[indexPath.row].name
            imageBeautifier(image: cell.imageCellView)
            if sortedArray[indexPath.row].like == true {
                cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
            } else {
                cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
            }
            let url = URL(string: sortedArray[indexPath.row].imageURL)
            cell.imageCellView.kf.setImage(with: url)
        case (true, true, false), (false, true, false):
            cell.nameOfCharacterLabel.text = likedArray[indexPath.row].name
            imageBeautifier(image: cell.imageCellView)
            if likedArray[indexPath.row].like == true {
                cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
            } else {
                cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
            }
            let url = URL(string: likedArray[indexPath.row].imageURL)
            cell.imageCellView.kf.setImage(with: url)
        case (true, false, true), (true, true, true), (false, false, true), (false, true, true) :
            cell.nameOfCharacterLabel.text = searchedArray[indexPath.row].name
            imageBeautifier(image: cell.imageCellView)
            if searchedArray[indexPath.row].like == true {
                cell.imageCellView.layer.borderColor = UIColor(named: "likeColour")?.cgColor
            } else {
                cell.imageCellView.layer.borderColor = UIColor(named: "dislikeColour")?.cgColor
            }
            let url = URL(string: searchedArray[indexPath.row].imageURL)
            cell.imageCellView.kf.setImage(with: url)
        case (false, false, false):
            cell.nameOfCharacterLabel.text = arrayWithFullData[indexPath.row].name
            imageBeautifier(image: cell.imageCellView)
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
    func imageBeautifier(image: UIImageView) {
        image.layer.masksToBounds = true
        image.layer.borderWidth = 5
        image.layer.cornerRadius = image.frame.size.height/2
    }
    // MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (isSorting, isLikedButtonClicked, resultSearchController.isActive) {
        case (true, false, false):
            replce(array: sortedArray, index: indexPath)
        case (true, true, false), (false, true, false):
            replce(array: likedArray, index: indexPath)
        case (true, false, true), (true, true, true), (false, false, true), (false, true, true) :
            replce(array: searchedArray, index: indexPath)
        case (false, false, false):
            replce(array: arrayWithFullData, index: indexPath)
        }
    }
    func replce(array: [ModelOfRickAndMortyData], index: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailView")
            as! DetailViewController
        detailViewController.characterName = array[index.row].name
        detailViewController.indexOfCurrentCharacter = array[index.row].identifier
        detailViewController.statusOfCurrentCharacter = array[index.row].status
        detailViewController.currentCharacterImage = array[index.row].imageURL
        detailViewController.dataOfCreation = array[index.row].data
        detailViewController.genderOfCurrentCharacter = array[index.row].gender
        detailViewController.isLiked = array[index.row].like
        detailViewController.characterEpisodesArray = array[index.row].episode
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
            coreDataArray.append(solvro)
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
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:
                                                            (NSLocalizedString("CoreDataEntityName", comment: "")))
        do {
            coreDataArray = try managedContext.fetch(fetchRequest)
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
            showLikedButton.image = UIImage.init(systemName: "star.fill")
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
            showLikedButton.image = UIImage.init(systemName: "star")
            switch navigationItem.title {
            case(NSLocalizedString("DefaultTitle", comment: "")):
                self.isSorting = false
            case((NSLocalizedString("DeadTitle", comment: ""))):
                sortedArray = []
                for index in 0...self.arrayWithFullData.count-1
                where self.arrayWithFullData[index].status == (NSLocalizedString("DeadTitle", comment: "")) {
                    self.sortedArray.append(self.arrayWithFullData[index])
                }
            case((NSLocalizedString("AliveTitle", comment: ""))):
                sortedArray = []
                for index in 0...self.arrayWithFullData.count-1
                where self.arrayWithFullData[index].status == (NSLocalizedString("AliveTitle", comment: "")) {
                    self.sortedArray.append(self.arrayWithFullData[index])
                }
            case((NSLocalizedString("UnknownTitle", comment: ""))):
                sortedArray = []
                for index in 0...self.arrayWithFullData.count-1
                where self.arrayWithFullData[index].status == (NSLocalizedString("UnknownTitle", comment: "")) {
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
        let alert = UIAlertController(title: "Sort Option's",
                                      message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "by Alive",
                                      style: .default, handler: { (_)in
                                        self.sortedArray = []
                                        self.navigationItem.title = (NSLocalizedString("AliveTitle", comment: ""))
                                        switch self.isLikedButtonClicked {
                                        case true:
                                            self.likedArray = []
                                            for index in 0...self.arrayWithFullData.count-1 where
                                            self.arrayWithFullData[index].status == (NSLocalizedString("AliveTitle", comment: ""))
                                                && self.arrayWithFullData[index].like == true {
                                                    self.sortedArray.append(self.arrayWithFullData[index])
                                                    self.likedArray.append(self.arrayWithFullData[index])
                                            }
                                        case false:
                                            for index in 0...self.arrayWithFullData.count-1 where
                                            self.arrayWithFullData[index].status == (NSLocalizedString("AliveTitle", comment: "")) {
                                                    self.sortedArray.append(self.arrayWithFullData[index])
                                                }
                                        }
                                        self.isSorting = true
                                        self.tableView.reloadData()
                                        self.sortTitle = (NSLocalizedString("AliveTitle", comment: ""))
                                      }))
        alert.addAction(UIAlertAction(title: "by Dead",
                                      style: .default, handler: { (_) in
                                        self.sortedArray = []
                                        self.navigationItem.title = (NSLocalizedString("DeadTitle", comment: ""))
                                        switch self.isLikedButtonClicked {
                                        case true:
                                            self.likedArray = []
                                            for index in 0...self.arrayWithFullData.count-1 where
                                                self.arrayWithFullData[index].status == (NSLocalizedString("DeadTitle", comment: ""))
                                                && self.arrayWithFullData[index].like == true {
                                                    self.sortedArray.append(self.arrayWithFullData[index])
                                                    self.likedArray.append(self.arrayWithFullData[index])
                                                }
                                        case false:
                                            for index in 0...self.arrayWithFullData.count-1 where
                                                self.arrayWithFullData[index].status == (NSLocalizedString("DeadTitle", comment: "")) {
                                                    self.sortedArray.append(self.arrayWithFullData[index])
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
                for index in 0...self.arrayWithFullData.count-1
                where self.arrayWithFullData[index].status == (NSLocalizedString("UnknownTitle", comment: "")) &&
                    self.arrayWithFullData[index].like == true {
                    self.sortedArray.append(self.arrayWithFullData[index])
                    self.likedArray.append(self.arrayWithFullData[index])
                }
            case false:
                for index in 0...self.arrayWithFullData.count-1
                where self.arrayWithFullData[index].status == (NSLocalizedString("UnknownTitle", comment: "")) {
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
        let cancelAction = UIAlertAction(title: (NSLocalizedString("TitleOfCancelAlertInAction", comment: "")),
                                         style: .cancel, handler: { (_: UIAlertAction!) -> Void in })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        tableView.reloadData()
    }
    // MARK: - SearchField Action's
    func updateSearchResults(for searchController: UISearchController) {
        filteredDataArray.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        if let array = (episodesArray as NSArray).filtered(using: searchPredicate) as? [String] {
            filteredDataArray = array
            navigationItem.title = sortTitle
        }
        searchedArray = []
        if filteredDataArray.count > 0 {
            for items in 0...arrayWithFullData.count-1 {
                // DEAD
                switch sortTitle {
                case("Dead"):
                    if arrayWithFullData[items].episode.contains(filteredDataArray[0]) &&
                        arrayWithFullData[items].status == (NSLocalizedString("DeadTitle", comment: "")) {
                        searchedArray.append(arrayWithFullData[items])
                    }
                case("Alive"):
                    if arrayWithFullData[items].episode.contains(filteredDataArray[0]) &&
                        arrayWithFullData[items].status == (NSLocalizedString("AliveTitle", comment: "")) {
                        searchedArray.append(arrayWithFullData[items])
                    }
                case("unknown"):
                    if arrayWithFullData[items].episode.contains(filteredDataArray[0]) &&
                        arrayWithFullData[items].status == (NSLocalizedString("UnknownTitle", comment: "")) {
                        searchedArray.append(arrayWithFullData[items])
                    }
                case("Default"):
                    if arrayWithFullData[items].episode.contains(filteredDataArray[0]) {
                        searchedArray.append(arrayWithFullData[items])
                    }
                default:
                    break
                }
            }
            navigationItem.title = "Searching: \(filteredDataArray[0])"
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
                for index in 0...arrayWithFullData.count-1
                where sortedArray[indexPath!.row].identifier == arrayWithFullData[index].identifier {
                    arrayWithFullData[index].like = sortedArray[indexPath!.row].like
                }
            }
            tableView.reloadData()
        case (true, true, false), (false, true, false):
            likedArray[indexPath!.row].like = !likedArray[indexPath!.row].like
            if sortedArray.count > 0 {
                for index in 0...sortedArray.count-1
                where likedArray[indexPath!.row].identifier == sortedArray[index].identifier {
                    sortedArray[index].like = likedArray[indexPath!.row].like
                }
            }
            if arrayWithFullData.count > 0 {
                for index in 0...arrayWithFullData.count-1
                where likedArray[indexPath!.row].identifier == arrayWithFullData[index].identifier {
                    arrayWithFullData[index].like = likedArray[indexPath!.row].like
                }
            }
            likedArray.remove(at: indexPath!.row)
            tableView.reloadData()
        case (true, false, true), (true, true, true), (false, false, true), (false, true, true) :
            if searchedArray.count > 0 {
                searchedArray[indexPath!.row].like = !searchedArray[indexPath!.row].like
                for index in 0...arrayWithFullData.count-1
                where searchedArray[indexPath!.row].identifier == arrayWithFullData[index].identifier {
                    arrayWithFullData[index].like = searchedArray[indexPath!.row].like
                }
                if sortedArray.count > 0 {
                    for index in 0...sortedArray.count-1
                    where searchedArray[indexPath!.row].identifier == sortedArray[index].identifier {
                        sortedArray[index].like = searchedArray[indexPath!.row].like
                    }
                }
                if likedArray.count > 0 {
                    for index in 0...likedArray.count-1
                    where searchedArray[indexPath!.row].identifier == likedArray[index].identifier {
                        likedArray[index].like = searchedArray[indexPath!.row].like
                        likedArray.remove(at: index)
                        break
                    }
                }
                if searchedArray[indexPath!.row].like == true {
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
