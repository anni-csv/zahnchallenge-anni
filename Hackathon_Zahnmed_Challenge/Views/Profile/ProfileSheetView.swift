import SwiftUI

// MARK: - PROFILE SHEET
// Nickname fürs Ranking festlegen und Sichtbarkeit im Ranking steuern.
struct ProfileSheetView: View {
    @EnvironmentObject private var backend: BackendService
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var nickname = ""
    @State private var showInRanking = true
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var trimmedNickname: String {
        nickname.trimmingCharacters(in: .whitespaces)
    }

    private var isNicknameValid: Bool {
        trimmedNickname.range(of: "^[A-Za-z0-9_.-]{3,20}$", options: .regularExpression) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nickname", text: $nickname)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Toggle("Im Ranking anzeigen", isOn: $showInRanking)
                } header: {
                    Text("Ranking")
                } footer: {
                    Text("3–20 Zeichen: Buchstaben, Zahlen, _ . -  Andere sehen nur deinen Nickname und deine Punkte.")
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                    }
                }

                Section("Fortschritt") {
                    LabeledContent("Punkte", value: "\(appState.userScore)")
                    LabeledContent("Abgeschlossene Fälle",
                                   value: "\(appState.completedCaseIDs.count) / \(appState.cases.count)")
                }

                Section {
                    LabeledContent("Verbindung", value: statusText)
                } footer: {
                    Text("Dein Fortschritt wird anonym gespeichert. Anmeldung per E-Mail folgt, damit du ihn auf andere Geräte mitnehmen kannst.")
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Sichern", action: save)
                            .disabled(!isNicknameValid || !backend.isReady)
                    }
                }
            }
            .onAppear {
                nickname = backend.profile?.nickname ?? ""
                showInRanking = backend.profile?.showInRanking ?? true
            }
        }
    }

    private var statusText: String {
        switch backend.status {
        case .idle, .connecting: return "Verbinde…"
        case .ready:             return "Verbunden"
        case .failed:            return "Offline"
        }
    }

    private func save() {
        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await backend.updateProfile(nickname: trimmedNickname, showInRanking: showInRanking)
                dismiss()
            } catch {
                // 23505 = unique_violation in PostgreSQL
                errorMessage = "\(error)".contains("23505")
                    ? "Dieser Nickname ist schon vergeben."
                    : "Speichern fehlgeschlagen. Bitte später erneut versuchen."
            }
            isSaving = false
        }
    }
}
