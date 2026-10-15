import SwiftUI
import UniformTypeIdentifiers
import Combine


class NavState: ObservableObject {
    @Published var rootID = UUID()
    func goHome() { rootID = UUID() }
}

// Note: Color extension and AppState are defined in ZahnChallenge_Backend.swift

// MARK: - PERSISTENT BOTTOM BAR
struct PersistentBottomBar: View {
    @EnvironmentObject var navState: NavState
    var body: some View {
        HStack(spacing: 0) {
            PersistentBarItem(icon: "house.fill",        label: "Startseite", active: false, action: { navState.goHome() })
            PersistentBarItem(icon: "trophy.fill",       label: "Ranking",    active: false, action: {})
            PersistentBarItem(icon: "bubble.left.fill",  label: "Chat",       active: false, action: {})
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .top)
    }
}

private struct PersistentBarItem: View {
    let icon: String
    let label: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20))
                Text(label).font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(active ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func withPersistentBottomBar() -> some View {
        self.safeAreaInset(edge: .bottom, spacing: 0) {
            PersistentBottomBar()
        }
    }
}

// MARK: - ROOT VIEW
struct ContentView: View {
    @StateObject private var state = AppState()
    @StateObject private var navState = NavState()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        TopBarView()
                        SearchBarView()
                        CategoryPillsView(state: state)
                        HeroBannerView()
                        NavigationLink(destination: ModelOverviewView()){
                            Modell3DButtonView()
                        }
                        .padding(.horizontal, 16)
                        CasesSectionView(state: state)
                        Spacer(minLength: 120)
                    }
                }
                BottomNavView(state: state)
            }
            .background(Color(hex: "F9FAFB"))
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $state.showAvatarSheet) {
                AvatarSheetView()
                    .presentationDetents([.fraction(0.55)])
                    .presentationCornerRadius(24)
            }
        }
        .environmentObject(navState)
        .id(navState.rootID)
    }
}

// MARK: - TOP BAR
struct TopBarView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Willkommen zurück")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6B7280"))
                Text("Max Mustermann")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "084B83"))
            }
            Spacer()
            ZStack {
                Circle().fill(Color(hex: "084B83")).frame(width: 44, height: 44)
                Image(systemName: "bell.fill").foregroundColor(.white).font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }
}

// MARK: - SEARCH BAR
struct SearchBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "727781"))
                    .padding(.leading, 12)
                Text("Fall suchen...")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6B7280"))
                Spacer()
            }
            .frame(height: 44)
            .background(Color(hex: "F3F4F6"))
            .clipShape(Capsule())

            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Color(hex: "084B83"))
                    .frame(width: 44, height: 44)
                    .overlay(Capsule().stroke(Color(hex: "727781"), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - CATEGORY PILLS
struct CategoryPillsView: View {
    @ObservedObject var state: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(state.categories, id: \.self) { cat in
                    Button(action: { state.selectedCategory = cat }) {
                        Text(cat)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(state.selectedCategory == cat ? .white : Color(hex: "084B83"))
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(state.selectedCategory == cat ? Color(hex: "084B83") : .white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: "084B83"),
                                     lineWidth: state.selectedCategory == cat ? 0 : 1))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - HERO BANNER
struct HeroBannerView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color(hex: "084B83"), Color(hex: "1A6FBA")],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 160)
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 240, y: 20)
            HStack(alignment: .bottom, spacing: 0) {
                Image("dr_lukas")
                    .resizable().scaledToFit()
                    .frame(width: 110, height: 140).clipped()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Jetzt lernen &\nPunkte sammeln!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white).lineSpacing(2)
                    Text("3 interaktive Patientenfälle\nwarten auf dich")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.9))
                    Button(action: {}) {
                        Text("Los geht\'s")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "084B83"))
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(.white).clipShape(Capsule())
                    }
                }
                .padding(.leading, 12).padding(.bottom, 20)
                Spacer()
            }
        }
        .frame(height: 160)
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - CASES SECTION
struct CasesSectionView: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Patientenfälle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30"))
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Alle sehen").font(.system(size: 14, weight: .medium))
                        Image(systemName: "arrow.right").font(.system(size: 11))
                    }
                    .foregroundColor(Color(hex: "084B83"))
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(state.cases) { patientCase in
                        NavigationLink(destination: CaseDetailView(patientCase: patientCase)) {
                            CaseCardView(patientCase: patientCase)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 8)
            }
        }
    }
}

// MARK: - CASE CARD
struct CaseCardView: View {
    let patientCase: PatientCase

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [patientCase.gradientStart, patientCase.gradientEnd],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 96)
                Image(systemName: patientCase.sfSymbol)
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.white.opacity(0.75))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if let badge = patientCase.badge,
                   let badgeBG = patientCase.badgeBG,
                   let badgeText = patientCase.badgeText {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badgeText)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(badgeBG).clipShape(Capsule()).padding(8)
                }
            }
            .frame(height: 96)

            VStack(alignment: .leading, spacing: 5) {
                Text(patientCase.category)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "727781")).tracking(0.5)
                Text(patientCase.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1C30")).lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= patientCase.difficulty ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(i <= patientCase.difficulty
                                             ? patientCase.starColor : Color(hex: "D1D5DB"))
                    }
                    Text(patientCase.difficultyLabel)
                        .font(.system(size: 11)).foregroundColor(Color(hex: "727781"))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E5E7EB")).frame(height: 5)
                        RoundedRectangle(cornerRadius: 4).fill(Color(hex: "084B83"))
                            .frame(width: max(geo.size.width * patientCase.progress, 0), height: 5)
                    }
                }.frame(height: 5)
                HStack {
                    Spacer()
                    Text("\(Int(patientCase.progress * Double(patientCase.totalSteps))) / \(patientCase.totalSteps) Schritte")
                        .font(.system(size: 10)).foregroundColor(Color(hex: "9CA3AF"))
                }
            }
            .padding(12)
        }
        .frame(width: 200).background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "084B83").opacity(0.08), radius: 8, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "EFF4FF"), lineWidth: 1))
    }
}

// MARK: - BOTTOM NAV
struct BottomNavView: View {
    @ObservedObject var state: AppState

    var body: some View {
        HStack {
            Spacer()
            Button(action: { state.selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: "house.fill").font(.system(size: 20))
                    Text("Startseite").font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(state.selectedTab == 0 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(state.selectedTab == 0 ? Color(hex: "C9F0FF") : .clear)
                .clipShape(Capsule())
            }
            Spacer()
            Button(action: { state.selectedTab = 1 }) {
                VStack(spacing: 4) {
                    Image(systemName: "trophy.fill").font(.system(size: 20))
                    Text("Ranking").font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(state.selectedTab == 1 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
            }
            Spacer()
            ZStack(alignment: .top) {
                Button(action: { state.selectedTab = 2 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill").font(.system(size: 20))
                        Text("Chat").font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(state.selectedTab == 2 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                }
                .padding(.top, 30)

                Button(action: { state.showAvatarSheet = true }) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(Color(hex: "084B83"))
                            .frame(width: 50, height: 50)
                            .shadow(color: Color(hex: "084B83").opacity(0.35), radius: 8, y: 3)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .overlay(
                                Image("dr_lukas").resizable().scaledToFill()
                                    .frame(width: 46, height: 46).clipShape(Circle())
                            )
                        Circle().fill(Color.red).frame(width: 16, height: 16)
                            .overlay(Text("1").font(.system(size: 9, weight: .bold)).foregroundColor(.white))
                            .offset(x: 2, y: -2)
                    }
                }
                .offset(y: -28)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(.white)
        .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
    }
}

// MARK: - AVATAR SHEET
struct AvatarSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color(hex: "E5E7EB")).frame(width: 40, height: 4).padding(.top, 12)
            HStack(spacing: 12) {
                Circle().fill(Color(hex: "C9F0FF")).frame(width: 52, height: 52)
                    .overlay(Image("dr_lukas").resizable().scaledToFill()
                        .frame(width: 48, height: 48).clipShape(Circle()))
                VStack(alignment: .leading) {
                    Text("Dr. Lukas").font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("Dein persönlicher Lernassistent").font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 24))
                        .foregroundColor(Color(hex: "D1D5DB"))
                }
            }
            .padding(.horizontal, 20)
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(hex: "C9F0FF"))
                    Text("Hallo Max! Ich bin Dr. Lukas.\nSoll ich dir die App kurz erklären?")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "084B83")).padding(14)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            VStack(spacing: 10) {
                Button(action: { dismiss() }) {
                    Text("Ja, zeig mir alles!")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color(hex: "084B83")).clipShape(Capsule())
                }
                Button(action: { dismiss() }) {
                    Text("Ich kenne mich aus, danke!")
                        .font(.system(size: 15, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .overlay(Capsule().stroke(Color(hex: "084B83"), lineWidth: 1.5))
                }
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(["Fall 1 starten", "Was sind Badges?", "Mein Fortschritt"], id: \.self) { chip in
                        Label(chip, systemImage: chip == "Fall 1 starten" ? "play.circle"
                              : chip == "Was sind Badges?" ? "questionmark.circle" : "chart.bar")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "084B83"))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color(hex: "EAFFFD")).clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
}

// MARK: - CASE DETAIL
struct CaseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    let patientCase: PatientCase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [patientCase.gradientStart, patientCase.gradientEnd],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 20))
                    Image(systemName: patientCase.sfSymbol)
                        .font(.system(size: 72, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center).padding(.bottom, 30)
                    HStack {
                        Label("Notfall", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.red.opacity(0.85)).clipShape(Capsule())
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(1...3, id: \.self) { i in
                                Image(systemName: i <= patientCase.difficulty ? "star.fill" : "star")
                                    .font(.system(size: 11))
                                    .foregroundColor(i <= patientCase.difficulty ? .yellow : .white.opacity(0.4))
                            }
                            Text(patientCase.difficultyLabel)
                                .font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.black.opacity(0.25)).clipShape(Capsule())
                    }
                    .padding(12)
                }
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(Color(hex: "084B83")).font(.system(size: 20))
                        VStack(alignment: .leading) {
                            Text("Ignaz Grünzinger")
                                .font(.system(size: 17, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                            Text("23 Jahre | Maurergeselle")
                                .font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                        }
                    }
                    Divider()
                    Text("\"Ich bin über eine Gehwegplatte gestolpert und mit dem Gesicht gegen einen Blumentopf gefallen. Sofort spürte ich starken Schmerz in den Schneidezähnen.\"")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "374151"))
                        .italic().lineSpacing(4)
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Label("Notdienst 23:00", systemImage: "clock.fill")
                        Label("Obere Schneidezähne", systemImage: "mouth.fill")
                        Label("Rettungsdienst", systemImage: "cross.fill")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "084B83")).padding(.horizontal, 16)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Fallverlauf")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).padding(.horizontal, 16)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array([
                                "Anamnese","Konsilium","Aufbewahrung",
                                "Untersuchung","Diagnose","Therapie","MCQ","Upload"
                            ].enumerated()), id: \.0) { i, step in
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(i == 0 ? Color(hex: "084B83") : Color(hex: "E5E7EB"))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Text("\(i+1)")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(i == 0 ? .white : Color(hex: "9CA3AF"))
                                        )
                                    Text(step).font(.system(size: 9))
                                        .foregroundColor(i == 0 ? Color(hex: "084B83") : Color(hex: "9CA3AF"))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                NavigationLink(destination: Step1FreeTextView()) {
                    Text("Fall starten")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "084B83").opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
            .padding(.top, 16)
        }
        .navigationTitle(patientCase.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .withPersistentBottomBar()
    }
}

// MARK: - REUSABLE: Progress Bar
struct ProgressBarView: View {
    let step: Int
    let total: Int
    let score: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Schritt \(step) von \(total)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "084B83"))
                Spacer()
                if score > 0 {
                    Text("+\(score) Punkte")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                } else {
                    Text("\(score) Punkte")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "9CA3AF"))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color(hex: "E5E7EB")).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Color(hex: "084B83"))
                        .frame(width: geo.size.width * (Double(step) / Double(total)), height: 6)
                }
            }.frame(height: 6)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - REUSABLE: Dr. Lukas Hint
struct DrLukasHintView: View {
    let text: String
    @State private var showHint = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { showHint.toggle() } }) {
                HStack(spacing: 8) {
                    Circle().fill(Color(hex: "C9F0FF")).frame(width: 30, height: 30)
                        .overlay(Image("dr_lukas").resizable().scaledToFill()
                            .frame(width: 28, height: 28).clipShape(Circle()))
                    Text("Dr. Lukas hat einen Tipp")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "084B83"))
                    Spacer()
                    Image(systemName: showHint ? "chevron.up" : "chevron.right")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "084B83"))
                }
                .padding(14)
            }
            if showHint {
                Text(text)
                    .font(.system(size: 13)).foregroundColor(Color(hex: "084B83"))
                    .padding([.horizontal, .bottom], 14)
            }
        }
        .background(Color(hex: "EAFFFD"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

// MARK: - REUSABLE: Expert Comment Card
struct ExpertCommentView: View {
    let score: Int
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "stethoscope").font(.system(size: 14))
                        .foregroundColor(Color(hex: "084B83"))
                    Text("Dr. Zahnix kommentiert")
                        .font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                }
                Spacer()
                if score > 0 {
                    Text("+\(score) Punkte 🎯")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "166534"))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: "CAFFBF")).clipShape(Capsule())
                }
            }
            Text(text).font(.system(size: 13)).foregroundColor(Color(hex: "374151")).lineSpacing(4)
        }
        .padding(14)
        .background(Color(hex: "EAFFFD"))
        .overlay(HStack { Rectangle().fill(Color(hex: "084B83")).frame(width: 3); Spacer() })
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color(hex: "084B83").opacity(0.06), radius: 6, y: 2)
    }
}

// MARK: - REUSABLE: QuestionCardView
private struct QuestionCardView: View {
    let badge: String
    let badgeIcon: String
    let badgeColor: Color
    let typeLabel: String
    let question: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(badge, systemImage: badgeIcon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "084b83"))
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(badgeColor).clipShape(Capsule())
                Spacer()
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(typeLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "727781")).tracking(0.8)
                Text(question)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "084b83")).lineSpacing(4)
                Text(subtitle)
                    .font(.system(size: 13)).foregroundColor(Color(hex: "424750"))
            }
            .padding(20).background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "084b83").opacity(0.08), radius: 12, y: 4)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - REUSABLE: ConfirmButton
private struct ConfirmButton: View {
    let title: String
    let icon: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 16, weight: .bold))
                Image(systemName: icon)
            }
            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(enabled ? Color(hex: "084b83") : Color(hex: "9CA3AF"))
            .clipShape(RoundedRectangle(cornerRadius: 50))
            .shadow(color: Color(hex: "084b83").opacity(enabled ? 0.3 : 0), radius: 8, y: 4)
            .scaleEffect(enabled ? 1.0 : 0.97)
        }
        .disabled(!enabled)
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.3), value: enabled)
    }
}

private func confirmButtonLabel(title: String, icon: String) -> some View {
    HStack(spacing: 8) {
        Text(title).font(.system(size: 16, weight: .bold))
        Image(systemName: icon)
    }
    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
    .background(Color(hex: "084b83"))
    .clipShape(RoundedRectangle(cornerRadius: 50))
    .shadow(color: Color(hex: "084b83").opacity(0.3), radius: 8, y: 4)
}

// MARK: - Step7NavBar
private struct Step7NavBar: View {
    enum Tab { case cases, learn, progress, profile }
    @Binding var selected: Tab

    var body: some View {
        HStack(spacing: 0) {
            navItem(icon: "list.clipboard.fill", label: "Fälle",       tab: .cases)
            navItem(icon: "book.fill",           label: "Lernen",      tab: .learn)
            navItem(icon: "chart.bar.fill",      label: "Fortschritt", tab: .progress)
            navItem(icon: "person.fill",         label: "Profil",      tab: .profile)
        }
        .padding(.horizontal, 8).padding(.vertical, 8)
        .background(Color(hex: "f8f9ff"))
        .shadow(color: Color(hex: "084b83").opacity(0.08), radius: 10, y: -4)
    }

    @ViewBuilder
    func navItem(icon: String, label: String, tab: Tab) -> some View {
        let isActive = selected == tab
        Button(action: { selected = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 22))
                Text(label).font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(isActive ? Color(hex: "084b83") : Color(hex: "424750"))
            .frame(maxWidth: .infinity).padding(.vertical, 6)
            .background(isActive ? Color(hex: "a5d8ff").opacity(0.6) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - STEP 1: FREITEXT
struct Step1FreeTextView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var inputText = ""
    
    private let relevantKeywords = [
        "anamnese", "bewusstsein", "neurolog", "mkg",
        "untersuch", "schmerz", "blutung", "kopf",
        "zahn", "fraktur", "avulsion", "sturz", "fragen", "ct", "mrt"
    ]

    private var wordCount: Int {
        inputText.split(whereSeparator: \.isWhitespace).count
    }

    private var matchedKeywords: [String] {
        let normalizedText = inputText.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: .current
        )

        return relevantKeywords.filter { normalizedText.contains($0) }
    }

    private var isAnswerValid: Bool {
        wordCount >= 6 && matchedKeywords.count >= 2
    }

    private var validationMessage: String? {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        if wordCount < 6 {
            return "Formuliere bitte mindestens sechs Wörter."
        }

        if matchedKeywords.count < 2 {
            return "Interessanter Ansatz. Vergleiche deine Überlegungen noch mit dem Hinweis von Dr. Lukas, bevor du weitergehst."
        }

        return "Gute erste Einschätzung – du kannst fortfahren."
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 1, total: 8, score: 0)

                Label("Erste Gedanken", systemImage: "text.bubble")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "FFD6A5")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 10) {
                    Text("OFFENE FRAGE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Bevor Sie den Patienten untersuchen – welche Gedanken gehen Ihnen durch den Kopf?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Denken Sie laut nach. Es gibt keine falsche Antwort.")
                        .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $inputText)
                        .frame(height: 140).padding(12)
                        .background(Color(hex: "F9FAFB"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(inputText.isEmpty ? Color(hex: "E5E7EB") : Color(hex: "A5D8FF"),
                                    lineWidth: 1.5))
                    if inputText.isEmpty {
                        Text("Ihre Überlegungen hier eingeben...")
                            .foregroundColor(Color(hex: "9CA3AF")).font(.system(size: 14)).italic()
                            .padding(20).allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 16)

                Text("\(inputText.count) / 300")
                    .font(.system(size: 11)).foregroundColor(Color(hex: "9CA3AF"))
                    .frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal, 16)
                
                if let validationMessage {
                    Label(
                        validationMessage,
                        systemImage: isAnswerValid
                            ? "checkmark.circle.fill"
                            : "exclamationmark.circle.fill"
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isAnswerValid ? .green : .orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }

                DrLukasHintView(text: "Denken Sie nicht nur an Zähne – der Patient hatte einen Sturz am Kopf! An Neurologie und MKG-Chirurgie denken. Was sollten Sie bei dem Patienten anordnen")

                NavigationLink(destination: Step2MCQView()) {
                    Text("Weiter")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(inputText.isEmpty ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(inputText.isEmpty)
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 1 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .withPersistentBottomBar()
    }
}

// MARK: - STEP 2: MCQ
struct Step2MCQView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selectedAnswer: Int? = nil
    @State private var submitted = false
    let options = ["MKG-Chirurgie & Neurologie", "Urologie", "Kardiologie", "Dermatologie"]
    let correctIndex = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 2, total: 8, score: submitted ? 10 : 0)

                Label("Konsilium", systemImage: "person.2.fill")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "C9F0FF")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 8) {
                    Text("SINGLE CHOICE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Welche Fachrichtungen sollten Sie konsiliarisch hinzuziehen?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Eine Antwort ist richtig")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(0..<options.count, id: \.self) { i in
                        Button(action: { if !submitted { selectedAnswer = i } }) {
                            HStack {
                                Text(options[i])
                                    .font(.system(size: 15,
                                                  weight: selectedAnswer == i ? .semibold : .regular))
                                    .foregroundColor(Color(hex: "0B1C30"))
                                Spacer()
                                if submitted {
                                    Image(systemName: i == correctIndex
                                          ? "checkmark.circle.fill"
                                          : (selectedAnswer == i ? "xmark.circle.fill" : "circle"))
                                        .foregroundColor(i == correctIndex ? .green
                                                         : (selectedAnswer == i ? .red
                                                            : Color(hex: "E5E7EB")))
                                }
                            }
                            .padding(16)
                            .background(answerBG(i))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(answerBorder(i), lineWidth: selectedAnswer == i ? 2 : 1))
                        }
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    NavigationLink(destination: Step3SortingView()) {
                        Text("Weiter →")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16)
                } else {
                    Button(action: { if !submitted { withAnimation { submitted = true } } }) {
                        Text("Antwort bestätigen")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(selectedAnswer == nil ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selectedAnswer == nil)
                    .padding(.horizontal, 16).padding(.bottom, 30)
                }
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 2 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .withPersistentBottomBar()
    }

    func answerBG(_ i: Int) -> Color {
        if !submitted { return selectedAnswer == i ? Color(hex: "A5D8FF") : .white }
        if i == correctIndex { return Color(hex: "CAFFBF") }
        if selectedAnswer == i { return Color(hex: "FFD6D6") }
        return .white
    }
    func answerBorder(_ i: Int) -> Color {
        if !submitted { return selectedAnswer == i ? Color(hex: "084B83") : Color(hex: "E5E7EB") }
        if i == correctIndex { return .green }
        if selectedAnswer == i { return .red }
        return Color(hex: "E5E7EB")
    }
}

// MARK: - STEP 3: SORTING
struct SortItem: Identifiable {
    let id: UUID
    let label: String
    let correctRank: Int
}

struct Step3SortingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var items: [SortItem] = [
        SortItem(id: UUID(), label: "Zahnrettungsbox (Dentosafe)", correctRank: 1),
        SortItem(id: UUID(), label: "Sterile Kochsalzlösung",     correctRank: 2),
        SortItem(id: UUID(), label: "Haltbare Milch",              correctRank: 3),
        SortItem(id: UUID(), label: "Mundspeichel",                correctRank: 4),
        SortItem(id: UUID(), label: "Leitungswasser",              correctRank: 5),
        SortItem(id: UUID(), label: "Luft / Trocken",              correctRank: 6),
    ].shuffled()
    @State private var submitted = false
    @State private var score = 0
    @State private var dragging: SortItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 3, total: 8, score: score)

                Label("Aufbewahrung", systemImage: "cross.case.fill")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "C9F0FF")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 8) {
                    Text("SORTIERAUFGABE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Bringen Sie folgende Medien zur Aufbewahrung eines avulsierten Zahnes in die richtige Reihenfolge – beginnend mit der BESTEN.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Ziehen Sie die Karten oder nutzen Sie die Pfeile.")
                        .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(items) { item in
                        SortRowView(
                            item: item, rank: rankOf(item),
                            submitted: submitted, isCorrect: isCorrect(item),
                            onMoveUp: { moveUp(item) }, onMoveDown: { moveDown(item) }
                        )
                        .onDrag { dragging = item; return NSItemProvider(object: item.id.uuidString as NSString) }
                        .onDrop(of: [.text], delegate: SortDropDelegate(item: item, items: $items, dragging: $dragging))
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    ExpertCommentView(
                        score: score,
                        text: "Die Zahnrettungsbox ist die erste Wahl! Milch und Kochsalzlösung sind gute Alternativen. Leitungswasser und Luft schädigen die Wurzelhaut."
                    )
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                DrLukasHintView(text: "Die Zahnrettungsbox enthält eine spezielle Nährlösung, die die Parodontalzellen am Leben erhält – ähnlich wie ein Organ-Transportmedium.")

                if !submitted {
                    Button(action: submitAnswer) {
                        HStack(spacing: 8) {
                            Text("Reihenfolge bestätigen").font(.system(size: 16, weight: .bold))
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "084B83").opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 16).padding(.bottom, 8)
                } else {
                    NavigationLink(destination: Step4DiagnosisView()) {
                        HStack(spacing: 8) {
                            Text("Weiter").font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16).padding(.bottom, 30)
                }
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 3 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }

    private func rankOf(_ item: SortItem) -> Int {
        (items.firstIndex(where: { $0.id == item.id }) ?? 0) + 1
    }
    private func isCorrect(_ item: SortItem) -> Bool { rankOf(item) == item.correctRank }
    private func moveUp(_ item: SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx > 0 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx - 1) }
    }
    private func moveDown(_ item: SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx < items.count - 1 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx + 1) }
    }
    private func submitAnswer() {
        let correct = items.filter { isCorrect($0) }.count
        score = correct == 6 ? 15 : correct >= 4 ? 10 : correct >= 2 ? 5 : 0
        withAnimation { submitted = true }
    }
}

struct SortRowView: View {
    let item: SortItem
    let rank: Int
    let submitted: Bool
    let isCorrect: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var borderColor: Color { !submitted ? Color(hex: "E5E7EB") : (isCorrect ? .green : .red) }
    var bgColor: Color     { !submitted ? .white : (isCorrect ? Color(hex: "CAFFBF") : Color(hex: "FFD6D6")) }
    var rankBgColor: Color { !submitted ? Color(hex: "E5E7EB") : (isCorrect ? .green : .red) }
    var rankTextColor: Color { !submitted ? Color(hex: "6B7280") : .white }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: submitted ? (isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill") : "line.3.horizontal")
                .foregroundColor(submitted ? (isCorrect ? .green : .red) : Color(hex: "9CA3AF"))
                .font(.system(size: 18))
            ZStack {
                Circle().fill(rankBgColor).frame(width: 26, height: 26)
                Text("\(rank)").font(.system(size: 12, weight: .bold)).foregroundColor(rankTextColor)
            }
            Text(item.label)
                .font(.system(size: 14, weight: submitted ? .semibold : .regular))
                .foregroundColor(Color(hex: submitted ? "0B1C30" : "374151"))
                .frame(maxWidth: .infinity, alignment: .leading)
            if submitted && !isCorrect {
                Text("→ \(item.correctRank)")
                    .font(.system(size: 11, weight: .bold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color(hex: "C9F0FF")).clipShape(Capsule())
            }
            if !submitted {
                VStack(spacing: 0) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up").font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "084B83")).frame(width: 28, height: 22)
                    }
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down").font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "084B83")).frame(width: 28, height: 22)
                    }
                }
            }
        }
        .padding(.horizontal, 12).frame(height: 52)
        .background(bgColor).clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: 1.5))
        .animation(.easeInOut(duration: 0.25), value: submitted)
    }
}

struct SortDropDelegate: DropDelegate {
    let item: SortItem
    @Binding var items: [SortItem]
    @Binding var dragging: SortItem?
    func performDrop(info: DropInfo) -> Bool { dragging = nil; return true }
    func dropEntered(info: DropInfo) {
        guard let dragging, dragging.id != item.id,
              let fromIdx = items.firstIndex(where: { $0.id == dragging.id }),
              let toIdx   = items.firstIndex(where: { $0.id == item.id })
        else { return }
        withAnimation(.spring(response: 0.3)) {
            items.move(fromOffsets: IndexSet(integer: fromIdx),
                       toOffset: toIdx > fromIdx ? toIdx + 1 : toIdx)
        }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
}

// MARK: - STEP 4: Multiple Choice – Sofortmaßnahmen
struct Step4DiagnosisView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selectedImages: Set<Int> = []
    @State private var submitted = false
    let imageOptions = [
        (id: 0, label: "Replantation sofort", icon: "arrow.uturn.left.circle"),
        (id: 1, label: "Extraktion",           icon: "minus.circle"),
        (id: 2, label: "Schienung anlegen",    icon: "bandage"),
        (id: 3, label: "Röntgen anordnen",     icon: "rays"),
    ]
    let correctIDs: Set<Int> = [0, 2, 3]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 4, total: 8, score: submitted ? 10 : 0)

                Label("Untersuchung", systemImage: "eye")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "084B83"))
                    .padding(.horizontal, 16).padding(.vertical, 7)
                    .background(Color(hex: "B5EAD7")).clipShape(Capsule())

                VStack(alignment: .leading, spacing: 8) {
                    Text("MULTIPLE CHOICE").font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "9CA3AF")).tracking(0.8)
                    Text("Welche Maßnahmen leiten Sie sofort ein?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83")).lineSpacing(4)
                    Text("Mehrere Antworten sind möglich.")
                        .font(.system(size: 13)).foregroundColor(Color(hex: "6B7280"))
                }
                .padding(16).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 8, y: 3)
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(imageOptions, id: \.id) { opt in
                        let isSel  = selectedImages.contains(opt.id)
                        let isRight = submitted && correctIDs.contains(opt.id)
                        let isWrong = submitted && isSel && !correctIDs.contains(opt.id)
                        Button(action: {
                            if !submitted {
                                if isSel { selectedImages.remove(opt.id) }
                                else     { selectedImages.insert(opt.id) }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: opt.icon).font(.system(size: 22))
                                    .foregroundColor(isRight ? .green : (isWrong ? .red : Color(hex: "084B83")))
                                    .frame(width: 36, height: 36)
                                    .background(isRight ? Color(hex: "CAFFBF") : (isWrong ? Color(hex: "FFD6D6") : Color(hex: "EFF4FF")))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                Text(opt.label)
                                    .font(.system(size: 15, weight: isSel ? .semibold : .regular))
                                    .foregroundColor(isRight ? Color(hex: "166534") : (isWrong ? Color(hex: "93000a") : Color(hex: "0B1C30")))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: submitted
                                      ? (isRight ? "checkmark.circle.fill" : (isWrong ? "xmark.circle.fill" : "circle"))
                                      : (isSel ? "checkmark.circle.fill" : "circle"))
                                    .foregroundColor(isSel ? Color(hex: "084B83") : Color(hex: "D1D5DB"))
                            }
                            .padding(14)
                            .background(isRight ? Color(hex: "CAFFBF") : (isWrong ? Color(hex: "FFD6D6") : (isSel ? Color(hex: "EFF4FF") : .white)))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(isRight ? Color.green : (isWrong ? Color.red : (isSel ? Color(hex: "084B83") : Color(hex: "E5E7EB"))),
                                        lineWidth: isSel ? 2 : 1.5))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    ExpertCommentView(score: 10,
                        text: "Replantation so schnell wie möglich! Die Schiene stabilisiert den Zahn. Röntgen zur Verlaufskontrolle ist Pflicht.")
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                DrLukasHintView(text: "Zeit ist entscheidend: Je schneller replantiert wird, desto besser die Prognose für das Parodont!")

                if !submitted {
                    Button(action: { withAnimation { submitted = true } }) {
                        HStack(spacing: 8) {
                            Text("Antwort bestätigen").font(.system(size: 16, weight: .bold))
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(selectedImages.isEmpty ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selectedImages.isEmpty)
                    .padding(.horizontal, 16).padding(.bottom, 8)
                } else {
                    NavigationLink(destination: Step5DiagnosisView()) {
                        HStack(spacing: 8) {
                            Text("Weiter").font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color(hex: "084B83")).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16).padding(.bottom, 30)
                }
                Spacer(minLength: 20)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 4 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB"))
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
}

// MARK: - STEP 5: Diagnose-Zuordnung
struct Step5DiagnosisView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selections: [String: String] = [:]
    @State private var submitted = false
    let teeth = ["11", "12", "21", "22"]
    let diagnoses = [
        "Komplette Avulsion", "Laterale Dislokation",
        "Kronenfraktur mit Pulpabeteiligung", "Keine Verletzung"
    ]
    let correct: [String: String] = [
        "11": "Komplette Avulsion",        "12": "Laterale Dislokation",
        "21": "Kronenfraktur mit Pulpabeteiligung", "22": "Keine Verletzung"
    ]
    var allSelected: Bool { teeth.allSatisfy { selections[$0] != nil } }
    var score: Int { teeth.filter { selections[$0] == correct[$0] }.count * 3 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 5, total: 8, score: submitted ? score : 0)

                QuestionCardView(
                    badge: "Diagnose", badgeIcon: "stethoscope",
                    badgeColor: Color(hex: "FFD6A5"), typeLabel: "ZUORDNUNGSAUFGABE",
                    question: "Ordnen Sie jedem Zahn die richtige Diagnose zu.",
                    subtitle: "Wählen Sie pro Zahn eine Diagnose aus dem Dropdown."
                )

                VStack(spacing: 12) {
                    ForEach(teeth, id: \.self) { tooth in
                        ToothRowView(tooth: tooth, selection: $selections,
                                     diagnoses: diagnoses, correct: correct, submitted: submitted)
                    }
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(diagnoses.enumerated()), id: \.offset) { i, d in
                            Text(d)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(i == 0 ? .white : Color(hex: "0b1c30"))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(i == 0 ? Color(hex: "00345f") : Color(hex: "2e6385"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                }

                if submitted {
                    ExpertCommentView(score: score,
                        text: "Waren Sie sich bei den Zähnen 12 und 22 nicht sicher? Gerade bei nicht kieferorthopädisch vorbehandelten Patienten ist es schwer, laterale Dislokationen zu identifizieren.")
                }

                DrLukasHintView(text: "Beachte den Unfallmechanismus: der Patient fiel auf die rechte Gesichtshälfte. Zahn 12 hat deshalb mit hoher Wahrscheinlichkeit etwas abbekommen!")

                if submitted {
                    NavigationLink(destination: Step6SortingTherapyView()) {
                        confirmButtonLabel(title: "Weiter", icon: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                } else {
                    ConfirmButton(title: "Diagnosen bestätigen", icon: "checkmark.circle.fill",
                                  enabled: allSelected) {
                        withAnimation(.easeInOut) { submitted = true }
                    }
                }
                Spacer(minLength: 80)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 5 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
}

private struct ToothRowView: View {
    let tooth: String
    @Binding var selection: [String: String]
    let diagnoses: [String]
    let correct: [String: String]
    let submitted: Bool
    var sel: String?  { selection[tooth] }
    var isRight: Bool { submitted && sel == correct[tooth] }
    var isWrong: Bool { submitted && sel != nil && sel != correct[tooth] }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color(hex: "00345f").opacity(sel != nil ? 1.0 : 0.8))
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(
                        submitted ? (isRight ? Color.green : (isWrong ? Color.red : Color.clear)) : Color.clear,
                        lineWidth: 2.5))
                Text(tooth).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                if submitted {
                    Text(sel ?? "–").font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isRight ? .green : .red)
                    if isWrong {
                        Text("Richtig: \(correct[tooth] ?? "")").font(.system(size: 11))
                            .foregroundColor(Color(hex: "00345f"))
                    }
                } else {
                    Menu {
                        ForEach(diagnoses, id: \.self) { d in
                            Button(d) { selection[tooth] = d }
                        }
                    } label: {
                        HStack {
                            Text(sel ?? "Diagnose wählen...").font(.system(size: 14))
                                .foregroundColor(sel != nil ? Color(hex: "00345f") : Color(hex: "727781"))
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down").font(.system(size: 11))
                                .foregroundColor(Color(hex: "727781"))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(sel != nil ? Color(hex: "f8f9ff") : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(sel != nil ? Color(hex: "00345f") : Color(hex: "727781"), lineWidth: 1.5))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            if submitted {
                Image(systemName: isRight ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isRight ? .green : .red).font(.system(size: 20))
            }
        }
        .padding(12)
        .background(submitted ? (isRight ? Color(hex: "CAFFBF") : Color(hex: "FFD6D6")) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(submitted ? (isRight ? Color.green : Color.red) : Color(hex: "727781"), lineWidth: 1.5))
        .shadow(color: Color(hex: "00345f").opacity(0.06), radius: 8, y: 2)
    }
}

// MARK: - STEP 6: Repositionierung
struct Step6SortItem: Identifiable {
    let id: UUID; let label: String; let correctRank: Int
}
struct Step6DropDelegate: DropDelegate {
    let item: Step6SortItem
    @Binding var items: [Step6SortItem]
    @Binding var dragging: Step6SortItem?
    func performDrop(info: DropInfo) -> Bool { dragging = nil; return true }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
    func dropEntered(info: DropInfo) {
        guard let dragging, dragging.id != item.id,
              let from = items.firstIndex(where: { $0.id == dragging.id }),
              let to   = items.firstIndex(where: { $0.id == item.id })
        else { return }
        withAnimation(.spring(response: 0.3)) {
            items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }
}

struct Step6SortingTherapyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var items: [Step6SortItem] = {
        [
            Step6SortItem(id: UUID(), label: "Kurzes Einlegen in Dentosafe-Box",  correctRank: 1),
            Step6SortItem(id: UUID(), label: "Repositionierung in die Alveole",   correctRank: 2),
            Step6SortItem(id: UUID(), label: "Anlage eines Titan-Trauma-Splints", correctRank: 3)
        ].shuffled()
    }()
    @State private var submitted = false
    @State private var dragging: Step6SortItem?
    @State private var activeID: UUID? = nil
    var allCorrect: Bool { items.enumerated().allSatisfy { $0.element.correctRank == $0.offset + 1 } }
    var score: Int { allCorrect ? 15 : 5 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressBarView(step: 6, total: 8, score: submitted ? score : 0)

                QuestionCardView(
                    badge: "Therapie", badgeIcon: "arrow.up.arrow.down.circle.fill",
                    badgeColor: Color(hex: "C9F0FF"), typeLabel: "SORTIERAUFGABE",
                    question: "Wie gehen Sie bei der Repositionierung des avulsierten Zahnes vor?",
                    subtitle: "Verschieben Sie die Karten mit den Pfeilen."
                )

                VStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { offset, item in
                        SortCardView(
                            item: item, rank: offset + 1,
                            isCorrect: submitted && (offset + 1) == item.correctRank,
                            isActive: activeID == item.id, submitted: submitted,
                            onTap: { withAnimation(.spring(response: 0.25)) { activeID = (activeID == item.id) ? nil : item.id } },
                            onMoveUp: { moveUp(item) }, onMoveDown: { moveDown(item) }
                        )
                        .onDrag { dragging = item; return NSItemProvider(object: item.id.uuidString as NSString) }
                        .onDrop(of: [.text], delegate: Step6DropDelegate(item: item, items: $items, dragging: $dragging))
                    }
                }
                .padding(.horizontal, 16)

                if submitted {
                    ExpertCommentView(score: score,
                        text: "Erst die Vitalität mit Dentosafe sichern, dann in die Alveole repositionieren, dann mit dem Titan-Trauma-Splint stabilisieren.")
                }
                DrLukasHintView(text: "Zuerst die Vitalität sichern, dann repositionieren, dann stabilisieren – wie beim Einrenken eines Gelenks!")

                if submitted {
                    NavigationLink(destination: Step7MCQView()) {
                        confirmButtonLabel(title: "Weiter", icon: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                } else {
                    ConfirmButton(title: "Reihenfolge bestätigen", icon: "checkmark.circle.fill", enabled: true) {
                        withAnimation(.easeInOut) { submitted = true }
                    }
                }
                Spacer(minLength: 80)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Schritt 6 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
    private func moveUp(_ item: Step6SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx > 0 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx - 1) }
    }
    private func moveDown(_ item: Step6SortItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }), idx < items.count - 1 else { return }
        withAnimation(.spring(response: 0.3)) { items.swapAt(idx, idx + 1) }
    }
}

private struct SortCardView: View {
    let item: Step6SortItem; let rank: Int; let isCorrect: Bool
    let isActive: Bool; let submitted: Bool
    let onTap: () -> Void; let onMoveUp: () -> Void; let onMoveDown: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: submitted ? (isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill") : "line.3.horizontal")
                .foregroundColor(submitted ? (isCorrect ? .green : .red) : Color(hex: "727781"))
                .font(.system(size: 18))
            ZStack {
                Circle().fill(submitted ? (isCorrect ? Color.green : Color.red) : Color(hex: "00345f"))
                    .frame(width: 32, height: 32)
                Text("\(rank)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
            }
            Text(item.label)
                .font(.system(size: 15, weight: submitted ? .semibold : .medium))
                .foregroundColor(Color(hex: "0b1c30")).frame(maxWidth: .infinity, alignment: .leading)
            if !submitted {
                VStack(spacing: 0) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up").font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "727781").opacity(0.6)).frame(width: 30, height: 24)
                    }
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down").font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "727781").opacity(0.6)).frame(width: 30, height: 24)
                    }
                }
            }
        }
        .padding(16)
        .background(submitted ? (isCorrect ? Color(hex: "CAFFBF") : Color(hex: "FFD6D6")) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
            submitted ? (isCorrect ? Color.green : Color.red) : (isActive ? Color(hex: "00345f") : Color(hex: "727781")),
            lineWidth: (isActive || submitted) ? 2 : 1.5))
        .shadow(color: Color(hex: "00345f").opacity(isActive ? 0.18 : 0.05), radius: isActive ? 14 : 6, y: isActive ? -2 : 2)
        .scaleEffect(isActive ? 1.015 : 1.0)
        .animation(.spring(response: 0.25), value: isActive)
        .onTapGesture { onTap() }
    }
}

// MARK: - STEP 7: MCQ
struct Step7MCQView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var selected: Int? = nil
    @State private var submitted = false
    @State private var navTab: Step7NavBar.Tab = .cases
    let options = ["Sofortige Extraktion","Vitalexstirpation","Partielle Pulpotomie","Indirekte Überkappung"]
    let correctIndex = 1
    private var score: Int { (submitted && selected == correctIndex) ? 10 : 0 }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressBarView(step: 7, total: 8, score: submitted ? 10 : 0)

                    QuestionCardView(
                        badge: "Behandlung", badgeIcon: "cross.case.fill",
                        badgeColor: Color(hex: "CAFFBF"), typeLabel: "SINGLE CHOICE",
                        question: "Welche Methode der Behandlung einer Kronenfraktur mit Pulpabeteiligung ist bei einem Zahn mit abgeschlossenem Wurzelwachstum indiziert?",
                        subtitle: "Eine Antwort ist richtig."
                    )

                    VStack(spacing: 10) {
                        ForEach(0..<options.count, id: \.self) { i in
                            MCQOptionRow(text: options[i], index: i, selected: selected,
                                         correctIndex: correctIndex, submitted: submitted) {
                                if !submitted { selected = i }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if submitted {
                        ExpertCommentView(score: score,
                            text: "Bei abgeschlossenem Wurzelwachstum ist die Vitalexstirpation indiziert, gefolgt von einer Wurzelkanalbehandlung. Die partielle Pulpotomie ist eher bei jungen Zähnen mit offenem Apex angezeigt.")
                    }
                    DrLukasHintView(text: "Entscheidend ist das Wurzelwachstum: offen = Pulpotomie, abgeschlossen = Vitalexstirpation!")

                    if submitted {
                        NavigationLink(destination: Step8PhotoUploadView()) {
                            confirmButtonLabel(title: "Weiter zu Schritt 8", icon: "arrow.right.circle.fill")
                        }
                        .padding(.horizontal, 16)
                    } else {
                        ConfirmButton(title: "Antwort bestätigen", icon: "arrow.forward", enabled: selected != nil) {
                            withAnimation(.easeInOut) { submitted = true }
                        }
                    }
                    Spacer(minLength: 120)
                }
                .padding(.top, 20)
            }
            
            
        }
        .navigationTitle("Schritt 7 von 8")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .animation(.easeInOut, value: submitted)
        .withPersistentBottomBar()
    }
}

private struct MCQOptionRow: View {
    let text: String; let index: Int; let selected: Int?
    let correctIndex: Int; let submitted: Bool; let action: () -> Void
    private var isSelected: Bool { selected == index }
    private var isCorrect: Bool  { index == correctIndex }
    private var isWrong: Bool    { submitted && isSelected && !isCorrect }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(text)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(textColor).frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                ZStack {
                    Circle().stroke(borderColor, lineWidth: 2).frame(width: 24, height: 24)
                    if isSelected && !submitted { Circle().fill(Color(hex: "00345f")).frame(width: 12, height: 12) }
                    if submitted && isCorrect {
                        Circle().fill(Color.green).frame(width: 24, height: 24)
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    } else if submitted && isWrong {
                        Circle().fill(Color.red).frame(width: 24, height: 24)
                        Image(systemName: "xmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
            .padding(16).background(bgColor).clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: isSelected ? 2 : 1.5))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.0 : 0.997)
        .animation(.spring(response: 0.25), value: isSelected)
    }
    private var bgColor: Color {
        if !submitted { return isSelected ? Color(hex: "2e6385") : Color.white }
        if isCorrect { return Color(hex: "CAFFBF") }
        if isWrong   { return Color(hex: "FFD6D6") }
        return Color.white
    }
    private var borderColor: Color {
        if !submitted { return isSelected ? Color(hex: "00345f") : Color(hex: "727781") }
        if isCorrect { return .green }
        if isWrong   { return .red }
        return Color(hex: "727781")
    }
    private var textColor: Color {
        if !submitted { return isSelected ? Color(hex: "00345f") : Color(hex: "0b1c30") }
        if isCorrect { return Color(hex: "166534") }
        if isWrong   { return Color(hex: "93000a") }
        return Color(hex: "0b1c30")
    }
}

// MARK: - STEP 8: Foto-Upload
struct Step8PhotoUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @State private var images: [UIImage] = []
    @State private var showPicker = false
    @State private var isPulsing = false
    let maxPhotos = 5

    @StateObject private var geminiVM = GeminiViewModel()
    @State private var navigateToCompleted = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Schritt 8 von 8")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "084B83"))
                            Spacer()
                            Image(systemName: "star.fill").font(.system(size: 16))
                                .foregroundColor(Color(hex: "F59E0B"))
                        }
                        .padding(.horizontal, 16)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "2e6385")).frame(height: 6)
                                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "00345f"))
                                    .frame(width: geo.size.width, height: 6)
                            }
                        }
                        .frame(height: 6).padding(.horizontal, 16)
                    }

                    HStack {
                        Label("Dokumentation", systemImage: "camera.fill")
                            .font(.system(size: 13, weight: .bold)).foregroundColor(Color(hex: "0c4b6c"))
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color(hex: "FFD6A5")).clipShape(Capsule())
                            .opacity(isPulsing ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRAXISAUFGABE").font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "0b1c30")).tracking(0.8)
                        Text("Laden Sie jetzt bis zu 5 Bilder Ihrer am 3D-Modell durchgeführten Behandlung hoch!")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "00345f")).lineSpacing(4)
                        Text("Fotografieren Sie Ihre Arbeit am Modell aus verschiedenen Winkeln.")
                            .font(.system(size: 14)).foregroundColor(Color(hex: "0b1c30"))
                    }
                    .padding(20).background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "727781").opacity(0.4), lineWidth: 1))
                    .shadow(color: Color(hex: "00345f").opacity(0.08), radius: 12, y: 4)
                    .padding(.horizontal, 16)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(0..<maxPhotos, id: \.self) { idx in
                            PhotoSlotView(
                                image: idx < images.count ? images[idx] : nil,
                                onAdd: { showPicker = true },
                                onRemove: { guard idx < images.count else { return }; images.remove(at: idx) }
                            )
                            .aspectRatio(1, contentMode: .fill)
                        }
                    }
                    .padding(.horizontal, 16)

                    Text("\(images.count) / \(maxPhotos) Bilder hochgeladen")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(Color(hex: "0b1c30"))

                    DrLukasHintView(text: "Klinische Fotografie: von vorne, seitlich und von oben fotografieren.")

                    Spacer(minLength: 120)
                }
                .padding(.top, 20)
            }

            VStack(spacing: 0) {
                Divider()
                VStack(spacing: 10) {
                    Button(action: {
                        guard let firstImage = images.first else { return }
                        geminiVM.uploadedImage = firstImage
                        Task {
                            await geminiVM.evaluate(prompt: GeminiPrompts.fall1_upload)
                            await MainActor.run { navigateToCompleted = true }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if geminiVM.isEvaluating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.85)
                                Text("KI wertet aus…")
                                    .font(.system(size: 16, weight: .bold))
                            } else {
                                Text("Zur Kontrolle an KI abgeben")
                                    .font(.system(size: 16, weight: .bold))
                                Image(systemName: "brain.head.profile")
                            }
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(images.isEmpty || geminiVM.isEvaluating ? Color(hex: "9CA3AF") : Color(hex: "084B83"))
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .shadow(color: Color(hex: "084B83").opacity(images.isEmpty ? 0 : 0.3), radius: 8, y: 4)
                    }
                    .disabled(images.isEmpty || geminiVM.isEvaluating)
                    .padding(.horizontal, 16)

                    if images.isEmpty {
                        Text("Bitte mindestens ein Bild hochladen")
                            .font(.system(size: 12)).foregroundColor(Color(hex: "9CA3AF"))
                    }
                }
                .padding(.vertical, 16)
                .background(Color(hex: "f8f9ff"))
            }
        }
        .navigationDestination(isPresented: $navigateToCompleted) {
            CaseCompletedView(geminiVM: geminiVM)
        }
        .navigationTitle("Schritt 8 von 8 – Abschluss")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .sheet(isPresented: $showPicker) { ImagePicker(images: $images, maxCount: maxPhotos) }
        .onAppear { isPulsing = true }
        .withPersistentBottomBar()
    }
}

private struct PhotoSlotView: View {
    let image: UIImage?
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        if let img = image {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: img).resizable().scaledToFill().clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "727781"), lineWidth: 1))
                Button(action: onRemove) {
                    ZStack {
                        Circle().fill(Color.red.opacity(0.85)).frame(width: 26, height: 26)
                        Image(systemName: "xmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
                .padding(6)
            }
        } else {
            Button(action: onAdd) {
                VStack(spacing: 8) {
                    Image(systemName: "plus").font(.system(size: 28, weight: .light))
                        .foregroundColor(Color(hex: "00345f"))
                    Text("Foto hinzufügen").font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "0b1c30"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "f8f9ff"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(Color(hex: "727781")))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Image Picker (UIKit Bridge)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    let maxCount: Int
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.delegate = context.coordinator
        p.sourceType = .photoLibrary
        return p
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage, parent.images.count < parent.maxCount {
                parent.images.append(img)
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - CASE COMPLETED VIEW
struct CaseCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navState: NavState
    @EnvironmentObject private var appState: AppState
    @ObservedObject var geminiVM: GeminiViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color(hex: "084B83"))
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("Fall abgeschlossen")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "0B1C30"))
                    Text("KI-Auswertung abgeschlossen")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "6B7280"))
                }

               
                .padding(.horizontal, 24).padding(.vertical, 14)
                .background(Color(hex: "C9F0FF"))
                .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 10) {
                    Label("KI-Auswertung", systemImage: "brain.head.profile")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "084B83"))

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "EAFFFD"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "084B83").opacity(0.2), lineWidth: 1.5)
                            )

                        Text(geminiVM.feedbackText ?? GeminiViewModel.mockFeedback)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "084B83"))
                            .lineSpacing(5)
                            .padding(16)
                    }
                    .frame(minHeight: 160)
                }
                .padding(20).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(hex: "084B83").opacity(0.07), radius: 10, y: 4)
                .padding(.horizontal, 16)

                Spacer(minLength: 100)
            }
        }
        .navigationTitle("Fall abgeschlossen")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9FAFB").ignoresSafeArea())
        .withPersistentBottomBar()
    }
}

