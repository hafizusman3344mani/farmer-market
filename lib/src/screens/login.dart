import 'dart:async';

import 'package:farmer_market/src/blocs/auth_bloc.dart';
import 'package:farmer_market/src/styles/base.dart';
import 'package:farmer_market/src/styles/text.dart';
import 'package:farmer_market/src/widgets/alerts.dart';
import 'package:farmer_market/src/widgets/button.dart';
import 'package:farmer_market/src/widgets/social_button.dart';
import 'package:farmer_market/src/widgets/textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {


  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  StreamSubscription _userSubscription;
  StreamSubscription _errorSubscription;
  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
   _userSubscription =  authBloc.user.listen((user) {
      if (user != null) Navigator.pushReplacementNamed(context, '/landing');
    });

   _errorSubscription = authBloc.errorMessage.listen((errorMessage) {
     if(errorMessage != ''){
       AppAlerts.showErrorDialog(Platform.isIOS,context, errorMessage).then((_) => authBloc.clearErrorMessage());
     }
   });
    super.initState();
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    _errorSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context);

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        child: pageBody(context, authBloc),
      );
    } else {
      return Scaffold(
        body: pageBody(context, authBloc),
      );
    }
  }

  Widget pageBody(BuildContext context, AuthBloc authBloc) {
    return ListView(
      padding: EdgeInsets.all(0.0),
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .2,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/top_bg.png',
                  ),
                  fit: BoxFit.fill)),
        ),
        Container(
          height: MediaQuery.of(context).size.height * .25,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(
              'assets/images/logo.png',
            ),
          )),
        ),
        StreamBuilder<String>(
            stream: authBloc.email,
            builder: (context, snapshot) {
              return AppTextField(
                isIOS: Platform.isIOS,
                hintText: 'Email',
                cupertinoIcon: CupertinoIcons.mail_solid,
                materialIcon: Icons.email,
                textInputType: TextInputType.emailAddress,
                errorText: snapshot.error,
                onChanged: authBloc.changeEmail,
              );
            }),
        StreamBuilder<String>(
            stream: authBloc.password,
            builder: (context, snapshot) {
              return AppTextField(
                obscure: true,
                isIOS: Platform.isIOS,
                hintText: 'Password',
                cupertinoIcon: IconData(0xf4c9,
                    fontFamily: CupertinoIcons.iconFont,
                    fontPackage: CupertinoIcons.iconFontPackage),
                materialIcon: Icons.lock,
                errorText: snapshot.error,
                onChanged: authBloc.changePassword,
              );
            }),
        StreamBuilder<bool>(
            stream: authBloc.isValid,
            builder: (context, snapshot) {
              return AppButton(
                title: 'Login',
                buttonType: snapshot.data == true
                    ? ButtonType.Straw
                    : ButtonType.Disabled,
                onPressed: authBloc.loginEmail,
              );
            }),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Or',
            style: TextStyles.suggestion,
          ),
        ),
        SizedBox(height: 6),
        Padding(
          padding: BaseStyles.listPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppSocialButton(
                socialType: SocialType.Facebook,
                onTap: () {},
              ),
              SizedBox(width: 15),
              AppSocialButton(
                socialType: SocialType.Google,
                onTap: () {},
              )
            ],
          ),
        ),
        Padding(
          padding: BaseStyles.listPadding,
          child: RichText(
            textAlign: TextAlign.center,
            text:
                TextSpan(text: 'New Here? ', style: TextStyles.body, children: [
              TextSpan(
                  text: 'Signup',
                  style: TextStyles.link,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.pushNamed(context, '/signup'))
            ]),
          ),
        ),
      ],
    );
  }
}
