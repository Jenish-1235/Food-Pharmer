import 'package:flutter/material.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> with TickerProviderStateMixin {
  late TabController _tabBarController;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(
      vsync: this,
      length: 3, // We have three tabs: Capture, Dashboard, Profile
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Pharmer'),
        backgroundColor: theme.primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // The Expanded widget holds the TabBarView at the top
            Expanded(
              child: TabBarView(
                controller: _tabBarController,
                children: [
                  // Tab 1: Capture
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: theme.textTheme.bodyLarge?.color,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text("Capture Screen", style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  // Tab 2: Dashboard
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _buildListTile(title: "Item 1", subtitle: "Subtitle 1", context: context),
                            _buildListTile(title: "Item 2", subtitle: "Subtitle 2", context: context),
                            _buildListTile(title: "Item 3", subtitle: "Subtitle 3", context: context),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tab 3: Profile
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle logout
                          print("Log Out pressed");
                        },
                        child: const Text("Log Out"),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle account deletion
                          print("Delete Account pressed");
                        },
                        child: const Text("Delete Account"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TabBar at the bottom
            TabBar(
              controller: _tabBarController,
              labelColor: theme.textTheme.bodyLarge?.color,
              unselectedLabelColor: theme.disabledColor,
              indicatorColor: theme.primaryColor,
              tabs: const [
                Tab(text: 'Capture'),
                Tab(text: 'DashBoard'),
                Tab(text: 'Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required String subtitle, required BuildContext context}) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(title, style: theme.textTheme.titleLarge),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: theme.disabledColor,
          size: 24,
        ),
        tileColor: theme.cardColor,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
