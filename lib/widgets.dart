import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget button(text, txtColor, color, context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.6,
    height: MediaQuery.of(context).size.height * 0.07,
    child: Center(
        child: Text(text, style: TextStyle(color: txtColor, fontSize: 16.0))),
    color: color,
  );
}

appBar(text, context,type) {
  return AppBar(
    actions: [
      type==0?SizedBox():IconButton(
      icon: Icon(Icons.close, color: Colors.black,),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    ],
    title: Center(
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 30.0),
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

Widget therapistDashboard() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Welcome Leon!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                        child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    )),
                  )
                ],
              ),
            ),
            therapistRow("Patients", "20"),
            therapistRow("Sponsors", "12"),
            therapistRow("Points Earned", "300"),
            therapistRow("Hours Practiced", "20"),
          ],
        ),
      ),
    );
  }

  Widget therapistRow(text1, text2) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1 + " :",
            style: TextStyle(color: Colors.white),
          ),
          Text(text2, style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  Widget patientCard(context, name, condition, apptDate) {
    return Center(
      child: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          width: MediaQuery.of(context).size.width - 20,
          decoration: BoxDecoration(
              color: Colors.white30, borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              therapistRow('Name', name),
              therapistRow('Condition', condition),
              therapistRow('Appt Date', apptDate)
            ],
          )),
    );
  }
Widget therapistCard(context, name, hoursPracticed, patients) {
    return Center(
      child: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          width: MediaQuery.of(context).size.width - 20,
          decoration: BoxDecoration(
              color: Colors.white30, borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              therapistRow('Name', name),
              therapistRow('Hours Practiced', hoursPracticed),
              therapistRow('Patients', patients)
            ],
          )),
    );
  }
  Widget therapistSessionCard(context, name, licenseId, time) {
    return Center(
      child: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          width: MediaQuery.of(context).size.width - 20,
          decoration: BoxDecoration(
              color: Colors.white30, borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              therapistRow('Name', name),
              therapistRow('License ID', licenseId),
              therapistRow('Time:', time)
            ],
          )),
    );
  }
  showToast(message){
Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
loader(){
  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: SpinKitSquareCircle(
      color: Colors.white,
      size: 50.0,
),
    ),
  );
}
whiteloader(){
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: SpinKitSquareCircle(
      color: Colors.black,
      size: 50.0,
),
    ),
  );
}