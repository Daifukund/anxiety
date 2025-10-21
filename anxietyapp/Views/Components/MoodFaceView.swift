//
//  MoodFaceView.swift
//  anxietyapp
//
//  Created by Claude Code on 02/10/2025.
//

import SwiftUI

struct MoodFaceView: View {
    let moodValue: Double // 0.0 (calm/green) to 1.0 (anxious/red)
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background circle with mood color
            Circle()
                .fill(Color.moodGradient(for: moodValue))

            // Face elements
            VStack(spacing: size * 0.15) {
                // Eyes
                HStack(spacing: size * 0.25) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.09, height: size * 0.09)

                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.09, height: size * 0.09)
                }
                .offset(y: -size * 0.05)

                // Mouth - curved based on mood
                MouthShape(moodValue: moodValue)
                    .stroke(Color.black, lineWidth: size * 0.03)
                    .frame(width: size * 0.4, height: size * 0.15)
                    .offset(y: size * 0.05)
            }
        }
        .frame(width: size, height: size)
    }
}

/// Custom shape for the mood-based mouth
struct MouthShape: Shape {
    let moodValue: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Calculate curve direction and intensity
        // moodValue 0.0 (calm) = smile (curve down)
        // moodValue 1.0 (anxious) = frown (curve up)

        // Convert mood to curve offset: +1 (smile) to -1 (frown)
        // Reversed: calm (0.0) gets negative offset (smile), anxious (1.0) gets positive offset (frown)
        let curveOffset = (moodValue * 2 - 1) * rect.height * -1.5

        let startPoint = CGPoint(x: rect.minX, y: rect.midY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.midY)
        let controlPoint = CGPoint(x: rect.midX, y: rect.midY + curveOffset)

        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, control: controlPoint)

        return path
    }
}

#Preview {
    VStack(spacing: 32) {
        // Very calm (smile)
        VStack {
            MoodFaceView(moodValue: 0.0, size: 80)
            Text("Very calm (0.0)")
                .font(.caption)
        }

        // Neutral
        VStack {
            MoodFaceView(moodValue: 0.5, size: 80)
            Text("Neutral (0.5)")
                .font(.caption)
        }

        // Very anxious (frown)
        VStack {
            MoodFaceView(moodValue: 1.0, size: 80)
            Text("Very anxious (1.0)")
                .font(.caption)
        }

        // Interactive preview
        VStack {
            MoodFaceView(moodValue: 0.25, size: 120)
            Text("Calm (0.25)")
                .font(.caption)
        }
    }
    .padding()
}
