//
//  GroupedSection.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 17.03.2024.
//

import Foundation

struct GroupedSection<Section: Hashable, Row> {
    var headline: Section
    var rows: [Row]
    
    /// Creates groups of rows based on a some criteria.
    static func group(rows: [Row], by criteria: (Row) -> Section, sorted: (Row, Row) -> Bool) -> [GroupedSection<Section, Row>] {
        let groups = Dictionary(grouping: rows, by: criteria)
        return groups.map({ GroupedSection(headline: $0.key, rows: $0.value.sorted(by: sorted)) })
    }
}
