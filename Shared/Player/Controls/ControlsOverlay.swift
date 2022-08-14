import Defaults
import SwiftUI

struct ControlsOverlay: View {
    @EnvironmentObject<NetworkStateModel> private var networkState
    @EnvironmentObject<PlayerModel> private var player
    @EnvironmentObject<PlayerControlsModel> private var model

    @State private var contentSize: CGSize = .zero

    @Default(.showMPVPlaybackStats) private var showMPVPlaybackStats
    @Default(.qualityProfiles) private var qualityProfiles

    #if os(tvOS)
        enum Field: Hashable {
            case qualityProfile
            case stream
            case increaseRate
            case decreaseRate
            case captions
        }

        @FocusState private var focusedField: Field?
    #endif

    var body: some View {
        ScrollView {
            VStack {
                Section(header: controlsHeader("Rate & Captions")) {
                    HStack(spacing: rateButtonsSpacing) {
                        decreaseRateButton
                        #if os(tvOS)
                        .focused($focusedField, equals: .decreaseRate)
                        #endif
                        rateButton
                        increaseRateButton
                        #if os(tvOS)
                        .focused($focusedField, equals: .increaseRate)
                        #endif
                    }

                    captionsButton
                    #if os(tvOS)
                    .focused($focusedField, equals: .captions)
                    #endif
                    .disabled(player.activeBackend != .mpv)

                    #if os(iOS)
                        .foregroundColor(.white)
                    #endif
                }

                Section(header: controlsHeader("Quality Profile")) {
                    qualityProfileButton
                    #if os(tvOS)
                    .focused($focusedField, equals: .qualityProfile)
                    #endif
                }

                Section(header: controlsHeader("Stream & Player")) {
                    qualityButton
                    #if os(tvOS)
                    .focused($focusedField, equals: .stream)
                    #endif

                    #if !os(tvOS)
                        HStack {
                            backendButtons
                        }
                    #endif
                }

                if player.activeBackend == .mpv,
                   showMPVPlaybackStats
                {
                    Section(header: controlsHeader("Statistics")) {
                        mpvPlaybackStats
                    }
                    #if os(tvOS)
                    .frame(width: 400)
                    #else
                    .frame(width: 240)
                    #endif
                }
            }
            .overlay(
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        contentSize = geometry.size
                    }
                }
            )
            #if os(tvOS)
            .padding(.horizontal, 40)
            #endif
        }
        .frame(maxHeight: overlayHeight)
        #if os(tvOS)
            .onAppear {
                focusedField = .qualityProfile
            }
        #endif
    }

    private var overlayHeight: Double {
        #if os(tvOS)
            contentSize.height + 50.0
        #else
            contentSize.height
        #endif
    }

    private func controlsHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption))
            .foregroundColor(.secondary)
    }

    private var backendButtons: some View {
        ForEach(PlayerBackendType.allCases, id: \.self) { backend in
            backendButton(backend)
                .frame(height: 40)
            #if os(iOS)
                .frame(maxWidth: 115)
                .modifier(ControlBackgroundModifier())
                .clipShape(RoundedRectangle(cornerRadius: 4))
            #endif
        }
    }

    private func backendButton(_ backend: PlayerBackendType) -> some View {
        Button {
            player.saveTime {
                player.changeActiveBackend(from: player.activeBackend, to: backend)
                model.resetTimer()
            }
        } label: {
            Text(backend.label)
                .foregroundColor(player.activeBackend == backend ? .accentColor : .secondary)
        }
        #if os(macOS)
        .buttonStyle(.bordered)
        #else
        .modifier(ControlBackgroundModifier())
        .clipShape(RoundedRectangle(cornerRadius: 4))
        #endif
    }

    @ViewBuilder private var rateButton: some View {
        #if os(macOS)
            ratePicker
                .labelsHidden()
                .frame(maxWidth: 100)
        #elseif os(iOS)
            Menu {
                ratePicker
            } label: {
                Text(player.rateLabel(player.currentRate))
                    .foregroundColor(.primary)
                    .frame(width: 123)
            }
            .transaction { t in t.animation = .none }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .frame(width: 123, height: 40)
            .modifier(ControlBackgroundModifier())
            .mask(RoundedRectangle(cornerRadius: 3))
        #else
            Text(player.rateLabel(player.currentRate))
                .frame(minWidth: 120)
        #endif
    }

    var ratePicker: some View {
        Picker("Rate", selection: $player.currentRate) {
            ForEach(PlayerModel.availableRates, id: \.self) { rate in
                Text(player.rateLabel(rate)).tag(rate)
            }
        }
        .transaction { t in t.animation = .none }
    }

    private var increaseRateButton: some View {
        let increasedRate = PlayerModel.availableRates.first { $0 > player.currentRate }
        return Button {
            if let rate = increasedRate {
                player.currentRate = rate
            }
        } label: {
            Label("Increase rate", systemImage: "plus")
                .foregroundColor(.primary)
                .labelStyle(.iconOnly)
                .padding(8)
                .frame(width: 50, height: 40)
                .contentShape(Rectangle())
        }
        #if os(macOS)
        .buttonStyle(.bordered)
        #elseif os(iOS)
        .modifier(ControlBackgroundModifier())
        .clipShape(RoundedRectangle(cornerRadius: 4))
        #endif
        .disabled(increasedRate.isNil)
    }

    private var decreaseRateButton: some View {
        let decreasedRate = PlayerModel.availableRates.last { $0 < player.currentRate }

        return Button {
            if let rate = decreasedRate {
                player.currentRate = rate
            }
        } label: {
            Label("Decrease rate", systemImage: "minus")
                .foregroundColor(.primary)
                .labelStyle(.iconOnly)
                .padding(8)
                .frame(width: 50, height: 40)
                .contentShape(Rectangle())
        }
        #if os(macOS)
        .buttonStyle(.bordered)
        #elseif os(iOS)
        .modifier(ControlBackgroundModifier())
        .clipShape(RoundedRectangle(cornerRadius: 4))
        #endif
        .disabled(decreasedRate.isNil)
    }

    private var rateButtonsSpacing: Double {
        #if os(tvOS)
            10
        #else
            8
        #endif
    }

    @ViewBuilder private var qualityProfileButton: some View {
        #if os(macOS)
            qualityProfilePicker
                .labelsHidden()
                .frame(maxWidth: 300)
        #elseif os(iOS)
            Menu {
                qualityProfilePicker
            } label: {
                Text(player.qualityProfileSelection?.description ?? "Auto")
                    .frame(maxWidth: 240)
            }
            .transaction { t in t.animation = .none }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .frame(maxWidth: 240)
            .frame(height: 40)
            .modifier(ControlBackgroundModifier())
            .mask(RoundedRectangle(cornerRadius: 3))
        #else
            Button {} label: {
                Text(player.qualityProfileSelection?.description ?? "Auto")
                    .lineLimit(1)
                    .frame(maxWidth: 320)
            }
            .contextMenu {
                ForEach(qualityProfiles) { qualityProfile in
                    Button("Default") { player.qualityProfileSelection = nil }
                    Button {
                        player.qualityProfileSelection = qualityProfile
                    } label: {
                        Text(qualityProfile.description)
                    }

                    Button("Cancel", role: .cancel) {}
                }
            }
        #endif
    }

    private var qualityProfilePicker: some View {
        Picker("Quality Profile", selection: $player.qualityProfileSelection) {
            Text("Automatic").tag(QualityProfile?.none)
            ForEach(qualityProfiles) { qualityProfile in
                Text(qualityProfile.description).tag(qualityProfile as QualityProfile?)
            }
        }
        .transaction { t in t.animation = .none }
    }

    @ViewBuilder private var qualityButton: some View {
        #if os(macOS)
            StreamControl()
                .labelsHidden()
                .frame(maxWidth: 300)
        #elseif os(iOS)
            Menu {
                StreamControl()
            } label: {
                Text(player.streamSelection?.shortQuality ?? "loading")
                    .frame(width: 140, height: 40)
                    .foregroundColor(.primary)
            }
            .transaction { t in t.animation = .none }

            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .frame(width: 240, height: 40)
            .modifier(ControlBackgroundModifier())
            .mask(RoundedRectangle(cornerRadius: 3))
        #else
            StreamControl()
        #endif
    }

    @ViewBuilder private var captionsButton: some View {
        #if os(macOS)
            captionsPicker
                .labelsHidden()
                .frame(maxWidth: 300)
        #elseif os(iOS)
            Menu {
                captionsPicker
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble")
                    if let captions = captionsBinding.wrappedValue {
                        Text(captions.code)
                            .foregroundColor(.primary)
                    }
                }
                .frame(width: 240)
                .frame(height: 40)
            }
            .transaction { t in t.animation = .none }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .frame(width: 240)
            .modifier(ControlBackgroundModifier())
            .mask(RoundedRectangle(cornerRadius: 3))
        #else
            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                    if let captions = captionsBinding.wrappedValue {
                        Text(captions.code)
                    }
                }
                .frame(maxWidth: 320)
            }
            .contextMenu {
                ForEach(player.currentVideo?.captions ?? []) { caption in
                    Button(caption.description) { captionsBinding.wrappedValue = caption }
                }
                Button("Cancel", role: .cancel) {}
            }

        #endif
    }

    @ViewBuilder private var captionsPicker: some View {
        let captions = player.currentVideo?.captions ?? []
        Picker("Captions", selection: captionsBinding) {
            if captions.isEmpty {
                Text("Not available")
            } else {
                Text("Disabled").tag(Captions?.none)
            }
            ForEach(captions) { caption in
                Text(caption.description).tag(Optional(caption))
            }
        }
        .disabled(captions.isEmpty)
    }

    private var captionsBinding: Binding<Captions?> {
        .init(
            get: { player.mpvBackend.captions },
            set: {
                player.mpvBackend.captions = $0
                Defaults[.captionsLanguageCode] = $0?.code
            }
        )
    }

    var mpvPlaybackStats: some View {
        VStack(alignment: .leading, spacing: 6) {
            mpvPlaybackStatRow("Hardware decoder", player.mpvBackend.hwDecoder)
            mpvPlaybackStatRow("Dropped frames", String(player.mpvBackend.frameDropCount))
            mpvPlaybackStatRow("Stream FPS", String(format: "%.2ffps", player.mpvBackend.outputFps))
            mpvPlaybackStatRow("Cached time", String(format: "%.2fs", player.mpvBackend.cacheDuration))
        }
        .padding(.top, 2)
        #if os(tvOS)
            .font(.system(size: 20))
        #else
            .font(.system(size: 11))
        #endif
    }

    func mpvPlaybackStatRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

struct ControlsOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ControlsOverlay()
            .environmentObject(NetworkStateModel())
            .environmentObject(PlayerModel())
            .environmentObject(PlayerControlsModel())
    }
}
