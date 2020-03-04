import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class SignInPage extends StatefulWidget {
  static final tag = 'sign_in';

  SignInPage() : super();

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final pv = width > 400 ? 100.0 : 60.0;

    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
    );

    // Create e-mail address input
    final email = new TextInput(
      hint: 'Username or e-mail address',
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
      ),
      hintStyle: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
        color: const Color(0xffcccccc),
      ),
    );

    // Create password input
    final password = new TextInput(
      hint: 'Password',
      obscure: true,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
      ),
      hintStyle: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        letterSpacing: 0.33,
        color: const Color(0xffcccccc),
      ),
    );

    // Create sign-in submit button
    final sib = new SizedBox(
      width: double.infinity,
      child: new CupertinoButton(
        onPressed: signIn,
        color: ColorConst.buttonColor,
        borderRadius: BorderRadius.circular(8.0),
        pressedOpacity: 0.9,
        child: new Text(
          'Sign In',
          style: new TextStyle(
            color: const Color(0xffffffff),
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.28,
          ),
        ),
      ),
    );

    return new CupertinoPageScaffold(
      backgroundColor: const Color(0xffffffff),
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: pv),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            email,
            pt,
            password,
            pt,
            sib,
          ],
        ),
      ),
    );
  }

  void signIn() {
    
  }
}
