import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user_roles/assign_role/data/usecase/assign_role_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/revoke_role/data/usecase/revoke_role_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/update_role/data/usecase/update_role_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/my_team/data/usecase/get_my_team_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/find_user/data/usecase/find_user_usecase.dart';
import '../../../home/controllers/dinning_controller.dart';
import '../controllers/collaborators_controller.dart';

String _resolveBusinessContext(String role) {
  switch (role.toLowerCase()) {
    case 'food':
    case 'dinning':
      return 'restaurant';
    case 'clothes':
      return 'wardrobe';
    case 'retail':
    case 'pharmacy':
    case 'beauty':
    case 'construction':
    case 'automotive':
      return 'retail';
    case 'grocery':
    case 'electronics':
    case 'accessories':
    case 'pets':
    case 'water_distributor':
      return 'marketplace';
    case 'events':
      return 'events';
    default:
      return 'general';
  }
}

class CollaboratorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetMyTeamUseCase>(() => GetMyTeamUseCase());
    Get.lazyPut<AssignRoleUseCase>(() => AssignRoleUseCase());
    Get.lazyPut<RevokeRoleUseCase>(() => RevokeRoleUseCase());
    Get.lazyPut<UpdateRoleUseCase>(() => UpdateRoleUseCase());
    Get.lazyPut<FindUserUseCase>(() => FindUserUseCase());
    Get.lazyPut<CollaboratorsController>(
      () {
        final dinning = Get.find<DinningController>();
        final commerceId = dinning.dinningLogin.commerceId ?? '';
        final businessContext =
            _resolveBusinessContext(dinning.dinningLogin.role ?? '');
        return CollaboratorsController(
          getMyTeamUseCase: Get.find<GetMyTeamUseCase>(),
          assignRoleUseCase: Get.find<AssignRoleUseCase>(),
          revokeRoleUseCase: Get.find<RevokeRoleUseCase>(),
          updateRoleUseCase: Get.find<UpdateRoleUseCase>(),
          commerceId: commerceId,
          businessContext: businessContext,
        );
      },
    );
  }
}
