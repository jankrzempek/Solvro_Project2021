//
//  EpisodesIsInTableViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 26/10/2020.
//

import UIKit
                                                       

class EpisodesIsInTableViewController: UIViewController {

    private let arrayWithData : [String]
    
    init(items : [String]){
        self.arrayWithData = items
        super.init(nibName: nil, bundle: nil)
    }
   
    
    
    var aaray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
            tableView.dataSource = self
            tableView.delegate = self
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrayWithData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "IsInEpisode") as? TableViewCell {
                cell.textLabel?.text = arrayWithData[indexPath.row]
                return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

}
