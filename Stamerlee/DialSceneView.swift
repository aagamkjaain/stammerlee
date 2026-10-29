import SwiftUI
import UIKit
// MARK: - Dial Scene
/// Conversation practice unlocked alongside Picture Description.
public struct DialSceneView: View {
    @Bindable public var state: AppState

    @State private var selectedScenario = "Ordering at a Café"
    @State private var stage: Stage = .scenarios
    @State private var selectedSegment = "Prolongations"
    @State private var selectedWords: Set<String> = ["Medium", "Special"]
    @State private var showAddScenarioSheet = false
    @State private var newScenarioName = ""
    @State private var newScenarioDescription = ""
    @State private var visibleConversationItems = 0
    @State private var micPulse = false

    @State private var customScenarios: [(String, String, String)] = []
    @State private var customScenarioDescriptions: [String: String] = [:]
    @State private var selectedScenarioDescription = ""
    
    @State private var isDAFActive = false
    
    private enum Stage {
        case scenarios
        case conversation
        case analysis
    }

    private let scenarios = [
        ("Ordering at a Café", "Practice placing your order.", "cup.and.saucer.fill"),
        ("Ordering at a Restaurant", "Practice ordering a meal.", "fork.knife"),
        ("Checking into a Hotel", "Build confidence checking in.", "building.2.fill"),
        ("At a Hair Salon", "Practice common salon phrases.", "scissors"),
        ("At a Grocery Store", "Practice asking for items.", "basket.fill")
    ]

    private let wordsBySegment: [String: [String]] = [
        "Prolongations": ["Medium", "What", "Order", "Special", "Side", "Iced"],
        "Blocks": ["One", "Vanilla", "Frappe", "Please", "Cup", "Small"],
        "Repetitions": ["What", "With", "Whole", "Latte", "Milk", "Today's"]
    ]

    public init(state: AppState) {
        self.state = state
    }

    private var words: [String] {
        wordsBySegment[selectedSegment, default: []]
    }

    private var allScenarios: [(String, String, String)] {
        scenarios + customScenarios
    }
    
    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()
            switch stage {
            case .scenarios:
                scenarioView
            case .conversation:
                conversationView
            case .analysis:
                analysisView
            }
        }
    }

    private var header: some View {
        HStack {
            BackNavButton {
                if stage == .scenarios {
                    state.navigate(to: .homeDashboard, forward: false)
                } else {
                    stage = .scenarios
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var scenarioView: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Text("Dial Scene")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 22)
            Text("Practice real life conversations through\ninteractive scenarios.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 24)

            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(allScenarios, id: \.0) { scenario in
                        Button {
                            selectedScenario = scenario.0
                            stage = .conversation
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: scenario.2)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(scenario.0)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)

                                    Text(scenario.1)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                                }

                                Spacer(minLength: 4)

                                Image(systemName: "phone.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Color(red: 73 / 255, green: 65 / 255, blue: 174 / 255),
                                        in: Circle()
                                    )
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, minHeight: 82)
                            .background(Color.white.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.white.opacity(0.08))
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }

                    // Add a custom practice scenario
                    Button {
                        newScenarioName = ""
                        newScenarioDescription = ""
                        showAddScenarioSheet = true
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(StamerleeTheme.primaryBlue)
                                .frame(width: 44, height: 44)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Add a Scenario")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text("Create your own conversation practice.")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, minHeight: 82)
                        .background(Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    StamerleeTheme.primaryBlue.opacity(0.55),
                                    style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                                )
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            
            .sheet(isPresented: $showAddScenarioSheet) {
                NavigationStack {
                    Form {
                        Section("Scenario name") {
                            TextField(
                                "e.g. Talking to customer care",
                                text: $newScenarioName
                            )
                        }

                        Section("Describe your scenario") {
                            TextEditor(text: $newScenarioDescription)
                                .frame(minHeight: 140)
                                .overlay(alignment: .topLeading) {
                                    if newScenarioDescription.isEmpty {
                                        Text("Describe the situation, who you're speaking to, what you want to achieve, and how you'd like the conversation to go...")
                                            .foregroundStyle(.tertiary)
                                            .padding(.top, 8)
                                            .padding(.leading, 5)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                    }
                    .navigationTitle("Add a Scenario")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAddScenarioSheet = false
                            }
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let name = newScenarioName.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                let description = newScenarioDescription.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )

                                guard !name.isEmpty, !description.isEmpty else {
                                    return
                                }

                                customScenarios.append(
                                    (
                                        name,
                                        "Personalized conversation practice.",
                                        "bubble.left.and.bubble.right.fill"
                                    )
                                )

                                customScenarioDescriptions[name] = description
                                selectedScenario = name
                                selectedScenarioDescription = description
                                stage = .conversation
                                showAddScenarioSheet = false
                                
                            }
                            .disabled(
                                newScenarioName.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty ||
                                newScenarioDescription.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty
                            )
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }


            Spacer()
        }
    }

    private var conversationScript: (
        speaker: String,
        opening: String,
        userLine: String,
        reply: String,
        finalUserLine: String
    ) {
        if let description = customScenarioDescriptions[selectedScenario] {
            return (
                speaker: selectedScenario,
                opening: "Hi! How can I help you today?",
                userLine: description,
                reply: "I understand. Could you tell me a little more?",
                finalUserLine: "Thank you for your help."
            )
        }

        switch selectedScenario {
        case "Ordering at a Café":
            return (
                speaker: "Barista",
                opening: "Hi! What can I get for you today?",
                userLine: "A medium iced latte with vanilla, please.",
                reply: "Of course! Anything else?",
                finalUserLine: "What about today's special?"
            )

        case "Ordering at a Restaurant":
            return (
                speaker: "Server",
                opening: "Hi! Are you ready to order?",
                userLine: "I'd like to order a grilled sandwich, please.",
                reply: "Certainly! Would you like a drink?",
                finalUserLine: "Could I have some water, please?"
            )

        case "Checking into a Hotel":
            return (
                speaker: "Receptionist",
                opening: "Welcome! Do you have a reservation?",
                userLine: "Yes, I have a reservation under my name.",
                reply: "May I see your ID, please?",
                finalUserLine: "What time is check-out?"
            )

        case "At a Hair Salon":
            return (
                speaker: "Stylist",
                opening: "Hi! What would you like today?",
                userLine: "I'd like a trim, please.",
                reply: "Would you like any layers?",
                finalUserLine: "Just a few light layers, please."
            )

        case "At a Grocery Store":
            return (
                speaker: "Store assistant",
                opening: "Hello! Can I help you find anything?",
                userLine: "Where can I find fresh apples?",
                reply: "They're in the produce section.",
                finalUserLine: "Thank you!"
            )

        default:
            return (
                speaker: "Conversation partner",
                opening: "Hello! How can I help you?",
                userLine: "I'd like to explain what I need.",
                reply: "Of course. Tell me a little more.",
                finalUserLine: "Thank you for your help."
            )
        }
    }
    private var conversationView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header and DAF badge
           
            // Header and interactive DAF button
           HStack {
               BackNavButton {
                   stage = .scenarios
               }

               Spacer()

               Button {
                   let impact = UIImpactFeedbackGenerator(style: .medium)
                   impact.impactOccurred()

                   withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                       isDAFActive.toggle()
                   }
               } label: {
                   HStack(spacing: 6) {
                       Image(systemName: "headphones")
                           .font(.system(size: 15, weight: .bold))

                       Text("DAF")
                           .font(.system(size: 13, weight: .bold, design: .rounded))
                   }
                   .foregroundStyle(.white)
                   .padding(.horizontal, 16)
                   .padding(.vertical, 8)
                   .background(
                       isDAFActive
                           ? StamerleeTheme.primaryBlue
                           : Color(red: 25.0 / 255, green: 55.0 / 255, blue: 130.0 / 255)
                   )
                   .clipShape(Capsule())
                   .shadow(
                       color: isDAFActive
                           ? StamerleeTheme.primaryBlue.opacity(0.4)
                           : .clear,
                       radius: 8,
                       x: 0,
                       y: 3
                   )
               }
               .buttonStyle(.plain)
           }
           .padding(.horizontal, 24)
           .padding(.top, 16)

            
            // Screen title
            Text(
                customScenarioDescriptions[selectedScenario] != nil
                    ? selectedScenario
                    : selectedScenario
            )
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.top, 22)

            Text("Practice at your own pace. Take your time.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 22)

            // Conversation bubbles
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if visibleConversationItems >= 1 {
                        bubble(
                            conversationScript.speaker,
                            conversationScript.opening,
                            isUser: false
                        )
                        .transition(
                            .opacity.combined(with: .move(edge: .leading))
                        )
                    }

                    if visibleConversationItems >= 2 {
                        bubble(
                            "You",
                            conversationScript.userLine,
                            isUser: true
                        )
                        .transition(
                            .opacity.combined(with: .move(edge: .trailing))
                        )
                    }

                    if visibleConversationItems >= 3 {
                        bubble(
                            conversationScript.speaker,
                            conversationScript.reply,
                            isUser: false
                        )
                        .transition(
                            .opacity.combined(with: .move(edge: .leading))
                        )
                    }

                    // User's latest voice message, on the right
                    if visibleConversationItems >= 4 {
                        HStack {
                            Spacer(minLength: 50)

                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(
                                        Color(red: 35/255, green: 39/255, blue: 78/255)
                                    )
                                    .frame(width: 38, height: 38)
                                    .background(
                                        Color(red: 190/255, green: 204/255, blue: 240/255),
                                        in: Circle()
                                    )

                                HStack(spacing: 4) {
                                    ForEach(
                                        Array(
                                            [3.0, 5.0, 9.0, 14.0, 8.0,
                                             20.0, 27.0, 17.0, 10.0, 6.0,
                                             12.0, 22.0, 14.0, 8.0, 16.0,
                                             11.0, 5.0, 3.0].enumerated()
                                        ),
                                        id: \.offset
                                    ) { _, height in
                                        Capsule()
                                            .fill(
                                                Color(red: 205/255, green: 215/255, blue: 245/255)
                                            )
                                            .frame(width: 3, height: height)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(12)
                            .background(
                                Color(red: 226/255, green: 229/255, blue: 250/255),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                           
                        }
                        .transition(
                            .opacity.combined(with: .move(edge: .trailing))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
            .frame(maxHeight: .infinity)

            Spacer(minLength: 0)

            // Native iOS microphone with a soft lavender pulse.
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            Color(red: 205/255, green: 215/255, blue: 245/255).opacity(0.08)
                        )
                        .frame(width: 124, height: 124)
                        .scaleEffect(micPulse ? 1.08 : 0.92)

                    Circle()
                        .fill(
                            Color(red: 205/255, green: 215/255, blue: 245/255).opacity(0.15)
                        )
                        .frame(width: 130, height: 130)
                        .scaleEffect(micPulse ? 1.05 : 0.95)

                    Circle()
                        .fill(
                            Color(red: 205/255, green: 215/255, blue: 245/255).opacity(0.35)
                        )
                        .frame(width: 106, height: 106)

                    Circle()
                        .fill(Color(red: 205/255, green: 215/255, blue: 245/255))
                        .frame(width: 82, height: 82)

                    Circle()
                        .fill(StamerleeTheme.backgroundDark)
                        .frame(width: 62, height: 62)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 27, weight: .medium))
                        .foregroundStyle(.white)
                }
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: micPulse
                )

                Text("You're speaking…")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Take your time. Speak naturally.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 12)

            PrimaryActionButton(title: "Finish practice") {
                state.hasCompletedDialScene = true
                stage = .analysis
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .task(id: selectedScenario) {
            visibleConversationItems = 0
            micPulse = true

            for item in 1...4 {
                do {
                    try await Task.sleep(for: .milliseconds(350))
                } catch {
                    return
                }

                withAnimation(.easeOut(duration: 0.4)) {
                    visibleConversationItems = item
                }
            }
        }
    }

   
    private func bubble(
        _ speaker: String,
        _ text: String,
        isUser: Bool
    ) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isUser {
                Spacer(minLength: 40)
            } else {
                Image(systemName: "headphones")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        StamerleeTheme.primaryBlueDark.opacity(0.65),
                        in: Circle()
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(speaker)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        isUser ? Color.black.opacity(0.75) : Color.white.opacity(0.8)
                    )

                Text(text)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(isUser ? Color.black : Color.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(
                isUser
                    ? Color(red: 226/255, green: 229/255, blue: 250/255)
                    : Color(red: 35/255, green: 39/255, blue: 78/255),
                in: RoundedRectangle(cornerRadius: 18)
            )
            
            .frame(maxWidth: 310, alignment: isUser ? .trailing : .leading)

            if !isUser {
                Spacer(minLength: 20)
            }
        }
    }


    private var analysisView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Analysis")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 24)
            VStack(spacing: 6) {
                Text("YOU SCORED").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("74%").font(.system(size: 52, weight: .bold, design: .rounded)).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 56)
            .padding(.bottom, 26)

            Text("Choose the words to practice them using Beat Buddy")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 14)

            HStack(spacing: 0) {
                ForEach(["Prolongations", "Blocks", "Repetitions"], id: \.self) { segment in
                    Button(segment) {
                        selectedSegment = segment
                        selectedWords = Set(wordsBySegment[segment, default: []].prefix(2))
                    }
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(selectedSegment == segment ? .black : .black.opacity(0.7))
                    .frame(maxWidth: .infinity).frame(height: 34)
                    .background(selectedSegment == segment ? .white : .clear)
                    .clipShape(Capsule())
                }
            }
            .padding(3)
            .background(Color(red: 220 / 255, green: 224 / 255, blue: 245 / 255))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
            .padding(.bottom, 22)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(words, id: \.self) { word in
                    Button(word) {
                        if selectedWords.contains(word) { selectedWords.remove(word) } else { selectedWords.insert(word) }
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(selectedWords.contains(word) ? .white : StamerleeTheme.textSecondaryDark)
                    .frame(maxWidth: .infinity).frame(height: 44)
                    .background(selectedWords.contains(word) ? Color(red: 20 / 255, green: 45 / 255, blue: 105 / 255) : Color.white.opacity(0.03))
                    .overlay(Capsule().stroke(selectedWords.contains(word) ? StamerleeTheme.primaryBlue : Color.white.opacity(0.06)))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            PrimaryActionButton(title: "Done") {
                state.navigate(to: .homeDashboard)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

