import 'dart:ffi';
import 'dart:io' as r;
import 'dart:io';
import 'package:intl/intl.dart';
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
import 'package:path_provider/path_provider.dart';

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
  const LandingPage({Key? key, this.initialization}) : super(key: key);

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
  bool loading = false;

  String acctype = '', userId = '';
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.signOut();
  }

  logIn() {
    setState(() {
      loading = true;
    });
    auth
        .signInWithEmailAndPassword(email: email.text, password: password.text)
        .then((value) {
      setState(() {
        userId = FirebaseAuth.instance.currentUser!.uid;
      });
      // log in user
      print("check...........................wewe");
      checkAcctType();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
      });
      showToast(error.toString());
    });
  }

  checkAcctType() {
    print("check...........................dfdf");
    FirebaseFirestore.instance
        .collection('accounts')
        .where('userId', isEqualTo: userId)
        .get()
        .then((QuerySnapshot mysnap) {
      mysnap.docs.forEach((data) {
        print("check...........................ppppp");
        acctype = data['accType'];
        if (acctype != '') {
          if (acctype == 'Therapist') {
            // check thepist status
            checkTherapistStatus();
          } else if (acctype == 'Sponsor') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SponsorHome()));
          } else if (acctype == 'Patient') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PatientHome()));
          }
          setState(() {
            loading = false;
          });
        }
      });
    });
  }

  checkTherapistStatus() {
    FirebaseFirestore.instance
        .collection('therapists')
        .where('therapistId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot snap) {
      snap.docs.forEach((data) {
        int status = data['status'];
        // 1: incomplete
        // 2: acccepted
        // 3: verified
        // 4: Denied
        if (status == 1) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TherapistSignUp(pageNumber: 0)));
        } else if (status == 2) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TherapistSignUp(pageNumber: 1)));
        } else if (status == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TherapistHomePage()));
        }
        if (status == 4) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TherapistSignUp(pageNumber: 2)));
        } else {
          print(status);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? whiteloader()
        : Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              title: Text("Login",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: email,
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Enter your email',
                            labelStyle: TextStyle(color: Colors.white54)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: password,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: 'Enter your password',
                            labelStyle: TextStyle(color: Colors.white54)),
                      ),
                    ),
                    GestureDetector(
                        onTap: logIn,
                        child: button(
                            "Log In", Colors.white, Colors.blue, context))
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
  final pageNumber;
  const TherapistSignUp({Key? key, this.pageNumber}) : super(key: key);

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
  int profileStatus = 0;

  nextStep() {
    setState(() {
      profileStatus = profileStatus + 1;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.pageNumber == 0) {
      profileStatus = 1;
    } else if (widget.pageNumber == 1) {
      profileStatus = 5;
    } else if (widget.pageNumber == 2) {
      profileStatus = 6;
    }
  }

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
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  createTherapistProfile(name, selfId, driversId, therapistId, phone, email,
      status, license, accType) {
    CollectionReference therapists =
        FirebaseFirestore.instance.collection('therapists');
    return therapists.add({
      'name': name, // John Doe
      'selfId': selfId, // Stokes and Sons
      'driversId': driversId,
      'therapistId': therapistId,
      'phone': phone,
      'email': email,
      'status': status,

      'licenseNo': license,
      'professionalBio': professionalBio.text,
    }).then((value) {
      FirebaseFirestore.instance.collection('accounts').add({
        'userId': therapistId,
        'accType': accType,
      }).then((val) {
        createLicenseInformation(therapistId, licenseNo.text, state.text,
            city.text, licenseType.text, expirationDate.text, dateofIssue.text);
      });
    }).catchError((error) => showToast("Failed to add user: $error"));
  }

  createLicenseInformation(therapistId, licenseNo, state, city, licenseType,
      expirationDate, dateofIssue) {
    CollectionReference licenses =
        FirebaseFirestore.instance.collection('licenses');
    return licenses.add({
      'therapistId': therapistId, // John Doe
      'licenseNo': licenseNo, // Stokes and Sons
      'state': state,
      'city': city,
      'inSession': false,

      'licenseType': licenseType,
      'expirationDate': expirationDate,
      'dateofIssue': dateofIssue,
    }).then((value) {
      createTherapistWallet(therapistId, 0, 0, 0, 0, 0);
    }).catchError((error) => showToast("Failed to add Lincese: $error"));
  }

  createTherapistWallet(therapistId, patients, monthlySponsors, oTsponsors,
      hoursDone, pointsEarned) {
    CollectionReference therapistWallets =
        FirebaseFirestore.instance.collection('therapistWallets');
    return therapistWallets.doc(therapistId).set({
      'therapistId': therapistId, // John Doe
      'patients': patients, // Stokes and Sons
      'monthlySponsors': monthlySponsors,
      'oTSponsors': oTsponsors,
      'hours': hoursDone,
      'inSession': false,
      'points': pointsEarned,
      'name': names.text,
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

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  Future<void> downloadURLExample(x) async {
    String downloadURL =
        await firebase_storage.FirebaseStorage.instance.ref(x).getDownloadURL();

    // Within your widgets:
    // Image.network(downloadURL);
  }

  uploadedSI(therapistId) async {
    String selfIdpic = await firebase_storage.FirebaseStorage.instance
        .ref('$therapistId/selfId.png')
        .getDownloadURL();

    setState(() {
      selfId = selfIdpic;
    });
  }

  uploadedDL(therapistId) async {
    String selfIdpic = await firebase_storage.FirebaseStorage.instance
        .ref('$therapistId/driversLicense.png')
        .getDownloadURL();

    setState(() {
      driversId = selfIdpic;
    });
  }

  Future<void> uploadFile(num, x) async {
    setState(() {
      loading = true;
    });
    print(x);
    final User? user = auth.currentUser;
    final therapistId = user!.uid;
    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // File file = File(x);

    try {
      num == 1
          ? await firebase_storage.FirebaseStorage.instance
              .ref('$therapistId/selfId.png')
              .putFile(x)
              .then((event) {
              uploadedSI(therapistId);
              setState(() {
                print("uploaded selfId");

                loading = false;
              });
              nextStep();
            })
          : await firebase_storage.FirebaseStorage.instance
              .ref('$therapistId/driversLicense.png')
              .putFile(x)
              .then((event) {
              uploadedDL(therapistId);
              setState(() {
                loading = false;
              });
              nextStep();
            });
    } catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  final ImagePicker _picker = ImagePicker();
  final ImagePicker _driversLicensePicker = ImagePicker();

  dynamic _pickImageError;
  bool isVideo = false;

  File? _selfIdPicture;
  File? _driversLicense;
  String? _retrieveDataError;

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    final LostDataResponse dlresponse =
        await _driversLicensePicker.retrieveLostData();
    if (response.isEmpty || dlresponse.isEmpty) {
      return;
    } else if (dlresponse.file != null) {
      setState(() {
        _driversLicense = dlresponse.file as r.File?;
      });
    } else if (response.file != null) {
      setState(() {
        _selfIdPicture = response.file as r.File?;
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
          _selfIdPicture = File(pickedFile!.path);
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
          _driversLicense = File(pickedFile!.path);
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
                          Center(child: Text("Self Identification")),
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
                              onTap: () {
                                uploadFile(1, _selfIdPicture);
                              },
                              child: button(
                                  "Next", Colors.white, Colors.black, context))
                        ]),
                      )
                    : profileStatus == 2
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView(children: [
                              Center(child: Text("Driver's License")),
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
                                      _driversLicense != null
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
                                  onTap: () {
                                    uploadFile(2, _driversLicense);
                                  },
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
                                : profileStatus == 5
                                    ? Center(
                                        child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                              "Thank you for your Sumbmission. Your Account is under review"),
                                        ],
                                      ))
                                    : Center(
                                        child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                              "Thank you for your Sumbmission. Your Account cannot be verified and was rejected, sorry."),
                                        ],
                                      )));
  }
}

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({Key? key}) : super(key: key);

  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  String fName = '';
  num patients = 0,
      onetimesponsors = 0,
      monthlysponsors = 0,
      points = 0,
      hours = 0;

  final therapistId = FirebaseAuth.instance.currentUser!.uid;
  getFirstName() {
    FirebaseFirestore.instance
        .collection('therapists')
        .where('therapistId', isEqualTo: therapistId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          fName = doc["name"].split(" ")[0];
        });
      });
    });
  }

  getTerapistStats() {
    FirebaseFirestore.instance
        .collection('therapistWallets')
        .where('therapistId', isEqualTo: therapistId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          patients = doc["patients"];
          onetimesponsors = doc["oTSponsors"];
          monthlysponsors = doc['monthlySponsors'];
          points = checkDouble(doc["points"]);
          hours = doc["hours"];
        });
      });
    });
  }

  Future<Widget> onePatient() async {
    return await FirebaseFirestore.instance
        .collection('requests')
        .where('therapistId', isEqualTo: therapistId)
        .get()
        .then((value) {
      return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewPatient(
                          userId: value.docs[0]['therapistId'],
                          docId: value.docs[0].id,
                          name: value.docs[0]['patientName'],
                          condition: value.docs[0]['condition'],
                          status: value.docs[0]['status'],
                        )));
          },
          child: patientSessionCard(
            context,
            value.docs[0]['patientName'],
            value.docs[0]['condition'],
            (value.docs[0]['dateMade'] as Timestamp).toDate(),
          ));
    });
  }

  void initState() {
    super.initState();
    getFirstName();
    getTerapistStats();
  }

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
                  therapistDashboard(context, fName, patients, monthlysponsors,
                      onetimesponsors, points, hours),
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Upcoming sessions",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold)),
                        FutureBuilder<Widget>(
                          future: onePatient(), // async work
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Text('Loading....');
                              default:
                                if (snapshot.hasError)
                                  return Text('Error: ${snapshot.error}');
                                else
                                  return snapshot.data as Widget;
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sessions')
                    .where('therapistId', isEqualTo: therapistId)
                    .where('status', isEqualTo: true)
                    .orderBy('scheduledDate', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        "No requests have been made yet",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPatient(
                                          userId: data['therapistId'],
                                          docId: document.id,
                                          name: data['patientName'],
                                          condition: data['condition'],
                                          status: data['status'],
                                        )));
                          },
                          child: patientCard(
                            context,
                            data['patientName'],
                            data['condition'],
                            (data['scheduledDate'] as Timestamp).toDate(),
                          ));
                    }).toList(),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('therapistId', isEqualTo: therapistId)
                    .where('status', isEqualTo: true)
                    .orderBy('dateMade', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        "No requests have been made yet",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPatient(
                                          userId: data['therapistId'],
                                          docId: document.id,
                                          name: data['patientName'],
                                          condition: data['condition'],
                                          status: data['status'],
                                        )));
                          },
                          child: patientCard(
                            context,
                            data['patientName'],
                            data['condition'],
                            (data['dateMade'] as Timestamp).toDate(),
                          ));
                    }).toList(),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('therapistId', isEqualTo: therapistId)
                    .where('status', isEqualTo: false)
                    .orderBy('dateMade', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        "No requests have been made yet",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPatient(
                                          userId: data['therapistId'],
                                          docId: document.id,
                                          name: data['patientName'],
                                          condition: data['condition'],
                                          status: data['status'],
                                        )));
                          },
                          child: patientCard(
                            context,
                            data['patientName'],
                            data['condition'],
                            (data['dateMade'] as Timestamp).toDate(),
                          ));
                    }).toList(),
                  );
                },
              )
            ])),
      ),
    );
  }
}

class ViewPatient extends StatefulWidget {
  final userId, docId, name, condition, status;

  const ViewPatient(
      {Key? key,
      this.userId,
      this.name,
      this.docId,
      this.condition,
      this.status})
      : super(key: key);

  @override
  _ViewPatientState createState() => _ViewPatientState();
}

class _ViewPatientState extends State<ViewPatient> {
  // ignore: non_constant_identifier_names
  DateTime initial = new DateTime.now();
  DateTime endDate = new DateTime(2023, 12, 12);
  bool status = false;
  String therapistName = '', therapistId = '', walletId = '', sessionId = '';
  num patientNumber = 0;
  DateTime finalDate = DateTime.now(), finalTime = DateTime.now();
  @override
  void initState() {
    super.initState();

    setState(() {
      therapistId = FirebaseAuth.instance.currentUser!.uid;
      status = widget.status;
    });
    fetchName();
    fetchPatientNumber();
  }

  fetchName() {
    FirebaseFirestore.instance
        .collection('therapists')
        .where('therapistId', isEqualTo: therapistId)
        .get()
        .then((QuerySnapshot snap) {
      snap.docs.forEach((element) {
        setState(() {
          therapistName = element['name'];
        });
      });
    });
  }

  fetchPatientNumber() {
    FirebaseFirestore.instance
        .collection('therapistWallets')
        .where('therapistId', isEqualTo: therapistId)
        .snapshots()
        .listen((QuerySnapshot snap) {
      snap.docs.forEach((element) {
        setState(() {
          patientNumber = element['patients'];
          walletId = element.id;
        });
      });
    });
  }

  createSession(time, date) {
    FirebaseFirestore.instance.collection('sessions').add({
      'patientName': widget.name,
      'patientId': widget.userId,
      'therapistName': therapistName,
      'scheduledTime': time,
      'scheduledDate': date,
      'therapistId': therapistId,
      'status': false,
    }).then((value) {
      showToast('Session Successfully created');
    });
  }

  beginNewSession() {
    FirebaseFirestore.instance.collection('sessions').add({
      'patientName': widget.name,
      'patientId': widget.userId,
      'therapistName': therapistName,
      'scheduledTime': DateTime.now(),
      'scheduledDate': DateTime.now(),
      'therapistId': therapistId,
      'status': true,
    }).then((value) {
      print(value.id);
      showToast('Session Started');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TakeNotes(
                  patientId: widget.userId,
                  docId: value.id,
                  patientName: widget.name,
                  startTime: DateTime.now())));
    });
  }

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
      setState(() {
        finalDate = date;
      });
      showAlertDialog();
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
        onChanged: (time) {}, onConfirm: (time) {
      setState(() {
        finalTime = time;
      });
      showAlertDialog();
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  showAlertDialog() {
    // set up the AlertDialog

    // show the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text("Schedule Session",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal)),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Date& time selected"),
                    Text(formatDateTime(DateTime.now()))
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDatePicker();
                    },
                    child: button(
                        'Select Date', Colors.white, Colors.black, context)),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showTimePicker();
                    },
                    child: button(
                        'Select Time', Colors.white, Colors.black, context)),
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
              onTap: () {
                createSession(finalTime, finalDate);
              },
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
      },
    );
  }

  acceptRequest() {
    FirebaseFirestore.instance.collection('requests').doc(widget.docId).update({
      'status': true,
    }).then((value) {
      // fetch number of patients
      // add one
      addPatients();
      setState(() {
        status = true;
      });
    });
  }

  addPatients() {
    FirebaseFirestore.instance
        .collection('therapistWallets')
        .doc(walletId)
        .update({'patients': patientNumber + 1});
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
                    Text(widget.name,
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
                            showToast('feature not available yet');
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
                            showToast('feature not available yet');
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Icon(
                                Icons.message,
                                color: Colors.white,
                              )),
                        ),
                        status
                            ? GestureDetector(
                                onTap: () {
                                  beginNewSession();
                                },
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: button("Begin New Session",
                                        Colors.black, Colors.white, context)),
                              )
                            : GestureDetector(
                                onTap: () {
                                  acceptRequest();
                                },
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: button("Accept Request",
                                        Colors.black, Colors.white, context)),
                              ),
                      ],
                    ),

                    // patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm')

                    therapistRow('Condition', widget.condition),
                    therapistRow('Number of Appointments', '10'),
                    // Text("M.A.R",
                    //     style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 30,
                    //         fontWeight: FontWeight.bold)),
                    // therapistRow('1', 'Gabapentin'),
                    // therapistRow('2', 'Trazodone'),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      // GestureDetector(
                      //   onTap: () {
                      //     showAlertDialog(context);
                      //   },
                      //   child: Container(
                      //       margin: EdgeInsets.only(top: 20, bottom: 20),
                      //       child: button("Schedule Session", Colors.black,
                      //           Colors.white, context)),
                      // ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        // color: Colors.red,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('notes')
                              .where('patientId', isEqualTo: widget.userId)
                              .where('therapistId', isEqualTo: therapistId)
                              .orderBy('stopTime', descending: true)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("Loading");
                            }

                            return ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () {
                                    // open Notes
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ViewNotes(
                                                sessionId: data['sessionId'])));
                                  },
                                  child: patientNotesCard(
                                    context,
                                    data['patientName'],
                                    (data['startTime'] as Timestamp).toDate(),
                                    (data['stopTime'] as Timestamp).toDate(),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
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
                          showAlertDialog();
                        },
                        child: Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            child: button("Schedule Session", Colors.black,
                                Colors.white, context)),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        // color: Colors.red,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('sessions')
                              .where('patientId', isEqualTo: widget.userId)
                              .where('therapistId', isEqualTo: therapistId)
                              .where('status', isEqualTo: false)
                              .orderBy('scheduledDate', descending: true)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("Loading");
                            }

                            return ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () {
                                    // can't click session
                                  },
                                  child: patientSessionCard(
                                    context,
                                    data['patientName'],
                                    (data['scheduledDate'] as Timestamp)
                                        .toDate(),
                                    (data['scheduledTime'] as Timestamp)
                                        .toDate(),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
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
  final patientId, docId, startTime, patientName;
  const TakeNotes(
      {Key? key,
      @required this.patientId,
      @required this.docId,
      @required this.startTime,
      @required this.patientName})
      : super(key: key);

  @override
  _TakeNotesState createState() => _TakeNotesState();
}

class _TakeNotesState extends State<TakeNotes> {
  String therapistId = '', walletId = '';
  TextEditingController notes = new TextEditingController();
  num hours = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      therapistId = FirebaseAuth.instance.currentUser!.uid;
    });
    fetchWalletId();
    fetchHours();
  }

  finishSession() {
    print('1111111111111111111111111111');
    print(widget.docId);
    FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.docId)
        .update({"stopTime": DateTime.now()}).then((value) {
      print('22222222222222222222222222222222');
      // add hours of practice to therapist
      recordNotes();
    });
  }

  recordNotes() {
    FirebaseFirestore.instance.collection('notes').add({
      'therapistId': therapistId,
      'patientId': widget.patientId,
      'patientName': widget.patientName,
      'notes': notes.text,
      'startTime': widget.startTime,
      'stopTime': DateTime.now(),
      'sessionId': widget.docId,
    }).then((value) {
      addHours();
    });
  }

  fetchHours() {
    FirebaseFirestore.instance
        .collection('therapistWallets')
        .where("therapistId", isEqualTo: therapistId)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          hours = element['hours'];
        });
      });
    });
  }

  addHours() {
    DateTime start = widget.startTime;
    Duration time = DateTime.now().difference(start);
    FirebaseFirestore.instance
        .collection('therapistWallets')
        .doc(walletId)
        .update({
      'hours': hours + time.inHours,
    }).then((value) {
      showToast("Session Succcessfully Recorded");
      Navigator.pop(context);
    });
  }

  fetchWalletId() {
    FirebaseFirestore.instance
        .collection('therapistWallets')
        .where('therapistId', isEqualTo: therapistId)
        .get()
        .then((QuerySnapshot snap) {
      snap.docs.forEach((element) {
        setState(() {
          walletId = element.id;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                finishSession();
              },
              child: Container(
                height: 25,
                color: Colors.white,
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Center(
                    child: Text('finish session',
                        style: TextStyle(color: Colors.black))),
              ),
            )
          ],
          title: Text("Notes")),
      body: ListView(
        children: [
          Container(
              padding: EdgeInsets.all(10),
              child: therapistRow('date: ', DateTime.now().toString())),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: TextFormField(
              controller: notes,
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
  bool loading = false;
  TextEditingController name = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController dateOfBirth = new TextEditingController();
  TextEditingController pronouns = new TextEditingController();
  TextEditingController condition = new TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
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

  createPatientProfile() {
    String patientId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference patient =
        FirebaseFirestore.instance.collection('patients');
    return patient.add({
      'name': name.text, // John Doe
      'patientId': patientId,
      'phone': phone.text,
      'email': email.text,
      'state': state.text,
      'city': city.text,
      'Date of Birth': dateOfBirth.text,
      'pronouns': pronouns.text,
      'condition': condition.text
    }).then((value) {
      CollectionReference accounts =
          FirebaseFirestore.instance.collection('accounts');
      return accounts.add({
        'userId': patientId,
        'accType': "Patient",
      }).then((val) {
        setState(() {
          loading = true;
          showToast("Account Created Successsfully");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PatientHome()),
              (route) => false);
        });
      });
    }).catchError((error) => showToast("Failed to add user: $error"));
  }

  createUser() {
    setState(() {
      loading = true;
    });
    if (checkIfPasswordsMatch()) {
      auth
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text)
          .then((value) {
        nextPage();
        setState(() {
          loading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          currentPage = 0;
          loading = false;
        });
        showToast(error.toString());
      });
    } else {
      setState(() {
        loading = true;
      });
    }
  }

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
    return loading
        ? whiteloader()
        : Scaffold(
            appBar: appBar("Patient", context, 1),
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
                            controller: name,
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
                            controller: phone,
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
                            controller: email,
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
                            onTap: () {
                              createUser();
                            },
                            child: button(
                                "Next", Colors.white, Colors.black, context))
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
                            controller: state,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'State (eg. FL)',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: dateOfBirth,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Date of Birth (MM/DD/YYYY)',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: pronouns,
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
                            controller: condition,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Condition eg ADHD',
                            ),
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              // add patient to database
                              createPatientProfile();
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
  FirebaseAuth auth = FirebaseAuth.instance;
  String patientId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      patientId = auth.currentUser!.uid;
    });
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
                  text: 'Sessions',
                ),
                Tab(
                  icon: Icon(Icons.watch_later_outlined, color: Colors.grey),
                  text: 'Request',
                ),
                Tab(
                  icon: Icon(Icons.lock_clock_outlined, color: Colors.grey),
                  text: 'Unconfirmed',
                )
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
            )),
        body: TabBarView(
          children: [
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 0, bottom: 15),
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Upcoming Sessions",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            GestureDetector(
                                onTap: () {
                                  FirebaseAuth.instance.signOut();
                                  // Navigator.push
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()),
                                      (route) => false);
                                },
                                child: Icon(Icons.logout_outlined,
                                    size: 30, color: Colors.white))
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('sessions')
                                .where('patientId', isEqualTo: patientId)
                                .where('status', isEqualTo: false)
                                .orderBy('scheduledDate', descending: true)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading");
                              }

                              return ListView(
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  return GestureDetector(
                                    onTap: () {
                                      // can't click session

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewTherapist(
                                                      therapistId:
                                                          data['therapistId'],
                                                      who: 1,
                                                      request: false)));
                                    },
                                    child: patientSessionCard(
                                      context,
                                      data['patientName'],
                                      (data['scheduledDate'] as Timestamp)
                                          .toDate(),
                                      (data['scheduledTime'] as Timestamp)
                                          .toDate(),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            MakeRequests(),
            Unconfirmed(patientId: patientId)
          ],
        ),
      ),
    );
  }
}

class MakeRequests extends StatefulWidget {
  const MakeRequests({Key? key}) : super(key: key);

  @override
  _MakeRequestsState createState() => _MakeRequestsState();
}

class _MakeRequestsState extends State<MakeRequests> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('therapistWallets')
          .where('inSession', isEqualTo: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewTherapist(
                              therapistId: data['therapistId'],
                              who: 1,
                              request: true,
                            )));
              },
              child: therapistCard(
                  context, data['name'], data['hours'], data['patients']),
            );
          }).toList(),
        );
      },
    );
  }
}

class Unconfirmed extends StatefulWidget {
  final patientId;
  const Unconfirmed({Key? key, @required this.patientId}) : super(key: key);

  @override
  _UnconfirmedState createState() => _UnconfirmedState();
}

class _UnconfirmedState extends State<Unconfirmed> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('patientId', isEqualTo: widget.patientId)
          .where('status', isEqualTo: false)
          .orderBy('dateMade', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewTherapist(
                              therapistId: data['therapistId'],
                              who: 1,
                              request: true,
                            )));
              },
              child: therapistRequestCard(
                context,
                data['therapistName'],
                data['licenseNo'],
                (data['dateMade'] as Timestamp).toDate(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class ViewTherapist extends StatefulWidget {
  final therapistId, who, request;
  const ViewTherapist(
      {Key? key,
      @required this.therapistId,
      @required this.who,
      @required this.request})
      : super(key: key);

  @override
  _ViewTherapistState createState() => _ViewTherapistState();
}

class _ViewTherapistState extends State<ViewTherapist> {
  String therapistName = '',
      professionalSummary = '',
      licenseNo = '',
      patientCondition = '';
  int patients = 1, sponsors = 1;
  bool loading = false;
  num hours = 1, sponsorPoints = 1, therapistPoints = 1;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController amount = new TextEditingController();
  @override
  void initState() {
    super.initState();
    getTherapistInfo();
    getTherapistStats();
    setState(() {
      userId = FirebaseAuth.instance.currentUser!.uid;
    });
    if (widget.who == 2) {
      getSponsorPoints();
    }
    if (widget.request) {
      getPatientInfo();
    }
  }

  getTherapistInfo() {
    setState(() {
      loading = true;
    });
    FirebaseFirestore.instance
        .collection('therapists')
        .where('therapistId', isEqualTo: widget.therapistId)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          therapistName = doc["name"];
          professionalSummary = doc["professionalBio"];
          licenseNo = doc['licenseNo'];
        });
      });
      await getTherapistStats();
    });
  }

  getTherapistStats() {
    FirebaseFirestore.instance
        .collection('therapistWallets')
        .where('therapistId', isEqualTo: widget.therapistId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          hours = doc["hours"];
          patients = doc["patients"];
          sponsors = doc['monthlySponsors'] + doc['oTSponsors'];
          therapistPoints = checkDouble(doc["points"]);
          loading = false;
        });
      });
    });
  }

  getSponsorPoints() {
    FirebaseFirestore.instance
        .collection('sponsorWallets')
        .where('sponsorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          sponsorPoints = checkDouble(doc["points"]);
        });
      });
    });
  }

  oneTimeSponsor(amount, ctxt) {
    FirebaseFirestore.instance.collection('sponsorWallets').doc(userId).update({
      "points": sponsorPoints - amount,
    }).then((value) {
      // add points to the therapist ~
      // ad therapist to one time sponsored
      // add number of sponsors to therapist ~
      FirebaseFirestore.instance
          .collection('therapistWallets')
          .doc(widget.therapistId)
          .update({
        "points": therapistPoints + amount,
        "oTSponsors": sponsors + 1
      }).then((value) {
        FirebaseFirestore.instance.collection('sponsorships').add({
          'sponsorId': userId,
          'therapistId': widget.therapistId,
          'type': 'oneTime',
          'name': therapistName,
          'date': DateTime.now()
        }).then((value) {
          Navigator.pop(ctxt);
          showToast("Sponsorship Successful");
        });
      });
    });
  }

  monthlySponsor(amount, ctxt) {
    var today = new DateTime.now();
    FirebaseFirestore.instance.collection('sponsorWallets').doc(userId).update({
      "points": sponsorPoints - amount,
    }).then((value) {
      // add points to the therapist ~
      // ad therapist to one time sponsored
      // add number of sponsors to therapist ~
      FirebaseFirestore.instance
          .collection('therapistWallets')
          .doc(widget.therapistId)
          .update({
        "points": therapistPoints + amount,
        "oTSponsors": sponsors + 1
      }).then((value) {
        FirebaseFirestore.instance.collection('sponsorships').add({
          'sponsorId': userId,
          'therapistId': widget.therapistId,
          'type': 'monthly',
          'date': DateTime.now(),
          'name': therapistName,
          'nextDate': DateTime(today.year, today.month + 1, today.day),
        }).then((value) {
          Navigator.pop(ctxt);
          showToast("Sponsorship Successful");
        });
      });
    });
  }

  showAlertDialog(type) {
    // set up the AlertDialog

    // show the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text("Sponsor Therapist",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.normal)),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: TextFormField(
              controller: amount,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter Amount',
              ),
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
              onTap: () {
                print(amount.text);
                print(sponsorPoints);

                if (checkDouble(amount.text) > sponsorPoints) {
                  showToast("You dont have enough Points");
                  Navigator.pop(context);
                } else {
                  type == 1
                      ? oneTimeSponsor(double.parse(amount.text), context)
                      : monthlySponsor(double.parse(amount.text), context);
                }
              },
              child: Container(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.3,
                  color: Colors.blue,
                  child: Center(
                      child: Text(
                    'Sponsor',
                    style: TextStyle(color: Colors.white),
                  ))),
            )
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
        );
      },
    );
  }

  String patientName = '';
  getPatientInfo() {
    FirebaseFirestore.instance
        .collection("patients")
        .where("patientId", isEqualTo: userId)
        .get()
        .then((QuerySnapshot qs) {
      qs.docs.forEach((element) {
        setState(() {
          patientName = element["name"];
          patientCondition = element["condition"];
        });
      });
    });
  }

  requestSession() {
    setState(() {
      loading = true;
    });
    FirebaseFirestore.instance.collection('requests').add({
      'patientId': userId,
      'therapistId': widget.therapistId,
      'patientName': patientName,
      'therapistName': therapistName,
      'status': false,
      'condition': patientCondition,
      'licenseNo': licenseNo,
      'dateMade': DateTime.now(),
    }).then((value) {
      setState(() {
        loading = false;
      });
      showToast("Request Successful");
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? loader()
        : Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.black,
              leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              title: Text(therapistName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.normal)),
            ),
            body: ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 0, bottom: 15),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      // patientCard(context, 'Leon', "ADHD", 'Today at 2:15pm')

                      therapistRow('Patients', '$patients'),
                      therapistRow('Sponsors', '$sponsors'),
                      therapistRow('Hours Practiced', '$hours'),

                      Text("Professional Summary",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "$professionalSummary",
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
              child: widget.who == 0
                  ? SizedBox()
                  : widget.who == 1
                      ? !widget.request
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.08,
                              color: Colors.white30,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    //  email the therapist or use twilio
                                  },
                                  child: Container(
                                      //  margin: EdgeInsets.only(bottom: 20),
                                      child: Icon(
                                    Icons.email_outlined,
                                    color: Colors.white,
                                  )),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    //  email the therapist or use twilio
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
                                    requestSession();
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      child: button("Request Session",
                                          Colors.black, Colors.white, context)),
                                ),
                              ],
                            )
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showAlertDialog(2);
                              },
                              child: Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    child: Center(
                                        child: Text("🤍 Monthly",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0))),
                                    color: Colors.red[200],
                                  )),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) => TakeNotes()));
                                // Session has been requested
                                showAlertDialog(1);
                              },
                              child: Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    child: Center(
                                        child: Text("🤍 One Time",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0))),
                                    color: Colors.blue[200],
                                  )),
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
  bool loading = false;
  TextEditingController name = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();
  TextEditingController cardname = new TextEditingController();
  TextEditingController cardNumber = new TextEditingController();
  TextEditingController secCode = new TextEditingController();
  TextEditingController billingAddress = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController state = new TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  String sponsorId = FirebaseAuth.instance.currentUser!.uid;
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

  createSponsorProfile() {
    String sponsorId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference sponsor =
        FirebaseFirestore.instance.collection('sponsors');
    return sponsor.add({
      'name': name.text, // John Doe
      'sponsorId': sponsorId,
      'phone': phone.text,
      'email': email.text,
      'state': state.text,
    }).then((value) {
      CollectionReference accounts =
          FirebaseFirestore.instance.collection('accounts');
      return accounts.add({
        'userId': sponsorId,
        'accType': "Sponsor",
      }).then((val) {
        setState(() {
          loading = true;
          createSponsorWallet(sponsorId, 0, 0, 0);
        });
      });
    }).catchError((error) => showToast("Failed to add user: $error"));
  }

  createSponsorWallet(
      sponsorId, monthlySponsorships, oTsponsorships, pointsEarned) {
    CollectionReference sponsor =
        FirebaseFirestore.instance.collection('sponsorWallets');
    return sponsor.doc(sponsorId).set({
      'sponsorId': sponsorId,
      'points': pointsEarned,
      'monthlySponsorships': monthlySponsorships,
      'oneTimeSponsorships': oTsponsorships
    }).then((value) {
      showToast("Account Created Successfully");
      setState(() {
        nextPage();
        loading = false;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SponsorHome()));
      });
    }).catchError((error) => showToast("Failed to add Lincese: $error"));
  }

  createUser() {
    setState(() {
      loading = true;
    });
    if (checkIfPasswordsMatch()) {
      auth
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text)
          .then((value) {
        nextPage();
        setState(() {
          loading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          currentPage = 0;
          loading = false;
        });
        showToast(error.toString());
      });
    } else {
      setState(() {
        loading = true;
      });
    }
  }

  String sponsorName = '';
  num points = 1;
  @override
  initState() {
    super.initState();
    sponsorId = FirebaseAuth.instance.currentUser!.uid;

    sponsorInfo();
    sponsorNames();
  }

  sponsorInfo() {
    FirebaseFirestore.instance
        .collection('sponsorWallets')
        .where('sponsorId', isEqualTo: sponsorId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          points = checkDouble(doc["points"]);
        });
      });
    });
  }

  sponsorNames() {
    FirebaseFirestore.instance
        .collection('sponsors')
        .where('sponsorId', isEqualTo: sponsorId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          sponsorName = doc["name"].split(" ")[0];
        });
      });
    });
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
        appBar: appBar("Sponsor", context, 1),
        body: loading
            ? loader()
            : currentPage == 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        Text("Personal Info"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: name,
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
                            controller: phone,
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
                            controller: email,
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
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        Text("Card Details"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: cardname,
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
                            controller: cardNumber,
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
                            controller: secCode,
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
                            controller: billingAddress,
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
                                  controller: city,
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
                                  controller: state,
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
                              createSponsorProfile();
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
  String sponsorId = FirebaseAuth.instance.currentUser!.uid;
  String sponsorName = '';
  num points = 0.0;
  @override
  initState() {
    super.initState();
    sponsorId = FirebaseAuth.instance.currentUser!.uid;

    sponsorInfo();
    sponsorNames();
  }

  sponsorInfo() {
    FirebaseFirestore.instance
        .collection('sponsorWallets')
        .where('sponsorId', isEqualTo: sponsorId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          points = checkDouble(doc["points"]);
          // points = double.parse(doc["points"]);
        });
      });
    });
  }

  sponsorNames() async {
    await FirebaseFirestore.instance
        .collection('sponsors')
        .where('sponsorId', isEqualTo: sponsorId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          sponsorName = doc["name"].split(" ")[0];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hello $sponsorName!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      // Navigator.push
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                          (route) => false);
                    },
                    child: Icon(Icons.logout_outlined,
                        size: 40, color: Colors.white))
              ],
            ),
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
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text("My Points: ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal)),
                      Text("$points",
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
                              builder: (context) => MonthlySponsorships(
                                    sponsorId: sponsorId,
                                  )));
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
  String sponsorId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController usd = new TextEditingController();
  double points = 1.0;
  double total = 0.0, exchRate = 0.001;
  String docId = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sponsorInfo();
  }

  sponsorInfo() {
    FirebaseFirestore.instance
        .collection('sponsorWallets')
        .where('sponsorId', isEqualTo: sponsorId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          points = checkDouble(doc["points"]);
          docId = doc.id;
        });
      });
    });
  }

  exchange(txt) {
    setState(() {
      total = txt * exchRate;
    });
  }

  buyPoints(amount) {
    FirebaseFirestore.instance.collection('sponsorWallets').doc(docId).update({
      "points": points + amount,
    }).then((value) {
      showToast("Successfully bought $amount points");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SponsorHome()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SponsorHome()),
                    (route) => false);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text("Your Points",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.normal)),
                  Text("$points",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.normal)),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Center(child: Text("1 point = $exchRate USD")),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: usd,
                  onChanged: (text) {
                    print(text);
                    if (text != '') {
                      exchange(double.parse(text));
                    } else {
                      setState(() {
                        total = 0.00;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Points',
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: total == 0.0
                      ? Text("Payable Amount",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.normal))
                      : Text('$total USD',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.normal)),
                ),
              ),
              GestureDetector(
                  onTap: () {
                    buyPoints(checkDouble(usd.text));
                  },
                  child: button("Buy", Colors.white, Colors.black, context))
            ],
          ),
        ));
  }
}

class MonthlySponsorships extends StatefulWidget {
  final sponsorId;

  const MonthlySponsorships({Key? key, @required this.sponsorId})
      : super(key: key);

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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sponsorships')
              .where('sponsorId', isEqualTo: widget.sponsorId)
              .where('type', isEqualTo: "monthly")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                //  var format = new DateFormat('y-MM-d');
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewTherapist(
                                therapistId: data['therapistId'],
                                who: 2,
                                request: false)));
                  },
                  child: therapistSponsorCard(
                      context,
                      data['name'],
                      (data['date'] as Timestamp).toDate(),
                      (data['nextDate'] as Timestamp).toDate(),
                      true),
                );
              }).toList(),
            );
          },
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAllTherapists()));
              },
              child:
                  button("Add Therapist", Colors.black, Colors.white, context),
            ),
          ),
        ));
  }
}

class OneTimeSponsorships extends StatefulWidget {
  final sponsorId;
  const OneTimeSponsorships({Key? key, this.sponsorId}) : super(key: key);

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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sponsorships')
              .where('sponsorId', isEqualTo: widget.sponsorId)
              .where('type', isEqualTo: "oneTime")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                //  var format = new DateFormat('y-MM-d');
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewTherapist(
                                therapistId: data['therapistId'],
                                who: 2,
                                request: false)));
                  },
                  child: therapistSponsorCard(
                      context,
                      data['name'],
                      (data['date'] as Timestamp).toDate(),
                      (data['date'] as Timestamp).toDate(),
                      false),
                );
              }).toList(),
            );
          },
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewAllTherapists()));
            },
            child: button("Add Therapist", Colors.black, Colors.white, context),
          ),
        ));
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SponsorHome()),
                    (route) => false);
              },
              child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.height * 0.9,
            height: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(12.0),
            child: ListView(
              children: [
                Text(
                  "Per Bank Transaction takes advantage of the fact that when you buy someting at the store the price doesn't come to .00 ",
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                SizedBox(height: 10),
                Text(
                  "So because of this Umoja takes the value remaining for it to reach .00 and divides that by two, then uses it to buy points",
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                SizedBox(height: 10),
                Text(
                  "For example; You buy something worth 2.32 USD, umoja takes 0.68 then divides it by two and buys 0.34 USD worth of points",
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                SizedBox(height: 10),
                Text(
                  "At the end of the month you can use these points to sponsor therapists",
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                SizedBox(height: 10),
                button("Set Up", Colors.white, Colors.black, context)
              ],
            ),
          ),
        ));
  }
}

class ViewAllTherapists extends StatefulWidget {
  const ViewAllTherapists({Key? key}) : super(key: key);

  @override
  _ViewAllTherapistsState createState() => _ViewAllTherapistsState();
}

class _ViewAllTherapistsState extends State<ViewAllTherapists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
            child: Text("Therapists",
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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('therapistWallets')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewTherapist(
                                therapistId: data['therapistId'],
                                who: 2,
                                request: false)));
                  },
                  child: therapistCard(
                      context, data['name'], data['hours'], data['patients']),
                );
              }).toList(),
            );
          },
        ));
  }
}

class ViewNotes extends StatefulWidget {
  final sessionId;
  const ViewNotes({Key? key, @required this.sessionId}) : super(key: key);

  @override
  _ViewNotesState createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  String text = '';
  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  fetchNotes() {
    FirebaseFirestore.instance
        .collection('notes')
        .where('sessionId', isEqualTo: widget.sessionId)
        .get()
        .then((val) {
      val.docs.forEach((element) {
        setState(() {
          text = element['notes'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar:AppBar(
              centerTitle: true,
              backgroundColor: Colors.black,
              leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              title: Text('Notes',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.normal)),),
        body: ListView(
          children: [
            Padding(
                padding: EdgeInsets.all(12),
                child: Text(text, style: TextStyle(color:Colors.white,fontSize: 20)))
          ],
        ));
  }
}
