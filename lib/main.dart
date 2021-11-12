import 'dart:io' as r;

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:umoja/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return MaterialApp(
      title: 'Umoja',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(initialization: _initialization),
    );
  }
}

class LandingPage extends StatefulWidget {
  final initialization;
  const LandingPage({Key? key, @required this.initialization})
      : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // check if user is logged in
  // later

  // FirebaseAuth auth = FirebaseAuth.instance;
  // bool loading = true;

  // isLoggedIn() {
  //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //     if (user == null) {
  //       setState(() {
  //         loading = false;
  //         print('user is not signed in');
  //       });
  //     } else {
  //       loading = false;
  //       print('User is signed in!');
  //     }
  //   });
  // }
  // write a function to find type of user and log them in acordingly

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: widget.initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return showToast("Something went wrong");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: appBar("umoja", context, 0),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child:
                          button('Login', Colors.white, Colors.blue, context)),
                  SizedBox(height: 10),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpSelect()));
                      },
                      child: button(
                          'Sign Up', Colors.black, Colors.white, context))
                ],
              ),
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return loader();
      },
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();

  logIn() {
    auth
        .signInWithEmailAndPassword(email: email.text, password: password.text)
        .then((value) {
      // log in user
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TherapistHomePage()));
    }).onError((error, stackTrace) {
      showToast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar("login", context, 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter your email',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter your password',
                  ),
                ),
              ),
              GestureDetector(
                  onTap: logIn,
                  child: button("Log In", Colors.white, Colors.blue, context))
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpSelect extends StatefulWidget {
  const SignUpSelect({Key? key}) : super(key: key);

  @override
  _SignUpSelectState createState() => _SignUpSelectState();
}

class _SignUpSelectState extends State<SignUpSelect> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Sign Up", context, 0),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Who are you signing up as?",
                    style: TextStyle(fontSize: 20.0)),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUp(type: 1)));
                  },
                  child:
                      button('A Therapist', Colors.white, Colors.blue, context),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUp(type: 2)));
                  },
                  child:
                      button('A Patient', Colors.white, Colors.blue, context),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUp(type: 3)));
                  },
                  child:
                      button('A Sponsor', Colors.white, Colors.blue, context),
                ),
              ],
            ),
          ),
        ));
  }
}

class SignUp extends StatefulWidget {
  final type;
  const SignUp({Key? key, @required this.type}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return widget.type == 1
        ?
        // Therapist
        TherapistSignUp()
        : widget.type == 2
            ?
            // Patient
            PatientSignUp()
            :
            // Sponsor
            SponsorSignUp();
  }
}

class TherapistSignUp extends StatefulWidget {
  const TherapistSignUp({Key? key}) : super(key: key);

  @override
  _TherapistSignUpState createState() => _TherapistSignUpState();
}

typedef void OnPickImageCallback(
    double? maxWidth, double? maxHeight, int? quality);

class _TherapistSignUpState extends State<TherapistSignUp> {
  // with Init state check whether user has been signed in
  // if yes chack status
  // if incomplete or under review
  // if incomplwtw profileStatus=
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore store = FirebaseFirestore.instance;
  // sign up the user
  String driversId = '', selfId = '';
  bool loading = false;
  TextEditingController names = new TextEditingController();
  TextEditingController phoneNumbers = new TextEditingController();
  TextEditingController emailAddress = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController licenseNo = new TextEditingController();
  TextEditingController licenseType = new TextEditingController();
  TextEditingController dateofIssue = new TextEditingController();
  TextEditingController expirationDate = new TextEditingController();
  TextEditingController professionalBio = new TextEditingController();

  bool checkIfPasswordsMatch() {
    bool mybool = true;
    if (password.text != confirmPassword.text) {
      print(password.value);
      print(password.text);
      mybool = false;
      showToast("Passwords do not match");
    }
    return mybool;
  }

  createUser() {
    setState(() {
      loading = true;
    });
    if (checkIfPasswordsMatch()) {
      auth
          .createUserWithEmailAndPassword(
              email: emailAddress.text, password: password.text)
          .then((value) {
        nextStep();
        setState(() {
          loading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          profileStatus = 0;
          loading = false;
        });
        showToast(error.toString());
      });
    }
  }

  createTherapistProfile(name, selfId, driversId, therapistId, phone, email,
      status, license, accType) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users.add({
      'name': name, // John Doe
      'selfId': selfId, // Stokes and Sons
      'driversId': driversId,
      'therapistId': therapistId,
      'phone': phone,
      'email': email,
      'status': status,
      'licenseNo': license,
      'accType': accType,
      'professionalBio': professionalBio.text,
    }).then((value) {
      createLicenseInformation(therapistId, licenseNo.text, state.text,
          city.text, licenseType.text, expirationDate.text, dateofIssue.text);
    }).catchError((error) => showToast("Failed to add user: $error"));
  }

  createLicenseInformation(therapistId, licenseNo, state, city, licenseType,
      expirationDate, dateofIssue) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('licenses');
    return users.add({
      'therapistId': therapistId, // John Doe
      'licenseNo': licenseNo, // Stokes and Sons
      'state': state,
      'city': city,
      'licenseType': licenseType,
      'expirationDate': expirationDate,
      'dateofIssue': dateofIssue,
    }).then((value) {
      createTherapistWallet(therapistId, 0, 0, 0, 0, 0);
    }).catchError((error) => showToast("Failed to add Lincese: $error"));
  }

  createTherapistWallet(therapistId, patients, monthlySponsors, oTsponsors,
      hoursDone, pointsEarned) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('therapistWallets');
    return users.add({
      'therapistId': therapistId, // John Doe
      'patients': patients, // Stokes and Sons
      'monthlySponsors': monthlySponsors,
      'oTSponsors': oTsponsors,
      'hours': hoursDone,
      'points': pointsEarned,
    }).then((value) {
      showToast("Account Created Successfully");
      setState(() {
        nextStep();
        loading = false;
      });
    }).catchError((error) => showToast("Failed to add Lincese: $error"));
  }

  createTherapist() {
    setState(() {
      loading = true;
    });
    final User? user = auth.currentUser;
    final therapistId = user!.uid;
    // fields selfId, driversId,therapistId,phone,email,name,status,licenseNo, accType
    createTherapistProfile(names.text, selfId, driversId, therapistId,
        phoneNumbers.text, emailAddress.text, 2, licenseNo.text, 'Therapist');
    // fields licenseNo,state,City,licenseType,expirationDate, DateofIssue
    // createLicenseInformation(therapistId, licenseNo.text, state.text, city.text,
    //     licenseType.text, expirationDate.text, dateofIssue.text);
    // fields therapistId, patients, monthlySponsors, OTsponsors, hoursDone, pointsEarned
    // createTherapistWallet(therapistId, 0, 0, 0, 0, 0);
  }


  firebase_storage.FirebaseStorage storage =  firebase_storage.FirebaseStorage.instance;
  submitSelfId() {}

  int profileStatus = 0;

  // // Pick an image
  // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  // // Capture a photo
  // final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  nextStep() {
    setState(() {
      profileStatus = profileStatus + 1;
    });
  }

  final ImagePicker _picker = ImagePicker();
  final ImagePicker _driversLicensePicker = ImagePicker();

  dynamic _pickImageError;
  bool isVideo = false;

  XFile? _selfIdPicture;
  XFile? _driversLicense;
  String? _retrieveDataError;

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    final LostDataResponse dlresponse =
        await _driversLicensePicker.retrieveLostData();
    if (response.isEmpty || dlresponse.isEmpty) {
      return;
    }
    if (dlresponse.file != null) {
      setState(() {
        _driversLicense = dlresponse.file;
      });
    }
    if (response.file != null) {
      setState(() {
        _selfIdPicture = response.file;
      });
    } else if (response.file == null) {
      _retrieveDataError = response.exception!.code;
    } else {
      _retrieveDataError = dlresponse.exception!.code;
    }
  }

  void _takePicture(type) async {
    if (type == 1) {
      try {
        final pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
        );
        setState(() {
          _selfIdPicture = pickedFile;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    } else {
      try {
        final pickedFile = await _driversLicensePicker.pickImage(
          source: ImageSource.camera,
        );
        setState(() {
          _driversLicense = pickedFile;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Therapist", context, 1),
        body: loading == true
            ? whiteloader()
            : profileStatus == 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        Text("Personal Info"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: names,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'First and Last Name',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: phoneNumbers,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Phone Number',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: emailAddress,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Email Address',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Password',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: confirmPassword,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Confirm Password',
                            ),
                          ),
                        ),
                        GestureDetector(
                            onTap: createUser,
                            child: button(
                                "Next", Colors.white, Colors.black, context))
                      ],
                    ),
                  )
                : profileStatus == 1
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(children: [
                          Text("Self Identification"),
                          Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: _selfIdPicture != null
                                  ? Image.file(r.File(_selfIdPicture!.path))
                                  : SizedBox()),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                _takePicture(1);
                              },
                              child: button(
                                  _selfIdPicture != null
                                      ? "Retake Self Id Picture"
                                      : "Take Self Id Picture",
                                  Colors.white,
                                  Colors.black,
                                  context),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                              onTap: nextStep,
                              child: button(
                                  "Next", Colors.white, Colors.black, context))
                        ]),
                      )
                    : profileStatus == 2
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView(children: [
                              Text("Self Identification"),
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: _driversLicense != null
                                      ? Image.file(
                                          r.File(_driversLicense!.path))
                                      : SizedBox()),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _takePicture(2);
                                  },
                                  child: button(
                                      _selfIdPicture != null
                                          ? "Retake Driver's License Picture"
                                          : "Take Driver's License Picture",
                                      Colors.white,
                                      Colors.black,
                                      context),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                  onTap: nextStep,
                                  child: button("Next", Colors.white,
                                      Colors.black, context))
                            ]),
                          )
                        : profileStatus == 3
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView(
                                  children: [
                                    Text("License Information"),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: state,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'State you Practice',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: licenseNo,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'License Number',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: licenseType,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'License Type',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: dateofIssue,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Date of Issue',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: expirationDate,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Date of Expiration',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: TextFormField(
                                        controller: city,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'City or Zip Code',
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: nextStep,
                                        child: button("Next", Colors.white,
                                            Colors.black, context))
                                  ],
                                ),
                              )
                            : profileStatus == 4
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView(
                                      children: [
                                        Text("Profesional Bio"),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 16),
                                          child: TextFormField(
                                            // expands: true,
                                            controller: professionalBio,
                                            maxLines: 30,
                                            minLines: 1,
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText:
                                                  'Type your Professional Bio Here',
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: createTherapist,
                                            child: button(
                                                "Finish",
                                                Colors.white,
                                                Colors.black,
                                                context))
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                    children: [
                                      Text(
                                          "Thank you for your Sumbmission. Your Account is under review"),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(type: 0)));
                                        },
                                        child: button("Next", Colors.white,
                                            Colors.white, context),
                                      )
                                    ],
                                  )));
  }
}

class HomePage extends StatefulWidget {
  final type;
  const HomePage({Key? key, @required this.type}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return widget.type == 0 ? TherapistHomePage() : Container();
  }
}

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({Key? key}) : super(key: key);

  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
                    text: 'Dashboard',
                  ),
                  Tab(
                    icon: Icon(Icons.watch_later_outlined, color: Colors.grey),
                    text: 'Sessions',
                  ),
                  Tab(
                    icon: Icon(Icons.book_outlined, color: Colors.grey),
                    text: 'My Patients',
                  ),
                  Tab(
                    icon: Icon(Icons.person_add_alt, color: Colors.grey),
                    text: 'Requests',
                  ),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
            ),
            body: TabBarView(children: [
              ListView(
                children: [
                  therapistDashboard(),
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Upcoming sessions",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewPatient()));
                            },
                            child: patientCard(
                                context, 'Leon', "ADHD", 'Today at 2:15pm')),
                      ],
                    ),
                  ),
                ],
              ),
              ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sessions",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm')
                      ],
                    ),
                  ),
                ],
              ),
              ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("My Patients",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm')
                      ],
                    ),
                  ),
                ],
              ),
              ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Requests",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm'),
                        patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm')
                      ],
                    ),
                  ),
                ],
              ),
            ])),
      ),
    );
  }
}

class ViewPatient extends StatefulWidget {
  final userId, name, condition;

  const ViewPatient({Key? key, this.userId, this.name, this.condition})
      : super(key: key);

  @override
  _ViewPatientState createState() => _ViewPatientState();
}

class _ViewPatientState extends State<ViewPatient> {
  // ignore: non_constant_identifier_names
  DateTime initial = new DateTime(2021, 11, 13);
  DateTime endDate = new DateTime(2022, 12, 12);
  showDatePicker() {
    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
            headerColor: Colors.black,
            backgroundColor: Colors.black,
            cancelStyle: TextStyle(color: Colors.red),
            itemStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
        showTitleActions: true,
        minTime: DateTime(2021, 11, 13),
        maxTime: DateTime(2023, 10, 12), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  showTimePicker() {
    DatePicker.showTimePicker(context,
        showTitleActions: true,
        showSecondsColumn: false,
        theme: DatePickerTheme(
            headerColor: Colors.black,
            backgroundColor: Colors.black,
            cancelStyle: TextStyle(color: Colors.red),
            itemStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
        onChanged: (time) {},
        onConfirm: (time) {},
        currentTime: DateTime.now(),
        locale: LocaleType.en);
  }

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Text("Schedule Session",
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.normal)),
      ),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  showDatePicker();
                },
                child:
                    button('Select Date', Colors.white, Colors.black, context)),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  showTimePicker();
                },
                child:
                    button('Select Time', Colors.white, Colors.black, context)),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              width: MediaQuery.of(context).size.width * 0.3,
              child: Center(
                  child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ))),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              width: MediaQuery.of(context).size.width * 0.3,
              color: Colors.blue,
              child: Center(
                  child: Text(
                'Done',
                style: TextStyle(color: Colors.white),
              ))),
        )
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
                text: 'Profile',
              ),
              Tab(
                icon: Icon(Icons.book_outlined, color: Colors.grey),
                text: 'Notes',
              ),
              Tab(
                icon: Icon(Icons.watch_later_outlined, color: Colors.grey),
                text: 'Sessions',
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(children: [
          ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Leon Kipkoech",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TakeNotes()));
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TakeNotes()));
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Icon(
                                Icons.message,
                                color: Colors.white,
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TakeNotes()));
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: button("Begin New Session", Colors.black,
                                  Colors.white, context)),
                        ),
                      ],
                    ),

                    // patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm')

                    therapistRow('Condition', 'Leon Kipkoech'),
                    therapistRow('Number of Appointments', '10'),
                    // Text("M.A.R",
                    //     style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 30,
                    //         fontWeight: FontWeight.bold)),
                    // therapistRow('1', 'Gabapentin'),
                    // therapistRow('2', 'Trazodone'),
                    Text("Summary",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "dkjsdfkasfsd fasdfbasdfhasd fsadfasdfasbdf asdfasdfasdfas dfasdf asdf sf sdf sd fsdfsdf sdf sdf sdf sfsd fsd",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        //  decoration: TextDecoration.underline,
                        // decorationStyle: TextDecorationStyle.wavy,
                        // decorationColor: Colors.white,
                        // decorationThickness: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Text("Patient Notes",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm')
                    ],
                  ),
                ),
              ),
            ],
          ),
          ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Text("Upcoming Sessions",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          showAlertDialog(context);
                        },
                        child: Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            child: button("Schedule Session", Colors.black,
                                Colors.white, context)),
                      ),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm'),
                      patientCard(context, 'Leon Kipoech', 'ADHD',
                          'Yesterday at 2:15pm')
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class TakeNotes extends StatefulWidget {
  const TakeNotes({Key? key}) : super(key: key);

  @override
  _TakeNotesState createState() => _TakeNotesState();
}

class _TakeNotesState extends State<TakeNotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text("Notes")),
      body: ListView(
        children: [
          Container(
              padding: EdgeInsets.all(10),
              child: therapistRow('date: ', DateTime.now().toString())),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: TextFormField(
              minLines: 200,
              maxLines: 1100,
              autofocus: true,
              style: TextStyle(fontSize: 23, color: Colors.white),
              showCursor: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Start Typing',
                labelStyle: TextStyle(fontSize: 20, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PatientNote extends StatefulWidget {
  const PatientNote({Key? key}) : super(key: key);

  @override
  _PatientNoteState createState() => _PatientNoteState();
}

class _PatientNoteState extends State<PatientNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Leon Kipkoech",
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          Container(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "dkjsdfkasfsd fasdfbasdfhasd fsadfasdfasbdf asdfasdfasdfas dfasdf asdf sf sdf sd fsdfsdf sdf sdf sdf sfsd fsd",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  //  decoration: TextDecoration.underline,
                  // decorationStyle: TextDecorationStyle.wavy,
                  // decorationColor: Colors.white,
                  // decorationThickness: 0.5,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class PatientSignUp extends StatefulWidget {
  const PatientSignUp({Key? key}) : super(key: key);

  @override
  _PatientSignUpState createState() => _PatientSignUpState();
}

class _PatientSignUpState extends State<PatientSignUp> {
  showDatePicker() {
    DatePicker.showDatePicker(context,
        theme: DatePickerTheme(
            headerColor: Colors.black,
            backgroundColor: Colors.black,
            cancelStyle: TextStyle(color: Colors.red),
            itemStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
        showTitleActions: true,
        minTime: DateTime(2021, 11, 13),
        maxTime: DateTime(2023, 10, 12), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  int currentPage = 0;
  nextPage() {
    setState(() {
      currentPage = currentPage + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: currentPage == 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Text("Personal Info"),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'First and Last Name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Phone Number',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Email Address',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Confirm Password',
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: nextPage,
                        child:
                            button("Next", Colors.white, Colors.black, context))
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Text("More Info"),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'State',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'City or Zip Code',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Date of Birth (MM-DD-YYYY)',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Pronouns (he/she/they)',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Condition eg ADHD',
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PatientHome()));
                        },
                        child: button(
                            "Finish", Colors.white, Colors.black, context))
                  ],
                ),
              ));
  }
}

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  _PatientHomeState createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
                  text: 'Upcoming Sessions',
                ),
                Tab(
                  icon: Icon(Icons.watch_later_outlined, color: Colors.grey),
                  text: 'Make Request',
                ),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
            )),
        body: TabBarView(
          children: [
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Text("Upcoming Sessions",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewTherapist()));
                          },
                          child: therapistSessionCard(
                              context, 'Leon K.', "26670", 'Today at 12:15pm'),
                        ),
                        therapistSessionCard(
                            context, 'Leon K.', "26670", 'Today at 12:15pm'),
                        therapistSessionCard(
                            context, 'Leon K.', "26670", 'Today at 12:15pm'),
                        therapistSessionCard(
                            context, 'Leon K.', "26670", 'Today at 12:15pm'),
                        therapistSessionCard(
                            context, 'Leon K.', "26670", 'Today at 12:15pm'),
                        therapistSessionCard(
                            context, 'Leon K.', "26670", 'Today at 12:15pm'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Make Request",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                      therapistCard(context, 'Leon K.', "20", '10'),
                      therapistCard(context, 'Leon K.', "20", '10'),
                      therapistCard(context, 'Leon K.', "20", '10'),
                      therapistCard(context, 'Leon K.', "20", '10'),
                      therapistCard(context, 'Leon K.', "20", '10'),
                      therapistCard(context, 'Leon K.', "20", '10'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ViewTherapist extends StatefulWidget {
  const ViewTherapist({Key? key}) : super(key: key);

  @override
  _ViewTherapistState createState() => _ViewTherapistState();
}

class _ViewTherapistState extends State<ViewTherapist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar('Leon Kipkoech', context, 1),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 15),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Leon Kipkoech",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                // patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm')

                therapistRow('Patients', '10'),
                therapistRow('Sponsors', '2'),
                therapistRow('Hours Practiced', '4'),
                // Text("M.A.R",
                //     style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 30,
                //         fontWeight: FontWeight.bold)),
                // therapistRow('1', 'Gabapentin'),
                // therapistRow('2', 'Trazodone'),
                Text("Professional Summary",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "dkjsdfkasfsd fasdfbasdfhasd fsadfasdfasbdf asdfasdfasdfas dfasdf asdf sf sdf sd fsdfsdf sdf sdf sdf sfsd fsd",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    //  decoration: TextDecoration.underline,
                    // decorationStyle: TextDecorationStyle.wavy,
                    // decorationColor: Colors.white,
                    // decorationThickness: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TakeNotes()));
              },
              child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                  )),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => TakeNotes()));
                // Session has been requested
              },
              child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: button(
                      "Request Session", Colors.black, Colors.white, context)),
            ),
          ],
        ),
      ),
    );
  }
}

class SponsorSignUp extends StatefulWidget {
  const SponsorSignUp({Key? key}) : super(key: key);

  @override
  _SponsorSignUpState createState() => _SponsorSignUpState();
}

class _SponsorSignUpState extends State<SponsorSignUp> {
  int currentPage = 0;
  nextPage() {
    setState(() {
      currentPage = currentPage + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: currentPage == 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Text("Personal Info"),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'First and Last Name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Phone Number',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Email Address',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Confirm Password',
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: nextPage,
                        child:
                            button("Next", Colors.white, Colors.black, context))
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Text("Card Details"),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Name On Card',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Card Number',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'sec code',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Billing Address',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'City or Zip',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'State',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SponsorHome()));
                        },
                        child: button(
                            "Finish", Colors.white, Colors.black, context))
                  ],
                ),
              ));
  }
}

class SponsorHome extends StatefulWidget {
  const SponsorHome({Key? key}) : super(key: key);

  @override
  _SponsorHomeState createState() => _SponsorHomeState();
}

class _SponsorHomeState extends State<SponsorHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Center(
            child: Text("Hello Leon!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text("My Points: ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal)),
                      Text("200",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                Text("Buy Points ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.normal)),
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => BuyPoints()));
                    },
                    child: button(
                        "Buy Points", Colors.black, Colors.white, context)),
                Text("or ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.normal)),
                Text("Set up per bank transaction ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.normal)),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PerTransaction()));
                    },
                    child: button(
                        "More Info", Colors.black, Colors.white, context)),
                Text("Monthly Sponsorships ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.normal)),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MonthlySponsorships()));
                    },
                    child: button("View Monthly Sponsorships", Colors.black,
                        Colors.white, context)),
                Text("One Time Sponsorships ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.normal)),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OneTimeSponsorships()));
                    },
                    child: button("View OT Sponsorships", Colors.black,
                        Colors.white, context)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BuyPoints extends StatefulWidget {
  const BuyPoints({Key? key}) : super(key: key);

  @override
  _BuyPointsState createState() => _BuyPointsState();
}

class _BuyPointsState extends State<BuyPoints> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Center(
                child: Text("Buy Points",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.normal)),
              ),
              SizedBox(
                height: 10,
              ),
              Center(child: Text("1 USD = 2 points")),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'USD',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Listener Points',
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SponsorHome()));
                  },
                  child: button("Buy", Colors.white, Colors.black, context))
            ],
          ),
        ));
  }
}

class MonthlySponsorships extends StatefulWidget {
  const MonthlySponsorships({Key? key}) : super(key: key);

  @override
  _MonthlySponsorshipsState createState() => _MonthlySponsorshipsState();
}

class _MonthlySponsorshipsState extends State<MonthlySponsorships> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text("Monthly Sponsorships",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
        ],
      ),
    );
  }
}

class OneTimeSponsorships extends StatefulWidget {
  const OneTimeSponsorships({Key? key}) : super(key: key);

  @override
  _OneTimeSponsorshipsState createState() => _OneTimeSponsorshipsState();
}

class _OneTimeSponsorshipsState extends State<OneTimeSponsorships> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text("One Time Sponsorships",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
          therapistCard(context, "Leon Kipkoech", "20", "29"),
        ],
      ),
    );
  }
}

class PerTransaction extends StatefulWidget {
  const PerTransaction({Key? key}) : super(key: key);

  @override
  _PerTransactionState createState() => _PerTransactionState();
}

class _PerTransactionState extends State<PerTransaction> {
  double amountInvested = 0.00;
  invest(rem) {
    setState(() {
      amountInvested = 1 / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        Text(
            "Per Bank Transaction takes advantage of the fact that when you buy someting at the store the price doesn't come to .00 "),
        Text(
            "So because of this Umoja takes the value remaining for it to reach .00 and divides that by two, then uses it to buy points"),
        Text(
            "For example; You buy something worth 2.32 USD, umoja takes 0.68 then divides it by two and buys 0.34 USD worth of points"),
        Text(
            "At the end of the month you can use these points to sponsor therapists")
      ],
    ));
  }
}
