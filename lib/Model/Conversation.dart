class Conversations {
  List<Conversation> list = [];

  Conversations(List input, List input2) {
    for(Map item in input) {
      Conversation conversation = new Conversation(item, input2);
      list.add(conversation);
    }
  }
}

class Conversation {
  int id;
  String username;
  String name;
  int userId;
  String recentMessage;
  String recentSender;
  int recentSenderId;
  String profilePicture;
  DateTime created;
  bool readConversation = false;
  List<Message> messages = [];

  Conversation(Map input, List input2) {
    this.id = input['id'];
    this.username = input['username'];
    this.name = input['name'];
    this.userId = input['user_Id'];
    this.recentMessage = input['recent_message'];
    this.recentSenderId = input['recent_sender_id'];
    this.recentSender = input['recent_sender'];
    this.profilePicture = input['profile_picture'];
    this.readConversation = input['read_conversation'] == 1 ? true : false;
    this.created = DateTime.parse(input['recent_message_created']);

    for(var item in input2) {
      if(item['conversationId'] == input['id']) {
        this.messages.add(new Message(item));
      }
    }
  }
}

class Message {
  int id;
  int conversationId;
  String message;
  int senderId;
  DateTime created;

  Message(Map input) {
    this.id = input['id'];
    this.conversationId = input['conversationId'];
    this.message = input['message'];
    this.senderId = input['senderId'];
    this.created = DateTime.parse(input['created']);
  }
}