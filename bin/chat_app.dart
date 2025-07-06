import 'dart:io';
import 'package:chat_app/chat_app.dart';

void main() async {
  final chatApp = FirebaseChatApp();

  while (true) {
    if (chatApp.idToken == null) {
      print("=============== CHAT APP ===============");
      print("1. Sign Up");
      print("2. Login");
      print("3. Exit\n");

      String? input = stdin.readLineSync()?.trim();
      if (input == null || input.isEmpty) {
        print('Invalid input! Please try again.');
        continue;
      }

      if (input == '1') {
        stdout.write("Enter your email: ");
        final email = stdin.readLineSync()?.trim();
        if (email == null || email.isEmpty) {
          print("Please enter your email to continue.");
          continue;
        }
        stdout.write("Enter your password: ");
        final password = stdin.readLineSync()?.trim();
        if (password == null || password.isEmpty) {
          print("Please enter your password to continue.");
          continue;
        }

        await chatApp.signUp(email, password);
      } else if (input == '2') {
        stdout.write("Enter your email: ");
        final email = stdin.readLineSync()?.trim();
        if (email == null || email.isEmpty) {
          print("Please enter your email to continue.");
          continue;
        }
        stdout.write("Enter your password: ");
        final password = stdin.readLineSync()?.trim();
        if (password == null || password.isEmpty) {
          print("Please enter your password to continue.");
          continue;
        }
        await chatApp.login(email, password);
      } else if (input == '3') {
        print("Exiting the Chat App. Goodbye!");
        return;
      } else {
        print("Invalid choice! Please try again.");
      }
    } else {
      while (chatApp.idToken != null) {
        print("\n---------- CHAT ROOM ----------");
        print("You're signed in as ${chatApp.userEmail}\n");
        print("1. Send a Message");
        print("2. Logout\n");

        final input = stdin.readLineSync()?.trim();
        if (input == null) {
          print('Invalid input! Please try again.');
          continue;
        }

        if (input == '1') {
          stdout.write("Enter recipient's email: ");
          final recipient = stdin.readLineSync()?.trim();
          if (recipient == null || recipient.isEmpty) {
            print("Recipient's email cannot be empty!");
            continue;
          }

          if (await chatApp.checkEmailExists(recipient)) {
            chatApp.startChatPolling(chatApp, recipient);
            print(
              'Chatting with $recipient... Type "exit" to exit this chat room.\n',
            );
            while (true) {
              stdout.write(
                "Enter your message (or 'exit' to exit the chat room):\n\n",
              );
              final message = stdin.readLineSync()?.trim();
              if (message == null || message.isEmpty) {
                print('Message cannot be empty!!! Please Enter your message:');
                continue;
              }
              if (message.toLowerCase() == 'exit') {
                chatApp.messagePollingTimer?.cancel();
                break;
              } else {
                await chatApp.sendMessage(recipient, message);
              }
            }
          }
        } else if (input == '2') {
          chatApp.messagePollingTimer?.cancel();
          print("Logging out...");
          chatApp.logout();
          break;
        } else {
          print("Invalid option! Please try again.");
        }
      }
    }
  }
}
