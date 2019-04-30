//
//  OutputsAdapter.swift
//  PointingApp
//
//  Created by Berk on 21.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
protocol OutputsAdapter {
    func generateOutputAlphabetical(test: Test, patient: Patient) -> String
    func generateOutputShuffled(test: Test, patient: Patient) -> String
}
