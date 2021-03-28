//
//  TableViewCell.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 22/10/2020.
//

import UIKit

protocol MyCellDelegate: AnyObject {
    func buttonTapped(cell: CharacterTableViewCell)
}

class CharacterTableViewCell: UITableViewCell {
    weak var delegate: MyCellDelegate?
    var passedCellURL = ""
    @IBOutlet weak var likedButton: UIButton!
    @IBOutlet weak var nameOfCharacterLabel: UILabel!
    @IBOutlet weak var imageCellView: UIImageView!
    @IBAction func buttonTappedAction(_ sender: Any) {
        delegate?.buttonTapped(cell: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
