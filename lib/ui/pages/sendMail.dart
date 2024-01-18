import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

sendEmail(BuildContext context ,String text, DateTime birthdayDate, String contactName, String description//For showing snackbar
    ) async {
  String username = 'zakaria.chelbi.pro@gmail.com'; //Your Email
  String password =
      'ihxs quzs miop wjri'; // 16 Digits App Password Generated From Google Account
  String formattedDate = DateFormat('dd/MM/yyyy').format(birthdayDate);

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.

  if (text=="vous avez supprimé tout les anniversaires! "){
    final message = Message()
      ..from = Address(username, 'zakaria chelbi')
      ..recipients.add('zakaria.chelbi@esprit.tn')
    // ..ccRecipients.addAll(['abc@gmail.com', 'xyz@gmail.com']) // For Adding Multiple Recipients
    // ..bccRecipients.add(Address('a@gmail.com')) For Binding Carbon Copy of Sent Email
      ..subject = 'BIRTHDAY APP REMINDER !  '
      ..text = text+" "+"\n"+"le "+formattedDate+"\n";
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>"; // For Adding Html in email
    // ..attachments = [
    //   FileAttachment(File('image.png'))  //For Adding Attachments
    //     ..location = Location.inline
    //     ..cid = '<myimg@3.141>'
    // ]
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Mail Send Successfully")));
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }

  }
else {
    final message = Message()
      ..from = Address(username, 'zakaria chelbi')
      ..recipients.add('zakaria.chelbi@esprit.tn')
    // ..ccRecipients.addAll(['abc@gmail.com', 'xyz@gmail.com']) // For Adding Multiple Recipients
    // ..bccRecipients.add(Address('a@gmail.com')) For Binding Carbon Copy of Sent Email
      ..subject = 'BIRTHDAY APP REMINDER !  '
      ..text = text + contactName + "\n" + "le " + formattedDate + "\n" +
          "description :" + description;
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>"; // For Adding Html in email
    // ..attachments = [
    //   FileAttachment(File('image.png'))  //For Adding Attachments
    //     ..location = Location.inline
    //     ..cid = '<myimg@3.141>'
    // ]
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Mail Send Successfully")));
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
      ;


}