///
/// `homepage.dart`
/// Class for homepage GUI
///

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:mediccare/core/appointment.dart';
import 'package:mediccare/core/doctor.dart';
import 'package:mediccare/core/medicine.dart';
import 'package:mediccare/core/medicine_overview_data.dart';
import 'package:mediccare/core/user.dart';
import 'package:mediccare/core/user_setting.dart';
import 'package:mediccare/gui/add_appointment_page.dart';
import 'package:mediccare/gui/add_doctor_page.dart';
import 'package:mediccare/gui/add_medicine_page.dart';
import 'package:mediccare/gui/appointment_page.dart';
import 'package:mediccare/gui/doctor_page.dart';
import 'package:mediccare/gui/edit_appointment_page.dart';
import 'package:mediccare/gui/map_page.dart';
import 'package:mediccare/gui/medicine_page.dart';
import 'package:mediccare/gui/location.dart';
import 'package:mediccare/gui/profile_page.dart';
import 'package:mediccare/util/custom_icons.dart';
import 'package:mediccare/util/firebase_utils.dart';

const kGoogleApiKey = 'AIzaSyA2B775mUfKZPORyzvlUjxlyyalfx0Qd_E';

class Homepage extends StatefulWidget {
  int initialIndex;

  Homepage({Key key, this.initialIndex = 2}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomepageState();
  }
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 2;

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController medicineSearch = new TextEditingController();
  TextEditingController appointmentSearch = new TextEditingController();
  TextEditingController doctorSearch = new TextEditingController();

  Future<List<Doctor>> _getDoctors;
  Future<List<Medicine>> _getMedicines;
  Future<List<Appointment>> _getAppointments;

  Set<Medicine> searchMed;
  bool isMedSearch;
  String searchMedText;

  // Set<Doctor> searchDoc;
  bool isDocSearch;
  String searchDocText;

  _HomepageState() {
    medicineSearch.addListener(() {
      if (medicineSearch.text.isEmpty) {
        setState(() {
          isMedSearch = true;
          searchMedText = '';
        });
      } else {
        setState(() {
          isMedSearch = false;
          searchMedText = medicineSearch.text;
        });
      }
    });

    doctorSearch.addListener(() {
      if (doctorSearch.text.isEmpty) {
        setState(() {
          isDocSearch = true;
          searchDocText = '';
        });
      } else {
        setState(() {
          isDocSearch = false;
          searchDocText = medicineSearch.text;
        });
      }
    });
  }

  // Utility Method: Returns Custom List Tile
  ListTile getCustomListTile({
    String name,
    String subtitle,
    Object icon,
    Widget trailing,
    Function onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(width: 1.0, color: Colors.black38)),
        ),
        child: Icon(icon, color: Colors.blue[300]),
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: <Widget>[
          Icon(Icons.linear_scale, color: Colors.blueAccent),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              subtitle,
              // 'asdfghjklqwertyuiopzxcvbnm,asdfghjk',
              style: TextStyle(
                color: Colors.black54,
              ),
              overflow: TextOverflow.fade,
              softWrap: false,
              maxLines: 1,
            ),
          )
        ],
      ),
      trailing: trailing ??
          Icon(Icons.keyboard_arrow_right, color: Colors.blue[300], size: 30.0),
      onTap: onTap ?? () {},
    );
  }

  // Utility Method: Returns custom card
  Card getCustomCard({
    String name,
    String subtitle,
    Object icon,
    Widget trailing,
    Function onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: getCustomListTile(
          name: name,
          subtitle: subtitle,
          icon: icon,
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }

  // Utility Method: Returns text title
  Text textTitle({String title}) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
        fontFamily: 'Raleway',
        color: Colors.blueGrey,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Utility Method: Returns section divider
  Container getSectionDivider(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Raleway',
          color: Colors.blueGrey[400],
        ),
      ),
    );
  }

  // Utility Method: Returns formatted date
  String getFormattedDate(DateTime dateTime) {
    String month;

    switch (dateTime.month) {
      case 1:
        month = 'January';
        break;
      case 2:
        month = 'February';
        break;
      case 3:
        month = 'March';
        break;
      case 4:
        month = 'April';
        break;
      case 5:
        month = 'May';
        break;
      case 6:
        month = 'June';
        break;
      case 7:
        month = 'July';
        break;
      case 8:
        month = 'August';
        break;
      case 9:
        month = 'September';
        break;
      case 10:
        month = 'October';
        break;
      case 11:
        month = 'November';
        break;
      case 12:
        month = 'December';
        break;
    }
    return dateTime.day.toString() +
        ' ' +
        month +
        ' ' +
        dateTime.year.toString();
  }

  // Map Search Area

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<LatLng> getUserLocation() async {
    var currentLocation = <String, double>{};
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation['latitude'];
      final lng = currentLocation['longitude'];
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
      );
    }
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.overlay,
          language: 'en',
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);

      print(' this is placeID ${p.placeId}');
      showDetailPlace(p.placeId);
    } catch (e) {
      return;
    }
  }
  // End map search Area

  // |---------------------- Medicine List

  // Search Method: Search medicine by name
  void searchListView(List<Medicine> medicines) {
    searchMed = new Set<Medicine>();
    for (int i = 0; i < medicines.length; i++) {
      var item = medicines[i].name;
      searchMedText = medicineSearch.text;
      if (searchMedText.trim() == '' || searchMedText == null) {
        searchMed.add(medicines[i]);
      } else if (item
          .toLowerCase()
          .contains(searchMedText.toLowerCase().trim())) {
        searchMed.add(medicines[i]);
      }
    }
  }

  // Data Method: Returns a list of medicine
  List<Widget> totalMedic(List<Medicine> medicines) {
    List<Widget> list = [
      Padding(
        padding: const EdgeInsets.all(20),
        child: TextField(
          controller: medicineSearch,
          onChanged: (value) {},
          decoration: InputDecoration(
            labelText: 'Search',
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
    ];

    List<Medicine> remainingMedicine = List();
    List<Medicine> emptyMedicine = List();

    if (medicines.length == 0) {
      list.add(Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset('assets/images/medical-grey.png', height: 200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Text(
              'Start adding your medicine now!',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ));
    } else {
      searchListView(medicines);
      if (searchMed != null) {
        searchMed.forEach((m) {
          if (m.remainingAmount == 0) {
            emptyMedicine.add(m);
          } else {
            remainingMedicine.add(m);
          }
        });
      } else {
        medicines.forEach((m) {
          if (m.remainingAmount == 0) {
            emptyMedicine.add(m);
          } else {
            remainingMedicine.add(m);
          }
        });
      }

      if (remainingMedicine.length > 0) {
        list.add(getSectionDivider('Remaining Medicines'));
        remainingMedicine.forEach((e) {
          list.add(
            getCustomCard(
              name: e.name,
              subtitle: e.getSubtitle(),
              icon: CustomIcons.medicine,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicinePage(
                          medicine: e,
                        ),
                  ),
                );
              },
            ),
          );
        });
      }
    }

    if (emptyMedicine.length > 0) {
      list.add(getSectionDivider('Deleted Medicines'));
      emptyMedicine.forEach((e) {
        list.add(
          getCustomCard(
            name: e.name,
            subtitle: e.getSubtitle(),
            icon: CustomIcons.medicine,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicinePage(
                        medicine: e,
                      ),
                ),
              );
            },
          ),
        );
      });
    }

    list.add(SizedBox(height: 40.0));

    return list;
  }

  // GUI Method: Returns GUI of medicine tab
  Container getMedicineListPage() {
    return Container(
      child: FutureBuilder(
          future: _getMedicines,
          builder: (_, medicines) {
            if (medicines.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (medicines.connectionState == ConnectionState.done) {
              return ListView(
                shrinkWrap: true,
                children: totalMedic(medicines.data),
              );
            }
          }),
    );
  }
  // |---------------------- end Medicine List

  // |---------------------- Appointment List

  // Data Method: Returns a list of appointments
  List<Widget> getAppointmentList(List<Appointment> appointmentList) {
    List<Widget> list = [
      // Padding(
      //   padding: const EdgeInsets.all(20),
      //   child: TextField(
      //     onChanged: (value) {},
      //     // controller: ,
      //     decoration: InputDecoration(
      //       labelText: 'Search',
      //       hintText: 'Search',
      //       prefixIcon: Icon(Icons.search),
      //       // border: OutlineInputBorder(
      //       //   borderRadius: BorderRadius.all(Radius.circular(25.0)),
      //       // ),
      //     ),
      //   ),
      // ),
    ];

    appointmentList.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    List<Appointment> comingAppointmentList = List<Appointment>();
    List<Appointment> completedAppointmentList = List<Appointment>();
    List<Appointment> skipAppointmentList = List<Appointment>();
    if (appointmentList.length == 0) {
      list.add(Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset('assets/images/note-grey.png', height: 200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Text(
              'Start adding your appointment now!',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ));
    }
    appointmentList.forEach((a) {
      switch (a.status) {
        case 0:
          comingAppointmentList.add(a);
          break;
        case 1:
          completedAppointmentList.add(a);
          break;
        case 2:
          skipAppointmentList.add(a);
          break;
      }
    });

    if (comingAppointmentList.length > 0) {
      list.add(getSectionDivider('Coming Appointment'));
      comingAppointmentList.forEach((e) {
        list.add(
          getCustomCard(
            name: e.title,
            subtitle: ' ' + e.dateTime.toString().replaceAll(':00.000', ''),
            icon: Icons.local_hospital,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentPage(
                        appointment: e,
                      ),
                ),
              );
            },
          ),
        );
      });
    }

    if (completedAppointmentList.length > 0) {
      list.add(getSectionDivider('Completed Appointment'));
      completedAppointmentList.forEach((e) {
        list.add(
          getCustomCard(
            name: e.title,
            subtitle: ' ' + e.dateTime.toString().replaceAll(':00.000', ''),
            icon: Icons.local_hospital,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentPage(
                        appointment: e,
                      ),
                ),
              );
            },
          ),
        );
      });
    }

    if (skipAppointmentList.length > 0) {
      list.add(getSectionDivider('Skipped Appointment'));
      skipAppointmentList.forEach((e) {
        list.add(
          getCustomCard(
            name: e.title,
            subtitle: ' ' + e.dateTime.toString().replaceAll(':00.000', ''),
            icon: Icons.local_hospital,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentPage(
                        appointment: e,
                      ),
                ),
              );
            },
          ),
        );
      });
    }

    list.add(SizedBox(height: 40.0));

    return list;
  }

  // GUI Method: Returns GUI of appointment tab
  Container getAppointmentListPage() {
    return Container(
      child: FutureBuilder(
        future: _getAppointments,
        builder: (_, appointments) {
          if (appointments.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (appointments.connectionState == ConnectionState.done) {
            return ListView(
              shrinkWrap: true,
              children: getAppointmentList(appointments.data),
            );
          }
        },
      ),
    );
  }

  // |---------------------- end Appointment List

  // |-------------------------- Overview

  // Data Method: Returns list of coming appointments
  List<Widget> getComingAppointmentList(List<Appointment> appointmentList) {
    List<Widget> list = List<Widget>();

    appointmentList.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    List<Appointment> comingAppointmentList = List();

    appointmentList.forEach((a) {
      switch (a.status) {
        case 0:
          comingAppointmentList.add(a);
          break;
      }
    });

    if (comingAppointmentList.length > 0) {
      list.add(textTitle(title: 'Coming Appointments'));
      list.add(SizedBox(height: 20.0));
      comingAppointmentList.forEach((e) {
        String formattedDate = DateFormat('MMM dd | kk:mm').format(e.dateTime);
        list.add(
          getCustomCard(
            name: e.title,
            subtitle: formattedDate,
            // subtitle: e.dateTime.toString().replaceAll(':00.000', '').split(' ').join('\n'),
            // subtitle: e.dateTime.toString(),
            icon: Icons.local_hospital,
            trailing: (DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    ).compareTo(DateTime(
                      e.dateTime.year,
                      e.dateTime.month,
                      e.dateTime.day,
                    )) >=
                    0)
                ? DropdownButtonHideUnderline(
                    child: DropdownButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: 'view',
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor,
                              ),
                              Text('  View'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'check',
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              Text('  Check'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'skip',
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              Text('  Skip'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (dynamic value) {
                        setState(
                          () {
                            if (value == 'check') {
                              e.status = 1;
                            } else if (value == 'skip') {
                              e.status = 2;
                            } else if (value == 'view') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentPage(
                                        appointment: e,
                                      ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  )
                : Icon(Icons.edit, color: Colors.grey),
          ),
        );
      });
    }

    return list;
  }

  // GUI Method: Returns GUI of coming appointments (Part of overview)
  Container getComingAppointmentListWidget() {
    return Container(
      child: FutureBuilder(
        future: _getAppointments,
        builder: (_, appointments) {
          if (appointments.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text('Loading...'),
            );
          } else if (appointments.connectionState == ConnectionState.done) {
            return Column(
              children: getComingAppointmentList(appointments.data),
            );
          }
        },
      ),
    );
  }

  // Data Method: Returns list of remaining indose
  List<Widget> getRemainingIndoseList(List<Medicine> medicineList) {
    List<Widget> list = List<Widget>();

    final List<MedicineOverviewData> medicineOverviewDataList =
        List<MedicineOverviewData>();
    List<DateTime> temp = List<DateTime>();

    for (int i = 0; i < medicineList.length; i++) {
      temp = medicineList[i].getMedicineSchedule(UserSettings());
      for (int j = 0; j < temp.length; j++) {
        medicineOverviewDataList.add(MedicineOverviewData(
          medicine: medicineList[i],
          dateTime: temp[j],
        ));
      }
    }

    medicineOverviewDataList.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (medicineOverviewDataList.length > 0) {
      list.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: textTitle(title: 'Remaining Indose'),
        ),
      );

      List<DateTime> dateList = List<DateTime>();
      medicineOverviewDataList.forEach((e) {
        if (!dateList.contains(
            DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day))) {
          dateList
              .add(DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day));
        }
      });

      dateList.sort((a, b) => a.compareTo(b));

      dateList.length;

      dateList.forEach((e) {
        list.add(
          getSectionDivider((e.compareTo(DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  )) !=
                  0)
              ? getFormattedDate(e)
              : getFormattedDate(e) + ' (Today)'),
        );

        medicineOverviewDataList.forEach((f) {
          if (e.year == f.dateTime.year &&
              e.month == f.dateTime.month &&
              e.day == f.dateTime.day) {
            list.add(
              getCustomCard(
                name: f.medicine.name,
                subtitle: f.getSubtitle(),
                icon: CustomIcons.medicine,
                trailing: (DateTime.now().compareTo(
                                f.dateTime.subtract(Duration(hours: 1))) >
                            0 &&
                        DateTime(
                              f.dateTime.year,
                              f.dateTime.month,
                              f.dateTime.day,
                              f.dateTime.hour,
                              f.dateTime.minute,
                            ).compareTo(medicineOverviewDataList[0].dateTime) ==
                            0)
                    ? DropdownButtonHideUnderline(
                        child: DropdownButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).primaryColor,
                          ),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: 'take',
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  Text('  Take'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'skip',
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  Text('  Skip'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (dynamic value) {
                            setState(() {
                              if (value == 'take') {
                                f.medicine.takeMedicine();
                              } else if (value == 'skip') {
                                f.medicine.skipMedicine();
                              }
                              FirebaseUtils.updateMedicine(f.medicine);
                            });
                          },
                        ),
                      )
                    : Icon(Icons.edit, color: Colors.grey),
              ),
            );
          }
        });
      });
    }
    if (list.length == 0) {
      list.add(Center(
          child: Column(
        children: <Widget>[
          Image.asset(
            'assets/medicine.png',
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "That's no Overview yet, Starting adding yours now!",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800),
            ),
          )
        ],
      )));
    }

    return list;
  }

  // GUI Method: Returns GUI of remaining indose (Part of overview)
  Container getRemainingIndoseListWidget() {
    return Container(
      child: FutureBuilder(
          future: _getMedicines,
          builder: (_, medicines) {
            if (medicines.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text('Loading...'),
              );
            } else if (medicines.connectionState == ConnectionState.done) {
              return Column(
                children: getRemainingIndoseList(medicines.data),
              );
            }
          }),
    );
  }

  // GUI Method: Returns GUI of overview tab
  Widget getOverviewPage() {
    // if (!this._user.containsComingAppointments() &&
    //     !this._user.containsRemainingMedicine()) {
    //   return getSectionDivider(
    //       'Your overview feed is currently empty.\nAdding a medicine or an appointment will show them up here!');
    // }

    return ListView(shrinkWrap: true, children: <Widget>[
      getComingAppointmentListWidget(),
      SizedBox(height: 20.0),
      getRemainingIndoseListWidget(),
      SizedBox(height: 40.0),
    ]);
  }

  // |----------------------end Overview

  // |----------------------Doctor

  // Search Method: Search doctor by full name
  List<Doctor> searchDoctor(List<Doctor> doctors) {
    List<Doctor> searchDoc = List<Doctor>();
    for (int i = 0; i < doctors.length; i++) {
      var item = doctors[i].fullName;
      searchDocText = doctorSearch.text;
      if (searchDocText.trim() == '' || searchDocText == null) {
        searchDoc.add(doctors[i]);
      } else if (item
          .toLowerCase()
          .contains(searchDocText.toLowerCase().trim())) {
        searchDoc.add(doctors[i]);
      }
    }
    return searchDoc;
  }

  // Data Method: Returns a list of doctors
  List<Widget> getDoctorList(List<Doctor> doctors) {
    List<Widget> list = [
      Padding(
        padding: const EdgeInsets.all(20),
        child: TextField(
          onChanged: (value) {},
          controller: doctorSearch,
          // controller: ,
          decoration: InputDecoration(
            labelText: 'Search',
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
    ];
    if (doctors.length != 0) {
      List<Doctor> searchDoctors = searchDoctor(doctors);
      searchDoctors.forEach((e) {
        list.add(
          getCustomCard(
            name: e.prefix + ' ' + e.firstName + ' ' + e.lastName,
            subtitle: ' ' + e.hospital,
            icon: CustomIcons.doctor_specialist,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorPage(
                        doctor: e,
                      ),
                ),
              );
            },
          ),
        );
      });
    } else {
      list.add(Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/doctor-grey.png',
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text('Add your personal doctors now!',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w500)),
            )
          ],
        ),
      ));
    }

    list.add(SizedBox(height: 40.0));

    return list;
  }

  // GUI Method: Returns GUI of doctor tab
  Container getDoctorListPage() {
    return Container(
      child: FutureBuilder(
        future: _getDoctors,
        builder: (_, doctors) {
          if (doctors.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (doctors.connectionState == ConnectionState.done) {
            return ListView(
              shrinkWrap: true,
              children: getDoctorList(doctors.data),
            );
          }
        },
      ),
    );
  }

  void refreshState() {
    setState(() {});
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text('MedicCare'),
          content: Text('Payload : $payload'),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getDoctors = FirebaseUtils.getDoctors();
    _getMedicines = FirebaseUtils.getMedicines();
    _getAppointments = FirebaseUtils.getAppointments();
    this._currentIndex = widget.initialIndex;

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        Map<String, dynamic> notification =
            Map<String, dynamic>.from(message['notification']);

        Future _showNotification() async {
          var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
              'mediccare', 'MedicCare', 'MedicCare App',
              importance: Importance.Max, priority: Priority.High);
          var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
          var platformChannelSpecifics = new NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
          await flutterLocalNotificationsPlugin.show(
            0,
            notification['title'],
            notification['body'],
            platformChannelSpecifics,
          );
        }

        _showNotification();

        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).primaryColor;
    final List<List<IconButton>> actions = <List<IconButton>>[
      // Index 0 : Medicine
      <IconButton>[
        IconButton(
          icon: Icon(
            Icons.add,
            color: color,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMedicinePage(),
              ),
            );
          },
        ),
      ],

      // Index 1 : Appointment
      <IconButton>[
        IconButton(
          icon: Icon(
            Icons.add,
            color: color,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAppointmentPage(),
              ),
            );
          },
        ),
      ],

      // Index 2 : Overview
      <IconButton>[
        IconButton(
          icon: Icon(Icons.help, color: Colors.blue),
          onPressed: () {
            Navigator.pushNamed(context, 'IntroPage');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.account_circle,
            color: color,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ],

      // Index 3 : Doctor
      <IconButton>[
        IconButton(
          icon: Icon(
            Icons.add,
            color: color,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDoctorPage(),
              ),
            );
          },
        ),
      ],

      // Index 4 : Hospital
      <IconButton>[
        IconButton(
          icon: Icon(Icons.search),
          color: color,
          onPressed: () {
            _handlePressButton();
          },
        ),
      ],
    ];

    List<Widget> pages = <Widget>[
      getMedicineListPage(),
      getAppointmentListPage(),
      getOverviewPage(),
      getDoctorListPage(),
      MapPage(),
    ];

    List headerTitle = [
      Text('Medicine List', style: TextStyle(color: Colors.blueGrey)),
      Text('Appointment List', style: TextStyle(color: Colors.blueGrey)),
      Text('MedicCare', style: TextStyle(color: Colors.blueGrey)),
      Text('Doctor List', style: TextStyle(color: Colors.blueGrey)),
      Text('Nearby Hospitals', style: TextStyle(color: Colors.blueGrey))
    ];

    return Scaffold(
      appBar: AppBar(
        title: headerTitle[this._currentIndex],
        centerTitle: true,
        elevation: 0.1,
        backgroundColor: Colors.white.withOpacity(0.9),
        actions: actions[this._currentIndex],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 2;
          });
        },
        child: Icon(Icons.face),
        elevation: 3.0,
      ),
      body: pages[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 13.5,
        unselectedFontSize: 11.5,
        type: BottomNavigationBarType.fixed,
        currentIndex: this._currentIndex,
        onTap: (int i) {
          setState(() {
            this._currentIndex = i;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.medicine),
            title: Text('Medicine'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle),
            title: Text('Appointment'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy, color: Colors.white),
            title: Text('Overview'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.doctor_specialist),
            title: Text('Doctor'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            title: Text('Hospital'),
          ),
        ],
      ),
    );
  }
}
