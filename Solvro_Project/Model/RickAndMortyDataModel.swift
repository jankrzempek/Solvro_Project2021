//
//  RickAndMortyDataStruct.swift
//  Solvro_Project
//
//  Created by Jan Krzempek on 31/10/2020.
//

import Foundation
// struct which represent Api's data

struct ModelOfRickAndMortyCharacterData {
    var name: String
    var identifier: Int
    var status: String
    var imageURL: String
    var data: String
    var gender: String
    var episode: [String]
    var like: Bool
}
