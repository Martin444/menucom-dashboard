import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Atomic Widgets imported
import '../widgets/membership_status_card.dart';
import '../widgets/membership_quick_actions.dart';
import '../widgets/membership_plans_section.dart';
import '../widgets/membership_discount_section.dart';
import '../widgets/membership_billing_history.dart';
import '../widgets/membership_audit_history.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  late final MembershipController membershipController;
  late final DinningController dinningController;

  @override
  void initState() {
    super.initState();
    membershipController = Get.put(MembershipController());
    dinningController = Get.find<DinningController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMembership();
    });
  }

  Future<void> _loadMembership() async {
    await membershipController.fetchMembershipStatus();
    await membershipController.fetchAvailablePlans();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;

        if (isMobile) {
          return Scaffold(
            drawer: const MenuSide(isMobile: true),
            appBar: AppBar(
              title: const Text(
                'Membresía',
                style: TextStyle(fontFamily: 'Fira Code'),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(FluentIcons.line_horizontal_3_24_regular),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _loadMembership,
                  icon: const Icon(FluentIcons.arrow_sync_24_regular),
                  tooltip: 'Actualizar',
                ),
              ],
            ),
            body: const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MembershipStatusCard(),
                  SizedBox(height: 24),
                  MembershipQuickActions(),
                  SizedBox(height: 32),
                  MembershipPlansSection(),
                  SizedBox(height: 32),
                  MembershipDiscountSection(),
                  SizedBox(height: 32),
                  MembershipBillingHistory(),
                  SizedBox(height: 32),
                  MembershipAuditHistory(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          );
        } else {
          final horizontalPadding = isTablet ? 24.0 : 32.0;
          final verticalPadding = isTablet ? 16.0 : 24.0;

          return Row(
            children: [
              SizedBox(
                width: isTablet ? 200 : 250,
                child: const MenuSide(isMobile: false),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Membresía',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: isTablet ? 24 : 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Fira Code',
                                ),
                          ),
                          IconButton(
                            onPressed: _loadMembership,
                            icon: const Icon(FluentIcons.arrow_sync_24_regular),
                            tooltip: 'Actualizar',
                            iconSize: isTablet ? 20 : 24,
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 24 : 32),
                      const Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MembershipStatusCard(),
                              SizedBox(height: 24),
                              MembershipQuickActions(),
                              SizedBox(height: 32),
                              MembershipPlansSection(),
                              SizedBox(height: 32),
                              MembershipDiscountSection(),
                              SizedBox(height: 32),
                              MembershipBillingHistory(),
                              SizedBox(height: 32),
                              MembershipAuditHistory(),
                              SizedBox(height: 48),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}