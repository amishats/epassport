import 'dart:io';

import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  const UserForm({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.ageController,
    required this.passportPhotoFile,
    required this.signaturePhotoFile,
    required this.onTapPassportPhoto,
    required this.onTapSignaturePhoto,
    required this.onTapSubmit,
    this.passportPhotoUrl,
    this.signaturePhotoUrl,
  }) : super(key: key);
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController ageController;
  final File? passportPhotoFile;
  final File? signaturePhotoFile;
  final String? passportPhotoUrl;
  final String? signaturePhotoUrl;
  final VoidCallback onTapPassportPhoto;
  final VoidCallback onTapSignaturePhoto;
  final VoidCallback? onTapSubmit;

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // first name
          TextFormField(
            controller: widget.firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // last name
          TextFormField(
            controller: widget.lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // email
          TextFormField(
            controller: widget.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // phone number
          TextFormField(
            controller: widget.phoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // age
          TextFormField(
            controller: widget.ageController,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // passport photo

          ListTile(
            title: const Text('Passport Photo'),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              height: 100,
              child: Builder(
                builder: (context) {
                  if (widget.passportPhotoUrl != null &&
                      widget.passportPhotoFile == null) {
                    return Image.network(
                      '${widget.passportPhotoUrl}',
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Error loading image'),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  } else if (widget.passportPhotoUrl != null &&
                      widget.passportPhotoFile != null) {
                    return Image.file(
                      File('${widget.passportPhotoFile?.path}'),
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Error loading image'),
                    );
                  } else if (widget.passportPhotoUrl == null &&
                      widget.passportPhotoFile != null) {
                    return Image.file(
                      File('${widget.passportPhotoFile?.path}'),
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Error loading image'),
                    );
                  } else {
                    return const Text('No file selected');
                  }
                },
              ),
            ),
            trailing: const Icon(Icons.upload_file),
            onTap: widget.onTapPassportPhoto,
          ),
          const SizedBox(
            height: 10,
          ),
          // signature photo
          ListTile(
            title: const Text('Signature Photo'),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              height: 100,
              child: Builder(
                builder: (context) {
                  if (widget.signaturePhotoUrl != null &&
                      widget.signaturePhotoFile == null) {
                    return Image.network(
                      '${widget.signaturePhotoUrl}',
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Error loading image'),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  } else if (widget.signaturePhotoUrl != null &&
                      widget.signaturePhotoFile != null) {
                    return Image.file(
                      File('${widget.signaturePhotoFile?.path}'),
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Error loading image'),
                    );
                  } else if (widget.signaturePhotoUrl == null &&
                      widget.signaturePhotoFile != null) {
                    return Image.file(
                      File('${widget.signaturePhotoFile?.path}'),
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Error loading image'),
                    );
                  } else {
                    return const Text('No file selected');
                  }
                },
              ),
            ),
            trailing: const Icon(Icons.upload_file),
            onTap: widget.onTapSignaturePhoto,
          ),

          const SizedBox(
            height: 10,
          ),
          // submit button
          ElevatedButton(
            onPressed: widget.onTapSubmit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
