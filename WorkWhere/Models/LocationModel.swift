//
//  LocationModel.swift
//  WorkWhere
//
//  Created by Onur Alan on 27.02.2024.
//

import Foundation
import MapKit
import CoreLocation


struct LocationModel: Identifiable, Equatable {
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitute == rhs.longitute
}
    // Add Identifiable for use in Map annotations
    let id = UUID().uuidString // For Identifiable
    let latitude: CGFloat
    let longitute: CGFloat
    let title: String
    let city: String
    let district: String

    init(latitude: CGFloat, longitute: CGFloat, title: String, city: String, district: String) {
        self.latitude = latitude
        self.longitute = longitute
        self.title = title
        self.city = city
        self.district = district
    }

    // MARK: - MapKit Integration
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitute)
    }
}
