import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseChatApp {
  static const String apiKey = "AIzaSyCQ0tvRkGuVUNykL-a1opsdqFZa2q1w3Vg";
  static const String databaseUrl = "https://console-chat-app-419ed-default-rtdb.firebaseio.com";
  static const String authBaseUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';

  String? idToken;
  String? userEmail;
  String? userUid;

  String getChatId(String user1, String user2){
    final users = [user1, user2]..sort();
    return '${users[0]}_${users[1]}'.replaceAll('@', '_').replaceAll('.', '_');
  }

  Future<bool> signUp(String email, String password) async {
    final url = Uri.parse('$authBaseUrl:signUp?key=$apiKey');
    try{
      final response = await http.post(
        url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final data = jsonDecode(response.body);
      if(response.statusCode == 200){
        print('\nAccount created successfully! Please log in.');
        return true;
      } else {
        print("\nError creating your account: ${data['error']['message']}");
        return false;
      }
    }
    catch(e){
      print("\nError: $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$authBaseUrl:signInWithPassword?key=$apiKey');
    try{
      final response = await http.post(
        url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final data = jsonDecode(response.body);
      if(response.statusCode == 200){
        idToken = data['idToken'];
        userEmail = email;
        userUid = data['localId'];
        print("\nLogin Successful! Welcome $userEmail");
        return true;
      } else {
        print("\nLogin failed! Error: ${data['error']['message']}");
        return false;
      }
    }
    catch(e){
      print(("\nError! $e"));
      return false;
    }
  }

  Future<bool> sendMessage(String recipientEmail, String message) async {
    if(idToken == null){
      print("\nPlease log in to send a message.");
      return false;
    }
    final chatId = getChatId(userEmail!, recipientEmail);
    final url = Uri.parse('$databaseUrl/chats/room1/messages.json?auth=$idToken');
    try{
      final response = await http.post(
        url,
        body: jsonEncode({
        'sender': userEmail,
        'receiver': recipientEmail,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      if(response.statusCode == 200 || response.statusCode == 201){
        print("\nMessage sent successfully sent to $recipientEmail");
        await fetchMessages(recipientEmail);
        return true;
      } else {
        print("\nFailed to send message! ${response.statusCode}");
        await fetchMessages(recipientEmail);
        return false;
      }
    }
    catch(e){
      print("\nError: $e");
      return false;
    }
  }

  Future<void> fetchMessages(String recipientEmail) async {
    if(idToken == null || userEmail == null || userUid == null){
      print("Please log in to fetch messages!");
      return;
    }

    final chatId = getChatId(userEmail!, recipientEmail);
    final url = Uri.parse('$databaseUrl/chats/room1/messages.json?auth=$idToken');
    try {
      final response = await http.get(url);
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        if(data != null){
          print('\n---------- Chat Messages ----------\n');
          data.forEach((key, value) {
            print("[${value['timestamp']}] ${value['user']}: $value['message']");
          });
        } else {
          print("No messages found.");
        }
      } else {
        print("Failed to fetch messages! ${response.statusCode}");
      }
    } catch (e) {
      print("error: $e");
    }
  }

  void logout(){
    idToken = null;
    userEmail = null;
    userUid = null;
    print("\nYou've successfully logged out.");
  }
}