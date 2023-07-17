//

import XCTest
@testable import KeyframeReimplementation
import SwiftUI

struct ShakeData {
    var offset: CGFloat = 0
    var rotation: Angle = .zero
}

final class KeyframeReimplementationTests: XCTestCase {
    func testTimeline() throws {
        let timeline = MyKeyframeTimeline(initialValue: ShakeData(), tracks: [
            MyKeyframeTrack(\.offset, [
                MyLinearKeyframe(100, duration: 1),
                MyLinearKeyframe(150, duration: 1),
                MyMoveKeyframe(200, duration: 1),
            ]),
            MyKeyframeTrack(\.rotation, [
                MyLinearKeyframe(Angle.degrees(10), duration: 0.5),
                MyLinearKeyframe(Angle.degrees(50), duration: 1)
            ])
        ])
        XCTAssertEqual(timeline.value(at: 0.5).offset, 50)
        XCTAssertEqual(timeline.value(at: 1.5).offset, 125)
        XCTAssertEqual(timeline.value(at: 3).offset, 200)
        XCTAssertEqual(timeline.value(at: 0.25).rotation.degrees, 5)
        XCTAssertEqual(timeline.value(at: 1).rotation.degrees, 30, accuracy: 0.01)
        XCTAssertEqual(timeline.value(at: 3).rotation.degrees, 50, accuracy: 0.01)
    }
}
