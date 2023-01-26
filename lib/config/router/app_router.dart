import 'package:epassport/config/config.dart';
import 'package:epassport/pages/home/views/home_view.dart';
import 'package:epassport/pages/home/views/update_user_form_view.dart';
import 'package:epassport/service/firebase_service.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static String get initialRoute {
    final auth = FirebaseService.instance.firebaseAuth;

    if (auth.currentUser == null || auth.currentUser!.isAnonymous) {
      return '/';
    }

    if (!auth.currentUser!.emailVerified && auth.currentUser!.email != null) {
      return '/verify-email';
    }

    return '/home';
  }

  static Map<String, Widget Function(BuildContext)> routes() {
    return {
      '/': (context) {
        return SignInScreen(
          actions: [
            ForgotPasswordAction((context, email) {
              Navigator.pushNamed(
                context,
                '/forgot-password',
                arguments: {'email': email},
              );
            }),
            VerifyPhoneAction((context, _) {
              Navigator.pushNamed(context, '/phone');
            }),
            AuthStateChangeAction<SignedIn>((context, state) {
              if (!(state.user?.emailVerified ?? false)) {
                Navigator.pushNamed(context, '/verify-email');
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }),
            AuthStateChangeAction<UserCreated>((context, state) {
              if (!(state.credential.user?.emailVerified ?? false)) {
                Navigator.pushNamed(context, '/verify-email');
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }),
            AuthStateChangeAction<CredentialLinked>((context, state) {
              if (!state.user.emailVerified) {
                Navigator.pushNamed(context, '/verify-email');
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }),
            // mfaAction,
            EmailLinkSignInAction((context) {
              Navigator.pushReplacementNamed(context, '/email-link-sign-in');
            }),
          ],
          styles: const {
            EmailFormStyle(signInButtonVariant: ButtonVariant.filled),
          },
          headerBuilder: headerImage('assets/icons/app_icon.png'),
          sideBuilder: sideImage('assets/icons/app_icon.png'),
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                action == AuthAction.signIn
                    ? 'Welcome to $APP_NAME! Please sign in to continue.'
                    : 'Welcome to $APP_NAME! Please create an account to continue',
              ),
            );
          },
          footerBuilder: (context, action) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  action == AuthAction.signIn
                      ? 'By signing in, you agree to our terms and conditions.'
                      : 'By registering, you agree to our terms and conditions.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        );
      },
      '/verify-email': (context) {
        return EmailVerificationScreen(
          headerBuilder: headerIcon(Icons.verified),
          sideBuilder: sideIcon(Icons.verified),
          actionCodeSettings: FirebaseService.instance.actionCodeSettings,
          actions: [
            EmailVerifiedAction(() {
              Navigator.pushReplacementNamed(context, '/home');
            }),
            AuthCancelledAction((context) {
              FirebaseUIAuth.signOut(context: context);
              Navigator.pushReplacementNamed(context, '/');
            }),
          ],
        );
      },
      '/phone': (context) {
        return PhoneInputScreen(
          actions: [
            SMSCodeRequestedAction((context, action, flowKey, phone) {
              Navigator.of(context).pushReplacementNamed(
                '/sms',
                arguments: {
                  'action': action,
                  'flowKey': flowKey,
                  'phone': phone,
                },
              );
            }),
          ],
          headerBuilder: headerIcon(Icons.phone),
          sideBuilder: sideIcon(Icons.phone),
        );
      },
      '/sms': (context) {
        final arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        return SMSCodeInputScreen(
          actions: [
            AuthStateChangeAction<SignedIn>((context, state) {
              Navigator.of(context).pushReplacementNamed('/home');
            })
          ],
          flowKey: arguments?['flowKey'],
          action: arguments?['action'],
          headerBuilder: headerIcon(Icons.sms_outlined),
          sideBuilder: sideIcon(Icons.sms_outlined),
        );
      },
      '/forgot-password': (context) {
        final arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        return ForgotPasswordScreen(
          email: arguments?['email'],
          headerMaxExtent: 200,
          headerBuilder: headerIcon(Icons.lock),
          sideBuilder: sideIcon(Icons.lock),
        );
      },
      '/profile': (context) {
        return ProfileScreen(
          actions: [
            SignedOutAction((context) {
              Navigator.pushReplacementNamed(context, '/');
            }),
            // mfaAction,
          ],
          actionCodeSettings: FirebaseService.instance.actionCodeSettings,
          appBar: AppBar(
            title: const Text('Profile'),
          ),
        );
      },
      '/home': (context) {
        return const HomeView();
      },
      '/edit': (context) {
        return const UpdateUserForm();
      }
    };
  }
}
