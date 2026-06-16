import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/candidate_controller.dart';
import '../controllers/election_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/notification_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController(), fenix: true);
    Get.lazyPut<CandidateController>(() => CandidateController(), fenix: true);
    Get.lazyPut<ElectionController>(() => ElectionController(), fenix: true);
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}
