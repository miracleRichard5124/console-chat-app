import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseChatApp {
  static const String apiKey = "AIzaSyCQ0tvRkGuVUNykL-a1opsdqFZa2q1w3Vg";
  static const String databaseUrl = "https://console-chat-app-419ed-default-rtdb.firebaseio.com";
  static const String authBaseUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';

  String? idToken;
  String? userEmail;

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

  Future<bool> sendMessage(String message) async {
    if(idToken == null){
      print("\nPlease log in to send a message.");
      return false;
    }
    final url = Uri.parse('$databaseUrl/chats/room1/messages.json?auth=$idToken');
    try{
      final response = await http.post(
        url,
        body: jsonEncode({
        'user': userEmail,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      }),
      );
      if(response.statusCode == 200 || response.statusCode == 201){
        print("\nMessage sent successfully!");
        return true;
      } else {
        print("\nFailed to send message! ${response.statusCode}");
        return false;
      }
    }
    catch(e){
      print("\nError: $e");
      return false;
    }
  }

  Future<void> fetchMessages() async {
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
    print("\nYou've successfully logged out.");
  }
}