

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ScreenScaffold {
            VStack(spacing: TTSpacing.xl) {
                Spacer(minLength: TTSpacing.xxl)

                VStack(alignment: .leading, spacing: TTSpacing.sm) {
                    Text("Hello,")
                        .font(TTFont.display())
                        .foregroundStyle(TTColor.ink)

                    Text("Welcome to")
                        .font(TTFont.title())
                        .foregroundStyle(TTColor.ink)

                    HStack(spacing: TTSpacing.xs) {
                        Text("Tap")
                            .font(TTFont.display())
                            .foregroundStyle(TTColor.ink)

                        ZStack {
                            Circle()
                                .fill(TTColor.ink)
                                .frame(width: 44, height: 44)
                            Image(systemName: "waveform")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(TTColor.buttonLabel)
                        }

                        Text("Talk")
                            .font(TTFont.display())
                            .foregroundStyle(TTColor.logoAccent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Hello, Welcome to TapTalk")

                Spacer()

                PrimaryButton(title: "continue") {
                    coordinator.advanceFromWelcome()
                }
            }
            .frame(minHeight: 480)
        }
    }
}

#Preview {
    WelcomeView().environmentObject(AppCoordinator())
}
