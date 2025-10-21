//
//  OnboardingCommitmentView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI
import PencilKit

struct OnboardingCommitmentView: View {
    let userName: String
    let onContinue: () -> Void

    @State private var canvasView = PKCanvasView()
    @State private var hasSigned = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Header
            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("Ready to commit to your wellbeing?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)

                Text("Small daily steps can change your brain and your life. Let's make this official.")
                    .font(DesignSystem.Typography.bodyFont)
                    .foregroundColor(.textMedium)
                    .multilineTextAlignment(.center)
                }
                .padding(.top, DesignSystem.Spacing.xl)
                .padding(.horizontal, DesignSystem.Spacing.large)

                // Signature area
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                Text("Sign it.")
                    .font(DesignSystem.Typography.questionTitle)
                    .foregroundColor(.textDark)

                CanvasView(canvasView: $canvasView, onDraw: {
                    hasSigned = true
                })
                .frame(height: 200)
                .background(Color.secondaryViolet.opacity(0.3))
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(Color.borderGray, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                )

                if !hasSigned {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.textLight)
                        Text("Draw your signature above")
                            .font(DesignSystem.Typography.helperText)
                            .foregroundColor(.textLight)
                    }
                }
                }
                .padding(.horizontal, DesignSystem.Spacing.medium)

            Spacer()

            // Buttons
            VStack(spacing: DesignSystem.Spacing.small) {
                OnboardingButton(
                title: "I'm committed",
                action: onContinue,
                isEnabled: hasSigned
                )

                Button(action: {
                canvasView.drawing = PKDrawing()
                hasSigned = false
                }) {
                Text("Clear signature")
                    .font(DesignSystem.Typography.button)
                    .foregroundColor(.textLight)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.bottom, DesignSystem.Spacing.medium)
        }
        .gradientBackground()
    }
}

// Canvas wrapper for signature
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let onDraw: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDraw: onDraw)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let onDraw: () -> Void

        init(onDraw: @escaping () -> Void) {
            self.onDraw = onDraw
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onDraw()
        }
    }
}

#Preview {
    OnboardingCommitmentView(
        userName: "John",
        onContinue: {}
    )
}
