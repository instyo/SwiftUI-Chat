import SwiftUI
import CachedAsyncImage

struct FriendRequestsView: View {
    @EnvironmentObject var friendsVM: FriendsViewModel
    @EnvironmentObject var auth: AuthViewModel

    @State private var senderUsers: [String: ChatUser] = [:]

    var body: some View {
        List {
            ForEach(friendsVM.friendRequests) { request in
                FriendRequestRowView(
                    request: request,
                    senderUser: senderUsers[request.fromUserId],
                    onAppear: {
                        
                    },
                    onAccept: {
                        friendsVM.acceptRequest(request)
                    },
                    onReject: {
                        friendsVM.rejectRequest(request)
                    }
                )
            }
        }
        .navigationTitle("Friend Requests")
    }
}

struct FriendRequestRowView: View {
    let request: FriendRequest
    let senderUser: ChatUser?
    let onAppear: () -> Void
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            profileImageView
            userInfoView
            Spacer()
            actionButtonsView
        }
        .padding(.vertical, 8)
        .onAppear {
            onAppear()
        }
    }
    
    @ViewBuilder
    private var profileImageView: some View {
        if let user = senderUser {
            CachedAsyncImage(url: user.imageUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.secondary.opacity(0.3))
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 44, height: 44)
        }
    }
    
    @ViewBuilder
    private var userInfoView: some View {
        VStack(alignment: .leading) {
            if let user = senderUser {
                Text(user.displayName)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Loading...")
                    .foregroundColor(.secondary)
            }
            
            Text(request.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 8) {
            acceptButton
            declineButton
        }
    }
    
    private var acceptButton: some View {
        Button(action: onAccept) {
            Text("Accept")
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
        }
    }
    
    private var declineButton: some View {
        Button(action: onReject) {
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

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        let current = ChatUser(
            id: "1",
            displayName: "Alice",
            email: "a@a.com",
            createdAt: Date(),
            profilePicture: "https://api.dicebear.com/9.x/adventurer/jpg?seed=1"
        )
        let vm = FriendsViewModel(currentUser: current)

        return NavigationStack {
            FriendRequestsView()
                .environmentObject(vm)
                .environmentObject(AuthViewModel.shared)
        }
    }
}
