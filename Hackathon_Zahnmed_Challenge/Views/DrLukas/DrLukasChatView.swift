import SwiftUI

// MARK: - DR. LUKAS CHAT
struct DrLukasChatView: View {
    enum Mode {
        /// Fragen stellen – zu einem Schritt (ohne Lösung) oder allgemein (step == nil)
        case ask(StepContext?)
        /// Nach dem Beantworten: Erklärung, warum die Antwort richtig/falsch ist
        case explain(StepContext)
    }

    let mode: Mode
    var patientCase: PatientCase? = nil
    var greetingName: String? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var messages: [DrLukasService.ChatMessage] = []
    @State private var input = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var inputFocused: Bool

    private var isExplain: Bool {
        if case .explain = mode { return true }
        return false
    }

    private var intro: String {
        switch mode {
        case .ask(.some):
            return "Frag mich alles zur aktuellen Aufgabe. Ich gebe dir Denkanstöße – die Lösung erkläre ich dir aber erst, wenn du geantwortet hast."
        case .ask(.none):
            let name = greetingName.map { " \($0)" } ?? ""
            return "Hallo\(name)! Ich bin Dr. Lukas. Frag mich zur Zahnmedizin, zu den Fällen oder zur App."
        case .explain:
            return "Schauen wir uns deine Antwort gemeinsam an."
        }
    }

    private var suggestions: [String] {
        switch mode {
        case .ask(.some):
            return ["Gib mir einen Denkanstoß", "Erklär mir die Fachbegriffe", "Worauf muss ich achten?"]
        case .ask(.none):
            return ["Wie funktioniert die App?", "Was bedeutet der PSI?", "Wie lerne ich Traumatologie am besten?"]
        case .explain:
            return ["Kannst du das einfacher erklären?", "Gibt es eine Eselsbrücke?"]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ChatBubble(role: .assistant, text: intro)
                        ForEach(messages) { message in
                            ChatBubble(role: message.role, text: message.text)
                        }
                        if isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Dr. Lukas denkt nach…")
                                    .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                            }
                            .padding(.leading, 44)
                        }
                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 13)).foregroundColor(.orange)
                                .padding(.leading, 44)
                        }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
                .onChange(of: isLoading) { _, _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }
            .background(Color(hex: "F9FAFB"))
            .safeAreaInset(edge: .bottom) { inputArea }
            .navigationTitle("Dr. Lukas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .task {
                // Im Erklär-Modus legt Dr. Lukas direkt los
                if isExplain && messages.isEmpty { await send(nil) }
            }
        }
    }

    private var inputArea: some View {
        VStack(spacing: 8) {
            if !isLoading && messages.filter({ $0.role == .user }).count < 2 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(suggestion) { Task { await send(suggestion) } }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "084B83"))
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(Color(hex: "EAFFFD")).clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            HStack(spacing: 10) {
                TextField("Frage an Dr. Lukas…", text: $input, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "E5E7EB"), lineWidth: 1))
                Button(action: { Task { await send(input) } }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(canSend ? Color(hex: "084B83") : Color(hex: "D1D5DB"))
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 16)
            Text("KI-Antworten können Fehler enthalten. Im Zweifel gilt der Expertenkommentar.")
                .font(.system(size: 10)).foregroundColor(Color(hex: "9CA3AF"))
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var canSend: Bool {
        !isLoading && !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Schickt eine Nachricht (oder im Erklär-Modus mit `nil` die erste Anfrage) an Dr. Lukas.
    private func send(_ text: String?) async {
        if let text {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            messages.append(.init(role: .user, text: trimmed))
            input = ""
        }
        isLoading = true
        errorMessage = nil
        do {
            let reply: String
            switch mode {
            case .ask(let step):
                reply = try await DrLukasService.ask(messages, about: step, in: patientCase)
            case .explain(let step):
                reply = try await DrLukasService.explain(messages, step: step, in: patientCase)
            }
            messages.append(.init(role: .assistant, text: reply))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Sprechblase
private struct ChatBubble: View {
    let role: DrLukasService.ChatMessage.Role
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if role == .assistant {
                Image("dr_lukas").resizable().scaledToFill()
                    .frame(width: 36, height: 36).clipShape(Circle())
                    .background(Circle().fill(Color(hex: "C9F0FF")))
            } else {
                Spacer(minLength: 44)
            }
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(role == .assistant ? Color(hex: "0B1C30") : .white)
                .lineSpacing(3)
                .padding(12)
                .background(role == .assistant ? Color.white : Color(hex: "084B83"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(role == .assistant ? Color(hex: "E5E7EB") : .clear, lineWidth: 1))
                .textSelection(.enabled)
            if role == .assistant { Spacer(minLength: 24) }
        }
        .frame(maxWidth: .infinity, alignment: role == .assistant ? .leading : .trailing)
    }
}
