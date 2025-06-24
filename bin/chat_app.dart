import 'dart:io';
import 'package:chat_app/chat_app.dart';

void main() async {
  final chatApp = FirebaseChatApp();

  while(true){
    if(chatApp.idToken == null){
      print("=============== CHAT APP ===============");
      print("1. Sign Up");
      print("2. Login");
      print("3. Exit\n");

      String? input = stdin.readLineSync();
      if(input == null) continue;
      if(input == '1'){
        stdout.write("Enter your email: ");
        final email = stdin.readLineSync();
        if( email == null || email.isEmpty){
          print("Please enter your email to continue.");
          continue;
        }
        stdout.write("Enter your password: ");
        final password = stdin.readLineSync();
        if(password == null || password.isEmpty){
          print("Please enter your password to continue.");
          continue;
        }
        await chatApp.signUp(email, password);
      } else if( input == '2'){
        stdout.write("Enter your email: ");
        final email = stdin.readLineSync();
        if( email == null || email.isEmpty){
          print("Please enter your email to continue.");
          continue;
        }
        stdout.write("Enter your password: ");
        final password = stdin.readLineSync();
        if(password == null || password.isEmpty){
          print("Please enter your password to continue.");
          continue;
        }
        await chatApp.login(email, password);
      } else if(input == '3'){
        print("Exiting the Chat App. Goodbye!");
        return;
      } else {
        print("Invalid choice! Please try again.");
      }
    } else {
      print("\n---------- CHAT ROOM ----------");
      print("You're signed in as ${chatApp.userEmail}\n");
      print("1. Send Message");
      print("2. Fetch Messages");
      print("3. Exit");
      
      final input = stdin.readLineSync();

      if(input == '1'){
        stdout.write("Enter your message:\n\n");
        final message = stdin.readLineSync();
        if(message != null && message.isNotEmpty){
          await chatApp.sendMessage(message);
        } else {
          print("Message cannot be empty. Please try again.");
        }
      } else if(input == '2'){
        await chatApp.fetchMessages();
      } else if(input == '3'){
        chatApp.logout();
      } else {
        print("Invalid option! Please try again.");
      }
    }
  }
}

