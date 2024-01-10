import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/Birthday_controller.dart';
import '../../models/birthday.dart';
import '../../services/notify_helper.dart';
import '../size_config.dart';
import '../theme.dart';
import '../widgets/BD_tile.dart';
import '../widgets/button.dart';
import 'add_BD_page.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DateTime _selectedDate = DateTime.now();
  final BDController _BDController = Get.put(BDController());

  @override
  void initState() {
    super.initState();
    _BDController.getBD();
  }

  @override
  void dispose() {
    _BDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: context.theme.backgroundColor,
      appBar: _customAppBar(),
      body: Column(
        children: [
          _addBDBar(),
          _addDateBar(),
          _calendar_view(),
          const SizedBox(
            height: 6,
          ),
          _showBD(),
        ],
      ),
    );
  }

  AppBar _customAppBar() {
    return AppBar(
      elevation: 0,
      // ignore: deprecated_member_use
      backgroundColor: context.theme.backgroundColor,
      actions: [
        IconButton(
          icon: Icon(Icons.cleaning_services_outlined,
              size: 24, color: Get.isDarkMode ? Colors.white : darkGreyClr),
          onPressed: () {
            NotifyHelper().cancelAllNotifications();
            _BDController.deleteAllBD();
          },
        ),
        const SizedBox(
          width: 20,
        ),
      ],
      centerTitle: true,
    );
  }

  _addBDBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                'Aujourd\'hui',
                style: subHeadingStyle,
              ),
            ],
          ),
          MyButton(
              label: 'Ajouter Anniversaire',
              onTap: () async {
                await Get.to(() => const AddBDPage());
                _BDController.getBD(date: _selectedDate);
              }),
        ],
      ),
    );
  }

  _calendar_view() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: TableCalendar(
        firstDay: DateTime(DateTime.now().year - 5),
        lastDay: DateTime(DateTime.now().year + 5),
        focusedDay: _selectedDate,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: const CalendarStyle(
          selectedTextStyle: TextStyle(color: Colors.lightBlue),
          todayDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonTextStyle: TextStyle().copyWith(color: Colors.white),
          formatButtonDecoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onDaySelected: (DateTime selectedDate, DateTime focusedDay) {
          _handleDateChange(selectedDate);
        },
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: DatePicker(
        DateTime.now(),
        width: 80,
        height: 100,
        initialSelectedDate: _selectedDate,
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        )),
        dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        )),
        monthTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        )),
        onDateChange: (newDate) async => await _handleDateChange(newDate),
      ),
    );
  }

  Future<void> _handleDateChange(DateTime newDate) async {
    setState(() {
      _selectedDate = newDate;
    });
    await _BDController.getBD(date: _selectedDate);
  }

  Future<void> _onRefresh() async {
    _BDController.getBD();
  }

  _showBD() {
    return Expanded(
      child: Obx(() {
        if (_BDController.BDList.isEmpty) {
          return _noBDMsg();
        } else {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                var bd = _BDController.BDList[index];

                if (bd.repeat == 'Daily' ||
                    bd.date == DateFormat.yMd().format(_selectedDate) ||
                    (bd.repeat == 'Weekly' &&
                        _selectedDate
                                    .difference(
                                        DateFormat.yMd().parse(bd.date!))
                                    .inDays %
                                7 ==
                            0) ||
                    (bd.repeat == 'Monthly' &&
                        DateFormat.yMd().parse(bd.date!).day ==
                            _selectedDate.day)) {
                  try {
                    /*   var hour = task.startTime.toString().split(':')[0];
                    var minutes = task.startTime.toString().split(':')[1]; */
                    var date = DateFormat.jm().parse(bd.startTime!);
                    var myTime = DateFormat('HH:mm').format(date);

                    NotifyHelper().scheduledNotification(
                      int.parse(myTime.toString().split(':')[0]),
                      int.parse(myTime.toString().split(':')[1]),
                      bd,
                    );
                  } catch (e) {
                    print('Error parsing time: $e');
                  }
                } else {
                  Container();
                }
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 1375),
                  child: SlideAnimation(
                    horizontalOffset: 300,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        child: BDTile(bd),
                      ),
                    ),
                  ),
                );
              },
              itemCount: _BDController.BDList.length,
            ),
          );
        }
      }),
    );
  }

  _noBDMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6,
                        )
                      : const SizedBox(
                          height: 220,
                        ),
                  SvgPicture.asset(
                    'images/task.svg',
                    // ignore: deprecated_member_use
                    color: primaryClr.withOpacity(0.5),
                    height: 90,
                    semanticsLabel: 'Task',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'Aucun anniversaire!\n',
                      style: subTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 120,
                        )
                      : const SizedBox(
                          height: 180,
                        ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr,
            ),
            borderRadius: BorderRadius.circular(20),
            color: isClose ? Colors.transparent : clr),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
