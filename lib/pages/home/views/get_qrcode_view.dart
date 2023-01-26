import 'package:epassport/app/widgets/qr_code_view.dart';
import 'package:epassport/app/widgets/user_image.dart';
import 'package:epassport/service/firebase_service.dart';
import 'package:flutter/material.dart';

class GetUserQrCode extends StatelessWidget {
  const GetUserQrCode({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Qr code
          QrCodeView(
            data: '${FirebaseService.instance.user?.email}',
            size: MediaQuery.of(context).size.width * 0.9,
          ),

          //User email
          ListTile(
            leading: UserProfileImage(
              photoURL: '${FirebaseService.instance.user?.photoURL}',
              size: 40,
            ),
            title: Text(
              FirebaseService.instance.user?.displayName ?? 'User',
            ),
            subtitle: Text(
              '${FirebaseService.instance.user?.email}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/edit');
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}
