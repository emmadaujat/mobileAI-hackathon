import SwiftUI

struct HomeScreenView: View {
    @StateObject private var viewModel = HomeScreenViewModel()
    @State private var showingSettings = false
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange, .pink.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("9:41")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Assist settings")
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 22) {
                        ForEach(AppTile.all) { tile in
                            AppIconTileView(
                                tile: tile,
                                isHighlighted: viewModel.highlightedTileID == tile.id,
                                onTap: {
                                    viewModel.tileTapped(tile, wasHighlighted: viewModel.highlightedTileID == tile.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }

                Spacer(minLength: 8)

                AssistantBubbleView(
                    message: viewModel.messages.last(where: { $0.isSpoken }),
                    isListening: viewModel.isListening,
                    assistEnabled: viewModel.assistEnabled,
                    onMicTap: {
                        viewModel.isListening ? viewModel.stopListening() : viewModel.startListening()
                    }
                )
                .padding(.bottom, 10)
            }
        }
        .onAppear { viewModel.onAppear() }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
}

#Preview {
    HomeScreenView()
}
