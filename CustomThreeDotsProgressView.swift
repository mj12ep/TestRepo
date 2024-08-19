import SwiftUI
import Combine

struct CustomThreeDotsProgressView: View {
    @State private var dotScales: [CGFloat] = [1.0, 1.0, 1.0]
    @State private var timerSubscription: Cancellable?
    
    private let maxDotCount = 3
    private let animationDuration = 0.3 // Duration for each dot to scale up and down
    private let delayBetweenDots = 0.15  // Delay before starting the next dot's animation

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<maxDotCount, id: \.self) { index in
                Circle()
                    .fill(Color.blue)  // Change the color as needed
                    .frame(width: 10, height: 10)
                    .scaleEffect(dotScales[index])
                    .animation(.easeInOut(duration: animationDuration), value: dotScales[index])
                    .padding(.top, 16) // Adjust vertical position if needed
            }
        }
        .onAppear {
            startAnimationSequence()
        }
        .onDisappear {
            timerSubscription?.cancel() // Cancel the timer when the view disappears
        }
    }

    private func startAnimationSequence() {
        let timer = Timer.publish(every: delayBetweenDots, on: .main, in: .common).autoconnect()

        var activeDot = 0

        timerSubscription = timer.sink { _ in
            withAnimation(.easeInOut(duration: animationDuration)) {
                dotScales[activeDot] = 1.5
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    dotScales[activeDot] = 1.0
                }
            }

            activeDot = (activeDot + 1) % maxDotCount
        }
    }
}

struct CustomThreeDotsProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CustomThreeDotsProgressView()
    }
}
