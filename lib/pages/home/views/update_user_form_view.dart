import 'dart:developer';
import 'dart:io';

import 'package:epassport/app/widgets/user_form_widget.dart';
import 'package:epassport/config/config.dart';
import 'package:epassport/service/firebase_service.dart';
import 'package:epassport/pages/user/model/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class UpdateUserForm extends StatefulWidget {
  const UpdateUserForm({
    Key? key,
  }) : super(key: key);
  @override
  State<UpdateUserForm> createState() => _UpdateUserFormState();
}

class _UpdateUserFormState extends State<UpdateUserForm> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  late TextEditingController ageController;
  late ValueNotifier<File?> passportPhotoFile;
  late ValueNotifier<File?> signaturePhotoFile;
  String? passportPhotoUrl;
  String? signaturePhotoUrl;
  UserData? userdata;
  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    ageController = TextEditingController();
    passportPhotoFile = ValueNotifier(null);
    signaturePhotoFile = ValueNotifier(null);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userdata = await FirebaseService.instance.getUserDocument(
        '${FirebaseService.instance.uid}',
      );
      if (userdata != null) {
        firstNameController.text = userdata!.firstName;
        lastNameController.text = userdata!.lastName;
        emailController.text = userdata!.email;
        phoneNumberController.text = userdata!.phoneNumber;
        ageController.text = userdata!.age.toString();
        passportPhotoUrl = userdata!.passportPhoto;
        signaturePhotoUrl = userdata!.signPhoto;
        setState(() {});
      } else {
        log('userdata is null');
        // TODO: Handle error
      }
    });
  }

  Future<String> getPassportPhoto() async {
    String url;
    final storage = FirebaseService.instance.storage;
    if (passportPhotoFile.value != null) {
      final passportFileRef =
          storage.ref('users/${FirebaseService.instance.uid}/passportPhoto');
      File passportFile = File('${passportPhotoFile.value?.path}');
      final uploadPassportFileTask =
          await passportFileRef.putFile(passportFile);

      final passportFileUrl =
          await (uploadPassportFileTask).ref.getDownloadURL();
      url = passportFileUrl.toString();
    } else {
      url = passportPhotoUrl.toString();
    }
    return url;
  }

  Future<String> getSignaturePhoto() async {
    String url;
    final storage = FirebaseService.instance.storage;
    if (signaturePhotoFile.value != null) {
      final signatureFileRef =
          storage.ref('users/${FirebaseService.instance.uid}/signaturePhoto');

      File signaturefile = File('${signaturePhotoFile.value?.path}');

      final uploadSignatureFileTask =
          await signatureFileRef.putFile(signaturefile);

      final signatureFileUrl =
          await uploadSignatureFileTask.ref.getDownloadURL();
      url = signatureFileUrl.toString();
    } else {
      url = signaturePhotoUrl.toString();
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigator.pushNamed(context, '/home');
          },
        ),
        centerTitle: true,
        title: const Text('Update User Details'),
      ),
      body: ValueListenableBuilder<File?>(
        valueListenable: passportPhotoFile,
        builder: (context, passportPhoto, child) =>
            ValueListenableBuilder<File?>(
          valueListenable: signaturePhotoFile,
          builder: (context, signaturePhoto, child) => SingleChildScrollView(
            child: UserForm(
              firstNameController: firstNameController,
              lastNameController: lastNameController,
              emailController: emailController,
              phoneNumberController: phoneNumberController,
              ageController: ageController,
              passportPhotoFile: passportPhoto,
              signaturePhotoFile: signaturePhoto,
              passportPhotoUrl: passportPhotoUrl,
              signaturePhotoUrl: signaturePhotoUrl,
              onTapSubmit: (firstNameController.text.isEmpty ||
                      lastNameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      phoneNumberController.text.isEmpty ||
                      ageController.text.isEmpty)
                  ? null
                  : () async {
                      try {
                        final uid = '${FirebaseService.instance.uid}';
                        final passportUrl = await getPassportPhoto();
                        final signatureUrl = await getSignaturePhoto();
                        final user = UserData(
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          email: emailController.text,
                          phoneNumber: phoneNumberController.text,
                          age: int.parse(ageController.text),
                          passportPhoto: passportUrl,
                          signPhoto: signatureUrl,
                        );

                        await FirebaseService.instance
                            .createUserDocument(uid: uid, userData: user);
                        final isUseExists =
                            await FirebaseService.instance.userExists(uid);
                        if (isUseExists) {
                          showToast(
                              'User registered successfully', Colors.green);
                        } else {
                          showToast('User registration failed', Colors.red);
                        }
                      } on FirebaseException catch (e) {
                        log(
                          e.message.toString(),
                          name: 'RegisterUserForm',
                          error: e,
                          stackTrace: e.stackTrace,
                        );
                        showToast(
                          'Failed to register user, ${e.message ?? 'Somthing went wrong'}',
                          Colors.red,
                        );
                      }
                    },
              onTapPassportPhoto: () async {
                final file = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  // allowedExtensions: ['jpg', 'png'],
                  allowCompression: true,
                );
                if (file != null) {
                  final path = file.files.single.path;

                  if (path != null) {
                    passportPhotoFile.value = File(path);
                  }
                } else {
                  showToast('No file selected', Colors.red);
                }
              },
              onTapSignaturePhoto: () async {
                final file = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  // allowedExtensions: ['jpg', 'png'],
                  allowCompression: true,
                );
                if (file != null) {
                  final path = file.files.single.path;

                  if (path != null) {
                    signaturePhotoFile.value = File(path);
                  }
                } else {
                  showToast('No file selected', Colors.red);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
