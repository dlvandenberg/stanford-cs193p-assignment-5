//
//  OptionalImage.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 22/05/2023.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}
