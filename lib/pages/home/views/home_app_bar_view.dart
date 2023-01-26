import 'package:epassport/app/widgets/user_image.dart';
import 'package:epassport/service/firebase_service.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: RichText(
        text: TextSpan(
          text: 'Welcome',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          children: [
            TextSpan(
              text:
                  '\n${FirebaseService.instance.user?.displayName?.split(' ').first ?? 'User'}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        //UserAvatar from firebase auth
        UserProfileImage(
          photoURL: '${FirebaseService.instance.user?.photoURL}',
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          size: 40,
        ),
        //Logout button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            FirebaseService.instance.signOut(context);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
