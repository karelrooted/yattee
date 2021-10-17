import Defaults
import SwiftUI

struct InstancesSettingsView: View {
    @Default(.instances) private var instances

    @EnvironmentObject<InvidiousAPI> private var api
    @EnvironmentObject<InstancesModel> private var instancesModel
    @EnvironmentObject<SubscriptionsModel> private var subscriptions
    @EnvironmentObject<PlaylistsModel> private var playlists

    @State private var selectedInstanceID: Instance.ID?
    @State private var selectedAccount: Instance.Account?

    @State private var presentingInstanceForm = false
    @State private var savedFormInstanceID: Instance.ID?

    var body: some View {
        Group {
            Section(header: Text("Instances"), footer: DefaultAccountHint()) {
                ForEach(instances) { instance in
                    Group {
                        NavigationLink(instance.longDescription) {
                            AccountsSettingsView(instanceID: instance.id)
                        }
                    }
                    #if os(iOS)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            removeInstanceButton(instance)
                        }
                        .buttonStyle(.plain)
                    #else
                        .contextMenu {
                            removeInstanceButton(instance)
                        }
                    #endif
                }

                addInstanceButton
            }
            #if os(iOS)
                .listStyle(.insetGrouped)
            #endif
        }
        .sheet(isPresented: $presentingInstanceForm) {
            InstanceFormView(savedInstanceID: $savedFormInstanceID)
        }
    }

    private var addInstanceButton: some View {
        Button("Add Instance...") {
            presentingInstanceForm = true
        }
    }

    private func removeInstanceButton(_ instance: Instance) -> some View {
        Button("Remove", role: .destructive) {
            instancesModel.remove(instance)
        }
    }

    private func resetDefaultAccount() {
        instancesModel.resetDefaultAccount()
    }
}

struct InstancesSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InstancesSettingsView()
        }
        .frame(width: 400, height: 270)
        .environmentObject(InstancesModel())
    }
}