import 'package:flutter/material.dart';
import 'package:epassport/service/firebase_service.dart';
import 'get_qrcode_view.dart';
import 'home_app_bar_view.dart';
import 'register_form_view.dart';
import 'scan_qrcode_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          //Register page with qr code
          _Tab1(),

          //Qr Scan page
          ScanQrCode(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
        ],
        onTap: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }
}

class _Tab1 extends StatelessWidget {
  const _Tab1({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: FirebaseService.instance
          .userExistsStream('${FirebaseService.instance.uid}'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error} occurred',
              style: const TextStyle(fontSize: 18),
            ),
          );
        } else if (snapshot.hasData) {
          final data = (snapshot.data ?? false);
          if (data) {
            return const Center(
              child: GetUserQrCode(),
            );
          } else {
            return const SingleChildScrollView(
              child: RegisterUserForm(),
            );
          }
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
