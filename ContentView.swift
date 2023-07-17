//

import SwiftUI

struct ShakeData {
    var offset: CGFloat = 0
    var rotation: Angle = .zero
}

struct MyKeyframeAnimator<Root, Trigger: Equatable, Content: View>: View {
    var initialValue: Root
    var trigger: Trigger
    @ViewBuilder var content: (Root) -> Content
    var keyframes: [any MyKeyframeTracks<Root>]

    @State private var startDate: Date? = nil
    @State private var suspended = true

    var timeline: MyKeyframeTimeline<Root> {
        MyKeyframeTimeline(initialValue: initialValue, tracks: keyframes)
    }

    func value(for date: Date) -> Root {
        guard let s = startDate else { return initialValue }
        return timeline.value(at: date.timeIntervalSince(s))
    }

    func isPaused(_ date: Date) -> Bool {
        guard let s = startDate else { return true }
        let time = date.timeIntervalSince(s)
        if time > timeline.duration { return true }
        return false
    }

    var body: some View {
        TimelineView(.animation(paused: suspended)) { context in
            let _ = print(Date.now.timeIntervalSince1970)
            let value = value(for: context.date)
            content(value)
                .onChange(of: isPaused(context.date)) { _, newValue in
                    suspended = newValue
                }
        }
        .onChange(of: trigger) { _, _ in
            startDate = Date()
            suspended = false
        }
    }
}

struct ContentView: View {
    @State private var shakes = 0

    var body: some View {
        ZStack {
            KeyframeAnimator(initialValue: ShakeData(), trigger: shakes, content: { value in
                Button("Shake") {
                    shakes += 1
                }
                .offset(x: value.offset)
                .rotationEffect(value.rotation)
            }, keyframes: { _ in
                KeyframeTrack(\.offset) {
                    LinearKeyframe(-30, duration: 0.5)
                    LinearKeyframe(30, duration: 1)
                    LinearKeyframe(0, duration: 0.5)
                }
                KeyframeTrack(\.rotation) {
                    LinearKeyframe(.degrees(30), duration: 1)
                    LinearKeyframe(.zero, duration: 1)
                }
            })
            MyKeyframeAnimator(initialValue: ShakeData(), trigger: shakes, content: { value in
                Button("Shake") {
                    shakes += 1
                }
                .offset(x: value.offset)
                .rotationEffect(value.rotation)
            }, keyframes: [
                MyKeyframeTrack(\ShakeData.offset, [
                    MyLinearKeyframe(-30, duration: 0.5),
                    MyLinearKeyframe(30, duration: 1),
                    MyLinearKeyframe(0, duration: 0.5),
                ]),
                MyKeyframeTrack(\.rotation, [
                    MyLinearKeyframe(Angle.degrees(30), duration: 1),
                    MyLinearKeyframe(Angle.zero, duration: 1)
                ])
            ])
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
