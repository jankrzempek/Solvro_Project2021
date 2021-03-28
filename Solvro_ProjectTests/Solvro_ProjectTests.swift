//
//  Solvro_ProjectTests.swift
//  Solvro_ProjectTests
//
//  Created by Jan Krzempek on 19/03/2021.
//

import XCTest
@testable import Solvro_Project

class SolvroProjectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRikAndDataModel() {
        let data = ModelOfRickAndMortyData(name: "Rick",
                                           identifier: 1,
                                           status: "Alive",
                                           imageURL: "http://image.png/",
                                           data: "12-04-2020",
                                           gender: "Male",
                                           episode: ["X", "Y", "Z"],
                                           like: true)
        XCTAssertTrue(data.like)
        XCTAssertEqual(data.name, "Rick")
    }
}
