import 'package:get/get.dart';
import '../controllers/vote_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/election_controller.dart';
import '../controllers/candidate_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoteController>(() => VoteController(), fenix: true);
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<ElectionController>(() => ElectionController(), fenix: true);
    Get.lazyPut<CandidateController>(() => CandidateController(), fenix: true);
  }
}
