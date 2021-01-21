import SwiftUI
import Form
import Model
import Util
import ComposableArchitecture

public struct PhotoDetailCell: View {
    let photo: PhotoViewModel

    public init(photo: PhotoViewModel) {
        self.photo = photo
    }

    public var body: some View {
        Group {
            if extract(case: Photo.saved, from: photo.basePhoto) != nil {
                SavedTimelinePhotoCell(savedPhoto: extract(case: Photo.saved, from: photo.basePhoto)!)
            } else if extract(case: Photo.new, from: photo.basePhoto) != nil {
                NewTimelinePhotoCell(newPhoto: extract(case: Photo.new, from: photo.basePhoto)!)
            }
        }
    }
}
