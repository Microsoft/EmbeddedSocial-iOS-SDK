//
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation

struct ThemeAssets {
    let userPhotoPlaceholder: Asset
}

extension ThemeAssets {
    static let light = ThemeAssets(userPhotoPlaceholder: .userPhotoPlaceholderLight)
    
    static let dark = ThemeAssets(userPhotoPlaceholder: .userPhotoPlaceholderDark)
}
