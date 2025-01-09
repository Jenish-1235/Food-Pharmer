// lib/home/home_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'extensions/string_extension.dart';
import 'tabs/capture_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> with TickerProviderStateMixin {
  late TabController _tabBarController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(
      vsync: this,
      length: 3, // Capture, Dashboard, Profile
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }

  void _onImageSelected(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _onImageDiscarded() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      // Using Material Design 3
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: Colors.teal,
        secondary: Colors.tealAccent,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Pharmer'),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabBarController,
                children: [
                  // Tab 1: Capture
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CaptureTab(
                        selectedImage: _selectedImage,
                        onImageDiscarded: _onImageDiscarded,
                        onImageSelected: _onImageSelected,
                      ),
                    ),
                  ),

                  // Tab 2: Dashboard
                  DashboardTab(),

                  // Tab 3: Profile
                  ProfileTab(),
                ],
              ),
            ),

            // TabBar at the bottom
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabBarController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: theme.colorScheme.primary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.camera_alt), text: 'Capture'),
                  Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                  Tab(icon: Icon(Icons.person), text: 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
