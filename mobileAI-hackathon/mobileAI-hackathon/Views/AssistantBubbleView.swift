import SwiftUI

struct AssistantBubbleView: View {
    let message: ChatMessage?
    let isListening: Bool
    let assistEnabled: Bool
    let onMicTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let message {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(.black)
                if let status = message.statusLine {
                    Text(status)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.black.opacity(0.55))
                }
            }

            HStack {
                Spacer()
                Button(action: onMicTap) {
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(isListening ? Color.red : Color.blue, in: Circle())
                }
                .disabled(!assistEnabled)
                .opacity(assistEnabled ? 1 : 0.4)
                .accessibilityLabel(isListening ? "Stop listening" : "Tell the assistant what you're trying to do")
            }
        }
        .padding(14)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.black.opacity(0.06)))
        .shadow(radius: 8, y: 4)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }
}
