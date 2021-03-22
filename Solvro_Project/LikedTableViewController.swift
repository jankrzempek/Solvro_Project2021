//
//  LikedTableViewController.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 23/10/2020.
//

import UIKit


class LikedTableViewController: UITableViewController, LikedDelegate {
    func likedIsMade(data: Int) {
        print(data)
    }
var data = ""
var likedDataArray = [String]()
let controller = TableViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
       // controller.delegate = self
     //  data = LikedDataArray
//        tableView.dataSource = self
//        tableView.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LikedDataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "likedCell") as? LikedTableViewCell {
            cell.textLabel?.text = LikedDataArray[indexPath.row]
            return cell
        }
    }
}
