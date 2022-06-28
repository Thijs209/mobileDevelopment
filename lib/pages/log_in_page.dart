import 'package:datum_prikker/custom_widgets/custom_button.dart';
import 'package:datum_prikker/custom_widgets/custom_input_field.dart';
import 'package:datum_prikker/custom_widgets/planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {

  static const String routeName = "/LoginPage";

  static Route route({Planner? planner}){
    return MaterialPageRoute(
      settings: const RouteSettings(name:routeName),
      builder: (context) => LoginPage(planner: planner,)
    );
  }

  LoginPage({Key? key, required this.planner}) : super(key: key);
  Planner? planner;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  String? name;
  final _formKey = GlobalKey<FormState>();

  bool register = true;

  @override

  Widget build(BuildContext context) {
    if(_auth.currentUser != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, "/HomePage", arguments: widget.planner);
      });
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Planster"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(!register?"Log in":"Registreer", style: const TextStyle(fontSize: 20),),
                    const SizedBox(height: 10),
                    register? CustomInputField(labelText: "Naam", onSaved: (value) => name = value): Container(),
                    CustomInputField(labelText: "E-mail", onSaved: (value) => email = value),
                    CustomInputField(labelText: "Wachtwoord", onSaved: (value) => password = value),
                    const SizedBox(height: 20),
                    CustomButton(color: MyApp().theme, textColor: Colors.white, onPressed: !register? _loginEmail: _register, text: !register? "Log in": "Registreer"),
                    register? _loginButtons():Container(),
                    const SizedBox(height: 10,),
                    TextButton(onPressed: () {register? register = false : register = true; setState(() {});}, child: Text(register? "Ik heb al een account":"Ik heb nog geen account"))
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }

  Widget _loginButtons() {
    return Column(children: [
      const SizedBox(height: 10,),
      CustomButton(color: Colors.white, textColor: MyApp().theme, onPressed: ()async{await _loginGoogle(); widget.planner == null? toHomePage(): Navigator.pushNamed(context,'/WatchPlanner',arguments: widget.planner);}, text: "Log in met Google",),
      const SizedBox(height: 10,),
      CustomButton(color: Colors.lime[300]!, textColor: Colors.black87, onPressed: _loginAnon, text: "Ga verder zonder account",),
    ],);
  }

  _loginEmail() async{
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.signInWithEmailAndPassword(
            email: email!, password: password!);

        toHomePage();
      } on FirebaseAuthException catch (e) {
        showDialog(
            context: context,
            builder: (ctx) =>
                AlertDialog(
                  title: const Text("Oops! Login Failed"),
                  content: Text('${e.message}'),
                )
        );
      }
    }
  }

  _loginAnon()async{
    _auth.signInAnonymously();
    toHomePage();
  }

  _loginGoogle() async {
    GoogleAuthProvider authProvider = GoogleAuthProvider();
    User? user;
    if (kIsWeb) {
      try {
        final UserCredential userCredential = await _auth.signInWithPopup(
            authProvider);
        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // ...
          } else if (e.code == 'invalid-credential') {
            // ...
          }
        } catch (e) {
          // ...
        }
      }
    }
  }

  _register() async{
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email!, password: password!);
      User? user = result.user;
      user!.updateDisplayName(name!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account is gemaakt")));
    } on FirebaseException catch (e) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Registratie mislukt"),
            content: Text("${e.message}"),
          )
        );
      }
    }
  }

  void toHomePage() {
    if(_auth.currentUser != null) {
      if(widget.planner != null){
        Navigator.pushNamed(context, "/WatchPlanner", arguments: widget.planner);
      } else {
        Navigator.pushNamed(context, "/HomePage", arguments: widget.planner);
      }
    }
  }
}
