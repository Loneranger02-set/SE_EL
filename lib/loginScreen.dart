import 'dart:async';
import 'dart:io';
import 'ProfilePage.dart';
import 'SignUpScreen.dart';
import 'AuthFunctions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menuPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> setRem(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isRem', value);
}
class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

bool isRememberMe = false;

class _LoginScreenState extends State<LoginScreen> {
  bool isRem;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassword = true;
  LoginRequestModel loginRequestModel;
  bool isApiCallProcess = false;
  @override
  void initState() {
    super.initState();
    print("Hey");
//    print(secureStorage.read(key:'token'));
    loginRequestModel = new LoginRequestModel();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 1,
      color: Color.fromRGBO(163, 219, 191, 1),
    );
  }

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (input) => loginRequestModel.email = input,
            key: Key('emailField'),
            //validator: (input)=>!input.contains("@")?"Enter valid Email Id":null,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.email, color: Colors.black26),
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',

          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextFormField(
            keyboardType: TextInputType.visiblePassword,
            key: Key('pwdField'),
            obscureText: hidePassword,
            onSaved: (input) => loginRequestModel.password = input,
            //validator: (input)=>input.length<8?"Password should be more than 8 characters":null,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.lock, color: Colors.black26),
              hintText: 'Password',
              hintStyle: TextStyle(color: Colors.black38),
              suffixIcon: IconButton(
                icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility),
                color: Colors.black26,
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildForgotPassBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: printText(),//_launchURLBrowser,
        //padding: EdgeInsets.only(right: 0),
        child: Text(
          '',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildRememberCb() {
    return Container(
      height: 20,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: isRememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  isRememberMe = value;
                  setRem(value);
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        key:Key("LoginButton"),
        onPressed:/*()=> Navigator.push(context,new MaterialPageRoute(builder: (context)=>new MenuScreen())),*/() {
          if (validateAndSave()) {
            setState(() {
              isApiCallProcess = true;
            });
            APIservice apiService = new APIservice();
            apiService.login(loginRequestModel).then((value) {
              if (value != null) {
                setState(() {
                  isApiCallProcess = false;
                });
                if (value.token.isNotEmpty) {
                  saveToken(value.token).then((value){
                    User.fetchAndAuthUser();
                  });
//                  secureStorage.write(key:'token', value: value.token);
                  Navigator.push(context,new MaterialPageRoute(builder: (context)=>new MenuScreen()));
                } else {
                  final snackBar = buildErrorSnackBtn(value.error);
                  ScaffoldMessenger.of(context).showSnackBar((snackBar));
                }
              }
            });
            print(loginRequestModel.toJson());
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 5,
          onPrimary: Colors.black12,
          primary: Colors.white,
          padding: EdgeInsets.all(15),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'LOGIN',
          key:Key('LoginText'),
          style: TextStyle(
              color: Color(0xddff0000),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget buildSignUpBtn() {
    return GestureDetector(
      key:Key("SignUpButton"),
      onTap:()=> Navigator.push(context,new MaterialPageRoute(builder: (context)=>new SignUpScreen())),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x44ff0000),
                        Color(0x66ff0000),
                        Color(0x99ff0000),
                        Color(0xccff0000),
                      ])),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 120),
                child: Form(
                  key: globalFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign In',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 50),
                      buildEmail(),
                      SizedBox(height: 20),
                      buildPassword(),
                      buildForgotPassBtn(),
                     // buildRememberCb(),
                      buildLoginBtn(),
                      buildSignUpBtn(),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form.validate()) {
      form.save();
       if (!loginRequestModel.email.contains("@")) {
        final snackBar = buildErrorSnackBtn("Enter a valid email !");
        ScaffoldMessenger.of(context).showSnackBar((snackBar));
        return false;
      }
      else if (loginRequestModel.password.isEmpty) {
      final snackBar = buildErrorSnackBtn("Password is Required !");
      ScaffoldMessenger.of(context).showSnackBar((snackBar));
      return false;
    }
    return true;
    } else {
      return false;
    }
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey<ScaffoldState>>('scaffoldKey', scaffoldKey));
  }
}

class APIservice {
  Future<LoginResponseModel> login(LoginRequestModel loginRequestModel) async {
    String HOST_NAME = "django-project-endpoint.herokuapp.com";
    try {
      final response = await http.post(Uri.http(HOST_NAME, "/rest-auth/login/"),
          body: loginRequestModel.toJson()).timeout(
          const Duration(seconds: 10));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode >= 400) {
        return LoginResponseModel.fromJson(
            json.decode(response.body), response.statusCode);
      } else {
        return LoginResponseModel(token: "", error: "Failed to load data");
      }
    } on TimeoutException catch (e){
      return LoginResponseModel(token: "", error: "Connection Timed out");
    } on SocketException catch (e) {
      return LoginResponseModel(token: "", error: "Connection Timed out");
    } catch(e) {
      return LoginResponseModel(token: "", error: e.toString());
    }
  }
}

class LoginResponseModel {
  final String token;
  final String error;
  LoginResponseModel({
    this.token,
    this.error,
  });
  factory LoginResponseModel.fromJson(Map<String, dynamic> json, int status) {
    var errorMsg;
    if (status >= 400) {
      if (json["non_field_errors"] != null) {
        errorMsg = json["non_field_errors"][0];
      } else if (json["email"] != null) {
        errorMsg = json["email"][0];
      } else if (json["password"] != null) {
        errorMsg = json["password"][0];
      }
    }
    return LoginResponseModel(
      token: json["key"] != null ? json["key"] : "",
      error: errorMsg != null ? errorMsg : "",
    );
  }
}

class LoginRequestModel {
  String email;
  String password;
  String username;
  LoginRequestModel({
    this.email,
    this.password,
    this.username
  });
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      //'email': email.trim(),
      'username':email.trim(),
      'password': password.trim(),
    };
    return map;
  }
}

printText()
{
  print("A button is pressed");
}

SnackBar buildErrorSnackBtn(String str){
  return SnackBar(
    content: Text(str,
        key: Key("error"),
        style: const TextStyle(
            fontSize:17,
            fontWeight: FontWeight.bold)
    ),
    backgroundColor: Colors.red,
  );
}

class ProgressHUD extends StatelessWidget{
  final Widget child;
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  final Animation<Color> valueColor;
  ProgressHUD({
    Key key,
    @required this.child,
    @required this.inAsyncCall,
    this.opacity=0.0,
    this.color=Colors.greenAccent,
    this.valueColor,
  }):super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList=[];
    widgetList.add(child);
    if(inAsyncCall){
      return Stack(
        children: [
          new Opacity(opacity: opacity,child:ModalBarrier(dismissible:false,color:color),),
          new Center(
              child: new CircularProgressIndicator(color: Colors.teal,)
          ),
        ],
      );
    }
    return Stack(
      children: widgetList,
    );
  }
}