
//
//  ChatViewController.swift
//  Chat
//
//  Created by Smart on 2019/12/21.
//  Copyright © 2019 Smart. All rights reserved.
//
import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseDatabase

class ChatViewController: MessagesViewController {

    let user1 = MockUser(senderId: "鈴木", displayName: "鈴木")
    let user2 = MockUser(senderId: "佐藤", displayName: "佐藤")

    var messages: [MockMessage] = []

    var ref: DatabaseReference!


    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageInputBar.delegate = self

        // Do any additional setup after loading the view.
//        createSampleMessage()

        ref = Database.database().reference()

        createFirebaseMessage()
    }

    func createSampleMessage() {

        let mes1 = MockMessage(text: "鈴木です。こんにちわ", user: user1, messageId: UUID().uuidString, date: Date())
        let mes2 = MockMessage(text: "どうも佐藤です", user: user2, messageId: UUID().uuidString, date: Date())
        let mes3 = MockMessage(text: "天気がいいですね", user: user1, messageId: UUID().uuidString, date: Date())
        let mes4 = MockMessage(text: "そうですね", user: user2, messageId: UUID().uuidString, date: Date())

        self.messages.append(mes1)
        self.messages.append(mes2)
        self.messages.append(mes3)
        self.messages.append(mes4)

        self.messagesCollectionView.reloadData()
    }

    func createFirebaseMessage() {

        self.ref.observe(DataEventType.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if let name = postDict["name"] as? String, let message = postDict["message"] as? String {

                let user = MockUser(senderId: name, displayName: name)
                let mes = MockMessage(text: message, user: user, messageId: UUID().uuidString, date: Date())
                self.messages.append(mes)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        })
    }
}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return MockUser(senderId: "佐藤", displayName: "佐藤")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm"
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

}


extension ChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }

    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }

}


extension ChatViewController: MessagesDisplayDelegate {

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(image: nil, initials: message.sender.displayName)
        avatarView.set(avatar: avatar)
    }
}

extension ChatViewController: MessageInputBarDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        let messageData = [
            "name" : "佐藤",
            "message" : text
        ]
        self.ref.childByAutoId().setValue(messageData)
    }
}
