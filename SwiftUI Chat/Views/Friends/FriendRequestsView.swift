import SwiftUI
import CachedAsyncImage

struct FriendRequestsView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var auth: AuthViewModel

    @State private var senderUsers: [String: ChatUser] = [:]

    var body: some View {
        List {
            ForEach(friendsVM.friendRequests) { request in
                HStack(spacing: 12) {
                    if let user = senderUsers[request.fromId] {
                        CachedAsyncImage(url: user.imageUrl)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }

                    VStack(alignment: .leading) {
                        if let user = senderUsers[request.fromId] {
                            Text(user.displayName).font(.headline)
                            Text(user.email).font(.subheadline).foregroundColor(.secondary)
                        } else {
                            Text("Loading...")
                                .foregroundColor(.secondary)
                        }
                        Text(request.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    HStack(spacing: 8) {
                        Button(action: { friendsVM.acceptRequest(request) }) {
                            Text("Accept")
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }

                        Button(action: { friendsVM.rejectRequest(request) }) {
                            Text("Decline")
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(.vertical, 8)
                .onAppear {
                    // Fetch sender user if not already present
                    if senderUsers[request.fromId] == nil {
                        friendsVM.fetchUser(userId: request.fromId) { user in
                            if let user = user {
                                senderUsers[request.fromId] = user
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Friend Requests")
    }
}

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide dummy environment objects for preview
        let current = ChatUser(id: "1", displayName: "Alice", email: "a@a.com", createdAt: Date(), profilePicture: "https://api.dicebear.com/7.x/adventurer/jpg?seed=1")
        let vm = FriendsViewModel(currentUser: current)

        return NavigationStack {
            FriendRequestsView()
                .environmentObject(vm)
                .environmentObject(AuthViewModel.shared)
        }
    }
}
