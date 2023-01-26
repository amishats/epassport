import 'dart:developer';
import 'dart:io';

import 'package:epassport/config/config.dart';
import 'package:epassport/pages/home/controller/qr_controller.dart';
import 'package:epassport/pages/home/model/qr_results_model.dart';
import 'package:epassport/pages/user/model/user_model.dart';
import 'package:epassport/service/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({
    Key? key,
  }) : super(key: key);

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.watch<QrResultsProvider>().qrResults.isEmpty
          ? Stack(
              children: [
                _buildQrView(context),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // if (result != null)
                      //   Text(
                      //     'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}',
                      //     style: const TextStyle(fontSize: 20),
                      //   )
                      // else
                      const Text(
                        'Scan a code',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: IconButton(
                                onPressed: () async {
                                  await controller?.toggleFlash();
                                  setState(() {});
                                },
                                icon: FutureBuilder<bool?>(
                                  future: controller?.getFlashStatus(),
                                  builder: (context, snapshot) {
                                    return Icon(
                                      Icons.flash_on,
                                      color: snapshot.data ?? false
                                          ? Colors.blue
                                          : Colors.grey,
                                    );
                                  },
                                )),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: IconButton(
                                onPressed: () async {
                                  await controller?.flipCamera();
                                  setState(() {});
                                },
                                icon: FutureBuilder<CameraFacing>(
                                  future: controller?.getCameraInfo(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data != null) {
                                      return Icon(
                                        describeEnum(snapshot.data!)
                                                    .toString() ==
                                                "front"
                                            ? Icons.camera_front
                                            : Icons.camera_rear,
                                        color: Colors.blue,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                )),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await controller?.pauseCamera();
                              },
                              icon: const Icon(Icons.pause),
                              label: const Text('pause',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await controller?.resumeCamera();
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('resume',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : _buildQrResults(context),
    );
  }

  Widget _buildQrResults(BuildContext context) {
    // Form the results into a list of widgets
    var results = context.read<QrResultsProvider>().qrResults;
    var widgets = results
        .map((result) => FutureBuilder(
            future: FirebaseService.instance.getUserDataEmail('${result.code}'),
            builder: (context, snapshot) {
              var data = snapshot.data;
              log('email: ${result.code}');
              log('data: $data');
              if (data is UserData) {
                return Card(
                    child: ListBody(
                  children: [
                    ListTile(
                      dense: true,
                      title: Text('${data.firstName} ${data.lastName}'),
                      leading: const Text('Full Name'),
                    ),
                    const Divider(),
                    ListTile(
                      dense: true,
                      title: Text(data.email),
                      leading: const Text('Email'),
                    ),
                    const Divider(),
                    ListTile(
                      dense: true,
                      title: Text(data.phoneNumber),
                      leading: const Text('Phone Number'),
                    ),
                    const Divider(),
                    ListTile(
                      dense: true,
                      title: Text('${data.age}'),
                      leading: const Text('Age'),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            dense: true,
                            title: Image.network(
                              data.passportPhoto,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            subtitle: const Text('Passport Photo'),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            dense: true,
                            title: Image.network(
                              data.signPhoto,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            subtitle: const Text('Signature Photo'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ));
              } else {
                return const SizedBox.shrink();
              }
            }))
        .toList();
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: widgets,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<QrResultsProvider>().clearQrResults();
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final QrResultsProvider provider = context.read<QrResultsProvider>();
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      final qrResults = QrResults.fromJson({
        'code': scanData.code,
        'format': describeEnum(scanData.format),
      }).toJson().toString();

      if (provider.qrResults.isNotEmpty) {
        for (QrResults value in provider.qrResults) {
          if (!(value.code!.contains(scanData.code ?? ''))) {
            provider.addQrResults(QrResults.fromJson({
              'code': scanData.code,
              'format': describeEnum(scanData.format),
            }));

            log(
              qrResults,
              name: 'QrResults',
            );
          } else {
            log(
              qrResults,
              name: 'Already Scanned',
            );
          }
        }
      } else {
        provider.addQrResults(QrResults.fromJson({
          'code': scanData.code,
          'format': describeEnum(scanData.format),
        }));

        log(
          qrResults,
          name: 'QrResults',
        );
      }

      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      showToast(
        'No Permission',
        Colors.red,
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
