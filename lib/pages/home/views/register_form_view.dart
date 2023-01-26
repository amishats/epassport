import 'dart:developer';
import 'dart:io';

import 'package:epassport/app/widgets/user_form_widget.dart';
import 'package:epassport/config/config.dart';
import 'package:epassport/service/firebase_service.dart';
import 'package:epassport/pages/user/model/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterUserForm extends StatefulWidget {
  const RegisterUserForm({
    Key? key,
  }) : super(key: key);
  @override
  State<RegisterUserForm> createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<RegisterUserForm> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  late TextEditingController ageController;
  late ValueNotifier<File?> passportPhotoFile;
  late ValueNotifier<File?> signaturePhotoFile;
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
      final userdata = FirebaseService.instance.user;
      if (userdata != null) {
        firstNameController.text = userdata.displayName?.split(' ').first ?? '';
        lastNameController.text = userdata.displayName?.split(' ').last ?? '';
        emailController.text = userdata.email!;
        setState(() {});
      } else {
        log('userdata is null');
        // TODO: Handle error
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            ' Register User Form',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          ValueListenableBuilder<File?>(
            valueListenable: passportPhotoFile,
            builder: (context, passportPhoto, child) =>
                ValueListenableBuilder<File?>(
              valueListenable: signaturePhotoFile,
              builder: (context, signaturePhoto, child) =>
                  SingleChildScrollView(
                child: UserForm(
                  firstNameController: firstNameController,
                  lastNameController: lastNameController,
                  emailController: emailController,
                  phoneNumberController: phoneNumberController,
                  ageController: ageController,
                  passportPhotoFile: passportPhoto,
                  signaturePhotoFile: signaturePhoto,
                  onTapSubmit: (firstNameController.text.isEmpty ||
                          lastNameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          phoneNumberController.text.isEmpty ||
                          ageController.text.isEmpty ||
                          passportPhotoFile.value == null ||
                          signaturePhotoFile.value == null)
                      ? null
                      : () async {
                          try {
                            final storage = FirebaseService.instance.storage;
                            final uid = '${FirebaseService.instance.uid}';
                            final passportFileRef = storage.ref(
                                'users/${FirebaseService.instance.uid}/passportPhoto');
                            final signatureFileRef = storage.ref(
                                'users/${FirebaseService.instance.uid}/signaturePhoto');
                            File passportFile =
                                File('${passportPhotoFile.value?.path}');
                            File signaturefile =
                                File('${signaturePhotoFile.value?.path}');

                            final uploadPassportFileTask =
                                await passportFileRef.putFile(passportFile);
                            final uploadSignatureFileTask =
                                await signatureFileRef.putFile(signaturefile);

                            final passportFileUrl =
                                await (uploadPassportFileTask)
                                    .ref
                                    .getDownloadURL();
                            final signatureFileUrl =
                                await (uploadSignatureFileTask)
                                    .ref
                                    .getDownloadURL();
                            final user = UserData(
                              firstName: firstNameController.text,
                              lastName: lastNameController.text,
                              email: emailController.text,
                              phoneNumber: phoneNumberController.text,
                              age: int.parse(ageController.text),
                              passportPhoto: passportFileUrl,
                              signPhoto: signatureFileUrl,
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
        ],
      ),
    );
  }
}
