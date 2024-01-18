import 'dart:io'; // Add this import for File
import 'package:bd_reminder/ui/pages/sendMail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/Birthday_controller.dart';
import '../../models/birthday.dart';
import '../theme.dart';
import '../widgets/button.dart';
import '../widgets/input_field.dart';

class AddBDPage extends StatefulWidget {
  const AddBDPage({Key? key}) : super(key: key);

  @override
  State<AddBDPage> createState() => _AddBDPageState();
}

class _AddBDPageState extends State<AddBDPage> {
  final BDController _BDController = Get.put(BDController());
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late Contact _selectedContact;

  DateTime _selectedDate = DateTime.now();
  String _startTime =
  DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();

  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = 'None';
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];

  int _selectedColor = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
    _selectedContact = Contact();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _customAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _importContact();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Background color
                  onPrimary: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add), // Icon before text
                      SizedBox(width: 8.0),
                      Text(
                        'Importer un contact',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),

              InputField(
                title: 'Titre',
                hint: 'Entrez titre',
                controller: _titleController,
              ),
              InputField(
                title: 'Description',
                hint: 'Entrez la description',
                controller: _noteController,
              ),
              InputField(
                title: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () => _getDateFromUser(),
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: 'heure de début',
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: InputField(
                      title: 'heure de fin',
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                title: 'Remind',
                hint: '$_selectedRemind minutes early',
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      items: remindList
                          .map<DropdownMenuItem<String>>(
                              (int value) => DropdownMenuItem(
                              value: value.toString(),
                              child: Text(
                                '$value',
                                style: const TextStyle(color: Colors.white),
                              )))
                          .toList(),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      style: subTitleStyle,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRemind = int.parse(newValue!);
                        });
                      },
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                  ],
                ),
              ),
              InputField(
                title: 'Répeter',
                hint: _selectedRepeat,
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      items: repeatList
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.white),
                              )))
                          .toList(),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      style: subTitleStyle,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRepeat = newValue!;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  MyButton(
                    label: 'Créer anniversaire',
                    onTap: () async {
                      // Send email using mailer package
                     await sendEmail(context,
                       "vous avez ajouté l'anniversaire de ",
                       _selectedDate,
                       _selectedContact.givenName ?? 'Unknown',
                       _noteController.text,
                     );

                      // Continue with other actions
                      _validateData();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _customAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 24,
          color: primaryClr,
        ),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      actions: const [
        SizedBox(
          width: 20,
        ),
      ],
      centerTitle: true,
    );
  }

  _validateData() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addBDToDb();
      Get.back();
      _BDController.getBD(
          date: _selectedDate); // Assurez-vous que la méthode getBD est appelée ici
    } else if (_titleController.text.isNotEmpty ||
        _noteController.text.isNotEmpty) {
      Get.snackbar('Requis', 'Tous les champs sont requis!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ));
    } else {
      print('Something wrong happened');
    }
  }

  Future<void> _addBDToDb() async {
    try {
      int value = await _BDController.addBD(
        bd: Birthday(
          title: _titleController.text,
          note: _noteController.text,
          isCompleted: 0,
          date: _selectedDate
              .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)
              .toUtc()
              .toString(),
          startTime: _startTime,
          endTime: _endTime,
          color: _selectedColor,
          remind: _selectedRemind,
          repeat: _selectedRepeat,
        ),
      );
      print('Value: $value');
    } catch (e) {
      print('error: $e');
    }
  }

  Column _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: titleStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          children: List<Widget>.generate(
            3,
                (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: CircleAvatar(
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                      ? pinkClr
                      : orangeClr,
                  radius: 14,
                  child: _selectedColor == index
                      ? const Icon(
                    Icons.done,
                    size: 16,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _getDateFromUser() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    } else {
      print('Please select the correct date');
    }
  }

  Future<void> _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
          DateTime.now().add(const Duration(minutes: 15))),
    );

    String formattedTime = pickedTime!.format(context);

    if (isStartTime) {
      setState(() => _startTime = formattedTime);
    } else if (!isStartTime) {
      setState(() => _endTime = formattedTime);
    } else {
      print('Something went wrong!');
    }
  }

  Future<void> _importContact() async {
    var status = await Permission.contacts.request();

    if (status.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select a contact'),
          content: SizedBox(
            height: 200,
            width: 300,
            child: ListView(
              children: contacts.map((contact) {
                return ListTile(
                  title: Text('${contact.givenName} ${contact.familyName}'),
                  onTap: () {
                    Navigator.pop(context, contact);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ).then((selectedContact) {
        if (selectedContact != null) {
          setState(() {
            _selectedContact = selectedContact;
            _titleController.text =
            '${selectedContact.givenName} ${selectedContact.familyName}';

            // Extract day and month from contact's birthday
            int day = selectedContact.birthday?.day ?? 1;
            int month = selectedContact.birthday?.month ?? 1;

            // Set the selected date with the extracted day and month and current year
            _selectedDate = DateTime(DateTime.now().year, month, day);

            _noteController.text =
            "c'est l'anniversaire de ${selectedContact.givenName}";
          });
        }
      });
    } else {
      print('Contact permission denied');
    }
  }
}
