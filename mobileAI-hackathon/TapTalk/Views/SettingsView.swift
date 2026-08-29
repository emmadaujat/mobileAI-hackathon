import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: HomeScreenViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var demoText: String = "I'm catching the train"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Tap-to-Explain & Voice Assist", isOn: $viewModel.assistEnabled)
                } footer: {
                    Text("When on, tapping any icon speaks what it does, and you can ask out loud what you're trying to do. Designed for people who are new to iPhone, or who find small text and icons hard to read — not a replacement for VoiceOver.")
                }

                Section("Voice") {
                    Toggle("Use ElevenLabs voice", isOn: $viewModel.useElevenLabs)
                    SecureField("ElevenLabs API key", text: $viewModel.elevenLabsAPIKey)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    Text("Get a key at elevenlabs.io. Leave this off, or the key blank, to use the free built-in iPhone voice instead — it still works with no internet and no key.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Try it without a microphone") {
                    TextField("Type what you'd say…", text: $demoText)
                    Button("Send") {
                        viewModel.simulateUserSaid(demoText)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
